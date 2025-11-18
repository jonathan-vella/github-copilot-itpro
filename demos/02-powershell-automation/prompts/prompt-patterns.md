# Reusable PowerShell Prompt Patterns for Azure Automation

This document provides reusable prompt templates for common Azure PowerShell automation scenarios. Copy these patterns and customize the placeholders to match your specific requirements.

---

## 📋 Table of Contents

1. [How to Use These Patterns](#how-to-use-these-patterns)
2. [Function Structure Patterns](#function-structure-patterns)
3. [Azure Resource Patterns](#azure-resource-patterns)
4. [Reporting Patterns](#reporting-patterns)
5. [Bulk Operations Patterns](#bulk-operations-patterns)
6. [Error Handling Patterns](#error-handling-patterns)
7. [Advanced Patterns](#advanced-patterns)
8. [Quick Reference](#quick-reference)

---

## How to Use These Patterns

1. **Copy the pattern** that matches your scenario
2. **Replace placeholders** in `{curly braces}` with your values
3. **Paste as a comment** in your PowerShell file
4. **Let Copilot generate** the code
5. **Review and adjust** the suggestions

**Example**:

```powershell
Pattern: # Create function {FunctionName} to {purpose}
Your use: # Create function Get-UntaggedResources to find resources missing required tags
```

---

## Function Structure Patterns

### Basic Function Pattern

```powershell
# Create a PowerShell function named {FunctionName}
# Include comment-based help with SYNOPSIS, DESCRIPTION, PARAMETER, and EXAMPLE sections
# Add [CmdletBinding()] for advanced function features
# {optional: Add SupportsShouldProcess for WhatIf support}
```

**Example**:

```powershell
# Create a PowerShell function named Get-AzResourceCost
# Include comment-based help with SYNOPSIS, DESCRIPTION, PARAMETER, and EXAMPLE sections
# Add [CmdletBinding()] for advanced function features
# Add SupportsShouldProcess for WhatIf support
```

---

### Parameter Block Pattern

```powershell
# Add parameters:
# - {Parameter1Name} ({mandatory/optional}, {type}, {validation})
# - {Parameter2Name} ({mandatory/optional}, {type}, {validation})
# - {Parameter3Name} ({mandatory/optional}, {type}, {validation})
# {optional: Add parameter sets for mutually exclusive parameters}
```

**Example**:

```powershell
# Add parameters:
# - SubscriptionId (mandatory, string, validate GUID format)
# - ResourceGroupName (optional, string, validate Azure naming rules)
# - OutputPath (optional, string, validate path exists, default to current directory)
# - IncludeCost (optional, switch parameter)
```

---

### Script Initialization Pattern

```powershell
# Set strict mode to latest version
# Set error action preference to {Stop/Continue/SilentlyContinue}
# Define color constants for console output (Success, Warning, Error, Info)
# {optional: Initialize logging to file}
```

**Example**:

```powershell
# Set strict mode to latest version
# Set error action preference to Stop
# Define color constants for console output (Success, Warning, Error, Info)
# Initialize logging to file "script-log.txt" with timestamp
```

---

## Azure Resource Patterns

### Connect to Azure Pattern

```powershell
# Create function to connect to Azure
# Check if already connected using Get-AzContext
# If not connected, call Connect-AzAccount
# Select subscription {SubscriptionId}
# Display connected account, subscription name, and tenant ID
# Handle connection errors with try-catch
```

**Example**:

```powershell
# Create function to connect to Azure
# Check if already connected using Get-AzContext
# If not connected, call Connect-AzAccount
# Select subscription "00000000-0000-0000-0000-000000000000"
# Display connected account, subscription name, and tenant ID
# Handle connection errors with try-catch
```

---

### Get Resources Pattern

```powershell
# Get all {resourceType} in {scope: subscription / resource group / multiple subscriptions}
# {optional: Filter by tag: {tagName} = {tagValue}}
# Include properties: {property1}, {property2}, {property3}
# {optional: Sort by {property}}
# {optional: Select first {number} results}
```

**Example**:

```powershell
# Get all virtual machines in subscription
# Filter by tag: Environment = Production
# Include properties: Name, Location, PowerState, VmSize, OsType
# Sort by Name
```

---

### Filter Resources by Criteria Pattern

```powershell
# Find all {resourceType} that meet these criteria:
# - {criterion1}
# - {criterion2}
# - {criterion3}
# Return as array of PSCustomObjects with properties: {properties}
```

**Example**:

```powershell
# Find all storage accounts that meet these criteria:
# - Do not have HTTPS-only enabled
# - Allow public blob access
# - Located in regions: eastus, westus
# Return as array of PSCustomObjects with properties: Name, ResourceGroup, Location, HttpsOnly, AllowBlobPublicAccess
```

---

### Query Resource Graph Pattern

```powershell
# Use Search-AzGraph to query Azure Resource Graph
# KQL query: {your KQL query}
# Handle pagination for results > {page size}
# {optional: Query across all accessible subscriptions}
# Return results as array
```

**Example**:

```powershell
# Use Search-AzGraph to query Azure Resource Graph
# KQL query: Resources | where type == "microsoft.compute/virtualmachines" | project name, location, properties.hardwareProfile.vmSize
# Handle pagination for results > 1000
# Query across all accessible subscriptions
# Return results as array
```

---

## Reporting Patterns

### CSV Report Pattern

```powershell
# Generate CSV report for {resource type / scenario}
# Include columns: {column1}, {column2}, {column3}, ...
# Export to file: {filename pattern with timestamp}
# Display summary statistics: {statistic1}, {statistic2}
# {optional: Send email with report as attachment}
```

**Example**:

```powershell
# Generate CSV report for untagged resources
# Include columns: ResourceName, ResourceType, ResourceGroup, Location, MissingTags
# Export to file: "UntaggedResources_YYYYMMDD_HHMMSS.csv"
# Display summary statistics: Total resources, Resources per type, Resources per location
```

---

### HTML Report Pattern

```powershell
# Generate HTML report for {scenario}
# Include sections: {section1}, {section2}, {section3}
# Use color coding: {color1} for {status1}, {color2} for {status2}
# Add CSS styling for professional appearance
# Include charts: {chart type} showing {data}
# {optional: Embed images/logos}
# Save to file: {filename}
```

**Example**:

```powershell
# Generate HTML report for compliance audit
# Include sections: Executive Summary, Critical Issues, Warnings, Recommendations
# Use color coding: Red for critical, Yellow for warnings, Green for compliant
# Add CSS styling for professional appearance
# Include charts: Pie chart showing compliance percentage by category
# Save to file: "ComplianceReport.html"
```

---

### JSON Export Pattern

```powershell
# Export {data description} to JSON file
# Convert objects to JSON with depth {depth}
# Pretty-print with indentation
# Save to file: {filename}
# {optional: Compress JSON file}
```

**Example**:

```powershell
# Export resource inventory to JSON file
# Convert objects to JSON with depth 5
# Pretty-print with indentation
# Save to file: "ResourceInventory.json"
```

---

### Dashboard Data Pattern

```powershell
# Collect dashboard metrics for {scenario}
# Calculate: {metric1}, {metric2}, {metric3}
# Format as PSCustomObject with properties matching dashboard schema
# {optional: Upload to {destination: Log Analytics / Storage / API endpoint}}
```

**Example**:

```powershell
# Collect dashboard metrics for cost monitoring
# Calculate: TotalCost, CostByResourceGroup, CostTrend (7 days), TopCostResources (10)
# Format as PSCustomObject with properties matching dashboard schema
# Upload to Log Analytics workspace
```

---

## Bulk Operations Patterns

### Bulk Tag Assignment Pattern

```powershell
# Apply tags to {resource type / all resources} matching {filter criteria}
# Tags to apply: {tag1} = {value1}, {tag2} = {value2}
# Parameters: {parameters}
# Add [CmdletBinding(SupportsShouldProcess)] for WhatIf support
# Include progress bar showing {current}/{total} resources
# Log all changes to file: {logfile}
# Handle errors: {error handling strategy}
# Return summary: {success count}, {failure count}, {skipped count}
```

**Example**:

```powershell
# Apply tags to all resources in resource groups matching pattern "rg-prod-*"
# Tags to apply: Environment = Production, ManagedBy = DevOps, CostCenter = 12345
# Parameters: ResourceGroupPattern, Tags (hashtable), LogPath
# Add [CmdletBinding(SupportsShouldProcess)] for WhatIf support
# Include progress bar showing current/total resources
# Log all changes to file: "TagChanges.log"
# Handle errors: Continue on error, collect failures
# Return summary: Success count, Failure count, Skipped count
```

---

### Bulk Start/Stop VMs Pattern

```powershell
# {Action: Start / Stop / Restart} VMs matching {filter criteria}
# Parameters: {parameters}
# Process VMs in parallel using ForEach-Object -Parallel -ThrottleLimit {limit}
# Add progress tracking with estimated time remaining
# Handle already {running/stopped} VMs gracefully
# Collect results: {success list}, {failure list with reasons}
# Display summary table at completion
```

**Example**:

```powershell
# Stop VMs matching tag Environment = Development
# Parameters: TagName, TagValue, WaitForCompletion (switch)
# Process VMs in parallel using ForEach-Object -Parallel -ThrottleLimit 10
# Add progress tracking with estimated time remaining
# Handle already stopped VMs gracefully
# Collect results: Success list, Failure list with reasons
# Display summary table at completion
```

---

### Bulk Resource Deletion Pattern

```powershell
# Remove {resource type} matching {criteria}
# Parameters: {parameters including Force switch}
# Add safety checks: {check1}, {check2}
# Require confirmation unless -Force is specified
# {optional: Create backup/snapshot before deletion}
# Process deletions {serially / in parallel}
# Log all deletions with timestamp
# Return list of deleted resources and any failures
```

**Example**:

```powershell
# Remove unattached managed disks older than 90 days
# Parameters: MinimumAgeInDays, ResourceGroupName (optional), Force (switch), BackupFirst (switch)
# Add safety checks: Verify disk is not attached, Verify age, Verify not in excluded RG list
# Require confirmation unless -Force is specified
# Create snapshot before deletion if BackupFirst is specified
# Process deletions serially to control load
# Log all deletions with timestamp to "DiskDeletions.log"
# Return list of deleted resources and any failures
```

---

### Bulk Update Pattern

```powershell
# Update {property/configuration} for {resource type} matching {criteria}
# Current value: {old value pattern}
# New value: {new value pattern}
# Parameters: {parameters}
# Add validation before update: {validation checks}
# Use transactions (rollback on failure)
# Include dry-run mode with -WhatIf
# Track changes in changelog
```

**Example**:

```powershell
# Update minimum TLS version for storage accounts to TLS1_2
# Current value: TLS1_0 or TLS1_1
# New value: TLS1_2
# Parameters: ResourceGroupName (optional), ExcludeStorageAccounts (array)
# Add validation before update: Check storage account is not locked, Verify no active connections on old TLS
# Use transactions (rollback on failure)
# Include dry-run mode with -WhatIf
# Track changes in "TLS_Updates.log"
```

---

## Error Handling Patterns

### Try-Catch with Logging Pattern

```powershell
# Wrap {operation} in try-catch block
# In catch block:
#   - Log error to file "{logfile}" with timestamp and full exception details
#   - Display user-friendly error message
#   - {Continue processing / Exit / Retry}
# Maintain error counter
# Display error summary at end: Total errors, Error types
```

**Example**:

```powershell
# Wrap Get-AzResource operation in try-catch block
# In catch block:
#   - Log error to file "errors.log" with timestamp and full exception details
#   - Display user-friendly error message
#   - Continue processing remaining subscriptions
# Maintain error counter
# Display error summary at end: Total errors, Error types
```

---

### Retry Logic Pattern

```powershell
# Implement retry logic for {operation}
# Retry up to {max attempts} times
# Use {backoff strategy: exponential / linear / fixed} backoff ({timing details})
# Catch specific exceptions: {exception1}, {exception2}
# Log each retry attempt with attempt number
# Throw exception after all retries exhausted
```

**Example**:

```powershell
# Implement retry logic for Get-AzVM API call
# Retry up to 5 times
# Use exponential backoff (1s, 2s, 4s, 8s, 16s)
# Catch specific exceptions: TooManyRequestsException, ServiceUnavailableException
# Log each retry attempt with attempt number to console
# Throw exception after all retries exhausted
```

---

### Input Validation Pattern

```powershell
# Validate input parameter {ParameterName}:
# - Check format: {format requirement}
# - Check range: {range requirement}
# - Check existence: {existence check}
# If validation fails: {Throw error / Return $false / Display warning}
# Error message: {error message template}
```

**Example**:

```powershell
# Validate input parameter SubscriptionId:
# - Check format: Must be valid GUID
# - Check existence: Subscription must exist and be accessible
# - Check permission: User must have at least Reader role
# If validation fails: Throw terminating error with descriptive message
# Error message: "Invalid subscription ID '{value}'. {reason}"
```

---

## Advanced Patterns

### Parallel Processing Pattern

```powershell
# Process {items} in parallel
# Use ForEach-Object -Parallel -ThrottleLimit {limit}
# Pass variables to parallel scriptblock: {var1}, {var2}
# Collect results using thread-safe collection
# Handle errors in parallel execution (log to shared error collection)
# Wait for all jobs to complete before proceeding
# Display combined results
```

**Example**:

```powershell
# Process subscriptions in parallel
# Use ForEach-Object -Parallel -ThrottleLimit 5
# Pass variables to parallel scriptblock: $LogPath, $RequiredTags
# Collect results using synchronized hashtable
# Handle errors in parallel execution (add to synchronized error list)
# Wait for all jobs to complete before proceeding
# Display combined results sorted by subscription name
```

---

### Pipeline Support Pattern

```powershell
# Create function {FunctionName} that accepts pipeline input
# Support ValueFromPipeline for parameter {ParameterName}
# Use Begin, Process, End blocks
# In Process block: Handle each pipeline object
# {optional: Support ValueFromPipelineByPropertyName for {PropertyName}}
# Return results that can be piped to next cmdlet
```

**Example**:

```powershell
# Create function Get-ResourceTags that accepts pipeline input
# Support ValueFromPipeline for parameter ResourceId
# Use Begin, Process, End blocks
# In Process block: Get resource details and extract tags
# Support ValueFromPipelineByPropertyName for Id property
# Return PSCustomObject that can be piped to Export-Csv
```

---

### Progress Reporting Pattern

```powershell
# Add progress bar for {operation}
# Use Write-Progress with these properties:
#   - Activity: {activity description}
#   - Status: {status format}
#   - PercentComplete: {calculation}
#   - CurrentOperation: {current item}
# Update progress every {interval}
# Clear progress bar when complete: Write-Progress -Completed
```

**Example**:

```powershell
# Add progress bar for resource processing loop
# Use Write-Progress with these properties:
#   - Activity: "Processing Azure Resources"
#   - Status: "Processing resource $current of $total"
#   - PercentComplete: ($current / $total) * 100
#   - CurrentOperation: "Current resource: $resourceName"
# Update progress for each resource
# Clear progress bar when complete: Write-Progress -Completed
```

---

### Configuration File Pattern

```powershell
# Load configuration from {format: JSON / XML / PSD1} file
# Parameter: ConfigPath (validate file exists, default to {default path})
# Validate required configuration keys: {key1}, {key2}, {key3}
# Provide default values for optional keys
# If configuration invalid: {Throw error / Use defaults / Prompt user}
# Return configuration as PSCustomObject
```

**Example**:

```powershell
# Load configuration from JSON file
# Parameter: ConfigPath (validate file exists, default to "./config.json")
# Validate required configuration keys: SubscriptionId, ResourceGroups, RequiredTags
# Provide default values for optional keys: LogPath (default "./logs"), MaxRetries (default 3)
# If configuration invalid: Throw descriptive error with example config
# Return configuration as PSCustomObject
```

---

### Scheduled Task Pattern

```powershell
# Create function to register scheduled task that runs this script
# Parameters: {TaskName}, {TriggerSchedule}, {Credential}
# Task settings: {run whether user logged in}, {highest privileges}, {retry on failure}
# Task action: Run PowerShell with this script path and parameters: {parameters}
# Trigger: {Daily at time / Weekly on days / On event}
# {optional: Send notification email when task completes}
```

**Example**:

```powershell
# Create function to register scheduled task that runs Get-AzResourceReport.ps1
# Parameters: TaskName (default "DailyResourceReport"), TriggerTime (default 6:00 AM), Credential
# Task settings: Run whether user logged in, Run with highest privileges, Restart on failure up to 3 times
# Task action: Run PowerShell with script path and parameters: -SubscriptionId $subId -OutputPath "C:\Reports"
# Trigger: Daily at specified time
# Send notification email to admin@company.com when task completes
```

---

## Quick Reference Cheat Sheet

### Placeholders Used in Patterns

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{FunctionName}` | PowerShell function name | `Get-AzResourceCost`, `Set-BulkTags` |
| `{ParameterName}` | Parameter name | `SubscriptionId`, `ResourceGroupName` |
| `{resourceType}` | Azure resource type | `virtual machines`, `storage accounts` |
| `{scope}` | Operation scope | `subscription`, `resource group`, `management group` |
| `{property}` | Resource property | `Name`, `Location`, `Tags` |
| `{tagName}` | Tag name | `Environment`, `Owner`, `CostCenter` |
| `{tagValue}` | Tag value | `Production`, `john@company.com`, `12345` |
| `{criteria}` | Filter criteria | `missing tags`, `older than 30 days` |
| `{operation}` | Azure operation | `Get-AzResource`, `Set-AzResource` |
| `{logfile}` | Log file path | `errors.log`, `changes.log` |
| `{number}` | Numeric value | `3`, `10`, `100` |
| `{optional: ...}` | Optional feature | Include if needed |

---

### Common Azure PowerShell Cmdlets

| Category | Cmdlets |
|----------|---------|
| **Authentication** | `Connect-AzAccount`, `Disconnect-AzAccount`, `Get-AzContext`, `Set-AzContext` |
| **Resources** | `Get-AzResource`, `Set-AzResource`, `New-AzResource`, `Remove-AzResource` |
| **Resource Groups** | `Get-AzResourceGroup`, `New-AzResourceGroup`, `Remove-AzResourceGroup` |
| **Tags** | `Get-AzTag`, `New-AzTag`, `Update-AzTag`, `Remove-AzTag` |
| **VMs** | `Get-AzVM`, `Start-AzVM`, `Stop-AzVM`, `Restart-AzVM`, `Remove-AzVM` |
| **Storage** | `Get-AzStorageAccount`, `Set-AzStorageAccount`, `New-AzStorageAccount` |
| **Networking** | `Get-AzVirtualNetwork`, `Get-AzNetworkSecurityGroup`, `Get-AzPublicIpAddress` |
| **Cost** | `Get-AzConsumptionUsageDetail`, `Get-AzConsumptionBudget` |
| **Policy** | `Get-AzPolicyAssignment`, `Get-AzPolicyDefinition`, `Get-AzPolicyState` |
| **RBAC** | `Get-AzRoleAssignment`, `New-AzRoleAssignment`, `Remove-AzRoleAssignment` |

---

## Pattern Combination Example

### Scenario: Complete Resource Audit Script

**Step 1 - Function Structure**

```powershell
# Create a PowerShell function named Invoke-AzResourceAudit
# Include comment-based help with SYNOPSIS, DESCRIPTION, PARAMETER, and EXAMPLE sections
# Add [CmdletBinding()] for advanced function features
```

**Step 2 - Parameters**

```powershell
# Add parameters:
# - SubscriptionId (mandatory, string, validate GUID format)
# - OutputPath (optional, string, default to current directory)
# - IncludeCompliant (optional, switch to include compliant resources in report)
```

**Step 3 - Initialization**

```powershell
# Set strict mode to latest version
# Set error action preference to Stop
# Define color constants for console output (Success, Warning, Error, Info)
# Initialize logging to file with timestamp
```

**Step 4 - Authentication**

```powershell
# Create function to connect to Azure
# Check if already connected using Get-AzContext
# Select subscription from SubscriptionId parameter
# Display connected account and subscription name
# Handle connection errors with try-catch
```

**Step 5 - Data Collection**

```powershell
# Get all Azure resources in subscription
# For each resource, check:
#   - Missing required tags (Environment, Owner, CostCenter)
#   - Location not in approved list (eastus, westus2, centralus)
#   - Resources older than 90 days without Owner tag
# Add progress bar showing current resource / total resources
```

**Step 6 - Analysis**

```powershell
# Group non-compliant resources by issue type
# Calculate compliance percentage
# Identify resource groups with most issues
# Estimate potential cost savings from removing orphaned resources
```

**Step 7 - Reporting**

```powershell
# Generate HTML report for compliance audit
# Include sections: Executive Summary, Critical Issues, Warnings, Recommendations
# Use color coding: Red for critical, Yellow for warnings, Green for compliant
# Add CSS styling for professional appearance
# Include charts: Pie chart showing compliance percentage
# Save to file in OutputPath with timestamp
```

**Step 8 - Error Handling**

```powershell
# Wrap all operations in try-catch blocks
# Log errors to file with timestamp and full exception details
# Display user-friendly error messages
# Display error summary at end showing total errors and types
```

---

## Tips for Customizing Patterns

1. **Start with the closest pattern** and modify details
2. **Combine multiple patterns** for complex scenarios
3. **Be specific about Azure resource types** and properties
4. **Always include error handling** patterns
5. **Test with small datasets first** before processing production data
6. **Use WhatIf** for any operations that make changes
7. **Document your customizations** in comments

---

## Additional Resources

- [Effective Prompts](./effective-prompts.md) - Detailed examples and explanations
- [PowerShell Best Practices](https://learn.microsoft.com/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines)
- [Azure PowerShell Module](https://learn.microsoft.com/powershell/azure/)
- [PowerShell Approved Verbs](https://learn.microsoft.com/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)

---

[🏠 Back to Demo README](../README.md) | [💡 View Effective Prompts](./effective-prompts.md)
