variable "config" {
  type = object({
    credentials_path = string
    bucket_settings  = map(string)
    definitions_path = string
  })
}

variable "project" {
  type = string
  default = null
}