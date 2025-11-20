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
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
