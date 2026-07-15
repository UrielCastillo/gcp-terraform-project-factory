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
  definitions_path = var.config.definitions_path
  definition_files = fileset(local.definitions_path, "*.json")
  project_services = { for index, dict in
    flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["project_services"]]) :
    dict.project_id => dict
  }
  gcp_services = { for index, dict in flatten([
    for i, project in local.project_services :
    [for j, gcp_service in project["gcp_service_list"] : {
      project_id : project["project_id"]
      gcp_service_name : gcp_service
    }]
  ]) : "${dict.project_id}-${dict.gcp_service_name}" => dict }

  # Reference the projects to create implicit dependency
  project_dependencies = var.projects
}

provider "google" {
  credentials = local.credentials
}

data "google_client_config" "current" {}

# Null resource to create explicit dependency on projects
resource "null_resource" "wait_for_projects" {
  triggers = {
    projects = jsonencode(var.projects)
  }
}

resource "google_project_service" "gcp_services" {
  timeouts {
    create = "60m"
    delete = "2h"
  }
  for_each = local.gcp_services
  project  = var.project != null ? var.project : each.value.project_id
  service  = each.value.gcp_service_name

  disable_dependent_services = true

  depends_on = [null_resource.wait_for_projects]
}
