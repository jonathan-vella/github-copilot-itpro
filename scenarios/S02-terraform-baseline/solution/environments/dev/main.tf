terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "networking" {
  source              = "../../modules/networking"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_name           = "vnet-${var.environment}"
  tags                = var.tags
}

module "app_service" {
  source              = "../../modules/app-service"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  app_service_name    = "app-${var.environment}-${random_string.suffix.result}"
  subnet_id           = module.networking.subnet_ids["app"]
  tags                = var.tags
}

module "database" {
  source              = "../../modules/database"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = "sql-${var.environment}-${random_string.suffix.result}"
  admin_username      = "sqladmin"
  admin_password      = "P@ssw0rd1234!" # In prod, use Key Vault
  subnet_id           = module.networking.subnet_ids["data"]
  tags                = var.tags

  aad_admin_login = "jonathan@lordofthecloud.eu" # Hardcoding based on user request context, or could use a variable if preferred, but user asked for "logged on user". 
  # Ideally I should use the client config object ID, but for login name, client config doesn't provide UPN directly in all cases (service principals). 
  # However, since I'm running as a user, I can try to use a variable or just hardcode for this specific request since I know the UPN.
  # Actually, better to use the object ID from the data source to be safe, but the login name is required.
  # I will use the hardcoded UPN "jonathan@lordofthecloud.eu" as requested/discovered, and the object ID from the data source to ensure it matches the authenticated principal.

  aad_admin_object_id = data.azurerm_client_config.current.object_id
  aad_admin_tenant_id = data.azurerm_client_config.current.tenant_id
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
