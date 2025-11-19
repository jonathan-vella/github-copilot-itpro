# Effective Prompts for Azure Arc Onboarding

This guide contains proven prompts for using GitHub Copilot to accelerate Azure Arc Connected Machine onboarding at scale. These prompts are optimized for the specific challenges of hybrid cloud infrastructure management.

---

## Table of Contents

1. [Service Principal Creation](#service-principal-creation)
2. [Parallel Agent Deployment](#parallel-agent-deployment)
3. [Azure Policy Configuration](#azure-policy-configuration)
4. [Monitoring Setup](#monitoring-setup)
5. [Validation & Health Checks](#validation--health-checks)
6. [Troubleshooting](#troubleshooting)
7. [Documentation](#documentation)

---

## Service Principal Creation

### Basic Service Principal Setup

```plaintext
Create a PowerShell function to create an Azure Service Principal for Azure Arc Connected Machine onboarding with the following requirements:
- Parameter for service principal name, subscription ID, and resource group scope
- Assign "Azure Connected Machine Onboarding" role (b64e21ea-ac4e-4cdf-9dc9-5b892992bee7)
- Assign "Log Analytics Contributor" role for monitoring
- Store credentials securely in Azure Key Vault
- Support both client secret and certificate-based authentication
- Include comprehensive error handling and logging
- Return service principal details including application ID and tenant ID
```

### Advanced Service Principal with Key Vault Integration

```plaintext
Extend the Service Principal creation script to:
- Check if Service Principal already exists before creating
- Support certificate-based authentication with .pfx file upload
- Configure Key Vault access policies automatically
- Set credential expiration based on parameter (default 1 year)
- Tag the Service Principal with metadata (Environment, Purpose, Owner)
- Generate a summary report with connection details
- Include validation that tests SP authentication before completion
```

### Least-Privilege RBAC Scoping

```plaintext
Create a function that scopes Service Principal permissions to the minimum required for Arc onboarding:
- Allow subscription-level scope or specific resource group scope
- Apply Azure Connected Machine Onboarding role only
- Add optional Log Analytics Contributor if monitoring is enabled
- Validate that no Owner or Contributor roles are assigned
- Generate audit report of assigned permissions
- Support multi-subscription scenarios with array input
```

---

## Parallel Agent Deployment

### Basic Parallel Deployment Script

```plaintext
Create a PowerShell script that deploys Azure Arc Connected Machine agent to multiple servers in parallel using runspaces:
- Accept CSV file input with columns: ServerName, OS, IPAddress
- Use runspaces to deploy to 50 servers concurrently
- Support both Windows (WinRM) and Linux (SSH) servers
- Include progress tracking with Write-Progress
- Implement retry logic with exponential backoff (3 attempts)
- Generate detailed log file for each deployment
- Export success/failure results to CSV
```

### Advanced Parallel Deployment with Health Checks

```plaintext
Enhance the parallel deployment script with:
- Pre-deployment validation (connectivity test, OS version check, disk space)
- Corporate proxy support with proxy URL parameter
- Automatic credential retrieval from Key Vault
- Support for multiple Azure regions and resource groups
- Tag application during onboarding (Environment, CostCenter, Owner)
- Post-deployment validation (verify Arc agent running, check heartbeat)
- Real-time progress dashboard with color-coded status
- Detailed HTML report with success rate, average time per server, and failure analysis
```

### Region-Aware Deployment with Geo-Tagging

```plaintext
Create an Arc deployment script that:
- Reads server list with Location column (e.g., "US-East", "EU-West", "APAC-Singapore")
- Maps locations to appropriate Azure regions automatically
- Groups servers by region and deploys in batches
- Applies geo-specific tags (Country, Site, Building)
- Handles region-specific networking requirements (different proxies per region)
- Generates per-region deployment reports
- Includes cost estimation based on server count per region
```

---

## Azure Policy Configuration

### Tagging Policy with Deny Effect

```plaintext
Generate an Azure Policy definition that:
- Enforces required tags on Arc-enabled servers: Environment, Owner, CostCenter
- Uses "deny" effect to prevent creation without tags
- Allows exemptions for specific resource groups
- Includes validation regex for tag values (e.g., CostCenter must be 4 digits)
- Generate both policy definition and assignment PowerShell script
- Include testing script to validate policy works correctly
```

### Monitoring Agent Deployment Policy

```plaintext
Create an Azure Policy with deployIfNotExists effect that:
- Automatically deploys Azure Monitor Agent extension to Arc servers
- Configures Data Collection Rule association
- Applies only to servers in Production environment (based on tag)
- Includes managed identity configuration for the extension
- Handles both Windows and Linux servers with OS-specific configurations
- Generates remediation task to fix existing non-compliant servers
- Includes PowerShell script to assign policy and trigger remediation
```

### Security Baseline Policy Suite

```plaintext
Create a policy initiative (policy set) for Arc server security baseline:
- Audit servers without guest configuration extension
- Ensure TLS 1.2 minimum for all Arc connections
- Verify Azure AD authentication is enabled
- Check that Update Management is configured
- Audit servers with public IP addresses (should be denied)
- Generate compliance dashboard query (KQL) for Azure Resource Graph
- Include PowerShell script to deploy initiative and generate compliance report
```

---

## Monitoring Setup

### Data Collection Rule Configuration

```plaintext
Create a PowerShell script that configures Azure Monitor for Arc servers:
- Create Data Collection Rule for Windows servers (performance counters, event logs)
- Create separate DCR for Linux servers (syslog, performance metrics)
- Associate DCRs with Arc-enabled servers based on OS type
- Deploy Azure Monitor Agent extension to all Arc servers
- Configure performance counters: CPU, Memory, Disk, Network
- Set up Windows event log collection: System, Application, Security
- Include validation that data is flowing to Log Analytics workspace
```

### Alert Rules for Arc Server Health

```plaintext
Generate PowerShell script to create alert rules for Arc server monitoring:
- Alert if Arc agent heartbeat older than 15 minutes
- Alert on high CPU usage (>90% for 15 minutes)
- Alert on low disk space (<10% free)
- Alert on memory pressure (>85% for 10 minutes)
- Create action group with email notifications
- Use metric alerts where possible, log alerts for custom KQL
- Include severity levels (Critical, Warning, Informational)
- Generate alert testing script to validate notifications work
```

### Log Analytics Workbook for Arc Fleet

```plaintext
Create a KQL-based workbook for Arc server fleet management:
- Overview tile with total servers, online/offline count, compliance status
- Server health grid with last heartbeat, CPU, memory, disk metrics
- Policy compliance section showing compliant vs. non-compliant servers
- Extension status showing which extensions are installed per server
- Geographic map visualization based on server tags
- Time-series charts for CPU/memory trends over 7 days
- Export as ARM template for easy deployment
```

---

## Validation & Health Checks

### Comprehensive Arc Server Health Check

```plaintext
Create a PowerShell health check script for Arc-enabled servers:
- Enumerate all Arc servers in subscription or resource group
- Check connectivity status (Connected, Disconnected, Expired)
- Verify Arc agent version and report if outdated
- Check all installed extensions and their provisioning state
- Validate tags are present and correct
- Check if server is sending heartbeat (last seen < 15 min)
- Generate HTML report with color-coded status indicators
- Include recommendations for remediation of issues found
```

### Policy Compliance Validation

```plaintext
Create a script that validates Azure Policy compliance for Arc servers:
- Query Azure Policy compliance state for all Arc servers
- List non-compliant resources with policy definition names
- Provide remediation guidance for each non-compliant resource
- Generate CSV export of compliance status for audit purposes
- Include policy exemption details if any exist
- Calculate compliance percentage by policy and overall
- Suggest policy modifications if compliance is consistently low
```

### Extension Status Audit

```plaintext
Generate a PowerShell script to audit Arc server extensions:
- List all Arc servers and their installed extensions
- Identify servers missing critical extensions (Azure Monitor Agent, Guest Configuration)
- Check extension provisioning state (Succeeded, Failed, Updating)
- Report extension versions and flag outdated versions
- Calculate average extension count per server
- Export to CSV and HTML report formats
- Include PowerShell commands to remediate missing extensions
```

---

## Troubleshooting

### Arc Agent Connectivity Troubleshooter

```plaintext
Create a troubleshooting script for Arc agent connectivity issues:
- Test network connectivity to required Azure endpoints
- Check firewall rules for Arc agent communication
- Verify proxy configuration if corporate proxy is used
- Test DNS resolution for Azure Arc endpoints
- Check Arc agent service status and restart if needed
- Review Arc agent logs for error messages
- Verify Service Principal credentials are valid
- Generate detailed troubleshooting report with specific recommendations
```

### Bulk Disconnect/Reconnect Script

```plaintext
Create a script to handle disconnected Arc servers:
- Identify all disconnected Arc servers (heartbeat > 24 hours)
- Attempt to reconnect by restarting Arc agent service remotely
- If restart fails, generate manual remediation steps
- Support both Windows (WinRM) and Linux (SSH) servers
- Log all actions taken with timestamps
- Send email notification summarizing reconnected vs. still-disconnected servers
- Create CSV report of servers requiring manual intervention
```

### Performance Degradation Analysis

```plaintext
Generate a PowerShell script using KQL queries to identify performance issues:
- Query Log Analytics for Arc servers with high CPU (>80% avg over 24 hours)
- Identify memory leaks (steadily increasing memory over time)
- Find disk space issues (free space trending downward)
- Detect network issues (high latency or packet loss)
- Correlate performance issues with recent policy changes
- Generate ranked list of top 10 problematic servers
- Include recommended actions (restart, disk cleanup, memory investigation)
```

---

## Documentation

### Architecture Diagram Generation

```plaintext
Generate Mermaid diagram code for Arc architecture:
- Show on-premises servers in multiple regions (Americas, EMEA, APAC)
- Display VPN connections to Azure
- Include Azure Arc control plane, Log Analytics, Azure Policy, Azure Monitor
- Show data flow: agent heartbeat, monitoring data, policy enforcement
- Add legend for server types (Windows, Linux) and states (Connected, Disconnected)
- Include security boundaries (VNets, NSGs, Azure AD authentication)
```

### Runbook Template

```plaintext
Create a comprehensive Arc onboarding runbook template in markdown:
- Prerequisites checklist (Azure subscription, Service Principal, network requirements)
- Step-by-step deployment procedures with PowerShell commands
- Troubleshooting section with common errors and solutions
- Validation steps to confirm successful deployment
- Rollback procedures if deployment fails
- Appendix with required Azure endpoints and firewall rules
- Contact information and escalation paths
```

### Automated Release Notes

```plaintext
Generate a PowerShell script that creates Arc deployment release notes:
- List servers onboarded in the last deployment batch
- Show policy assignments created or modified
- Display monitoring configurations applied
- Include success rate and deployment statistics
- List any exceptions or issues encountered
- Provide links to Azure Portal for Arc servers and policies
- Format as markdown for easy sharing
```

---

## Advanced Techniques

### Multi-Subscription Arc Onboarding

```plaintext
Create a script that onboards Arc servers across multiple Azure subscriptions:
- Accept array of subscription IDs as input
- Set Service Principal permissions in each subscription
- Deploy Arc agents with subscription-specific resource groups
- Apply subscription-level policies consistently across all subscriptions
- Aggregate monitoring data into central Log Analytics workspace
- Generate consolidated report showing Arc servers per subscription
- Include subscription-level cost estimation
```

### Disaster Recovery for Arc Configuration

```plaintext
Generate a backup and restore script for Arc configuration:
- Export all Arc-related Azure Policy assignments
- Backup Service Principal configurations
- Export Data Collection Rules and alert rules
- Save Log Analytics workspace queries and workbooks
- Create restore script that recreates all configurations
- Include validation that restored configuration matches original
- Store backups in Azure Storage with versioning
```

### Cost Optimization for Arc Fleet

```plaintext
Create a cost analysis script for Arc-enabled servers:
- Calculate Arc agent cost per server (licensing)
- Estimate Log Analytics ingestion costs based on data volume
- Show policy evaluation costs
- Identify opportunities to reduce costs (optimize DCR, reduce log retention)
- Compare cost vs. on-premises management tools
- Generate monthly cost projection based on current usage
- Include recommendations for cost optimization
```

---

## Tips for Best Results with Copilot

### 1. Be Specific About Scale
- ❌ "Create an Arc deployment script"
- ✅ "Create a script to deploy Arc agent to 500 servers in parallel with 50 concurrent connections"

### 2. Mention Error Handling Explicitly
- ❌ "Install Arc agent on servers"
- ✅ "Install Arc agent with retry logic, exponential backoff, and detailed error logging"

### 3. Specify Output Format
- ❌ "Generate a report"
- ✅ "Generate an HTML report with CSS styling, color-coded status indicators, and drill-down sections"

### 4. Include Security Requirements
- ❌ "Create Service Principal"
- ✅ "Create Service Principal with least-privilege RBAC, Key Vault credential storage, and certificate authentication"

### 5. Request Multi-Platform Support
- ❌ "Deploy Arc agent"
- ✅ "Deploy Arc agent to both Windows (WinRM) and Linux (SSH) servers with OS-specific validation"

### 6. Ask for Complete Solutions
- ❌ "Write Azure Policy"
- ✅ "Write Azure Policy definition, assignment script, testing validation, and remediation task creation"

### 7. Specify Azure Services
- ❌ "Set up monitoring"
- ✅ "Configure Azure Monitor with Data Collection Rules, Azure Monitor Agent extension, and Log Analytics workspace"

---

## Prompt Patterns for Common Scenarios

### Pattern: Script + Validation + Report
```plaintext
Create a [script type] that:
1. Performs [main action]
2. Validates [expected outcome]
3. Generates [report type] with [specific sections]
```

**Example:**
```plaintext
Create a PowerShell script that:
1. Deploys Arc agent to servers from CSV
2. Validates agent is running and sending heartbeat
3. Generates HTML report with server count, success rate, and failed server details
```

### Pattern: Pre-Check + Action + Post-Check
```plaintext
Create a script that:
- Pre-deployment: [validation steps]
- Deployment: [main action with error handling]
- Post-deployment: [verification steps]
```

**Example:**
```plaintext
Create a script that:
- Pre-deployment: Test network connectivity, verify disk space, check OS version
- Deployment: Install Arc agent with retry logic
- Post-deployment: Verify agent service running, check heartbeat in Azure, confirm tags applied
```

### Pattern: Parallel + Progress + Summary
```plaintext
Create a script using PowerShell runspaces to:
- Process [X] items in parallel with throttle limit of [Y]
- Show real-time progress with [progress indicator type]
- Generate summary with [metrics]
```

**Example:**
```plaintext
Create a script using PowerShell runspaces to:
- Process 500 servers in parallel with throttle limit of 50
- Show real-time progress with Write-Progress and colored console output
- Generate summary with total time, success rate, average time per server, top 5 errors
```

---

## Integration with Existing Tools

### SCCM/ConfigMgr Integration

```plaintext
Create a script that:
- Queries SCCM for list of servers in specific collection
- Extracts server details (name, IP, OS, last online)
- Generates CSV compatible with Arc deployment script
- Excludes servers that are already Arc-enabled
- Updates SCCM custom attributes after successful Arc onboarding
```

### ServiceNow CMDB Sync

```plaintext
Generate a script that syncs Arc server data to ServiceNow CMDB:
- Query Arc servers from Azure with tags and properties
- Map Azure properties to ServiceNow CI attributes
- Use ServiceNow REST API to update or create CIs
- Handle incremental updates (only changed records)
- Generate sync report showing new, updated, and deleted CIs
```

### Active Directory Integration

```plaintext
Create a script that:
- Queries Active Directory for servers in specific OUs
- Filters for Windows Server 2016+ and supported Linux distros
- Cross-references with Arc-enabled servers to find gaps
- Generates prioritized onboarding list based on server criticality (tags/attributes)
- Includes server owner contact information from AD
```

---

## Conclusion

These prompts are designed to accelerate Azure Arc onboarding from 106 hours to 8.5 hours—a 92% time reduction. By being specific, requesting comprehensive solutions, and leveraging Copilot's knowledge of Azure best practices, you can build production-ready Arc deployment automation quickly and confidently.

**Key Success Factors:**
- ✅ Be explicit about scale (number of servers)
- ✅ Request error handling and retry logic
- ✅ Ask for validation and reporting
- ✅ Specify security requirements upfront
- ✅ Mention both Windows and Linux support
- ✅ Request complete solutions (not just fragments)

**Remember:** GitHub Copilot knows Azure Arc best practices, Azure Policy syntax, PowerShell runspaces, and Log Analytics KQL—leverage this knowledge by asking detailed, specific questions!
