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
  definitions_path = var.config["definitions_path"]
  definition_files = fileset(local.definitions_path, "*.json")
  triggers         = flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["triggers"]])
}


provider "google" {
  credentials = local.credentials
  project     = var.project != null ? var.project : local.project_id
}



resource "google_eventarc_trigger" "triggers" {
  for_each = { for index, dict in local.triggers : dict.name => dict }

  name     = each.value.name
  location = each.value.region
  project = var.project != null ? var.project : local.project_id

  service_account = each.value.service_account

  depends_on = [ var.cloud_run_dependency ]

  destination {
    cloud_run_service {
        service = each.value.cloud_run_service
        region  = each.value.cloud_run_region
        path    = each.value.cloud_run_path
    }
  }
  transport {
    pubsub {
      topic = "projects/${local.project_id}/topics/${each.value.topic_name}"
    }
  }

  matching_criteria {
    attribute = "type"
    value = "google.cloud.pubsub.topic.v1.messagePublished"
  }

}
