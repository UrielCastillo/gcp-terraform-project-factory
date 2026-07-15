output "service_account_keys" {
  description = "Service account keys."
  sensitive   = true
  value       = { for index, dict in local.service_account_keys : dict.service_account_id => { key : base64decode(dict.private_key) } }
}

output "service_account_emails" {
  description = "Service account emails"
  value       = { for index, dict in local.resource_service_accounts : index => { email : dict.email, project : dict.project } }
}

output "emails_static" {
  description = "Static service account emails"
  value = {
    for index, dict in local.resources :
    "${var.config.service_account_settings.prefix}${dict.name}${var.config.service_account_settings.suffix}@${dict.project_id}.iam.gserviceaccount.com"
    => { email : "${var.config.service_account_settings.prefix}${dict.name}${var.config.service_account_settings.suffix}@${dict.project_id}.iam.gserviceaccount.com" }
  }
}