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

variable "projects" {
  type = map(object({
  }))
  default = null
}
