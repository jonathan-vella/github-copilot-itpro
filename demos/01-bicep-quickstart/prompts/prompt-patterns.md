# Reusable Bicep Prompt Patterns

This document provides reusable prompt templates for common Azure infrastructure scenarios. Copy these patterns and customize the placeholders to match your specific requirements.

---

## 📋 Table of Contents

1. [How to Use These Patterns](#how-to-use-these-patterns)
2. [Networking Patterns](#networking-patterns)
3. [Security Patterns](#security-patterns)
4. [Storage Patterns](#storage-patterns)
5. [Compute Patterns](#compute-patterns)
6. [Monitoring Patterns](#monitoring-patterns)
7. [Multi-Resource Patterns](#multi-resource-patterns)
8. [Parameter Patterns](#parameter-patterns)

---

## How to Use These Patterns

1. **Copy the pattern** that matches your scenario
2. **Replace placeholders** in `{curly braces}` with your values
3. **Paste as a comment** in your Bicep file
4. **Let Copilot generate** the code
5. **Review and adjust** the suggestions

**Example**:

```
Pattern: // Create a {resourceType} named '{name}' in {location}
Your use: // Create a storage account named 'stproddata' in eastus
```

---

## Networking Patterns

### Virtual Network Pattern

```bicep
// Create an Azure Virtual Network named '{vnetName}' with address space {addressSpace}
// Include {number} subnets: {subnet1Name} ({cidr1}), {subnet2Name} ({cidr2}), {subnet3Name} ({cidr3})
// Add parameters for location and environment
```

**Example**:

```bicep
// Create an Azure Virtual Network named 'vnet-prod-app' with address space 10.1.0.0/16
// Include 3 subnets: frontend (10.1.1.0/24), backend (10.1.2.0/24), database (10.1.3.0/24)
// Add parameters for location and environment
```

---

### Network Security Group Pattern

```bicep
// Create a Network Security Group for the {tierName} subnet
// Allow inbound {protocol} on port {port} from {source}
// Allow outbound to {destination} on port {port}
// Deny all other inbound traffic at priority 4096
```

**Example**:

```bicep
// Create a Network Security Group for the frontend subnet
// Allow inbound TCP on port 443 from Internet
// Allow outbound to backend subnet on port 8080
// Deny all other inbound traffic at priority 4096
```

---

### Subnet Pattern

```bicep
// Add a subnet named '{subnetName}' with address prefix {cidr}
// Attach Network Security Group '{nsgName}'
// {optionalFeature: Enable service endpoints for {services}}
```

**Example**:

```bicep
// Add a subnet named 'snet-data-prod' with address prefix 10.0.3.0/24
// Attach Network Security Group 'nsg-data-prod'
// Enable service endpoints for Microsoft.Storage and Microsoft.Sql
```

---

### Private Endpoint Pattern

```bicep
// Create a private endpoint for the {resourceType} named '{resourceName}'
// Connect to the {subnetName} subnet
// Add a private DNS zone for {dnsZoneName}
// Link the DNS zone to the virtual network
```

**Example**:

```bicep
// Create a private endpoint for the storage account named 'stproddata'
// Connect to the snet-data-prod subnet
// Add a private DNS zone for privatelink.blob.core.windows.net
// Link the DNS zone to the virtual network
```

---

### VNet Peering Pattern

```bicep
// Create VNet peering between '{vnet1Name}' and '{vnet2Name}'
// {option: Allow gateway transit / Use remote gateway}
// {option: Allow forwarded traffic}
```

**Example**:

```bicep
// Create VNet peering between 'vnet-hub-prod' and 'vnet-spoke-app'
// Allow gateway transit from hub to spoke
// Allow forwarded traffic
```

---

## Security Patterns

### Secure Storage Account Pattern

```bicep
// Create a storage account named '{storageAccountName}'
// Use {sku} replication and {tier} access tier
// Enable HTTPS only, minimum TLS {version}
// Disable public blob access
// Enable blob soft delete with {days} day retention
// {optional: Enable versioning and change feed}
```

**Example**:

```bicep
// Create a storage account named 'stproddataapp01'
// Use Standard_GRS replication and Hot access tier
// Enable HTTPS only, minimum TLS 1.2
// Disable public blob access
// Enable blob soft delete with 30 day retention
// Enable versioning and change feed
```

---

### Key Vault Pattern

```bicep
// Create an Azure Key Vault named '{keyVaultName}'
// Use {authorization: RBAC / Access Policies}
// Enable soft delete with {days} day retention
// Enable purge protection
// {optional: Configure network rules to allow access from {source}}
```

**Example**:

```bicep
// Create an Azure Key Vault named 'kv-prod-app-01'
// Use RBAC authorization
// Enable soft delete with 90 day retention
// Enable purge protection
// Configure network rules to allow access from application subnet
```

---

### Managed Identity Pattern

```bicep
// Create a {type: user-assigned / system-assigned} managed identity named '{identityName}'
// Grant it {roleName} role on the {resourceType} named '{resourceName}'
```

**Example**:

```bicep
// Create a user-assigned managed identity named 'id-app-prod'
// Grant it Storage Blob Data Contributor role on the storage account named 'stproddata'
```

---

### Role Assignment Pattern

```bicep
// Assign {roleName} role to {principalType} '{principalName}'
// Scope: {scope: subscription / resource group / resource}
// {optional: Add description '{description}'}
```

**Example**:

```bicep
// Assign Contributor role to service principal 'sp-devops-prod'
// Scope: resource group
// Add description 'DevOps deployment permissions'
```

---

## Storage Patterns

### Blob Container Pattern

```bicep
// Create a blob container named '{containerName}'
// Set public access to {level: None / Blob / Container}
// {optional: Add immutability policy with {days} day retention}
```

**Example**:

```bicep
// Create a blob container named 'backups'
// Set public access to None
// Add immutability policy with 365 day retention
```

---

### Lifecycle Management Pattern

```bicep
// Add lifecycle management policy to the storage account
// Move blobs to {tier: Cool / Archive} after {days} days
// Delete blobs older than {days} days
// {optional: Apply to containers matching '{prefix}'}
```

**Example**:

```bicep
// Add lifecycle management policy to the storage account
// Move blobs to Cool tier after 30 days
// Delete blobs older than 365 days
// Apply to containers matching 'logs-*'
```

---

### File Share Pattern

```bicep
// Create an Azure File Share named '{shareName}'
// Set quota to {size} GB
// Use {tier: TransactionOptimized / Hot / Cool} tier
// Enable {protocol: SMB / NFS} protocol
```

**Example**:

```bicep
// Create an Azure File Share named 'appdata'
// Set quota to 100 GB
// Use TransactionOptimized tier
// Enable SMB protocol
```

---

## Compute Patterns

### Linux Virtual Machine Pattern

```bicep
// Create a {osType} {osVersion} virtual machine named '{vmName}'
// Use {vmSize} SKU
// Deploy to '{subnetName}' subnet
// Use {authType: SSH key / password} authentication
// {optional: Attach {number} managed disk(s) for data ({size} GB, {sku: Premium_LRS / Standard_LRS})}
```

**Example**:

```bicep
// Create a Ubuntu 22.04 LTS virtual machine named 'vm-app-prod-01'
// Use Standard_D2s_v3 SKU
// Deploy to 'snet-app-prod' subnet
// Use SSH key authentication
// Attach 2 managed disks for data (256 GB, Premium_LRS)
```

---

### Windows Virtual Machine Pattern

```bicep
// Create a {osType} {osVersion} virtual machine named '{vmName}'
// Use {vmSize} SKU
// Deploy to '{subnetName}' subnet
// Use password authentication with admin user '{adminUsername}'
// Install {extension: IIS / SQL Server / custom}
```

**Example**:

```bicep
// Create a Windows Server 2022 Datacenter virtual machine named 'vm-web-prod-01'
// Use Standard_D4s_v3 SKU
// Deploy to 'snet-web-prod' subnet
// Use password authentication with admin user 'adminuser'
// Install IIS with management tools
```

---

### Virtual Machine Scale Set Pattern

```bicep
// Create a Virtual Machine Scale Set named '{vmssName}'
// Use {osImage} image and {vmSize} SKU
// Set initial capacity to {min} instances, scale between {min}-{max}
// Use autoscale based on {metric: CPU / Memory / Custom} > {threshold}%
// Deploy to '{subnetName}' subnet
// {optional: Add load balancer with health probe on port {port}}
```

**Example**:

```bicep
// Create a Virtual Machine Scale Set named 'vmss-web-prod'
// Use Ubuntu 22.04 LTS image and Standard_B2s SKU
// Set initial capacity to 2 instances, scale between 2-10
// Use autoscale based on CPU > 75%
// Deploy to 'snet-web-prod' subnet
// Add load balancer with health probe on port 80
```

---

### Azure Container Instances Pattern

```bicep
// Create an Azure Container Instance named '{aciName}'
// Run container image '{image}:{tag}'
// Expose port {port} with {ipType: public / private} IP
// Use {cpu} CPU cores and {memory} GB memory
// {optional: Add environment variables: {key1}={value1}, {key2}={value2}}
```

**Example**:

```bicep
// Create an Azure Container Instance named 'aci-api-dev'
// Run container image 'myapp:latest'
// Expose port 8080 with public IP
// Use 2 CPU cores and 4 GB memory
// Add environment variables: ENVIRONMENT=dev, LOG_LEVEL=debug
```

---

## Monitoring Patterns

### Log Analytics Workspace Pattern

```bicep
// Create a Log Analytics workspace named '{workspaceName}'
// Set retention to {days} days
// Use {sku: PerGB2018 / CapacityReservation} pricing tier
// {optional: Set daily cap to {gb} GB}
```

**Example**:

```bicep
// Create a Log Analytics workspace named 'log-prod-monitoring'
// Set retention to 90 days
// Use PerGB2018 pricing tier
// Set daily cap to 10 GB
```

---

### Diagnostic Settings Pattern

```bicep
// Add diagnostic settings for the {resourceType} named '{resourceName}'
// Send {logCategories: all logs / specific categories} to Log Analytics workspace
// Include {metrics: all metrics / specific metrics}
// {optional: Also send to storage account for long-term retention}
```

**Example**:

```bicep
// Add diagnostic settings for the storage account named 'stproddata'
// Send all logs to Log Analytics workspace
// Include all metrics
// Also send to storage account for long-term retention
```

---

### Application Insights Pattern

```bicep
// Create an Application Insights resource named '{appInsightsName}'
// Set application type to {type: web / other}
// Connect to Log Analytics workspace '{workspaceName}'
// {optional: Enable {features: profiler / snapshot debugger / live metrics}}
```

**Example**:

```bicep
// Create an Application Insights resource named 'appi-prod-web'
// Set application type to web
// Connect to Log Analytics workspace 'log-prod-monitoring'
// Enable profiler and live metrics
```

---

### Alert Rule Pattern

```bicep
// Create an alert rule named '{alertName}'
// Monitor {metric / log} on {resourceType} '{resourceName}'
// Trigger when {condition} for {duration} minutes
// Send notification to {actionGroup}
// Set severity to {severity: 0-4}
```

**Example**:

```bicep
// Create an alert rule named 'alert-high-cpu'
// Monitor CPU percentage on virtual machine 'vm-app-prod-01'
// Trigger when average > 85% for 5 minutes
// Send notification to action group 'ag-prod-ops'
// Set severity to 2
```

---

## Multi-Resource Patterns

### Three-Tier Application Pattern

```bicep
// Create infrastructure for a three-tier application in {environment}
// Tier 1 - Web: {number} VMs in '{webSubnet}' subnet, expose ports {ports}
// Tier 2 - App: {number} VMs in '{appSubnet}' subnet, communicate with web tier
// Tier 3 - Data: Azure SQL Database or storage in '{dataSubnet}' subnet
// Add NSGs with appropriate security rules for each tier
// Include Load Balancer for web tier
// Add Log Analytics and diagnostic settings for all resources
```

---

### Hub-Spoke Network Pattern

```bicep
// Create a hub-spoke network topology
// Hub VNet '{hubVnetName}' with address space {hubAddressSpace}
// Spoke VNet '{spokeVnetName}' with address space {spokeAddressSpace}
// Add VNet peering with gateway transit from hub
// {optional: Add Azure Firewall in hub for centralized security}
// {optional: Add Azure Bastion in hub for secure VM access}
```

---

### Secure Storage with Private Endpoints Pattern

```bicep
// Create a storage account with complete network isolation
// Storage account: '{storageAccountName}', {sku} replication
// Disable all public network access
// Add private endpoints for {services: blob, file, queue, table}
// Connect private endpoints to '{subnetName}' subnet
// Create private DNS zones for each service
// Link DNS zones to VNet '{vnetName}'
```

---

## Parameter Patterns

### Standard Parameters Pattern

```bicep
// Add standard parameters for Azure resources
// location: string with default resourceGroup().location
// environment: string with allowed values ['dev', 'staging', 'prod']
// tags: object with Environment, Owner, CostCenter, Application
```

---

### Naming Convention Pattern

```bicep
// Create naming convention variables
// Pattern: {resourceType}-{environment}-{application}-{instance}
// Example: storage account = st{env}{app}{uniqueString}
// Ensure names follow Azure naming rules (length, allowed characters)
```

---

### Conditional Resource Pattern

```bicep
// Create {resourceType} only if {condition}
// Use parameter '{parameterName}' to control deployment
// Example: Deploy Azure Bastion only in production environment
```

**Example**:

```bicep
// Create Azure Bastion only if environment is 'prod'
// Use parameter 'environment' to control deployment
```

---

### Resource Loop Pattern

```bicep
// Create {number} {resourceType} using a loop
// Base name: '{baseName}'
// Append index to each resource (e.g., '{baseName}-01', '{baseName}-02')
// Use range(start, count) or array of names
```

**Example**:

```bicep
// Create 5 storage accounts using a loop
// Base name: 'stproddata'
// Append index to each resource (e.g., 'stproddata01', 'stproddata02')
// Use range(1, 5)
```

---

## Quick Reference Cheat Sheet

### Placeholders Used in Patterns

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{name}` | Resource name | `vnet-prod-app` |
| `{resourceType}` | Azure resource type | `storage account`, `virtual machine` |
| `{location}` | Azure region | `eastus`, `westeurope` |
| `{environment}` | Environment name | `dev`, `staging`, `prod` |
| `{addressSpace}` | VNet address space | `10.0.0.0/16` |
| `{cidr}` | Subnet CIDR range | `10.0.1.0/24` |
| `{port}` | Network port | `80`, `443`, `1433` |
| `{sku}` | Resource SKU/tier | `Standard_LRS`, `Standard_B2s` |
| `{days}` | Time period in days | `7`, `30`, `90` |
| `{size}` | Size in GB | `128`, `256`, `512` |
| `{number}` | Count/quantity | `2`, `5`, `10` |
| `{option: ...}` | Optional feature | Include if needed |

---

## Pattern Combination Example

Here's how to combine multiple patterns to build a complete solution:

### Scenario: Secure Web Application with Database

**Step 1 - Network Foundation**

```bicep
// Create an Azure Virtual Network named 'vnet-prod-webapp' with address space 10.2.0.0/16
// Include 3 subnets: web (10.2.1.0/24), app (10.2.2.0/24), data (10.2.3.0/24)
// Add parameters for location and environment
```

**Step 2 - Network Security**

```bicep
// Create a Network Security Group for the web subnet
// Allow inbound HTTPS on port 443 from Internet
// Allow outbound to app subnet on port 8080
// Deny all other inbound traffic at priority 4096
```

**Step 3 - Compute Resources**

```bicep
// Create a Virtual Machine Scale Set named 'vmss-web-prod'
// Use Ubuntu 22.04 LTS image and Standard_B2s SKU
// Set initial capacity to 2 instances, scale between 2-5
// Use autoscale based on CPU > 70%
// Deploy to 'snet-web-prod' subnet
// Add load balancer with health probe on port 443
```

**Step 4 - Data Storage**

```bicep
// Create a storage account named 'stprodwebappdata'
// Use Standard_GRS replication and Hot access tier
// Enable HTTPS only, minimum TLS 1.2
// Disable public blob access
// Enable blob soft delete with 30 day retention
```

**Step 5 - Private Connectivity**

```bicep
// Create a private endpoint for the storage account named 'stprodwebappdata'
// Connect to the snet-data-prod subnet
// Add a private DNS zone for privatelink.blob.core.windows.net
// Link the DNS zone to the virtual network
```

**Step 6 - Monitoring**

```bicep
// Create a Log Analytics workspace named 'log-prod-webapp'
// Set retention to 90 days
// Use PerGB2018 pricing tier
```

```bicep
// Add diagnostic settings for the storage account named 'stprodwebappdata'
// Send all logs to Log Analytics workspace
// Include all metrics
```

---

## Tips for Customizing Patterns

1. **Start Simple**: Use basic patterns first, then add complexity
2. **Be Consistent**: Keep naming conventions consistent across resources
3. **Security First**: Always include security settings in your patterns
4. **Test Incrementally**: Deploy one pattern at a time to validate
5. **Document Choices**: Add comments explaining why you chose specific values
6. **Reuse Successfully**: Save patterns that work well for your organization

---

## Additional Resources

- [Effective Prompts](./effective-prompts.md) - Production-tested prompts with detailed examples
- [Azure Naming Conventions](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [Bicep Best Practices](https://learn.microsoft.com/azure/azure-resource-manager/bicep/best-practices)
- [Azure Resource Abbreviations](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)

---

[🏠 Back to Demo README](../README.md) | [💡 View Effective Prompts](./effective-prompts.md)
