variable "config" {
  type = object({
    credentials_path = string
    definitions_path = optional(string)
  })
}

variable "roles_per_resource" {
  type    = any
  default = null
}

variable "project" {
  type = string
  default = null
}