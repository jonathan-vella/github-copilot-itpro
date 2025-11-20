# Effective Prompts for PowerShell Azure Automation

This document contains production-tested prompts for generating Azure PowerShell automation scripts using GitHub Copilot. These prompts consistently produce high-quality, maintainable PowerShell code with proper error handling.

---

## 📋 Table of Contents

1. [Script Structure](#script-structure)
2. [Azure Resource Management](#azure-resource-management)
3. [Reporting and Auditing](#reporting-and-auditing)
4. [Bulk Operations](#bulk-operations)
5. [Error Handling](#error-handling)
6. [Advanced Patterns](#advanced-patterns)
7. [Prompt Engineering Tips](#prompt-engineering-tips)

---

## Script Structure

### Script Header with Help

```powershell
# Create a PowerShell function to get Azure resource information
# Include comment-based help with SYNOPSIS, DESCRIPTION, PARAMETER, and EXAMPLE sections
# Add CmdletBinding and parameter validation
```

**Expected Result**: Complete function structure with proper help documentation.

**Tips**:

- Copilot generates `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE` automatically
- Include `[CmdletBinding()]` for advanced function features
- Use proper verb-noun naming (Get-, Set-, New-, Remove-)

---

### Parameter Validation

```powershell
# Add parameters for SubscriptionId (mandatory), ResourceGroupName (optional), and OutputPath (with file validation)
# Include ValidateNotNullOrEmpty for mandatory parameters
# Add ValidateScript to check if output directory exists
```

**Expected Result**: Parameters with proper validation attributes.

**Example**:

```powershell
[Parameter(Mandatory = $true)]
[ValidateNotNullOrEmpty()]
[string]$SubscriptionId
```

---

### Script Configuration

```powershell
# Set strict mode to latest version
# Set error action preference to Stop
# Define color constants for console output (Green for success, Red for errors, Yellow for warnings)
```

**Expected Result**: Standard script initialization with error handling configuration.

---

## Azure Resource Management

### Connect to Azure

```powershell
# Create a function to connect to Azure and select the specified subscription
# Check if already connected
# Handle connection errors with try-catch
# Display connected account and subscription details
```

**Expected Result**: Connection function with authentication check and error handling.

---

### Get All Resources in Subscription

```powershell
# Get all Azure resources in the current subscription
# Include resource name, type, location, and resource group
# Use Get-AzResource cmdlet
# Handle pagination for large result sets
```

**Expected Result**: Resource retrieval with proper properties selection.

---

### Filter Resources by Tag

```powershell
# Find all Azure resources missing required tags (Environment, Owner, CostCenter)
# Return resources that don't have all three tags
# Group results by resource group
```

**Expected Result**: Tag compliance filtering with grouping logic.

---

### Get Resource Cost Information

```powershell
# Query Azure Cost Management API to get resource costs for the last 30 days
# Group by resource group and resource type
# Calculate total costs and display top 10 most expensive resources
```

**Expected Result**: Cost query using `Get-AzConsumptionUsageDetail` with aggregation.

---

## Reporting and Auditing

### Generate Resource Inventory Report

```powershell
# Create a report of all Azure resources with these columns:
# - ResourceName, ResourceType, ResourceGroup, Location, Tags, CreatedDate
# Export to CSV file with timestamp in filename
# Display summary statistics (total resources, resource types count, locations count)
```

**Expected Result**: Comprehensive inventory script with CSV export and statistics.

**Tips**:

- Use `Export-Csv` with `-NoTypeInformation`
- Add timestamp to filenames: `"Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"`
- Include `Write-Progress` for large datasets

---

### Compliance Audit Report

```powershell
# Audit Azure resources for compliance issues:
# - Missing required tags
# - Resources in non-approved locations
# - Storage accounts without HTTPS-only enabled
# - VMs without backup configured
# Generate HTML report with color-coded findings (red for critical, yellow for warnings)
```

**Expected Result**: Multi-check compliance script with HTML report generation.

---

### Orphaned Resource Detection

```powershell
# Find orphaned Azure resources:
# - Unattached managed disks
# - Unused public IP addresses (not associated with any resource)
# - Unused network interfaces
# - Empty resource groups
# Display potential monthly savings for each category
```

**Expected Result**: Orphaned resource detection with cost analysis.

---

### Activity Log Analysis

```powershell
# Analyze Azure Activity Log for the last 7 days
# Find failed operations grouped by operation name
# Include caller, timestamp, and error details
# Export to JSON for further analysis
```

**Expected Result**: Activity log query with filtering and export.

---

## Bulk Operations

### Bulk Tag Application

```powershell
# Apply tags to multiple Azure resources based on resource group name pattern
# Parameters: ResourceGroupPattern, Tags (hashtable)
# Use -WhatIf parameter to preview changes before applying
# Include progress bar for batch operations
# Log all changes to a file
```

**Expected Result**: Bulk tagging script with WhatIf support and logging.

**Tips**:

- Use `[CmdletBinding(SupportsShouldProcess)]` for WhatIf support
- Include `$PSCmdlet.ShouldProcess()` before making changes
- Use `Write-Progress` to show operation progress

---

### Bulk VM Start/Stop

```powershell
# Start or stop multiple VMs based on tag filter
# Parameters: Tag name, Tag value, Action (Start/Stop)
# Run operations in parallel using ForEach-Object -Parallel
# Handle failures and report which VMs succeeded/failed
# Include estimated time remaining
```

**Expected Result**: Parallel VM operations with error tracking.

---

### Bulk Resource Group Cleanup

```powershell
# Remove empty resource groups or resource groups matching a pattern
# Parameters: NamePattern, MinimumAgeInDays, Force
# Check if resource group is empty
# Verify resource group age before deletion
# Prompt for confirmation unless -Force is specified
# Generate deletion report
```

**Expected Result**: Safe bulk deletion script with multiple safeguards.

---

### Bulk NSG Rule Updates

```powershell
# Update Network Security Group rules across multiple NSGs
# Add or remove a security rule from all NSGs in specified resource groups
# Parameters: ResourceGroups, RuleName, Priority, Direction, Access, Protocol, Port
# Validate that priority doesn't conflict with existing rules
# Use transactions (roll back on failure)
```

**Expected Result**: NSG bulk update with conflict detection and rollback.

---

## Error Handling

### Try-Catch with Detailed Logging

```powershell
# Wrap Azure operations in try-catch blocks
# Log errors to a file with timestamp
# Display user-friendly error messages
# Continue processing remaining items after an error
# Maintain error counter and display summary at end
```

**Expected Result**: Robust error handling with logging and summary.

---

### Retry Logic for Transient Failures

```powershell
# Implement retry logic for Azure API calls
# Retry up to 3 times with exponential backoff (2s, 4s, 8s)
# Catch specific exceptions like 429 (Too Many Requests)
# Log each retry attempt
```

**Expected Result**: Retry mechanism with backoff strategy.

**Example**:

```powershell
# Retry Azure operation up to 3 times with exponential backoff
# Handle TooManyRequests and ServiceUnavailable errors
```

---

### Input Validation

```powershell
# Validate Azure subscription ID format (GUID)
# Validate resource group name follows Azure naming rules
# Validate file paths exist before reading
# Provide helpful error messages for validation failures
```

**Expected Result**: Parameter validation with custom validators.

---

## Advanced Patterns

### Parallel Processing

```powershell
# Process multiple subscriptions in parallel
# Use ForEach-Object -Parallel -ThrottleLimit 5
# Collect results from parallel jobs
# Handle errors in parallel execution
```

**Expected Result**: Parallel processing with throttling and error handling.

---

### Pipeline Support

```powershell
# Create a function that accepts pipeline input
# Support ValueFromPipeline and ValueFromPipelineByPropertyName
# Process each object in the pipeline with Begin, Process, End blocks
```

**Expected Result**: Pipeline-enabled function with proper parameter binding.

**Example**:

```powershell
# Create function Get-AzResourceDetails that accepts resource objects from pipeline
# Support: Get-AzResource | Get-AzResourceDetails
```

---

### Progress Reporting

```powershell
# Add progress bars for long-running operations
# Use Write-Progress with PercentComplete
# Include CurrentOperation and Status information
# Clear progress bar when complete
```

**Expected Result**: User-friendly progress indicators.

---

### Custom Object Output

```powershell
# Return custom PowerShell objects with specific properties
# Use [PSCustomObject] for consistent output
# Include calculated properties
# Support Format-Table and Format-List for display
```

**Expected Result**: Structured output objects.

**Example**:

```powershell
# Return custom object with ResourceName, ResourceType, Status, Cost properties
# Calculate cost per day as a computed property
```

---

### JSON Configuration File

```powershell
# Load configuration from JSON file
# Parameters: ConfigPath with default value
# Validate JSON structure after loading
# Provide sample JSON structure in help
```

**Expected Result**: Configuration file support with validation.

---

## Prompt Engineering Tips

### 🎯 Be Specific About Azure Cmdlets

**Bad**: "Get resources"  
**Good**: "Use Get-AzResource to retrieve all resources in subscription with name, type, and tags"

**Why**: Copilot knows which Azure PowerShell cmdlet to use.

---

### 🔄 Specify Error Handling Requirements

**Always include**: "Add try-catch error handling", "Log errors to file", "Display user-friendly messages"

**Why**: Copilot generates production-ready error handling.

---

### 📊 Request Output Format

**Be explicit**: "Export to CSV", "Generate HTML report", "Return PSCustomObject"

**Why**: Copilot structures output correctly for the format.

---

### 🛡️ Mention Parameter Validation

**Include**: "Validate subscription ID is GUID", "Check if path exists", "Ensure date is in past"

**Why**: Copilot adds appropriate validation attributes.

---

### ⚡ Specify Performance Requirements

**For large datasets**: "Add progress bar", "Process in batches of 100", "Use parallel processing"

**Why**: Copilot optimizes for scale.

---

### 📝 Request Help Documentation

**Always start with**: "Create function with comment-based help including examples"

**Why**: Copilot generates complete help documentation.

---

### 🔗 Use Azure Terminology

**Use**: "subscription", "resource group", "managed disk", "NSG", "RBAC"  
**Avoid**: "folder", "container", "hard drive", "firewall", "permissions"

**Why**: Azure-specific terms improve suggestion accuracy.

---

### 🧩 Break Complex Scripts into Functions

**Instead of**: "Create script that does A, B, C, D, and E"

**Do this**:

1. "Create function to do A"
2. "Create function to do B"
3. "Create main function that calls A and B"

**Why**: Smaller prompts produce more accurate results.

---

## Example: Complete Script with Prompts

Here's how to build a complete resource management script using these prompts:

### 1. Start with Function Header

```powershell
# Create a PowerShell function named Get-AzResourceInventory
# Include comment-based help with synopsis, description, parameters, and examples
# Add CmdletBinding for advanced function support
```

### 2. Add Parameters

```powershell
# Add parameters:
# - SubscriptionId (mandatory, validate GUID format)
# - ResourceGroupName (optional)
# - OutputPath (optional, default to current directory, validate path exists)
# - IncludeCost (switch parameter to include cost data)
```

### 3. Add Authentication

```powershell
# Connect to Azure and select the specified subscription
# Check if already connected to avoid redundant authentication
# Display connected account and subscription information
```

### 4. Get Resources

```powershell
# Get all Azure resources in the subscription
# If ResourceGroupName is specified, filter to that resource group
# Include resource name, type, location, resource group, and tags
```

### 5. Add Cost Data (if requested)

```powershell
# If IncludeCost switch is enabled, query cost data for each resource
# Use Get-AzConsumptionUsageDetail for last 30 days
# Group costs by resource ID and calculate total
```

### 6. Generate Report

```powershell
# Create custom objects with all collected data
# Export to CSV file with timestamp in filename
# Display summary: total resources, total cost, resource types breakdown
# Return the CSV file path
```

### 7. Add Error Handling

```powershell
# Wrap all operations in try-catch blocks
# Log errors to a file named "errors_timestamp.log"
# Continue processing after errors
# Display error summary at the end
```

---

## Advanced Prompts

### Working with Azure Resource Graph

```powershell
# Query Azure Resource Graph using KQL query
# Get all VMs with their OS type, size, and location
# Include resources across all subscriptions the user has access to
# Handle pagination for results > 1000 items
```

**Expected Result**: Resource Graph query with pagination.

---

### Managing Azure Policy

```powershell
# Get all Azure Policy assignments in subscription
# Show assignment name, policy definition, scope, and compliance state
# Filter to show only non-compliant assignments
# Export to JSON with details of non-compliant resources
```

**Expected Result**: Policy compliance reporting script.

---

### Azure AD Integration

```powershell
# Get Azure AD users who have Owner or Contributor role on subscription
# Include user display name, email, role definition, and assignment scope
# Use Get-AzRoleAssignment cmdlet
# Group by role definition
```

**Expected Result**: RBAC assignment reporting with grouping.

---

### Resource Locks Management

```powershell
# Find all Azure resources without a resource lock
# Check for ReadOnly or CanNotDelete locks
# Report resources that should have locks based on naming convention (prod-*)
# Provide command to add locks to each resource
```

**Expected Result**: Lock compliance checking with remediation commands.

---

### Backup Status Verification

```powershell
# Check backup status for all VMs in subscription
# Use Get-AzRecoveryServicesBackupItem
# Report VMs without backup configured
# Include last backup date for protected VMs
# Calculate backup storage cost
```

**Expected Result**: Backup compliance report with cost.

---

## Troubleshooting Prompts

### When Copilot Uses Wrong Cmdlet

**Try**: "Use the Az module cmdlet Get-AzResource, not the legacy AzureRM cmdlet"

**Why**: Specifies the exact cmdlet module.

---

### When Output Format is Wrong

**Try**: "Return PSCustomObject with properties: Name, Type, Location (not a hashtable)"

**Why**: Specifies exact object type and properties.

---

### When Error Handling is Missing

**Try**: "Add try-catch around all Azure cmdlets with proper error logging and user-friendly messages"

**Why**: Explicitly requests error handling.

---

### When Performance is Poor

**Try**: "Use Select-Object to return only needed properties, not entire objects. Process in batches of 100 resources."

**Why**: Adds performance optimizations.

---

## Additional Resources

- [Azure PowerShell Documentation](https://learn.microsoft.com/powershell/azure/)
- [PowerShell Best Practices](https://learn.microsoft.com/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines)
- [Az Module Reference](https://learn.microsoft.com/powershell/module/az)
- [GitHub Copilot for PowerShell](https://github.blog/2023-11-08-universe-2023-copilot-transforms-github-into-the-ai-powered-developer-platform/)

---

**💡 Pro Tip**: Start each script with a clear comment describing the overall goal. Copilot uses this context to generate more relevant suggestions throughout the entire file.

[🏠 Back to Demo README](../README.md) | [📚 View Prompt Patterns](./prompt-patterns.md)
