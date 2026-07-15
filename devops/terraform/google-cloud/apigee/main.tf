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
  credentials            = file(var.config["credentials_path"])
  definitions_path       = var.config.definitions_path
  definition_files       = fileset(local.definitions_path, "*.json")
  apigee                 = { for index, dict in
    flatten([for file_name in local.definition_files : jsondecode(file("${local.definitions_path}/${file_name}"))["apigee"]]):
    dict.instance_name => dict
  }
}

provider "google" {
  credentials            = local.credentials
}

data "google_client_config" "current" {}

# resource "google_compute_network" "apigee_network" {
#   name = "apigee-network"
# }

# resource "google_compute_global_address" "apigee_range" {
#   for_each      = { for index, dict in local.apigee : index => dict }  
#   name          = each.value.range_name
#   purpose       = each.value.purpose
#   address_type  = each.value.address_type
#   prefix_length = each.value.prefix_length
#   network       = each.value.network
# }

# resource "google_service_networking_connection" "apigee_vpc_connection" {
#   for_each                = { for index, dict in local.apigee : index => dict }
#   network                 = each.value.network
#   service                 = each.value.service
#   reserved_peering_ranges = [each.value.reserved_peering_ranges]
# }

resource "google_apigee_organization" "apigee_org" {
  for_each = { for index, dict in local.apigee : index => dict }
  # analytics_region   = each.value.analytics_region
  project_id         = var.project != null ? var.project : each.value.project_id
  authorized_network = each.value.network
}

resource "google_apigee_instance" "apigee_instance" {
  for_each = { for index, dict in local.apigee : index => dict }
  name     = each.value.instance_name
  location = each.value.location
  org_id   = "organizations/${google_apigee_organization.apigee_org[each.key].id}"
  depends_on = [google_apigee_organization.apigee_org]
}
