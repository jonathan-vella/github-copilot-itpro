# Manual Approach - Basic Terraform Configuration

# Simple monolithic configuration - no modules

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
  subscription_id = "00000000-0000-0000-0000-000000000000"  # Hard-coded
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-app-dev"
  location = "eastus"
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-app"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Subnets
resource "azurerm_subnet" "web" {
  name                 = "subnet-web"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "app" {
  name                 = "subnet-app"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group - basic
resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"  # Open to internet
    destination_address_prefix = "*"
  }
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "asp-app"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "S1"  # Standard tier (no zone redundancy)
}

# App Service
resource "azurerm_linux_web_app" "main" {
  name                = "app-myapp-12345"  # Hope this is unique
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }
  
  # No managed identity
  # No private endpoint
  # No https_only enforcement
}

# SQL Server
resource "azurerm_mssql_server" "main" {
  name                         = "sql-myapp"  # Hope this is unique
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd1234!"  # Hard-coded password (security risk)
  
  # No Azure AD admin
  # Public access enabled by default
}

# SQL Database
resource "azurerm_mssql_database" "main" {
  name           = "sqldb-app"
  server_id      = azurerm_mssql_server.main.id
  sku_name       = "Basic"
  max_size_gb    = 2
  
  # No threat detection
  # No backup retention
}

# Storage Account - for app data
resource "azurerm_storage_account" "main" {
  name                     = "stappdata"  # Too short, might conflict
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # No encryption enforcement
  # No min TLS version
  # Public access allowed
}

# No outputs defined
# No variables
# No tags
# No Key Vault
# No monitoring
# No private endpoints
# No RBAC
