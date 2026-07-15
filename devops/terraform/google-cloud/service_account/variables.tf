variable "config" {
  type = object({
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

variable "project" {
  type    = string
  default = null
}

variable "projects" {
  type = map(object({
  }))
  default = null
}
