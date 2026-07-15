variable "config" {
  type = object({
    general_project  = string
    credentials_path = string
    definitions_path = string
    bucket           = string
    bucket_path      = string
    service_account_settings = object({
      prefix                       = string
      suffix                       = string
      create_ignore_already_exists = string
    })
  })
}

variable "roles_per_resource" {
  type    = any
  default = null
}

variable "project" {
  type    = string
  default = null
}
