terraform {
  backend "gcs" {
  }
}

locals {
  credentials            = file(var.config["credentials_path"])
  definitions_path       = var.config.definitions_path
  definition_files       = fileset(local.definitions_path, "*.json")
  tables                 = flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["tables"]])
  pubsub_custom_endpoint = var.emulating_pubsub == true ? "http://localhost:8085/v1/" : null #Solo para pruebas
}

provider "google" {
  credentials            = local.credentials
  project                = var.project != null ? var.project : var.config.project_id
  region                 = var.config.region
  zone                   = var.config.zone
  pubsub_custom_endpoint = local.pubsub_custom_endpoint
}

resource "google_pubsub_schema" "schema" {
  for_each   = { for index, dict in local.tables : dict.name => dict }
  name       = "${var.config.schema_settings.prefix}${each.value.name}${var.config.schema_settings.suffix}"
  type       = each.value.type
  definition = (upper(each.value.type) == "AVRO" ? jsonencode(each.value.definition) : file(each.value.definition))
}
