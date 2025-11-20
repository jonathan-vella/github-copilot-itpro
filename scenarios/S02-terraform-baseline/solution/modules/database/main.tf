resource "azurerm_mssql_server" "sql" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password

  azuread_administrator {
    login_username = var.aad_admin_login
    object_id      = var.aad_admin_object_id
    tenant_id      = var.aad_admin_tenant_id
  }

  tags = merge(var.tags, {
    SecurityControl = "Ignore"
  })
}

resource "azurerm_mssql_database" "db" {
  name      = "db-app"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S0"
  tags      = var.tags
}

resource "azurerm_private_endpoint" "sql" {
  name                = "pe-sql"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-sql"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}
