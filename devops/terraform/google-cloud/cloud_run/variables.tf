variable "config" {
  type = object({
    credentials_path = string
    definitions_path = string
  })
}

variable "project" {
  type    = string
  default = null
}

variable "dockertag" {
  type    = string
  default = null
}

variable "service_account" {
  type    = string
  default = null
}

variable "cloud_run_name" {
  type    = string
  default = null
}
