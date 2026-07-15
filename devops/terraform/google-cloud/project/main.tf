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
  projects         = flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["projects"]])
}

provider "google" {
  credentials = local.credentials
}

resource "google_project" "projects" {
  timeouts {
    create = "60m"
    delete = "2h"
  }
  for_each            = { for index, dict in local.projects : dict.name => dict }
  name                = each.value.name
  project_id          = var.project != null ? var.project : each.value.name
  folder_id           = var.parent_folders != null && each.value.folder_name != null ? var.parent_folders[each.value.folder_name].folder_id : each.value.folder_id
  auto_create_network = each.value.auto_create_network
  billing_account     = each.value.billing_account
  labels              = each.value.labels != null ? each.value.labels : {}

  depends_on = [var.parent_folders]
}
