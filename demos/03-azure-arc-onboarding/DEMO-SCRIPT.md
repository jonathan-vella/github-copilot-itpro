# Demo 3: Azure Arc Onboarding at Scale - Presenter Guide

**Duration**: 30 minutes  
**Demo Type**: Live Copilot-assisted development  
**Audience**: IT Pros, Cloud Architects, System Integrators  
**Difficulty**: Intermediate to Advanced

---

## Quick Reference

### Time Allocation

| Phase | Duration | Focus |
|-------|----------|-------|
| **Scene Setting** | 5 min | Customer scenario, manual approach pain |
| **Live Copilot Demo** | 18 min | Build 5 Arc scripts with GitHub Copilot |
| **Deploy & Validate** | 5 min | Test deployment, show results |
| **Business Value Wrap-Up** | 2 min | ROI, metrics, call-to-action |

### Key Metrics to Emphasize

- **Time Savings**: 106 hours → 8.5 hours (92% reduction)
- **Scale**: 500 servers across 12 factories, 8 countries
- **ROI**: $14,625 per project, $58,500-$156K annual value
- **Complexity**: Hybrid cloud, policy-as-code, parallel deployment

---

## Pre-Demo Checklist (Do This Before Presentation)

### Environment Setup

- [ ] **VS Code**: Latest version with GitHub Copilot enabled
- [ ] **PowerShell**: Version 7.4+ installed
- [ ] **Azure Modules**: `Install-Module Az -Force` (Az.ConnectedMachine, Az.Monitor, Az.PolicyInsights)
- [ ] **Azure CLI**: Latest version installed
- [ ] **Demo Repository**: Cloned to local machine
- [ ] **Azure Subscription**: Access to test subscription with Contributor role
- [ ] **Service Principal**: Pre-created for demo (or show creation live)
- [ ] **Test VMs**: 2-3 VMs ready for Arc onboarding (Windows + Linux)

### Audience Discovery (5 Minutes Before Demo)

Ask these questions while attendees join:

1. **"How many of you manage on-premises servers?"** (gauge relevance)
2. **"What tools do you use today?"** (SCCM, Ansible, manual)
3. **"Biggest pain point with hybrid management?"** (visibility, compliance, patching)
4. **"Heard of Azure Arc?"** (adjust technical depth)
5. **"Using GitHub Copilot today?"** (adjust Copilot explanation)

---

## Phase 1: Scene Setting (5 Minutes)

### Opening Hook (30 seconds)

> "Today I'm going to show you how GitHub Copilot helped us reduce a 106-hour Azure Arc onboarding project to 8.5 hours—a 92% time savings. This is not a theoretical example. This is based on a real customer onboarding 500 servers across 12 global factories."

### Customer Scenario (2 minutes)

**Present the scenario** (use `scenario/requirements.md` as reference):

> "GlobalManu Corp is a $3.2B manufacturing company with 500 on-premises servers spread across 12 factories in 8 countries. They have:
> - 320 Windows servers and 180 Linux servers
> - Mix of tools: SCCM, Ansible, manual scripts—all inconsistent
> - No centralized visibility or governance
> - SOC 2 compliance deadline approaching
> - CIO mandate: hybrid cloud transformation is top priority for 2025"

**Show the architecture diagram** (`scenario/architecture.md` - High-Level Architecture):

Open the Mermaid diagram in VS Code preview to visualize:
- 12 facilities with site-to-site VPNs
- 500 servers connecting to Azure Arc
- Azure Policy, Monitor, Security Center integration

### The Manual Approach Pain (2 minutes)

**Walk through the time breakdown** (`manual-approach/time-tracking.md`):

> "Without Copilot, this project takes 106 hours. Let me show you why..."

**Display the breakdown on screen**:

| Phase | Manual Time | Why It Takes So Long |
|-------|-------------|---------------------|
| Planning & Research | 8 hrs | Learning Arc APIs, RBAC requirements, network endpoints |
| Service Principal Setup | 4 hrs | Permission scoping, Key Vault integration, testing |
| Script Development | 20 hrs | Complex parallel logic, error handling, retry mechanisms |
| Manual Deployment | 40 hrs | RDP/SSH to 500 servers, troubleshoot failures |
| Policy Configuration | 16 hrs | Azure Policy JSON syntax, guest configuration |
| Monitoring Setup | 12 hrs | Log Analytics, data collection rules, alert rules |
| Validation | 8 hrs | Check 500 servers, troubleshoot disconnected agents |
| Documentation | 10 hrs | Runbooks, architecture docs, troubleshooting guides |
| **Total** | **106 hrs** | **Over 2.5 work weeks for 1 engineer** |

