variable "config" {
  type = object({
    definitions_path = string
    credentials_path = string
    project_id       = string
  })
}

variable "project" {
  type = string
  default = null
}