terraform {
  backend "gcs" {}
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.12.0"
    }
  }
}

locals {
  general_project  = var.config["general_project"]
  credentials      = file(var.config["credentials_path"])
  definitions_path = var.config["definitions_path"]
  definition_files = fileset(local.definitions_path, "*.json")
  bucket           = var.config["bucket"]
  bucket_path      = var.config["bucket_path"]
}

provider "google" {
  credentials = local.credentials
  project     = local.general_project
}

module "folders" {
  source = "../folder"
  config = var.config
}

module "projects" {
  source         = "../project"
  config         = var.config
  parent_folders = module.folders.output_folders
}

module "projects_services" {
  source   = "../project_services"
  config   = var.config
  projects = module.projects.output_projects
}

module "services_accounts" {
  source   = "../service_account"
  config   = var.config
  projects = module.projects.output_projects
}

resource "google_storage_bucket_object" "service_account_key_folder" {
  timeouts {
    create = "60m"
    delete = "2h"
  }
  for_each = module.services_accounts.emails_static
  name     = "${local.bucket_path}/${each.key}"
  content  = module.services_accounts.service_account_keys[each.key].key
  bucket   = local.bucket

  depends_on = [module.services_accounts.service_account_keys]
}