**Key pain points to emphasize**:

1. **Complexity**: "Azure Arc requires understanding 5+ Azure services simultaneously—RBAC, Policy, Monitor, Extensions, ARM"
2. **Scale**: "Deploying to 500 servers manually means 500 potential failure points to troubleshoot"
3. **Knowledge Gap**: "Most IT Pros haven't done this before—there's a steep learning curve"
4. **Error-Prone**: "One missing RBAC permission or wrong API version = hours of debugging"

### The Copilot Difference (30 seconds)

> "With GitHub Copilot, we're going to build 5 production-ready PowerShell scripts live in 18 minutes. You'll see how Copilot acts as an efficiency multiplier—teaching best practices while we code."

---

## Phase 2: Live Copilot Demo (18 Minutes)

### Demo Flow Overview

You'll build 5 scripts in this order:

1. **New-ArcServicePrincipal.ps1** (3 min) - Create Service Principal with least-privilege RBAC
2. **Install-ArcAgentParallel.ps1** (6 min) - Parallel agent deployment to 500 servers
3. **Set-ArcGovernancePolicy.ps1** (5 min) - Apply Azure Policy at scale
4. **Enable-ArcMonitoring.ps1** (4 min) - Configure Log Analytics and monitoring

**Total Live Coding**: 18 minutes

---

### Script 1: New-ArcServicePrincipal.ps1 (3 Minutes)

**What You're Building**: Service Principal with proper RBAC for Arc onboarding

**Presenter Narrative**:

> "First, we need a Service Principal to authenticate Arc agent connections. This needs specific permissions—too much is a security risk, too little and deployment fails. Let's ask Copilot to help."

**Step 1: Create the file and start with a comment**

```powershell
# Create a Service Principal for Azure Arc onboarding with least-privilege permissions
# Requirements:
# - Azure Connected Machine Onboarding role at subscription scope
# - Log Analytics Contributor role at workspace scope
# - Store credentials in Azure Key Vault
# - Support certificate-based authentication
# - Include validation and error handling
```

**Pause and narrate**:
> "Notice I'm describing WHAT I need, not HOW to code it. Copilot will suggest the implementation."

**Step 2: Let Copilot suggest the function structure**

Press `Enter` and watch Copilot suggest:

```powershell
function New-ArcServicePrincipal {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServicePrincipalName,
        
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory = $true)]
        [string]$LogAnalyticsWorkspaceId,
        
        [Parameter(Mandatory = $true)]
        [string]$KeyVaultName
    )
    # ... Copilot will suggest the rest
}
```

**Accept and highlight**:
> "Copilot automatically added proper parameters with validation. This is PowerShell best practice."

**Step 3: Let Copilot build the logic**

Continue accepting suggestions. Copilot will likely suggest:

- `New-AzADServicePrincipal` for SP creation
- `New-AzRoleAssignment` for RBAC
- `Set-AzKeyVaultSecret` for credential storage
- Error handling with `try/catch`
- Output of SP details

**Highlight "Magic Moments"**:

1. "See how Copilot knew to use `New-AzRoleAssignment` with the correct role definition ID for 'Azure Connected Machine Onboarding'? It's pulling from Azure documentation."

2. "Notice the certificate expiration validation—Copilot added that because it's a security best practice. I didn't even ask for it."

3. "The Key Vault integration is automatic—Copilot knows Service Principal secrets should never be in plaintext."

**Expected Time**: 3 minutes (including explanation)

---

### Script 2: Install-ArcAgentParallel.ps1 (6 Minutes - MOST IMPORTANT)

**What You're Building**: Parallel Arc agent deployment to 500 servers

**Presenter Narrative**:

> "This is the core script. We need to install the Arc agent on 500 servers in 2 weeks. Doing this one-by-one would take 40 hours. We'll use PowerShell runspaces for parallel execution."

**Step 1: Start with requirements comment**

```powershell
# Install Azure Arc Connected Machine agent on multiple servers in parallel
# Requirements:
# - Support Windows (Server 2016+) and Linux (Ubuntu, RHEL, CentOS)
# - Parallel execution with configurable throttle limit (default 50 concurrent)
# - Progress tracking with progress bars
# - Retry logic for failed installations (3 attempts with exponential backoff)
# - Health validation after installation
# - CSV input for server list (Name, OS, IPAddress, Credentials)
# - CSV output for results (Server, Status, Duration, ErrorMessage)
# - Use Service Principal from Key Vault for authentication
# - Support corporate proxy configuration
```

