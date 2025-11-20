<#
.SYNOPSIS
    Generates operational runbooks using GitHub Copilot.

.DESCRIPTION
    Scans Azure resources and generates a structured prompt for GitHub Copilot Chat
    to create comprehensive operational runbooks with procedures, playbooks, and maintenance tasks.
    
    Demonstrates how Copilot reduces runbook creation from 4 hours to 20 minutes (92% faster).

.PARAMETER ResourceGroupName
    Name of the resource group to document.

.PARAMETER OutputPath
    Directory path for generated prompt. Default: current directory.

.PARAMETER IncludeDeployment
    Include deployment and rollback procedures.

.PARAMETER IncludeMonitoring
    Include monitoring and alerting runbooks.

.PARAMETER IncludeMaintenance
    Include maintenance tasks (patching, backups, scaling).

.PARAMETER CopyToClipboard
    Copy the generated Copilot prompt to clipboard.

.EXAMPLE
    New-RunbookDoc -ResourceGroupName "rg-production" -OutputPath ".\output" -IncludeDeployment -IncludeMonitoring -CopyToClipboard

.NOTES
    Author: Generated with GitHub Copilot
    Time Savings: 4 hours → 20 minutes (92% faster)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".",

    [Parameter(Mandatory = $false)]
    [switch]$IncludeDeployment,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeMonitoring,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeMaintenance,

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

Write-Log "Starting operational runbook prompt generation..." -Level Info

# Check Azure authentication
$context = Get-AzContext
if (-not $context) {
    throw "Not authenticated to Azure. Run 'Connect-AzAccount' first."
}

Write-Log "Connected to subscription: $($context.Subscription.Name)" -Level Success

# Get resource inventory
Write-Log "Discovering resources in '$ResourceGroupName'..."
$resources = Get-AzResource -ResourceGroupName $ResourceGroupName -ExpandProperties

if ($resources.Count -eq 0) {
    Write-Log "No resources found in resource group." -Level Warning
    return
}

Write-Log "Found $($resources.Count) resource(s)" -Level Success

# Categorize resources by operational concern
$webTier = $resources | Where-Object { $_.ResourceType -match 'Microsoft.Web|Microsoft.App|Microsoft.ContainerInstance' }
$dataTier = $resources | Where-Object { $_.ResourceType -match 'Microsoft.Sql|Microsoft.DBforMySQL|Microsoft.DBforPostgreSQL|Microsoft.DocumentDB|Microsoft.Cache' }
$storageTier = $resources | Where-Object { $_.ResourceType -match 'Microsoft.Storage' }
$networkTier = $resources | Where-Object { $_.ResourceType -match 'Microsoft.Network' }
$securityTier = $resources | Where-Object { $_.ResourceType -match 'Microsoft.KeyVault' }
$monitoringTier = $resources | Where-Object { $_.ResourceType -match 'Microsoft.Insights|Microsoft.OperationalInsights' }

# Build resource summary
$resourceSummary = ""
$resourceSummary += "## Web/Application Tier ($($webTier.Count) resources)`n"
foreach ($r in $webTier) {
    $resourceSummary += "- ``$($r.Name)`` ($($r.ResourceType))"
    if ($r.Sku) { $resourceSummary += " - SKU: ``$($r.Sku.Name)``" }
    $resourceSummary += "`n"
}

$resourceSummary += "`n## Data Tier ($($dataTier.Count) resources)`n"
foreach ($r in $dataTier) {
    $resourceSummary += "- ``$($r.Name)`` ($($r.ResourceType))"
    if ($r.Sku) { $resourceSummary += " - SKU: ``$($r.Sku.Name)``" }
    $resourceSummary += "`n"
}

$resourceSummary += "`n## Storage Tier ($($storageTier.Count) resources)`n"
foreach ($r in $storageTier) {
    $resourceSummary += "- ``$($r.Name)`` ($($r.ResourceType))"
    if ($r.Sku) { $resourceSummary += " - SKU: ``$($r.Sku.Name)``" }
    $resourceSummary += "`n"
}

