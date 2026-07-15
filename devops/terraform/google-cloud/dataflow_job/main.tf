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
  datas            = flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["dataflows"]])
}

provider "google" {
  credentials = local.credentials
  project     = var.project != null ? var.project : local.project_id
  region      = local.region
  zone        = local.zone
}

resource "google_dataflow_job" "dataflows" {
  for_each                = { for index, dict in datas : index => dict }
  name                    = "${var.config.bigquery_settings.prefix}${each.value.name}${var.config.bigquery_settings.suffix}"
  project                 = var.project != null ? var.project : local.project_id
  region                  = local.region
  template_gcs_path       = each.value.template_gcs_path
  temp_gcs_location       = each.value.temp_gcs_location
  enable_streaming_engine = each.value.enable_streaming_engine


  parameters = {
    inputTopic      = "projects/${local.project_id}/topics/${each.value.inputTopic}"
    outputTableSpec = each.value.outputTableSpec

  }
}
