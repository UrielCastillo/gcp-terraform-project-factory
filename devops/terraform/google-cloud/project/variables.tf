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

variable "parent_folders" {
  type = map(object({
    display_name = string
    parent       = string
    folder_id    = string
  }))
  default = null
}
