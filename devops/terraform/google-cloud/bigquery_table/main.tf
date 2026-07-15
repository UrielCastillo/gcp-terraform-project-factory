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
  project_id       = var.config["project_id"]
  region           = var.config["region"]
  zone             = var.config["zone"]
  hostname         = var.config["hostname"]
  definitions_path = var.config.definitions_path
  definition_files = fileset(local.definitions_path, "*.json")
  tables           = flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["tables"]])
}

provider "google" {
  credentials = local.credentials
  project     = var.project != null ? var.project : local.project_id
  region      = local.region
  zone        = local.zone
}

resource "google_bigquery_table" "tables" {
  for_each            = { for index, dict in tables : dict.table_id => dict }
  dataset_id          = each.value.dataset_id
  table_id            = "${var.config.bigquery_settings.prefix}${each.value.table_id}${var.config.bigquery_settings.suffix}"
  project             = var.project != null ? var.project : local.project_id
  deletion_protection = each.value.deletion_protection
  schema              = file(each.value.schema)

  time_partitioning {
    type = each.value.time_partitioning_type
  }

  labels = each.value.labels
}
