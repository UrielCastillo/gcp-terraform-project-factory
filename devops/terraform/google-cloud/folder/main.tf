terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.12.0"
    }
  }
  backend "gcs" {
  }
}

locals {
  credentials      = file(var.config["credentials_path"])
  definitions_path = var.config.definitions_path
  definition_files = fileset(local.definitions_path, "*.json")
  folders = { for index, dict in
    flatten([for file_name in local.definition_files :
      jsondecode(file("${local.definitions_path}/${file_name}"))["folders"]]
    ) : dict.name => dict
  }
}

provider "google" {
  credentials = local.credentials
}

resource "google_folder" "folders" {
  timeouts {
    create = "60m"
    delete = "2h"
  }
  for_each     = { for index, dict in local.folders : dict.name => dict }
  display_name = each.value.name
  parent       = each.value.parent == "folder" ? "folders/${each.value.parent_id}" : "organizations/${each.value.parent_id}"
}
