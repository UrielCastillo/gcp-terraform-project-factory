terraform {
  backend "gcs" {}
}

locals {
  credentials      = file(var.config["credentials_path"])
  project_id       = var.config["project_id"]
  region           = var.config["region"]
  definitions_path = var.config["definitions_path"]
  definition_files = fileset(local.definitions_path, "*.json")
  cloud_run_services = { for index, dict in flatten([for file_name in local.definition_files :
    jsondecode(file("${local.definitions_path}/${file_name}"))["cloud_run_services"]]
    ) : dict.name => dict
  }
  triggers = flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["triggers"]])
}

provider "google" {
  credentials = local.credentials
  project     = var.project != null ? var.project : local.project_id
  region      = local.region
}

module "cloud_run" {
  source = "./../cloud_run"
  config = var.config
}

module "eventarc_trigger" {
  source               = "./../eventarc_trigger_to_cloudrun"
  config               = var.config
  cloud_run_dependency = module.cloud_run.cloud_run_service
}
