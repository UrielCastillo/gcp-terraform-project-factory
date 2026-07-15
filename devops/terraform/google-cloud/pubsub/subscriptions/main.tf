terraform {
  backend "gcs" {
  }
}

locals {
  credentials            = file(var.config.credentials_path)
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

resource "google_pubsub_subscription" "subscriptions" {
  for_each = { for index, dict in local.tables : dict.name => dict }

  name  = "${var.config.subscription_settings.prefix}${each.value.name}${var.config.subscription_settings.suffix}"
  topic = "projects/${var.config.project_id}/topics/${var.config.topic_settings.prefix}${each.value.name}${var.config.topic_settings.suffix}"

  depends_on = [var.topic_dependency]
}

resource "google_pubsub_subscription" "subscriptions_storage" {
  for_each = { for index, dict in local.tables : dict.name => dict }

  name  = "${var.config.subscription_settings.storage_prefix}${each.value.name}${var.config.subscription_settings.storage_suffix}"
  topic = "projects/${var.config.project_id}/topics/${var.config.topic_settings.prefix}${each.value.name}${var.config.topic_settings.suffix}"

  cloud_storage_config {
    bucket          = "projects/${var.config.project_id}/bucket/${each.value.storage_bucket}"
    filename_prefix = "${each.value.name}_"
  }

  depends_on = [var.topic_dependency]
}

