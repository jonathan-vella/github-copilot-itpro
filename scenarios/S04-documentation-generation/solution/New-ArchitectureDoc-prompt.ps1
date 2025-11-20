<#
.SYNOPSIS
    Generates Azure architecture documentation using GitHub Copilot.

.DESCRIPTION
    Scans Azure resources and generates a structured prompt for GitHub Copilot Chat
    to create comprehensive architecture documentation with diagrams, network topology,
    and cost analysis.
    
    Demonstrates how Copilot reduces architecture documentation from 6 hours to 20 minutes (95% faster).

.PARAMETER ResourceGroupName
    Name of the resource group to document.

.PARAMETER OutputPath
    Directory path for generated prompt. Default: current directory.

.PARAMETER IncludeDiagrams
    Request Mermaid diagrams for architecture visualization.

.PARAMETER IncludeNetworkTopology
    Request detailed network topology documentation.

.PARAMETER IncludeCostAnalysis
    Request cost breakdown by resource.

.PARAMETER CopyToClipboard
    Copy the generated Copilot prompt to clipboard.

.EXAMPLE
    New-ArchitectureDoc -ResourceGroupName "rg-production" -OutputPath ".\output" -IncludeDiagrams -CopyToClipboard

.NOTES
    Author: Generated with GitHub Copilot
    Time Savings: 6 hours → 20 minutes (95% faster)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".",

    [Parameter(Mandatory = $false)]
    [switch]$IncludeDiagrams,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeNetworkTopology,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeCostAnalysis,

    [Parameter(Mandatory = $false)]
    [switch]$CopyToClipboard
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = 'Info')
    $colors = @{ 'Info' = 'Cyan'; 'Success' = 'Green'; 'Warning' = 'Yellow'; 'Error' = 'Red' }
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor $colors[$Level]
}

Write-Log "Starting architecture documentation prompt generation..." -Level Info

# Check Azure authentication
$context = Get-AzContext
if (-not $context) {
    throw "Not authenticated to Azure. Run 'Connect-AzAccount' first."
}

Write-Log "Connected to subscription: $($context.Subscription.Name)" -Level Success

# Get resource inventory
Write-Log "Discovering resources in '$ResourceGroupName'..."
$resources = Get-AzResource -ResourceGroupName $ResourceGroupName

if ($resources.Count -eq 0) {
    Write-Log "No resources found in resource group." -Level Warning
    return
}

Write-Log "Found $($resources.Count) resource(s)" -Level Success

# Group by resource type
$grouped = $resources | Group-Object -Property ResourceType | Sort-Object Count -Descending

Write-Log "Resource breakdown:" -Level Info
foreach ($group in $grouped) {
    Write-Log "  - $($group.Count)x $($group.Name)" -Level Info
}

# Build resource summary for prompt
$resourceSummary = ""
foreach ($group in $grouped) {
    $resourceSummary += "- **$($group.Name)** ($($group.Count) instance(s))`n"
    foreach ($resource in $group.Group) {
        $resourceSummary += "  - Name: ``$($resource.Name)``"
        if ($resource.Sku) {
            $resourceSummary += ", SKU: ``$($resource.Sku.Name)``"
        }
        if ($resource.Location) {
            $resourceSummary += ", Location: ``$($resource.Location)``"
        }
        $resourceSummary += "`n"
    }
}

# Build Copilot prompt
$prompt = @"
# Generate Azure Architecture Documentation

Please create comprehensive **Architecture Documentation** for the following Azure resources in resource group **$ResourceGroupName**:

## Deployed Resources

$resourceSummary

## Required Documentation Sections

### 1. Executive Summary
- **Purpose**: Brief description of what this infrastructure supports
- **Environment**: Development, Staging, or Production
- **Key Services**: Highlight the primary services (e.g., App Service, SQL Database, Storage)
- **Architecture Pattern**: Describe the pattern (e.g., 3-tier web app, microservices, data pipeline)

### 2. Resource Inventory

Create a comprehensive table of all resources:

| Resource Name | Resource Type | SKU/Tier | Location | Purpose | Dependencies |
|--------------|---------------|----------|----------|---------|--------------|
| (for each resource) | | | | | |