$resourceSummary += "`n## Network Tier ($($networkTier.Count) resources)`n"
foreach ($r in $networkTier) {
    $resourceSummary += "- ``$($r.Name)`` ($($r.ResourceType))"
    $resourceSummary += "`n"
}

$resourceSummary += "`n## Security Tier ($($securityTier.Count) resources)`n"
foreach ($r in $securityTier) {
    $resourceSummary += "- ``$($r.Name)`` ($($r.ResourceType))"
    $resourceSummary += "`n"
}

$resourceSummary += "`n## Monitoring Tier ($($monitoringTier.Count) resources)`n"
foreach ($r in $monitoringTier) {
    $resourceSummary += "- ``$($r.Name)`` ($($r.ResourceType))"
    $resourceSummary += "`n"
}

# Build Copilot prompt
$prompt = @"
# Generate Operational Runbooks

Please create comprehensive **Operational Runbooks** for the following Azure infrastructure in resource group **$ResourceGroupName**:

## Deployed Resources

$resourceSummary

## Required Runbook Sections

### 1. Overview

- **Purpose**: What these runbooks cover
- **Scope**: Resource group and primary services
- **Audience**: Operations team, SREs, on-call engineers
- **Prerequisites**: Required access, tools, credentials

### 2. Standard Operating Procedures (SOPs)

#### 2.1 Daily Operations
- Health check procedures (dashboard review, metrics validation)
- Log review procedures (errors, warnings, anomalies)
- Performance baseline validation
- Backup verification

#### 2.2 Weekly Operations
- Capacity planning review (resource utilization trends)
- Security review (access logs, audit logs, failed authentications)
- Cost review (spending trends, anomalies)
- Patch planning (available updates, maintenance windows)

#### 2.3 Monthly Operations
- Disaster recovery test
- Access review (RBAC, service principals, keys rotation)
- Performance optimization review
- Compliance validation

"@

if ($IncludeDeployment) {
    $prompt += @"


### 3. Deployment Procedures

#### 3.1 Standard Deployment
Create a step-by-step deployment runbook:

**Pre-Deployment Checklist:**
- [ ] Backup current configuration
- [ ] Review change request and approval
- [ ] Verify deployment artifacts
- [ ] Notify stakeholders
- [ ] Schedule maintenance window

**Deployment Steps:**
Provide PowerShell scripts for:
1. Pre-deployment validation
2. Resource deployment (Bicep/Terraform)
3. Post-deployment verification
4. Smoke tests
5. Monitoring validation

**Example PowerShell Deployment Script:**
``````powershell
# Example structure - customize for your resources
``````

#### 3.2 Rollback Procedures
Create rollback runbook:

**When to Rollback:**
- Failed health checks
- Critical errors in logs
- Performance degradation
- Business validation failure

**Rollback Steps:**
Provide scripts for:
1. Stop new traffic routing
2. Restore previous version
3. Validate rollback success
4. Incident documentation

"@
}

if ($IncludeMonitoring) {
    $prompt += @"


### 4. Monitoring & Alerting

#### 4.1 Key Metrics Dashboard
Create a monitoring dashboard reference:

**Application Metrics:**
- Availability (target: >99.9%)
- Response time (P50, P95, P99)
- Request rate (requests/sec)
- Error rate (% of requests)

**Infrastructure Metrics:**
- CPU utilization (per resource)
- Memory utilization
- Disk I/O
- Network throughput

**Database Metrics:**
- DTU/vCore utilization
- Connection count
- Query performance
- Replication lag (if applicable)

#### 4.2 Alert Response Playbooks

For each critical alert, provide a response playbook:

**Example: High CPU Alert**
``````markdown
**Severity:** P2
**Threshold:** CPU >85% for 10 minutes
**Impact:** Performance degradation

**Investigation Steps:**
1. Check Application Insights for traffic spike
2. Review slow queries in SQL Database
3. Check for memory leaks (memory trends)
4. Review recent deployments

**Resolution Steps:**
1. Scale up resources (if capacity issue)
2. Optimize slow queries (if database issue)
3. Restart application (if memory leak)
4. Review and optimize code (if inefficient code)

**Prevention:**
- Enable auto-scaling
- Set up query performance alerts
- Regular performance testing
``````

Create similar playbooks for:
- High memory usage
- Database connection pool exhaustion
- Storage capacity threshold
- Network latency spikes

#### 4.3 Log Analysis Queries

Provide KQL queries for common investigations:

**Error Tracking:**
``````kusto
AppExceptions
| where TimeGenerated > ago(1h)
| summarize count() by ProblemId, OuterMessage
| order by count_ desc
``````

**Performance Analysis:**
``````kusto
AppRequests
| where TimeGenerated > ago(1h)
| summarize P50=percentile(DurationMs, 50), P95=percentile(DurationMs, 95), P99=percentile(DurationMs, 99) by OperationName
| order by P95 desc
``````

"@
}

