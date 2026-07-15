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
  credentials       = file(var.config["credentials_path"])
  project_id        = var.config["project_id"]
  region            = var.config["region"]
  zone              = var.config["zone"]
  hostname          = var.config["hostname"]
  definitions_path  = var.config.definitions_path
  definition_files  = fileset(local.definitions_path, "*.json")
  bigquery_datasets = flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["bigquery_datasets"]])
}

provider "google" {
  credentials = local.credentials
  project     = var.project != null ? var.project : local.project_id
  region      = local.region
  zone        = local.zone
}

resource "google_bigquery_dataset" "datasets" {
  for_each      = { for index, dict in local.bigquery_datasets : dict.hostname => dict }
  dataset_id    = "${var.config.dataset_settings.prefix}${each.value.hostname}${var.config.dataset_settings.suffix}"
  project       = var.project != null ? var.project : local.project_id
  friendly_name = "${var.config.dataset_settings.prefix}${each.value.hostname}${var.config.dataset_settings.suffix}"
  description   = "${var.config.dataset_settings.prefix}${each.value.hostname}${var.config.dataset_settings.suffix}"
  location      = local.region
}