**Pause**:
> "This is a complex requirement. Let's see how Copilot handles it."

**Step 2: Define parameters and let Copilot suggest**

```powershell
function Install-ArcAgentParallel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerListPath,
        
        [Parameter(Mandatory = $false)]
        [int]$ThrottleLimit = 50,
        
        [Parameter(Mandatory = $true)]
        [string]$TenantId,
        
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroup,
        
        [Parameter(Mandatory = $true)]
        [string]$Location
    )
    # Copilot will suggest the rest
}
```

**Step 3: Let Copilot build the script block**

Copilot will suggest a scriptblock for parallel execution. Key elements:

- **CSV Import**: `Import-Csv` to read server list
- **Runspace Pool**: `[runspacefactory]::CreateRunspacePool()` for parallel execution
- **ScriptBlock**: Core logic to deploy Arc agent
- **Progress Tracking**: `Write-Progress` for user feedback
- **Error Handling**: Try/catch with retry logic
- **Results Collection**: Aggregate success/failure

**Highlight "Magic Moments"**:

1. **Runspace Complexity**: "See how Copilot suggested runspaces instead of `Start-Job`? That's because runspaces are much faster for this scale. Copilot knows performance patterns."

2. **OS Detection**: "Notice it's checking the OS type and using different installation commands—WinRM for Windows, SSH for Linux. Copilot understands cross-platform requirements."

3. **Network Validation**: "Copilot added proxy support and network connectivity checks automatically. This prevents 80% of common deployment failures."

4. **Retry Logic**: "See the exponential backoff retry? 1st attempt immediate, 2nd after 5 seconds, 3rd after 15 seconds. That's infrastructure engineering best practice."

**Step 4: Add the Arc agent connection command**

Inside the scriptblock, add a comment:

```powershell
# Connect the server to Azure Arc using azcmagent
```

Copilot will suggest:

```powershell
& 'C:\Program Files\AzureConnectedMachineAgent\azcmagent.exe' connect `
    --service-principal-id $ServicePrincipalId `
    --service-principal-secret $ServicePrincipalSecret `
    --tenant-id $TenantId `
    --subscription-id $SubscriptionId `
    --resource-group $ResourceGroup `
    --location $Location
```

**Highlight**: "Copilot even knows the default installation path for `azcmagent.exe`!"

**Expected Time**: 6 minutes (this is the centerpiece of the demo)

---

### Script 3: Set-ArcGovernancePolicy.ps1 (5 Minutes)

**What You're Building**: Azure Policy definitions and assignments for Arc servers

**Presenter Narrative**:

> "Now that servers are Arc-enabled, we need governance. Azure Policy ensures every server has tags, security baselines, and monitoring. Let's write policy-as-code."

**Step 1: Requirements comment**

```powershell
# Apply Azure Policy definitions to Arc-enabled servers
# Requirements:
# - Enforce required tags (CostCenter, Owner, Environment, Application)
# - Apply security baseline for Windows and Linux
# - Require Log Analytics agent installation
# - Enable Update Management extension
# - Support policy assignment at subscription or resource group scope
# - Generate compliance report after assignment
```

**Step 2: Let Copilot build the function**

Copilot will suggest:

- **Policy Definitions**: JSON templates for each policy
- **Policy Assignment**: `New-AzPolicyAssignment` cmdlets
- **Compliance Check**: `Get-AzPolicyState` for reporting
- **Remediation**: `Start-AzPolicyRemediation` for non-compliant resources

**Highlight "Magic Moments"**:

1. **Policy JSON**: "Copilot generated the Azure Policy definition JSON—most engineers would spend 2 hours Googling the correct syntax for DeployIfNotExists effect."

2. **Built-in Policy IDs**: "See how it's using built-in Azure Policy IDs like `/providers/Microsoft.Authorization/policyDefinitions/...`? Copilot knows the Azure Policy catalog."

3. **Compliance Reporting**: "The compliance check script Copilot added gives us a CSV report for auditors—exactly what SOC 2 requires."

**Step 3: Add compliance visualization**

Add comment:

```powershell
# Display compliance summary with color-coded output
```

Copilot suggests color-coded `Write-Host` output:

- Green: Compliant resources
- Yellow: Resources in progress
- Red: Non-compliant resources

**Expected Time**: 5 minutes

---