if ($IncludeMaintenance) {
    $prompt += @"


### 5. Maintenance Procedures

#### 5.1 Patching & Updates

**Monthly Patching Runbook:**
``````markdown
**Frequency:** Monthly (second Tuesday)
**Window:** 2:00 AM - 6:00 AM UTC
**Impact:** Potential downtime or performance impact

**Pre-Maintenance:**
1. Review available updates (OS, runtime, SQL)
2. Test in non-production environment
3. Backup all configurations and databases
4. Notify stakeholders (48 hours advance)
5. Prepare rollback plan

**Maintenance Steps:**
1. Enable maintenance mode (redirect traffic if possible)
2. Apply OS updates (App Service, VMs)
3. Apply SQL patches (during low-traffic window)
4. Update application runtimes (.NET, Node.js, Python)
5. Restart services in sequence (data tier → app tier → web tier)

**Post-Maintenance:**
1. Validate all health checks pass
2. Monitor for 30 minutes
3. Review logs for errors
4. Notify stakeholders of completion
5. Document any issues

**Rollback Plan:**
(if issues occur within 2 hours)
``````

#### 5.2 Backup & Restore

**Backup Validation Runbook:**
``````powershell
# Script to validate backups exist and are recent
``````

**Restore Testing Runbook:**
(Quarterly DR drill)

#### 5.3 Scaling Procedures

**Manual Scale-Up Runbook:**
(For planned events like Black Friday, product launches)

**Manual Scale-Down Runbook:**
(Post-event cost optimization)

#### 5.4 Certificate Renewal

**SSL/TLS Certificate Renewal Runbook:**
(If using custom domains)

"@
}

$prompt += @"


### 6. Incident Response

#### 6.1 Incident Classification

| Severity | Definition | Response Time | Examples |
|----------|------------|---------------|----------|
| P1 - Critical | Complete service outage | 15 minutes | App completely down, data breach |
| P2 - High | Major degradation | 1 hour | Severe performance issues, partial outage |
| P3 - Medium | Minor degradation | 4 hours | Non-critical feature broken |
| P4 - Low | Minimal impact | Next business day | Cosmetic issues, minor bugs |

#### 6.2 Incident Response Workflow

Create an incident response flowchart (Mermaid):
``````mermaid
graph TD
    A[Alert Triggered] --> B{Severity?}
    B -->|P1/P2| C[Page On-Call]
    B -->|P3/P4| D[Create Ticket]
    C --> E[Acknowledge Alert]
    E --> F[Initial Investigation]
    F --> G{Root Cause Found?}
    G -->|Yes| H[Implement Fix]
    G -->|No| I[Escalate to Engineering]
    H --> J[Verify Resolution]
    I --> J
    J --> K[Post-Incident Review]
``````

#### 6.3 Communication Templates

**Incident Start Notification:**
(Template for stakeholder communication)

**Incident Update:**
(Hourly updates for P1/P2)

**Incident Resolution:**
(Post-resolution summary)

### 7. Contact Information

**On-Call Rotation:**
- Primary: (contact info)
- Secondary: (contact info)
- Escalation: (manager contact)

