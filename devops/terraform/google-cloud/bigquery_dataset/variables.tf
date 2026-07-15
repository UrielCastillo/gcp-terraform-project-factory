variable "config" {
  type = object({
    credentials_path = string
    project_id       = string
    region           = string
    zone             = string
    definitions_path = string
    dataset_settings   = map(string)
  })
}

variable "project" {
  type = string
  default = null
}