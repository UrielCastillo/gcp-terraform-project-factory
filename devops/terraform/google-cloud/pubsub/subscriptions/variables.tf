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

variable "topic_dependency" {
  type = map(object({
    effective_labels = map(string)
    id               = string
    name             = string
    project          = string
    schema_settings = list(object({
      encoding = string
      schema   = string
    }))
    terraform_labels = map(string)
  }))
  default     = null
  description = "Para especificar si tiene dependencias"
}

variable "project" {
  type = string
  default = null
}