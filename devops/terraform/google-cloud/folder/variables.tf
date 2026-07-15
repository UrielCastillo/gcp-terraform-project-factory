variable "config" {
  type = object({
    credentials_path = string
    definitions_path = string
  })
}