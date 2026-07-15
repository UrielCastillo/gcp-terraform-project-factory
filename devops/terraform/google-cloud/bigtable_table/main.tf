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
  instances        = flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["bigtable_instances"]])
  tables           = flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["bigtable_tables"]])
}

provider "google" {
  credentials = local.credentials
}

resource "google_bigtable_instance" "instance" {
  for_each            = { for index, dict in local.instances : index => dict }
  name                = each.value.name
  deletion_protection = each.value.deletion_protection
  project             = var.project != null ? var.project : each.value.project_id
  cluster {
    cluster_id          = each.value.cluster_id
    zone                = each.value.zone
    storage_type        = each.value.storage_type
    autoscaling_config {
      min_nodes = each.value.min_nodes
      max_nodes = each.value.max_nodes
      cpu_target = each.value.cpu_target
    }
  }
}

resource "google_bigtable_table" "table" {
  for_each            = { for index, dict in local.tables : index => dict }
  name                = each.value.name
  instance_name       = each.value.instance_name
  project             = var.project != null ? var.project : each.value.project_id
  deletion_protection = each.value.deletion_protection

  column_family {
    family            = each.value.column_family
  }

  depends_on = [ google_bigtable_instance.instance ]
}