### Script 4: Enable-ArcMonitoring.ps1 (4 Minutes)

**What You're Building**: Configure Log Analytics and Azure Monitor for Arc servers

**Presenter Narrative**:

> "Final step: observability. We need performance metrics, logs, and alerting for 500 servers. Copilot will help us configure Azure Monitor at scale."

**Step 1: Requirements comment**

```powershell
# Enable Azure Monitor and Log Analytics for Arc-enabled servers
# Requirements:
# - Install Azure Monitor Agent (AMA) extension
# - Create data collection rules (DCR) for Windows and Linux
# - Configure performance counters (CPU, memory, disk, network)
# - Enable System and Security event log collection
# - Set up alert rules for critical metrics (CPU > 90%, disk < 10%)
# - Create Azure Workbook for operational dashboard
```

**Step 2: Let Copilot build**

Copilot will suggest:

- **AMA Extension**: `New-AzConnectedMachineExtension` for Azure Monitor Agent
- **DCR Creation**: `New-AzDataCollectionRule` with performance counters
- **Alert Rules**: `New-AzMetricAlertRuleV2` for threshold alerts
- **Workbook**: JSON template for Azure Workbook dashboard

**Highlight "Magic Moments"**:

1. **DCR Configuration**: "Copilot generated the data collection rule JSON with correct performance counter names—`\Processor(_Total)\% Processor Time` for Windows, `avg_cpu_usage` for Linux."

2. **Alert Queries**: "See the KQL queries for alerts? Copilot knows Kusto Query Language and wrote multi-conditional alert logic."

3. **Dashboard JSON**: "Copilot created an Azure Workbook JSON template. Most engineers would use the Portal GUI—this is Infrastructure-as-Code at its best."

**Expected Time**: 4 minutes

---

### Pacing Tips for Live Demo

**If You're Ahead of Schedule**:
- Add more explanation of what Copilot suggested
- Show the Azure Portal to visualize Arc servers
- Take more audience questions
- Show the `manual-approach/time-tracking.md` in detail

**If You're Behind Schedule**:
- Skip detailed explanation of Script 3 or 4
- Say: "In the interest of time, I'll let Copilot finish this script while we move on"
- Focus on Scripts 1 and 2 (Service Principal + Parallel Deployment)
- Jump to results (Phase 3)

---

## Phase 3: Deploy & Validate (5 Minutes)

### Deployment (2 Minutes)

**Presenter Narrative**:

> "Let's deploy this to real Azure resources. I have 3 test VMs ready—2 Windows, 1 Linux."

**Step 1: Run New-ArcServicePrincipal.ps1**

```powershell
# In terminal
.\with-copilot\New-ArcServicePrincipal.ps1 `
    -ServicePrincipalName "Demo-Arc-SP" `
    -SubscriptionId "YOUR_SUB_ID" `
    -LogAnalyticsWorkspaceId "/subscriptions/.../workspaces/..." `
    -KeyVaultName "YourKeyVault"
```

**Show output**:
- Service Principal created
- RBAC roles assigned
- Credentials stored in Key Vault

**Step 2: Run Install-ArcAgentParallel.ps1**

```powershell
# In terminal
.\with-copilot\Install-ArcAgentParallel.ps1 `
    -ServerListPath ".\test-servers.csv" `
    -TenantId "YOUR_TENANT_ID" `
    -SubscriptionId "YOUR_SUB_ID" `
    -ResourceGroup "rg-demo-arc" `
    -Location "eastus2" `
    -ThrottleLimit 3
```

**Show output**:
- Progress bar (3 servers in parallel)
- Success messages
- Total time (should be ~2-3 minutes for 3 servers)

### Validation (3 Minutes)

**Step 1: Show Azure Portal**

Navigate to **Azure Arc > Servers**:

- Show 3 connected machines
- Display metadata (OS, location, status)
- Show "Managed Identity" assigned automatically

**Step 2: Show Policy Compliance**

Navigate to **Azure Policy > Compliance**:

- Show policy assignments (tagging, security baseline)
- Display compliance percentage
- Click a policy to show which servers are compliant

**Step 3: Show Monitoring Data**

Navigate to **Azure Monitor > Logs**:

Run a KQL query:

```kusto
Perf
| where Computer contains "Demo"
| where CounterName == "% Processor Time"
| summarize avg(CounterValue) by Computer
| render barchart
```

Show CPU metrics from Arc-enabled servers.

**Expected Time**: 5 minutes total (2 min deployment, 3 min validation)

---

