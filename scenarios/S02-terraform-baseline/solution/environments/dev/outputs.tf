output "web_app_url" {
  value       = "https://${module.app_service.default_hostname}"
  description = "The URL of the deployed Web App"
}

output "sql_server_fqdn" {
  value       = module.database.server_fqdn
  description = "The FQDN of the SQL Server"
}

output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "The name of the resource group"
}
