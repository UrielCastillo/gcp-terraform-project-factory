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
  region           = var.config["region"]
  definitions_path = var.config.definitions_path
  definition_files = fileset(local.definitions_path, "*.json")
  repositories = { for index, dict in flatten(
    [for file_name in local.definition_files :
    jsondecode(file("${local.definitions_path}/${file_name}"))["repositories"]]) :
    "${dict.repository_id}-${dict.project}" => dict
  }
  roles = { for index, dict in flatten([
    for indexRepo, repository in local.repositories : [
      for indexRol, role in repository.roles : {
        repository_id : repository.repository_id
        role : role.name,
        member : role.members,
        project : repository.project
      }
    ]
    ]) : "${dict.repository_id}-${dict.role}" => dict
  }
}

provider "google" {
  credentials = local.credentials
}

resource "google_artifact_registry_repository" "repositories" {
  for_each      = local.repositories
  location      = local.region
  repository_id = each.value.repository_id
  description   = each.value.description
  format        = each.value.format
  project       = var.project != null ? var.project : each.value.project
}

resource "google_artifact_registry_repository_iam_binding" "bindings" {
  for_each   = local.roles
  project    = var.project != null ? var.project : each.value.project
  location   = local.region
  repository = each.value.repository_id
  role       = each.value.role
  members    = each.value.member

  depends_on = [google_artifact_registry_repository.repositories]
}
