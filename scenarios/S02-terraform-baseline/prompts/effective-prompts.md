# Effective Copilot Prompts for Terraform Infrastructure

This guide provides curated prompts for using GitHub Copilot to generate production-ready Terraform code for Azure infrastructure.

## Table of Contents

1. [Module Structure Prompts](#module-structure-prompts)
2. [Networking Prompts](#networking-prompts)
3. [Compute & App Services](#compute--app-services)
4. [Database & Storage](#database--storage)
5. [Security & Monitoring](#security--monitoring)
6. [Variables & Validation](#variables--validation)
7. [Outputs & Documentation](#outputs--documentation)
8. [Testing & Validation](#testing--validation)
9. [Advanced Patterns](#advanced-patterns)

---

## Module Structure Prompts

### Create Module Scaffold

```hcl
// Create a Terraform module structure for Azure [resource type] with:
// - main.tf for resource definitions
// - variables.tf for input parameters with validation
// - outputs.tf for resource IDs and properties
// - README.md with usage examples
// Follow Azure naming conventions and best practices
```

**Result**: Copilot generates the complete module file structure.

### Multi-File Module Organization

```hcl
// Split this large main.tf into logical files:
// - network.tf for VNet, subnets, NSGs
// - compute.tf for App Service, VMs
// - data.tf for databases, storage
// - security.tf for Key Vault, private endpoints
// - monitoring.tf for Log Analytics, App Insights
```

**Result**: Modular organization for better maintainability.

---

## Networking Prompts

### Virtual Network with Subnets

```hcl
// Create an Azure Virtual Network module with:
// - VNet with address space from variable
// - 3 subnets: web (10.0.1.0/24), app (10.0.2.0/24), data (10.0.3.0/24)
// - Subnet delegation for App Service if needed
// - NSG association for each subnet
// - Use swedencentral as default location
// - Add comprehensive tags (Environment, ManagedBy, CostCenter)
// - Validation: ensure CIDR blocks don't overlap
```

**Best Practice**: Copilot adds proper dependencies and validation.

### Network Security Groups with Rules

```hcl
// Create NSG for web tier with these rules:
// - Priority 100: Allow HTTPS (443) inbound from Internet
// - Priority 110: Allow HTTP (80) inbound from Internet (redirect to HTTPS)
// - Priority 200: Allow outbound to app subnet (10.0.2.0/24) on port 8080
// - Priority 4096: Deny all other inbound traffic
// - Associate with web subnet
// - Add diagnostic settings to Log Analytics workspace
```

**Security**: Copilot suggests deny-by-default rules.

### Application Gateway with WAF

```hcl
// Create Application Gateway with:
// - WAF_v2 SKU with autoscaling (min 2, max 10)
// - Zone redundancy across zones 1, 2, 3
// - Public IP with Standard SKU
// - Backend pool pointing to App Service private endpoint
// - HTTP to HTTPS redirect rule
// - Health probe on /health endpoint
// - WAF policy in Prevention mode (OWASP 3.2)
// - Custom error pages for 502/403
```

**Advanced**: Copilot handles complex configurations.

### Private DNS Zones

```hcl
// Create private DNS zones for:
// - privatelink.azurewebsites.net (App Service)
// - privatelink.database.windows.net (Azure SQL)
// - privatelink.vaultcore.azure.net (Key Vault)
// - privatelink.blob.core.windows.net (Storage)
// Link all zones to the virtual network
// Add A records automatically when private endpoints are created
```

---

## Compute & App Services

### App Service Plan with Zone Redundancy

```hcl
// Create Azure App Service Plan with:
// - Premium P1v3 SKU (required for zone redundancy)
// - Linux OS type
// - Zone balancing enabled across 3 availability zones
// - Minimum 3 worker instances for high availability
// - Autoscaling rules: scale out at 70% CPU, scale in at 30% CPU
// - Location from variable (default: swedencentral)
// - Tags for cost tracking
```

**Insight**: Copilot knows P1v3 is required for zone redundancy.

### App Service with Managed Identity

```hcl
// Create Linux App Service with:
// - .NET 7.0 runtime stack
// - System-assigned managed identity enabled
// - HTTPS only enforced
// - TLS 1.2 minimum version
// - HTTP2 enabled
// - Always on enabled
// - Public network access disabled (private endpoint only)
// - App settings from variables (KeyVaultUrl, AppInsightsKey)
// - Connection string for SQL database (reference Key Vault secret)
// - Diagnostic settings: send logs to Log Analytics workspace
```

**Security**: Managed Identity eliminates credential management.

### Private Endpoint for App Service

```hcl
// Create private endpoint for App Service with:
// - Deploy in app subnet (from variable)
// - Subresource name: "sites"
// - Private DNS zone group for automatic DNS registration
// - Link to privatelink.azurewebsites.net zone
// - Static private IP allocation (optional)
// - NSG rule to allow traffic from web subnet
```

---

## Database & Storage

### Azure SQL Server with Azure AD Admin

```hcl
// Create Azure SQL Server with:
// - Version 12.0
// - Azure AD administrator group (from variable)
// - Azure AD authentication only (disable SQL authentication)
// - Public network access disabled
// - Minimum TLS version 1.2
// - Identity type: SystemAssigned
// - Transparent Data Encryption enabled
// - Tags including SecurityControl: 'Ignore' for demo environments
```

**Compliance**: Azure AD-only auth meets security requirements.

### Azure SQL Database with Threat Protection

```hcl
// Create Azure SQL Database with:
// - SKU: S0 for dev, S3 for prod (from variable)
// - Max size: 250 GB
// - Zone redundancy: false for dev, true for prod
// - Collation: SQL_Latin1_General_CP1_CI_AS
// - Advanced Threat Protection enabled
// - Email alerts to security team
// - Retention: 30 days for dev, 90 days for prod
// - Short-term backup retention: 7 days dev, 35 days prod
// - Long-term backup: weekly for 4 weeks, monthly for 12 months
// - Geo-redundant backup for prod only
```

**Automation**: Environment-specific configurations handled automatically.

### Private Endpoint for SQL Database

```hcl
// Create private endpoint for SQL Server with:
// - Deploy in data subnet
// - Subresource name: "sqlServer"
// - Private DNS zone group for privatelink.database.windows.net
// - Connection approval: automatic
// - NSG rule: allow traffic from app subnet on port 1433
// - Output: private IP address and FQDN
```

### Storage Account with Encryption

```hcl
// Create Azure Storage Account with:
// - Name: st{projectname}{environment}{uniquesuffix} (max 24 chars, lowercase only)
// - Standard tier, LRS replication for dev, GRS for prod
// - HTTPS traffic only enforced
// - Minimum TLS version 1.2
// - Blob public access disabled
// - Infrastructure encryption enabled
// - Soft delete: 7 days for blobs, 7 days for containers
// - Versioning enabled
// - Network rules: deny all public access, allow Azure services
// - Private endpoint for blob service
```

---

## Security & Monitoring

### Key Vault with RBAC

```hcl
// Create Azure Key Vault with:
// - Name: kv-{projectname}-{env}-{suffix} (max 24 characters)
// - SKU: Standard
// - Enable RBAC authorization (disable access policies)
// - Purge protection enabled
// - Soft delete retention: 7 days for dev, 90 days for prod
// - Network ACLs: bypass AzureServices, default action Deny
// - No public network access
// - Private endpoint in app subnet
// - Diagnostic settings: audit logs to Log Analytics
```

**Modern Approach**: RBAC instead of access policies.

### RBAC Role Assignment

```hcl
// Create RBAC role assignments:
// - App Service managed identity → "Key Vault Secrets User" on Key Vault
// - App Service managed identity → "Storage Blob Data Reader" on Storage Account
// - SQL Server managed identity → "Storage Blob Data Contributor" for backups
// - DevOps Service Principal → "Key Vault Administrator" for deployments
// Use principle of least privilege
```

**Best Practice**: Managed identities with least-privilege roles.

### Log Analytics Workspace

```hcl
// Create Log Analytics workspace with:
// - SKU: PerGB2018
// - Retention: 30 days for dev, 90 days for prod (from variable)
// - Daily quota: 5 GB for dev, unlimited for prod
// - Internet ingestion enabled
// - Internet query enabled
// - Solutions: SecurityCenterFree, Updates, ChangeTracking
// - Output: workspace ID, primary shared key
```

### Application Insights

```hcl
// Create Application Insights with:
// - Application type: web
// - Linked to Log Analytics workspace
// - Sampling percentage: 100% for dev, 20% for prod
// - Retention: 90 days
// - Disable IP masking for dev (enable for prod)
// - Daily cap: 1 GB for dev, 10 GB for prod
// - Continuous export to Storage Account
```

### Diagnostic Settings

```hcl
// Create diagnostic settings for all resources to send:
// - All logs to Log Analytics workspace
// - All metrics to Log Analytics workspace
// - Resource types: App Service, SQL Database, Key Vault, Storage Account, NSG
// - Retention: match Log Analytics workspace retention
```

---

## Variables & Validation

### Variable Definitions with Validation

```hcl
// Define variables for infrastructure module:
// 
// variable "environment" - string, allowed values: dev, staging, prod
// variable "location" - string, default swedencentral, validate against list of Azure regions
// variable "resource_group_name" - string, required, not null or empty
// variable "vnet_address_space" - list(string), default ["10.0.0.0/16"], validate CIDR format
// variable "subnet_prefixes" - map of CIDR blocks, validate no overlaps
// variable "app_service_sku" - string, default P1v3, validate against valid SKUs
// variable "sql_database_sku" - string, default S0, validate against valid SKUs
// variable "tags" - map(string), required keys: Environment, ManagedBy, CostCenter, Owner
// 
// Add descriptions and validation rules for each variable
```

**Result**: Comprehensive variable definitions with type safety.

### Conditional Logic Based on Environment

```hcl
// Add conditional logic for environment-specific configurations:
// - App Service SKU: P1v3 for dev, P2v3 for staging, P3v3 for prod
// - SQL Database SKU: S0 for dev, S2 for staging, S3 for prod
// - Backup retention: 7 days dev, 14 days staging, 35 days prod
// - Log retention: 30 days dev, 60 days staging, 90 days prod
// - Zone redundancy: false for dev, false for staging, true for prod
// - Geo-redundancy: false for dev/staging, true for prod
// Use locals block with lookup() or conditional expressions
```

---

## Outputs & Documentation

### Comprehensive Outputs

```hcl
// Define outputs for this module:
// - vnet_id - Virtual Network resource ID
// - subnet_ids - Map of subnet names to resource IDs
// - app_service_url - HTTPS URL of the App Service
// - app_service_identity_principal_id - Managed Identity ID for RBAC
// - sql_server_fqdn - Fully qualified domain name of SQL Server
// - sql_connection_string - Connection string (retrieve from Key Vault)
// - key_vault_uri - Key Vault URL for application configuration
// - log_analytics_workspace_id - Workspace ID for monitoring
// - application_insights_instrumentation_key - For telemetry
// Add descriptions for each output
```

### README Generation

```markdown
// Generate README.md for this Terraform module with:
// - Module description and purpose
// - Architecture diagram (Mermaid format)
// - Usage example with sample values
// - Input variables table (name, type, description, default, required)
// - Outputs table (name, description)
// - Requirements (Terraform version, provider versions)
// - Examples for dev, staging, prod environments
// - Security considerations
// - Contributing guidelines
```

---

## Testing & Validation

### Terratest Unit Test

```go
// Create Terratest unit test for this infrastructure module:
// - Test function: TestTerraformInfrastructure
// - Initialize Terraform with test variables
// - Apply configuration
// - Validate outputs:
//   * VNet ID is not empty
//   * App Service URL contains "azurewebsites.net"
//   * SQL Server FQDN contains "database.windows.net"
//   * Key Vault URI contains "vault.azure.net"
// - Test connectivity to App Service (via Application Gateway)
// - Test SQL connection from App Service
// - Destroy resources after test
// - Use parallel testing for faster execution
```

### Validation Script

```bash
#!/bin/bash
# Create validation script to check:
# - Terraform fmt (code formatting)
# - Terraform validate (syntax and internal consistency)
# - tfsec (security scanning)
# - checkov (policy compliance)
# - terraform plan (preview changes)
// Run all checks and report results
// Exit code 0 if all pass, 1 if any fail
```

---

## Advanced Patterns

### Remote State Configuration

```hcl
// Configure Terraform backend for Azure Storage:
// - Resource group: rg-terraform-state
// - Storage account: sttfstate{projectname}{env} (globally unique)
// - Container: tfstate
// - Key: {environment}.terraform.tfstate
// - Use Azure AD authentication (no storage keys)
// - Enable state locking with Azure Storage lease
// - Add lifecycle rule: version retention for 30 days
```

### Data Sources for Existing Resources

```hcl
// Use data sources to reference existing resources:
// - azurerm_client_config for current Azure context
// - azurerm_subscription for subscription details
// - azurerm_resource_group if RG already exists
// - azurerm_virtual_network for hub VNet in hub-spoke topology
// - azurerm_log_analytics_workspace for central monitoring
// - azuread_group for Azure AD groups (SQL admins, Key Vault admins)
```

### Dynamic Blocks for Iteration

```hcl
// Use dynamic blocks to create multiple NSG rules from a list:
// - Define variable: list of objects with name, priority, direction, access, protocol, source_port_range, destination_port_range, source_address_prefix, destination_address_prefix
// - Use dynamic "security_rule" block to iterate
// - Validate: priority values must be unique
```

### Locals for Computed Values

```hcl
// Create locals block for:
// - unique_suffix = substr(sha256(resource_group_id), 0, 6)
// - resource_names with naming convention: {resourcetype}-{projectname}-{environment}-{suffix}
// - common_tags = merge(var.tags, {Environment = var.environment, ManagedBy = "Terraform"})
// - environment_config = lookup of environment-specific values (SKUs, retention, etc.)
```

### Module Composition

```hcl
// Create root module that composes these modules:
// - module "networking" - VNet, subnets, NSGs, private DNS zones
// - module "app_service" - App Service Plan, App Service, private endpoint
//   - Pass subnet ID from networking module
// - module "database" - SQL Server, database, private endpoint
//   - Pass subnet ID from networking module
// - module "monitoring" - Log Analytics, Application Insights
// - module "security" - Key Vault, RBAC assignments
//   - Pass App Service identity from app_service module
// Show explicit dependencies with depends_on where needed
```

---

## Prompt Engineering Tips

### 1. Be Specific About Azure Services

- ✅ "Create Azure SQL Database with private endpoint"
- ❌ "Create database"

### 2. Mention Security Requirements

- ✅ "with Azure AD authentication only, private endpoint, TLS 1.2 minimum"
- ❌ "secure database"

### 3. Specify Environment Context

- ✅ "S0 SKU for dev, S3 for prod, based on environment variable"
- ❌ "appropriate SKU"

### 4. Request Validation Rules

- ✅ "Add validation: location must be valid Azure region from list"
- ❌ "validate location"

### 5. Ask for Complete Modules

- ✅ "with main.tf, variables.tf, outputs.tf, and README.md"
- ❌ "create module"

### 6. Mention Dependencies

- ✅ "depends on VNet and subnet from networking module"
- ❌ "needs network"

### 7. Include Monitoring & Logging

- ✅ "Add diagnostic settings to send logs to Log Analytics workspace"
- ❌ "enable logging"

### 8. Reference Best Practices

- ✅ "Follow Azure Well-Architected Framework security pillar"
- ❌ "make it secure"

---

## Common Patterns Library

### Pattern: Unique Resource Names

```hcl
// Generate globally unique resource names using:
locals {
  unique_suffix = substr(sha256("${var.subscription_id}${var.resource_group_name}"), 0, 6)
  
  resource_names = {
    key_vault       = "kv-${var.project_name}-${var.environment}-${local.unique_suffix}"     // Max 24 chars
    storage_account = "st${replace(var.project_name, "-", "")}${var.environment}${local.unique_suffix}"  // Max 24, no hyphens
    sql_server      = "sql-${var.project_name}-${var.environment}-${local.unique_suffix}"    // Max 63 chars
    app_service     = "app-${var.project_name}-${var.environment}-${local.unique_suffix}"    // Globally unique
  }
}
```

### Pattern: Environment-Specific Configuration

```hcl
// Define environment-specific configurations:
locals {
  env_config = {
    dev = {
      app_service_sku  = "P1v3"
      sql_sku          = "S0"
      backup_retention = 7
      log_retention    = 30
      zone_redundant   = false
      geo_redundant    = false
    }
    staging = {
      app_service_sku  = "P2v3"
      sql_sku          = "S2"
      backup_retention = 14
      log_retention    = 60
      zone_redundant   = false
      geo_redundant    = false
    }
    prod = {
      app_service_sku  = "P3v3"
      sql_sku          = "S3"
      backup_retention = 35
      log_retention    = 90
      zone_redundant   = true
      geo_redundant    = true
    }
  }
  
  current_config = local.env_config[var.environment]
}
```

### Pattern: Tags Enforcement

```hcl
// Enforce mandatory tags across all resources:
locals {
  mandatory_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    CostCenter  = var.cost_center
    Owner       = var.owner_email
    Project     = var.project_name
  }
  
  all_tags = merge(local.mandatory_tags, var.additional_tags)
}

// Apply to all resources:
resource "azurerm_resource_group" "main" {
  tags = local.all_tags
}
```

---

**Next Steps**: Use these prompts in VS Code with GitHub Copilot to generate production-ready Terraform modules.