### 3. Architecture Overview

Provide a narrative description of:
- **Application Flow**: How requests flow through the system
- **Data Flow**: How data moves between components
- **Security Boundaries**: Network isolation, private endpoints, NSGs
- **High Availability**: Zone redundancy, backup strategies
- **Scaling Strategy**: Auto-scaling configuration, manual scaling procedures

"@

if ($IncludeDiagrams) {
    $prompt += @"


### 4. Architecture Diagrams (Mermaid)

Generate Mermaid diagrams for visualization:

#### System Architecture Diagram
Create a high-level Mermaid diagram showing:
- User/client access points
- Load balancers or Application Gateways
- Web tier (App Services, Container Apps)
- Application tier (Function Apps, APIs)
- Data tier (SQL Database, Cosmos DB, Storage)
- Supporting services (Key Vault, Application Insights, Log Analytics)
- External integrations

Example format:
``````mermaid
graph TB
    User[Users/Clients]
    AppGW[Application Gateway]
    WebApp[App Service]
    API[Function App]
    DB[(SQL Database)]
    KV[Key Vault]
    AppI[Application Insights]
    
    User -->|HTTPS| AppGW
    AppGW -->|Port 443| WebApp
    WebApp -->|API Calls| API
    API -->|Query| DB
    WebApp -.->|Secrets| KV
    WebApp -.->|Telemetry| AppI
``````

"@
}

if ($IncludeNetworkTopology) {
    $prompt += @"


### 5. Network Topology

Document the network architecture:

#### Virtual Networks
- VNet address spaces and subnets
- Subnet purposes (web tier, app tier, data tier)
- NSG rules summary
- Service endpoints or private endpoints
- VNet peering or VPN connections

#### Network Security
- NSG rules table (priority, source, destination, port, action)
- Private endpoint configurations
- Private DNS zones
- Firewall rules (if applicable)

#### Connectivity Diagram (Mermaid)
Create a network topology diagram:
``````mermaid
graph LR
    Internet((Internet))
    VNet[Virtual Network<br/>10.0.0.0/16]
    SubnetWeb[Web Subnet<br/>10.0.1.0/24]
    SubnetApp[App Subnet<br/>10.0.2.0/24]
    SubnetData[Data Subnet<br/>10.0.3.0/24]
    
    NSGWeb[NSG-Web]
    NSGApp[NSG-App]
    NSGData[NSG-Data]
    
    Internet -->|HTTPS:443| SubnetWeb
    VNet --> SubnetWeb
    VNet --> SubnetApp
    VNet --> SubnetData
    
    SubnetWeb -.->|Protected by| NSGWeb
    SubnetApp -.->|Protected by| NSGApp
    SubnetData -.->|Protected by| NSGData
``````

"@
}

if ($IncludeCostAnalysis) {
    $prompt += @"


### 6. Cost Analysis

Provide estimated monthly costs:

| Resource | Type | SKU/Tier | Estimated Monthly Cost | Cost Optimization Notes |
|----------|------|----------|----------------------|------------------------|
| (for each resource) | | | | |

**Total Estimated Monthly Cost**: `$`X,XXX

#### Cost Optimization Opportunities
- Reserved Instances: Potential savings for compute resources
- Right-sizing: Resources that could be downsized
- Auto-shutdown: Non-prod resources that could be shut down outside business hours
- Storage tiering: Cold/Archive storage for infrequent access
- Spot instances: For fault-tolerant workloads

"@
}

$prompt += @"


### 7. Security & Compliance

Document security configurations:
- **Authentication**: Managed Identity, Entra ID integration
- **Authorization**: RBAC roles, access policies
- **Encryption**: At-rest (TDE, Storage encryption), in-transit (TLS)
- **Secrets Management**: Key Vault usage, connection strings
- **Network Security**: Private endpoints, NSG rules, firewalls
- **Monitoring & Auditing**: Diagnostic logs, Azure Monitor, alerts

### 8. Disaster Recovery & Business Continuity

Document DR strategy:
- **Backup Configuration**: Automated backups, retention policies
- **Recovery Objectives**:
  - RTO (Recovery Time Objective): Target time to restore
  - RPO (Recovery Point Objective): Acceptable data loss window
