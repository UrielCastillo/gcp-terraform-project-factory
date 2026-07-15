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
  definitions_path = coalesce(var.config.definitions_path, "")
  definition_files = fileset(local.definitions_path, "*.json")
  roles_per_resources = { for index, dict in flatten([
    for file_name in local.definition_files :
    jsondecode(file("${local.definitions_path}/${file_name}"))["roles_per_resource"]]
    ) : dict.resource_id => dict if dict.resource_type == "project"
  }
  roles_flatten = { for index, dict in flatten([
    for roles_per_resource in(local.roles_per_resources != null ? local.roles_per_resources : var.roles_per_resource) : [for role in roles_per_resource["roles"] : {
      role : role.name,
      members : role.members,
      resource_id : roles_per_resource.resource_id
    }]
  ]) : "${dict.role}-${dict.resource_id}" => dict }
}

provider "google" {
  credentials = local.credentials
}

resource "google_project_iam_binding" "project_binding" {
  for_each = local.roles_flatten
  project  = var.project != null ? var.project : each.value.resource_id
  role     = each.value.role

  members = each.value.members

  depends_on = [var.projects]
}
