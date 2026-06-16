output "application_ids" {
  description = "Map of app key -> SAE application id."
  value       = { for k, app in alicloud_sae_application.this : k => app.app_id }
}

output "application_names" {
  description = "Map of app key -> SAE application name."
  value       = { for k, app in alicloud_sae_application.this : k => app.app_name }
}
