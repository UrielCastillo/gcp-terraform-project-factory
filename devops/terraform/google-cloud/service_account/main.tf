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
  credentials                  = file(var.config["credentials_path"])
  definitions_path             = var.config.definitions_path
  create_ignore_already_exists = var.config.service_account_settings.create_ignore_already_exists
  definition_files             = fileset(local.definitions_path, "*.json")
  resources = { for index, dict in
    flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["service_accounts"]]) :
    dict.name => dict
  }
  resource_service_accounts = { for index, dict in google_service_account.service_accounts : dict.display_name => dict }
  service_account_keys      = google_service_account_key.keys
}

provider "google" {
  credentials = local.credentials
}

# Null resource to create explicit dependency on projects
resource "null_resource" "wait_for_projects" {
  triggers = {
    projects = jsonencode(var.projects)
  }
}

resource "google_service_account" "service_accounts" {
  timeouts {
    create = "60m"
  }
  for_each                     = local.resources
  account_id                   = "${var.config.service_account_settings.prefix}${each.value.name}${var.config.service_account_settings.suffix}"
  display_name                 = each.value.name
  project                      = var.project != null ? var.project : each.value.project_id
  create_ignore_already_exists = local.create_ignore_already_exists

  depends_on = [null_resource.wait_for_projects]
}

resource "google_service_account_key" "keys" {
  for_each           = local.resource_service_accounts
  service_account_id = each.value.email

  depends_on = [google_service_account.service_accounts]
}
