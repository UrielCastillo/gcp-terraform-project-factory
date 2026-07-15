variable "emulating_pubsub" {
  type        = bool
  default     = true
  description = "Habilitar entorno de pruebas"
}

variable "config" {
  type = object({
    credentials_path = string
    project_id       = string
    region           = string
    zone             = string
    topic_settings   = object({
      prefix = string
      suffix = string
    })
    schema_settings  = object({
      prefix = string
      suffix = string
    })
    definitions_path = string
  })
}

variable "schema_dependency" {
  type = map(object({
    definition = string
    id         = string
    name       = string
    project    = string
    timeouts = object({
      create = string
      delete = string
      update = string
    })
    type = string
  }))
  default     = null
  description = "Para especificar si tiene dependencias"
}

variable "project" {
  type = string
  default = null
}