**Vendor Support:**
- Azure Support: (support plan details)
- Third-party services: (contact info)

### 8. Useful Links

- Azure Portal: [Resource Group Link]
- Application Insights: [Link]
- Log Analytics: [Link]
- Deployment Pipeline: [Link]
- Runbook Repository: [Link]
- Incident Management: [Ticketing system link]

## Output Format

- Use **Markdown** with clear headers and sections
- Include **Mermaid flowcharts** for decision trees
- Provide **PowerShell scripts** in code blocks
- Use **checklists** for procedures
- Include **KQL queries** for log analysis
- Make it **actionable** and **copy-paste ready**

## Additional Guidelines

- Focus on **practical, step-by-step procedures**
- Assume the reader is **on-call at 3 AM** (clarity is critical)
- Include **exact commands** (no placeholders if possible)
- Provide **rollback steps** for every risky operation
- Add **time estimates** for each procedure
- Include **success criteria** (how to know it worked)
- Reference **real resource names** from the inventory above

---

Please generate comprehensive operational runbooks following this structure. Make them practical, detailed, and ready for use by operations teams during normal operations and incidents.
"@

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

# Save prompt to file
$promptFile = Join-Path $OutputPath "runbook-prompt.txt"
$prompt | Out-File -FilePath $promptFile -Encoding UTF8

Write-Log "`n========================================" -Level Success
Write-Log "Operational Runbook Prompt Generated!" -Level Success
Write-Log "========================================`n" -Level Success
Write-Log "Prompt file: $promptFile" -Level Success
Write-Log "Resources analyzed: $($resources.Count)" -Level Success
Write-Log "  - Web/App Tier: $($webTier.Count)" -Level Info
Write-Log "  - Data Tier: $($dataTier.Count)" -Level Info
Write-Log "  - Storage Tier: $($storageTier.Count)" -Level Info
Write-Log "  - Network Tier: $($networkTier.Count)" -Level Info
Write-Log "  - Security Tier: $($securityTier.Count)" -Level Info
Write-Log "  - Monitoring Tier: $($monitoringTier.Count)" -Level Info

# Copy to clipboard if requested
if ($CopyToClipboard) {
    try {
        if ($IsWindows -or $env:OS -match "Windows") {
            $prompt | Set-Clipboard
            Write-Log "✅ Prompt copied to clipboard!" -Level Success
        } elseif ($IsLinux) {
            $prompt | xclip -selection clipboard 2>$null
            if ($?) {
                Write-Log "✅ Prompt copied to clipboard (xclip)!" -Level Success
            } else {
                Write-Log "⚠️  xclip not available. Install with: sudo apt install xclip" -Level Warning
            }
        } elseif ($IsMacOS) {
            $prompt | pbcopy
            Write-Log "✅ Prompt copied to clipboard!" -Level Success
        }
    } catch {
        Write-Log "⚠️  Failed to copy to clipboard: $_" -Level Warning
    }
}

Write-Log "`n📋 Next Steps:" -Level Info
Write-Log "1. Open GitHub Copilot Chat in VS Code (Ctrl+Shift+I or Cmd+Shift+I)" -Level Info
Write-Log "2. Paste the prompt from: $promptFile" -Level Info
Write-Log "3. Review and customize the generated runbooks" -Level Info
Write-Log "4. Save to: $(Join-Path $OutputPath 'operational-runbooks.md')" -Level Info

Write-Log "`n⏱️  Time Savings: 3hrs 40min (92% faster than manual creation)" -Level Success

return [PSCustomObject]@{
    ResourceGroupName = $ResourceGroupName
    ResourceCount = $resources.Count
    WebTier = $webTier.Count
    DataTier = $dataTier.Count
    StorageTier = $storageTier.Count
    NetworkTier = $networkTier.Count
    SecurityTier = $securityTier.Count
    MonitoringTier = $monitoringTier.Count
    PromptFile = $promptFile
    OutputPath = $OutputPath
    Timestamp = Get-Date
    CopiedToClipboard = $CopyToClipboard.IsPresent
}
