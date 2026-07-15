terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.15.0"
    }
  }
  backend "gcs" {
  }
}

locals {
  credentials      = file(var.config["credentials_path"])
  definitions_path = var.config.definitions_path
  definition_files = fileset(local.definitions_path, "*.json")
  groups = { for index, dict in flatten([for
    file_name in local.definition_files :
  jsondecode(file("${local.definitions_path}/${file_name}"))["groups"]]) : dict.name => dict }
  resource_groups = { for index, dict in google_cloud_identity_group.groups : dict.display_name => dict }
  members = { for index, dict in flatten([
    for group in local.groups : [for member in group["members"] : {
      group_name : group.name,
      email : member
    }]
  ]) : dict.email => dict }
  managers = { for index, dict in flatten([
    for group in local.groups : [for member in group["managers"] : {
      group_name : group.name,
      email : member
    }]
  ]) : dict.email => dict }
  owners = { for index, dict in flatten([
    for group in local.groups : [for member in group["owners"] : {
      group_name : group.name,
      email : member
    }]
  ]) : dict.email => dict }
}

provider "google" {
  credentials = local.credentials
}

resource "google_cloud_identity_group" "groups" {
  for_each     = local.groups
  display_name = each.value.name

  parent = each.value.parent

  group_key {
    id = "${lower(each.value.name)}${each.value.domain}"
  }

  labels = {
    "cloudidentity.googleapis.com/groups.discussion_forum" = ""
  }
}

resource "google_cloud_identity_group_membership" "managers" {
  for_each = local.managers
  group    = local.resource_groups[each.value.group_name].id

  preferred_member_key {
    id = each.value.email
  }

  roles {
    name = "MANAGER"
  }

  roles {
    name = "MEMBER"
  }

  depends_on = [google_cloud_identity_group.groups]
}

resource "google_cloud_identity_group_membership" "owners" {
  for_each = local.owners
  group    = local.resource_groups[each.value.group_name].id

  preferred_member_key {
    id = each.value.email
  }

  roles {
    name = "MANAGER"
  }

  roles {
    name = "OWNER"
  }

  roles {
    name = "MEMBER"
  }

  depends_on = [google_cloud_identity_group.groups]
}

resource "google_cloud_identity_group_membership" "members" {
  for_each = local.members
  group    = local.resource_groups[each.value.group_name].id

  preferred_member_key {
    id = each.value.email
  }

  roles {
    name = "MEMBER"
  }

  depends_on = [google_cloud_identity_group.groups, google_cloud_identity_group_membership.managers, google_cloud_identity_group_membership.owners]
}
