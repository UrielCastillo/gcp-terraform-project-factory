terraform {
  backend "local" {
  }
}

locals {
  credentials      = file(var.config["credentials_path"])
  definitions_path = var.config["definitions_path"]
  definition_files = fileset(local.definitions_path, "*.json")
  buckets          = flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["buckets"]])
}

provider "google" {
  credentials = local.credentials
}

resource "google_storage_bucket" "buckets" {
  for_each      = { for index, dict in local.buckets : index => dict }
  name          = "${var.config.bucket_settings.prefix}${each.value.name}${var.config.bucket_settings.suffix}"
  location      = each.value.location
  force_destroy = each.value.force_destroy
  project = var.project != null ? var.project : each.value.project_id

  versioning {
    enabled = each.value.versioning
  }
}
