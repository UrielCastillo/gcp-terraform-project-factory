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
  compute_instances = { for index, dict in flatten([for file_name in local.definition_files :
    jsondecode(file("${local.definitions_path}/${file_name}"))["compute_instances"]]
    ) : dict.name => dict
  }
  service_accounts = { for index, dict in local.compute_instances :
    dict.sa_account_id => { sa_account_id = dict.sa_account_id,
      sa_display_name                     = dict.sa_display_name,
      project_id                          = dict.project_id
    }
  }
}

provider "google" {
  credentials = local.credentials
}

resource "google_service_account" "service_accounts" {
  for_each     = local.service_accounts
  account_id   = each.value.sa_account_id
  display_name = each.value.sa_display_name
  project      = var.project != null ? var.project : each.value.project_id
}

resource "google_compute_instance" "compute_instances" {
  for_each                  = local.compute_instances
  name                      = each.value.name
  zone                      = each.value.zone
  project                   = var.project != null ? var.project : each.value.project_id
  machine_type              = each.value.machine_type
  can_ip_forward            = each.value.can_ip_forward
  deletion_protection       = each.value.deletion_protection
  enable_display            = each.value.enable_display
  tags                      = each.value.tags
  allow_stopping_for_update = each.value.allow_stopping_for_update

  boot_disk {
    auto_delete = each.value.auto_delete
    device_name = each.value.name

    initialize_params {
      image = each.value.image
      size  = each.value.size
      type  = each.value.type
    }

    mode = each.value.mode
  }

  labels = each.value.labels

  metadata = each.value.metadata

  network_interface {
    queue_count = each.value.queue_count
    stack_type  = each.value.stack_type
    subnetwork  = each.value.subnetwork
  }

  scheduling {
    automatic_restart   = each.value.automatic_restart
    on_host_maintenance = each.value.on_host_maintenance
    preemptible         = each.value.preemptible
    provisioning_model  = each.value.provisioning_model
  }

  service_account {
    email  = google_service_account.service_accounts[each.value.sa_account_id].email
    scopes = each.value.scopes
  }

  shielded_instance_config {
    enable_integrity_monitoring = each.value.enable_integrity_monitoring
    enable_secure_boot          = each.value.enable_secure_boot
    enable_vtpm                 = each.value.enable_vtpm
  }

  depends_on = [google_service_account.service_accounts]
}

