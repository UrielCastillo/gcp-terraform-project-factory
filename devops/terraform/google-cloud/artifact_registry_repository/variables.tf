variable "config" {
  type = object({
    credentials_path = string
    definitions_path = string
    region           = string
  })
}

variable "project" {
  type = string
  default = null
}