## Phase 4: Business Value Wrap-Up (2 Minutes)

### Show the Metrics (1 Minute)

**Display the comparison table** (from `README.md`):

| Activity | Manual Time | With Copilot | Time Saved |
|----------|-------------|--------------|------------|
| Script Development | 20 hrs | 2 hrs | 18 hrs (90%) |
| Agent Deployment | 40 hrs | 3 hrs | 37 hrs (93%) |
| Policy Configuration | 16 hrs | 1.5 hrs | 14.5 hrs (91%) |
| Monitoring Setup | 12 hrs | 1 hr | 11 hrs (92%) |
| Validation | 8 hrs | 0.5 hrs | 7.5 hrs (94%) |
| Documentation | 10 hrs | 0.5 hrs | 9.5 hrs (95%) |
| **Total** | **106 hrs** | **8.5 hrs** | **97.5 hrs (92%)** |

**Presenter Narrative**:

> "We just built in 18 minutes what would take 20 hours manually. That's a 92% time reduction. For GlobalManu Corp:
> - Project time: 106 hours → 8.5 hours
> - Cost savings: $14,625 per project
> - They do this quarterly: 4 projects/year = $58,500 annual savings
> - At enterprise scale (1500+ servers): $156,000+ annual value"

### The ROI Story (30 Seconds)

> "Here's the math:
> - GitHub Copilot: $39/month per engineer
> - This demo alone saved 97.5 hours @ $150/hour = $14,625
> - ROI: 38,000% on just ONE project
> - Payback period: Less than 1 day of work"

### Call to Action (30 Seconds)

**For Customers**:
> "If you're managing hybrid infrastructure, Arc + Copilot is a game-changer. Let's schedule a pilot to onboard your first 50 servers. We can show ROI in 2 weeks."

**For Partners**:
> "This demo is in the Partner Toolkit. You can deliver this to your customers and close Arc deals faster. I'll share the repo link and ROI calculator."

---

## Objection Handling (If Time Permits)

### "This looks too complex for my team"

**Response**:
> "That's exactly WHY Copilot is valuable. Your team doesn't need to be Azure Arc experts—Copilot teaches them as they code. It's like having a senior cloud architect pair-programming with every engineer."

**Proof Point**: Show how Copilot added comments and best practices automatically

---

### "We already use SCCM/Ansible"

**Response**:
> "Arc doesn't replace those—it augments them. You can keep SCCM for Windows patching and Ansible for config management, while Arc gives you centralized governance, Azure Policy, and Security Center. They work together."

**Proof Point**: Show the architecture diagram with SCCM/Ansible integration points

---

### "What if Arc agent goes offline?"

**Response**:
> "Great question. The agent buffers telemetry locally for up to 24 hours and auto-reconnects. We also set up alerts—if an agent is offline for 15 minutes, Azure Monitor notifies us. The validation script we built checks agent health automatically."

**Proof Point**: Show the health check in `Test-ArcConnectivity.ps1`

---

## Post-Demo Follow-Up

### Same Day (Within 2 Hours)

**Send email with**:
1. **Link to GitHub repository**: All scripts they saw in the demo
2. **ROI Calculator**: `partner-toolkit/roi-calculator.md` customized for their environment
3. **Recording** (if permitted): Link to demo recording
4. **Next Steps**:
   - Schedule pilot kickoff call (suggest specific dates)
   - Send questionnaire about their environment (server count, OS mix, tools)
   - Offer GitHub Copilot trial licenses

### Within 48 Hours

**Deliver pilot proposal**:
- Scope: Onboard 50 servers in 1 week
- Cost: GitHub Copilot licenses + Azure Arc costs (estimate)
- Success criteria: 90% first-time success rate, 80% time reduction
- Timeline: 2-week pilot with Go/No-Go decision

### Within 1 Week

**Send implementation roadmap**:
- Phase 1: Pilot (50 servers, 1 week)
- Phase 2: Production rollout (remaining servers, 2-4 weeks)
- Phase 3: Governance & optimization (policies, monitoring, dashboards)
- Training: 2-hour Copilot onboarding for their team

---

## Demo Environment Troubleshooting

### Common Issues

**Issue**: Copilot not suggesting code

**Solution**:
- Check Copilot status icon (bottom right of VS Code)
- Restart VS Code
- Use fallback: Type partial code and press `Tab` to trigger suggestions
- Emergency: Show pre-written scripts from `with-copilot/` folder

---

**Issue**: Azure authentication fails during deployment

