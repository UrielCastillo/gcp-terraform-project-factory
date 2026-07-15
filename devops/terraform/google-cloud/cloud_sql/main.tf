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
  definitions_path = var.config.definitions_path
  definition_files = fileset(local.definitions_path, "*.json")
  cloud_sqls       = flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["cloud_sqls"]])
}

provider "google" {
  credentials = local.credentials
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "instances" {
  for_each         = { for index, dict in local.cloud_sqls : dict.name => dict }
  project          = var.project != null ? var.project : each.value.project_id
  name             = each.value.name
  region           = each.value.region
  database_version = each.value.version
  settings {
    tier = each.value.tier
    ip_configuration {
      dynamic authorized_networks {
        for_each = {for index, dict in each.value.authorized_networks : index => dict }
        iterator = "network"
        content {
          name = network.value.name
          value = network.value.ip
        }
      }
    }
  }

  deletion_protection = each.value.deletion_protection
}

resource "google_sql_user" "users" {
  for_each = { for index, dict in local.cloud_sqls : dict.name => dict }
  name     = each.value.default_username
  instance = each.value.name
  password = each.value.default_password
  project  = var.project != null ? var.project : each.value.project_id
}
