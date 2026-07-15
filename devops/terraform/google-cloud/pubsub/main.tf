terraform {
  backend "gcs" {}
}

locals {
  credentials            = file(var.config["credentials_path"])
  project_id             = var.config["project_id"]
  region                 = var.config["region"]
  zone                   = var.config["zone"]
  definitions_path       = var.config["definitions_path"]
  definition_files       = fileset(local.definitions_path, "*.json")
  tables                 = flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["tables"]])
  pubsub_custom_endpoint = var.emulating_pubsub == true ? "http://localhost:8085/v1/" : null #Solo para pruebas
}

provider "google" {
  credentials            = local.credentials
  project                = var.project != null ? var.project : local.project_id
  region                 = local.region
  zone                   = local.zone
  pubsub_custom_endpoint = local.pubsub_custom_endpoint
}

module "pubsub_schemas" {
  source           = "./schemas"
  emulating_pubsub = var.emulating_pubsub
  config           = var.config
  has_dependencies = true
}

module "pubsub_topics" {
  source            = "./topics"
  emulating_pubsub  = var.emulating_pubsub
  config            = var.config
  schema_dependency = module.pubsub_schemas.schema
}

module "pubsub_subscription" {
  source           = "./subscriptions"
  emulating_pubsub = var.emulating_pubsub
  config           = var.config
  topic_dependency = module.pubsub_topics.topic
}