**Solution**:
- Run `Connect-AzAccount` before the demo
- Use `Get-AzContext` to verify subscription
- Fallback: Show validation results from previous test run (screenshots)

---

**Issue**: Test VMs not responding

**Solution**:
- Verify VMs are running: `Get-AzVM -Status`
- Check NSG rules allow WinRM (5985, 5986) or SSH (22)
- Fallback: Show Portal screenshots of previous successful deployment

---

## Backup Plan (If Live Demo Fails)

**Option 1: Show Pre-Recorded Demo**

If technical issues occur, switch to pre-recorded video:
> "I want to respect your time, so let me show you a recording of this working in our test environment..."

**Option 2: Walk Through Code Without Execution**

Show the scripts in VS Code and explain:
- Copilot suggestions (use inline comments to simulate)
- Key logic sections
- Business value at each step

**Option 3: Show Results Only**

Jump directly to Azure Portal:
- Show Arc-enabled servers
- Display policy compliance
- Show monitoring dashboards
- Walk through time savings calculation

---

## Advanced Demo Variations

### For Technical Audiences (Add 10 Minutes)

**Dive deeper into**:
- Runspace vs. `Start-Job` performance comparison
- Azure Policy DeployIfNotExists effect internals
- Data Collection Rule JSON schema
- Certificate-based authentication for Service Principal

**Show additional scripts**:
- `Test-ArcConnectivity.ps1` (validation script)
- `cleanup.ps1` (resource removal)

---

### For Executive Audiences (Shorten to 20 Minutes)

**Focus on**:
- Business scenario (3 min)
- Quick Copilot magic demo (8 min) - only Scripts 1 and 2
- Results in Portal (4 min)
- ROI and business value (5 min)

**Skip**:
- Detailed script explanations
- PowerShell syntax discussions
- Validation steps

---

### For Hands-On Workshop (Extend to 90 Minutes)

**Add**:
- Attendee machines with Copilot installed
- Guided exercise: Build Script 1 together
- Self-paced: Build Scripts 2-4 with Copilot
- Group discussion: Share Copilot "wow moments"
- Q&A and troubleshooting session

---

## Presenter Tips

### Do's

✅ **Pause after Copilot suggestions** - Let audience see the magic happen  
✅ **Narrate your thinking** - "I need error handling here, let's see if Copilot suggests it..."  
✅ **Make mistakes** - Type something wrong, show Copilot helping fix it  
✅ **Show surprise** - "Wow, Copilot added retry logic—I didn't even ask for that!"  
✅ **Use their language** - If audience mentions tools (SCCM, Nagios), incorporate into narrative  
✅ **Show enthusiasm** - Your excitement is contagious

### Don'ts

❌ **Don't rush** - Silence is okay; let Copilot suggestions appear  
❌ **Don't apologize** - If Copilot suggests something unexpected, roll with it  
❌ **Don't read slides** - This is a live demo, not a presentation  
❌ **Don't skip validation** - Showing it works in Azure is critical for credibility  
❌ **Don't ignore questions** - If asked mid-demo, pause and answer (or note for later)  
❌ **Don't go off-script** - Stay focused on the 5 core scripts

---

## Materials to Bring

**Printed** (for in-person demos):
- [ ] One-page ROI calculator (filled out for their environment if possible)
- [ ] Architecture diagram (high-level view)
- [ ] Your business card with follow-up info

**Digital** (for virtual or in-person):
- [ ] This demo script open in second monitor
- [ ] Azure Portal open and logged in
- [ ] GitHub repository cloned locally
- [ ] Test server CSV file prepared
- [ ] Follow-up email draft ready to send
- [ ] Customer's environment questionnaire

---

## Success Metrics (Track After Demo)

| Metric | Target | How to Measure |
|--------|--------|----------------|
| **Engagement** | 80%+ attentive | Audience questions, note-taking |
| **Technical Credibility** | No major errors | Demo runs smoothly, validation succeeds |
| **Interest Level** | 3+ substantive questions | Questions about pricing, timeline, pilot |
| **Next Step Commitment** | Meeting scheduled | Pilot kickoff call booked same day |
| **Partner Activation** | Repo cloned | Partners download toolkit materials |

---

**Demo Version**: 1.0  
**Last Updated**: November 2025  
**Demo Owner**: Cloud Infrastructure Team  
**Feedback**: [email protected]

**Pro Tip**: Practice this demo 3 times before delivering to a customer. Time yourself to ensure you stay within 30 minutes. Record yourself to identify areas for improvement.
