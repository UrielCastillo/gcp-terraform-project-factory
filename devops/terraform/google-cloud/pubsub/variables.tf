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
    schema_settings = object({
      prefix = string
      suffix = string
    })
    topic_settings = object({
      prefix = string
      suffix = string
    })
    subscription_settings = object({
      prefix         = string
      suffix         = string
      storage_prefix = string
      storage_suffix = string
    })
    definitions_path = string
  })
}

variable "project" {
  type = string
  default = null
}