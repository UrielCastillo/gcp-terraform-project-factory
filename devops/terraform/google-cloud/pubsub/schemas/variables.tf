variable "config" {
  type = object({
    credentials_path = string
    project_id       = string
    region           = string
    zone             = string
    schema_settings = object({
      prefix = string
      suffix = string
    })
    definitions_path = string
  })
}

variable "has_dependencies" {
  type        = bool
  default     = false
  description = "Para especificar si tiene dependencias"
}

variable "emulating_pubsub" {
  type        = bool
  default     = true
  description = "Habilitar entorno de pruebas"
}

variable "project" {
  type = string
  default = null
}