- **Failover Procedures**: Steps to switch to DR environment
- **Testing Schedule**: Regular DR drills

### 9. Monitoring & Observability

Document monitoring setup:
- **Application Insights**: Telemetry, traces, exceptions
- **Log Analytics**: Centralized logging, log queries
- **Alerts**: Critical metrics and thresholds
- **Dashboards**: Key metrics visualization
- **Health Checks**: Availability tests, endpoint monitoring

### 10. Dependencies & Integrations

Document external dependencies:
- **Azure Services**: Dependencies on other Azure services
- **Third-Party Services**: External APIs, SaaS integrations
- **On-Premises**: Hybrid connections, VPN/ExpressRoute
- **Data Sources**: External data feeds, databases

### 11. Deployment & Operations

Document operational procedures:
- **Deployment Method**: IaC (Bicep/Terraform), Azure Portal, ARM
- **CI/CD Pipeline**: Build and deployment automation
- **Configuration Management**: App settings, environment variables
- **Scaling Procedures**: Manual and automatic scaling
- **Maintenance Windows**: Scheduled maintenance, patching

## Output Format

- Use **Markdown** with clear headers and sections
- Include **Mermaid diagrams** for visual representation
- Use **tables** for structured data (inventory, costs, NSG rules)
- Provide **actionable** information (not just descriptions)
- Include **real resource names** from the inventory above
- Add **links** to Azure documentation where relevant

## Additional Guidelines

- Focus on **clarity and completeness**
- Assume the audience is technical (IT Pros, architects, engineers)
- Highlight **security and compliance** aspects
- Emphasize **cost optimization** opportunities
- Include **operational considerations** (monitoring, maintenance)
- Make it **actionable** (procedures, not just descriptions)

---

Please generate complete architecture documentation following this structure. Make it comprehensive yet practical for use by operations teams and new team members.
"@

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

# Save prompt to file
$promptFile = Join-Path $OutputPath "architecture-prompt.txt"
$prompt | Out-File -FilePath $promptFile -Encoding UTF8

Write-Log "`n========================================" -Level Success
Write-Log "Architecture Documentation Prompt Generated!" -Level Success
Write-Log "========================================`n" -Level Success
Write-Log "Prompt file: $promptFile" -Level Success
Write-Log "Resources analyzed: $($resources.Count)" -Level Success

# Copy to clipboard if requested
if ($CopyToClipboard) {
    try {
        if ($IsWindows -or $env:OS -match "Windows") {
            $prompt | Set-Clipboard
            Write-Log "✅ Prompt copied to clipboard!" -Level Success
        }
        elseif ($IsLinux) {
            $prompt | xclip -selection clipboard 2>$null
            if ($?) {
                Write-Log "✅ Prompt copied to clipboard (xclip)!" -Level Success
            }
            else {
                Write-Log "⚠️  xclip not available. Install with: sudo apt install xclip" -Level Warning
            }
        }
        elseif ($IsMacOS) {
            $prompt | pbcopy
            Write-Log "✅ Prompt copied to clipboard!" -Level Success
        }
    }
    catch {
        Write-Log "⚠️  Failed to copy to clipboard: $_" -Level Warning
    }
}

Write-Log "`n📋 Next Steps:" -Level Info
Write-Log "1. Open GitHub Copilot Chat in VS Code (Ctrl+Shift+I or Cmd+Shift+I)" -Level Info
Write-Log "2. Paste the prompt from: $promptFile" -Level Info
Write-Log "3. Review and customize the generated documentation" -Level Info
Write-Log "4. Save to: $(Join-Path $OutputPath 'architecture-documentation.md')" -Level Info

Write-Log "`n⏱️  Time Savings: 5hrs 40min (95% faster than manual creation)" -Level Success

return [PSCustomObject]@{
    ResourceGroupName = $ResourceGroupName
    ResourceCount     = $resources.Count
    PromptFile        = $promptFile
    OutputPath        = $OutputPath
    Timestamp         = Get-Date
    CopiedToClipboard = $CopyToClipboard.IsPresent
}
