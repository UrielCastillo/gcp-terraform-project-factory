variable "config" {
  type = object({
    credentials_path = string
    project_id       = string
    definitions_path = string
  })
}
variable "cloud_run_dependency" {
  type = object({})
  default = null
}

variable "project" {
  type = string
  default = null
}