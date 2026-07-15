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
  cloud_run_services = { for index, dict in flatten([for file_name in local.definition_files :
    jsondecode(file("${local.definitions_path}/${file_name}"))["cloud_run_services"]]
    ) : dict.name => dict
  }
  single_cloud_run_service = { for index, dict in local.cloud_run_services : dict.name => dict if dict.name == var.cloud_run_name
  }
}

provider "google" {
  credentials = local.credentials
}

resource "google_cloud_run_v2_service" "cloud_runs" {
  for_each = length(local.single_cloud_run_service) != 0 ? local.single_cloud_run_service : local.cloud_run_services
  name     = var.cloud_run_name != null ? var.cloud_run_name : each.value.name
  location = each.value.cloud_run_location
  ingress  = each.value.ingress
  project  = var.project != null ? var.project : each.value.project_id

  template {

    service_account = var.service_account != null ? var.service_account : each.value.service_account

    max_instance_request_concurrency = each.value.max_instance_request_concurrency

    scaling {
      max_instance_count = each.value.max_instance_count
      min_instance_count = each.value.min_instance_count
    }

    containers {
      image = var.dockertag != null ? var.dockertag : each.value.cloud_run_image
      resources {
        limits = {
          cpu    = each.value.cpu_limit
          memory = each.value.memory_limit
        }
      }

      dynamic "ports" {
        for_each = [for dict in each.value.ports : { port : dict }]
        content {
          container_port = ports.value.port
        }
      }

      dynamic "env" {
        for_each = [for dict in each.value.envs : { name : dict.name, version : dict.version }]
        content {
          name = env.value.name
          value_source {
            secret_key_ref {
              secret  = env.value.name
              version = env.value.version
            }
          }
        }
      }
    }
  }
}
