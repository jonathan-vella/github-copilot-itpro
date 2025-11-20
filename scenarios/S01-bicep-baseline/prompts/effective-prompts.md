# Effective Prompts for Bicep Infrastructure

This document contains production-tested prompts for generating Azure infrastructure using GitHub Copilot. These prompts have been refined through real-world use and consistently produce high-quality, secure Bicep code.

---

## 📋 Table of Contents

1. [Core Infrastructure](#core-infrastructure)
2. [Networking](#networking)
3. [Security](#security)
4. [Storage](#storage)
5. [Compute](#compute)
6. [Monitoring](#monitoring)
7. [Prompt Engineering Tips](#prompt-engineering-tips)

---

## Core Infrastructure

### Virtual Network with Subnets

```bicep
// Create an Azure Virtual Network named 'vnet-prod' with address space 10.0.0.0/16
// Include three subnets: web-tier (10.0.1.0/24), app-tier (10.0.2.0/24), data-tier (10.0.3.0/24)
// Add location and environment parameters
```

**Expected Result**: Complete VNet resource with parameters, addressSpace, and subnets array.

**Tips**:

- Be specific about subnet names and CIDR ranges
- Mention parameter names if you want consistency
- Copilot will use latest API version automatically

---

### Resource Group Tagging

```bicep
// Create a tags parameter with Environment, Owner, CostCenter, and Application
// Use these tags on all resources
```

**Expected Result**: Parameter object with tag schema, applied to resources.

---

## Networking

### Network Security Groups

```bicep
// Add a Network Security Group for the web tier subnet
// Allow inbound HTTP (80) and HTTPS (443) from Internet
// Allow outbound to app-tier subnet on port 8080
// Deny all other inbound traffic
```

**Expected Result**: NSG resource with security rules, proper priorities, and deny rules.

**Tips**:

- Specify traffic direction (inbound/outbound)
- Mention source and destination (IP ranges or tags)
- Copilot will set deny rules at priority 4096 automatically

---

### NSG Rules for Database Access

```bicep
// Add NSG rules to allow SQL Server traffic (port 1433) from app-tier subnet only
// Block all other database access
```

**Expected Result**: Security rules with correct protocol, ports, and priority.

---

### Private Endpoints

```bicep
// Create a private endpoint for the storage account in the data-tier subnet
// Add a private DNS zone for blob.core.windows.net
// Link the DNS zone to the virtual network
```

**Expected Result**: Private endpoint, private DNS zone, and DNS zone VNet link resources.

**Tips**:

- Specify which service (blob, file, queue, table)
- Mention target subnet
- Copilot understands private link resource types

---

### Azure Bastion

```bicep
// Add Azure Bastion subnet (/26 minimum) and Azure Bastion host
// Use Standard SKU with native client support
```

**Expected Result**: AzureBastionSubnet with /26 CIDR, Bastion host resource with public IP.

---

## Security

### Storage Account Security

```bicep
// Create a secure storage account with HTTPS only, minimum TLS 1.2
// Disable public blob access
// Enable blob soft delete with 7-day retention
// Use Microsoft-managed encryption keys
```

**Expected Result**: Storage account with security properties, blob services config, soft delete enabled.

**Tips**:

- Be explicit about security requirements
- Mention retention periods
- Copilot knows `supportsHttpsTrafficOnly`, `minimumTlsVersion`, `allowBlobPublicAccess` properties

---

### Key Vault with Access Policies

```bicep
// Create an Azure Key Vault with RBAC authorization
// Enable soft delete and purge protection
// Add diagnostic settings to send logs to Log Analytics
```

**Expected Result**: Key Vault with security features, diagnosticSettings resource.

---

### Managed Identity

```bicep
// Create a user-assigned managed identity
// Grant it Storage Blob Data Contributor role on the storage account
```

**Expected Result**: Managed identity resource, role assignment with correct scope and principalId.

---

## Storage

### Storage Account with Lifecycle Management

```bicep
// Add lifecycle management policy to move blobs to Cool tier after 30 days
// Delete blobs older than 90 days
```

**Expected Result**: `managementPolicies` resource with lifecycle rules.

---

### Storage Account with Private Endpoint

```bicep
// Create a storage account with private endpoint only (no public access)
// Use Standard LRS, Hot tier
// Connect private endpoint to data-tier subnet
```

**Expected Result**: Storage account with `publicNetworkAccess: 'Disabled'`, private endpoint resource.

---

### Blob Container with Immutability Policy

```bicep
// Create a blob container with immutable storage (WORM)
// Set retention period to 365 days
```

**Expected Result**: Blob container with `immutableStorageWithVersioning` property.

---

## Compute

### Virtual Machine (Linux)

```bicep
// Create an Ubuntu 22.04 LTS virtual machine
// Use Standard_B2s SKU
// Deploy to app-tier subnet
// Use SSH key authentication (no password)
// Attach managed disk for data (128 GB Premium SSD)
```

**Expected Result**: VM resource, NIC, OS disk, data disk, public key authentication.

**Tips**:

- Specify OS version clearly
- Mention subnet for placement
- Copilot will add networkProfile, storageProfile automatically

---

### Virtual Machine Scale Set

```bicep
// Create a Virtual Machine Scale Set with 3-10 instances
// Use autoscale based on CPU > 70%
// Deploy to web-tier subnet with load balancer
```

**Expected Result**: VMSS resource, autoscale settings, load balancer with backend pool.

---

### Azure Container Instances

```bicep
// Create an Azure Container Instance running nginx:latest
// Expose port 80 with public IP
// Use 1 CPU and 1.5 GB memory
```

**Expected Result**: Container group with container definition, ports, resources.

---

## Monitoring

### Log Analytics Workspace

```bicep
// Create a Log Analytics workspace
// Set retention to 90 days
// Use PerGB2018 pricing tier
```

**Expected Result**: Log Analytics workspace with correct SKU and retention.

---

### Diagnostic Settings for Storage Account

```bicep
// Add diagnostic settings for the storage account
// Send all logs and metrics to Log Analytics workspace
// Include blob, file, queue, and table services
```

**Expected Result**: Multiple `diagnosticSettings` resources for storage account and sub-services.

**Tips**:

- Specify which logs/metrics categories
- Mention destination (Log Analytics, Storage, Event Hub)
- Copilot knows service-specific log categories

---

### Application Insights

```bicep
// Create an Application Insights resource
// Connect it to the Log Analytics workspace
// Use workspace-based retention
```

**Expected Result**: Application Insights with `WorkspaceResourceId` property.

---

## Prompt Engineering Tips

### 🎯 Be Specific

**Bad**: "Create a VNet"  
**Good**: "Create a VNet named 'vnet-prod' with address space 10.0.0.0/16 and three subnets"

**Why**: Copilot generates more accurate code with specific requirements.

---

### 🔄 Use Iterative Refinement

**Step 1**: "Create a storage account"  
**Step 2**: "Add HTTPS only and TLS 1.2"  
**Step 3**: "Disable public blob access"  
**Step 4**: "Enable soft delete with 7-day retention"

**Why**: Building complexity gradually helps Copilot understand context.

---

### 📝 Describe Intent, Not Syntax

**Bad**: "Add a properties object with addressSpace containing an array of addressPrefixes"  
**Good**: "Add address space 10.0.0.0/16 to the virtual network"

**Why**: Copilot excels at understanding natural language intent.

---

### 🔒 Mention Security Requirements

**Always include**: "secure", "HTTPS only", "TLS 1.2", "no public access", "encrypted"

**Why**: Copilot will generate secure defaults but explicit requirements are clearer.

---

### 🏷️ Use Azure Terminology

**Use**: "Network Security Group", "subnet", "address prefix", "SKU"  
**Avoid**: "firewall" (unless you mean Azure Firewall), "network", "size"

**Why**: Azure-specific terms help Copilot generate correct resource types.

---

### 🧩 Break Complex Tasks into Smaller Prompts

**Instead of**: "Create a complete three-tier app with VNet, NSGs, VMs, load balancer, storage, and monitoring"

**Do this**:

1. "Create VNet with three subnets"
2. "Add NSGs for each subnet with appropriate rules"
3. "Create VMs in each tier"
4. "Add load balancer for web tier"
5. "Create storage account with private endpoint"
6. "Add Log Analytics and diagnostic settings"

**Why**: Smaller, focused prompts produce more reliable results.

---

### ⚡ Use Comments as Prompts

```bicep
// Resource Group should be in East US
param location string = resourceGroup().location

// Storage account name must be globally unique and lowercase
param storageAccountName string = 'mystorageaccount'
```

**Why**: Copilot reads comments as context and will adjust suggestions.

---

### 🔗 Reference Existing Resources

```bicep
// Use the subnet ID from the network module output
param subnetId string = network.outputs.subnets.data.id
```

**Why**: Copilot understands module outputs and resource references.

---

## Example: Complete Infrastructure with Prompts

Here's a real-world example of building a complete infrastructure using these prompts:

### 1. Start with Network

```bicep
// Create an Azure Virtual Network for production environment
// Address space: 10.0.0.0/16
// Subnets: web (10.0.1.0/24), app (10.0.2.0/24), data (10.0.3.0/24)
```

### 2. Add Security

```bicep
// Add Network Security Groups for each subnet
// Web tier: Allow 80, 443 from Internet
// App tier: Allow 8080 from web tier only
// Data tier: Allow 1433 from app tier only
```

### 3. Add Storage

```bicep
// Create a secure storage account
// HTTPS only, TLS 1.2 minimum, no public blob access
// Enable soft delete (7 days retention)
```

### 4. Add Monitoring

```bicep
// Add Log Analytics workspace
// Configure diagnostic settings for all resources
// Include blob storage logs
```

### 5. Create Outputs

```bicep
// Output VNet ID, subnet IDs, storage account name, and Log Analytics workspace ID
```

---

## Advanced Prompts

### Conditional Resources

```bicep
// Only create the Azure Bastion resource if environment is 'prod'
// Use a condition based on the environment parameter
```

**Expected Result**: Resource with `condition:` property.

---

### Resource Loops

```bicep
// Create 3 storage accounts named st-data01, st-data02, st-data03
// Use a loop with range(1, 3)
```

**Expected Result**: Resource with `for` loop using `range()` function.

---

### Dynamic NSG Rules

```bicep
// Create NSG rules dynamically from an array of port numbers
// Allow inbound on ports 80, 443, 8080 from Internet
```

**Expected Result**: Security rules generated with `for` loop over array.

---

## Troubleshooting Prompts

### When Copilot Doesn't Understand

**Try**: "// I need a [resource type] that [specific requirement]"

**Example**: "// I need a storage account that only allows access from my VNet"

---

### When Suggestions Are Wrong

**Try**: Refining the prompt with more context or breaking it into smaller parts.

**Example**: Instead of "secure storage", use "storage account with HTTPS only, minimum TLS 1.2, disabled public blob access"

---

### When You Need Specific API Version

**Try**: "// Use API version 2023-05-01 for this resource"

**Note**: Usually not needed—Copilot defaults to latest versions.

---

## Additional Resources

- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Resource Reference](https://learn.microsoft.com/azure/templates/)
- [Bicep Best Practices](https://learn.microsoft.com/azure/azure-resource-manager/bicep/best-practices)
- [GitHub Copilot for Azure](https://learn.microsoft.com/azure/developer/github/github-copilot-azure)

---

**💡 Pro Tip**: Save your successful prompts in a personal library. Over time, you'll build a collection of prompts that work well for your specific scenarios.

[🏠 Back to Demo README](../README.md) | [📚 View Prompt Patterns](./prompt-patterns.md)
