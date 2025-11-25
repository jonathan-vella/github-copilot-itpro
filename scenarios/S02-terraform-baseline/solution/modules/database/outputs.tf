output "server_id" {
  value = azurerm_mssql_server.sql.id
}

output "database_id" {
  value = azurerm_mssql_database.db.id
}

output "server_fqdn" {
  value = azurerm_mssql_server.sql.fully_qualified_domain_name
}
