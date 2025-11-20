# Demo Script: PowerShell Automation with GitHub Copilot

⏱️ **Total Duration**: 30 minutes  
🎯 **Target Audience**: IT Ops, System Administrators, Cloud Engineers  
📊 **Demonstrated Value**: 60 min → 15 min (75% time reduction)

---

## Pre-Demo Checklist

### 5 Minutes Before Demo

- [ ] Azure PowerShell logged in: \Connect-AzAccount\
- [ ] VS Code open with GitHub Copilot active
- [ ] PowerShell Extension active in VS Code
- [ ] Test subscription accessible
- [ ] Have [prompts/effective-prompts.md](./prompts/effective-prompts.md) open

### Environment Setup

\\\powershell

# Verify PowerShell version (need 7+)

\System.Management.Automation.PSVersionHashTable.PSVersion

# Verify Az module

Get-Module -ListAvailable Az.* | Select-Object Name, Version

# Connect to Azure

Connect-AzAccount
Get-AzContext
\\\

---

## Demo Flow

### Phase 1: Scene Setting (5 minutes)

#### 1.1 Introduce the Scenario (2 min)

**Script:**
> "Today we're helping an enterprise IT operations team that manages 200+ Azure subscriptions. Their daily challenges include:
>
> - Generating reports for the finance team (2 hours/day manually)
> - Finding untagged resources for compliance (4 hours/week)
> - Cleaning up orphaned resources wasting /month
>
> Traditionally, building these PowerShell automation scripts takes 60-90 minutes per script. With GitHub Copilot, we'll build a complete automation toolkit in 15 minutes."

**Show the scenario:**

- Open [scenario/requirements.md](./scenario/requirements.md)
- Highlight: 200+ subscriptions, daily reporting needs, cost optimization goals

#### 1.2 Show Traditional Approach (3 min)

**Script:**
> "The traditional approach involves:
>
> - Looking up Azure PowerShell cmdlet syntax
> - Copy-pasting from documentation
> - Debugging parameter errors
> - Writing error handling manually
> - Testing and fixing issues
>
> Let's see how Copilot changes this."

---

### Phase 2: Copilot-Assisted Development (18 minutes)

#### 2.1 Create Resource Reporting Function (6 min)

**Action:** Create new file \Get-AzResourceReport.ps1\

**Script:**
> "I'll start by describing what I need in a comment."

**Type this comment:**
\\\powershell

# Create a function to get all Azure resources with details

# Export to CSV, JSON, or HTML based on file extension

# Include progress indicator

\\\

**PAUSE** and let Copilot suggest.

**Script:**
> "Look what Copilot generated:
>
> - Comment-based help with .SYNOPSIS, .DESCRIPTION
> - Parameter validation with patterns
> - Module import with error handling
> - Azure connection check
> - Progress bar logic
> - Switch statement for different export formats
>
> This is 150+ lines of production-ready code from a simple comment. Manually, this would take 20-25 minutes."

**Type:** \# Add parameter validation for subscription ID (must be GUID)\

**Accept Copilot's ValidatePattern suggestion**

**Script:**
> "Copilot knows the regex pattern for Azure subscription IDs. No need to look it up or remember it."

**Save file:** \Ctrl+S\

---

#### 2.2 Create Compliance Auditing Function (5 min)

**Action:** Create new file \Find-UntaggedResources.ps1\

**Type this prompt:**
\\\powershell

# Find all Azure resources missing required tags

# Required tags: Environment, Owner, CostCenter

# Display results with color coding (red for non-compliant)

# Export to CSV if output path specified

\\\

**Accept Copilot's suggestion**

**Script:**
> "Copilot generated:
>
> - Parameter for RequiredTags array
> - Logic to check each resource's tags
> - Custom object creation for missing tags
> - Color-coded console output with Write-Host
> - Conditional CSV export
>
> This compliance checker would take 15-20 minutes manually. We just built it in 2 minutes."

**Test the logic:**
\\\powershell

# Run against your subscription

.\\Find-UntaggedResources.ps1 -RequiredTags @('Environment','Owner') -OutputPath 'untagged.csv'
\\\

**Show results** in console and open CSV

---

#### 2.3 Create Orphaned Resource Cleanup (4 min)

**Action:** Create new file \Remove-OrphanedResources.ps1\

**Type this prompt:**
\\\powershell

# Find and remove orphaned Azure resources

# Find unattached managed disks

# Find unused public IPs

# Find NICs not attached to VMs

# Add confirmation prompt before deletion

# Calculate cost savings

\\\

**Accept Copilot's suggestions**

**Script:**
> "Copilot understands the concept of 'orphaned resources' and generated:
>
> - Separate queries for disks, public IPs, and NICs
> - Filter logic to identify unused resources
> - Confirmation prompt with resource details
> - Cost calculation based on SKU and size
> - Safe deletion with error handling
>
> This type of script would take 25-30 minutes to write and test manually. With Copilot: 4 minutes."

**Demo dry-run mode:**
\\\powershell

# Show what would be deleted (don't actually delete)

.\\Remove-OrphanedResources.ps1 -WhatIf
\\\

---

#### 2.4 Create Bulk Tag Operations (3 min)

**Action:** Create new file \Set-BulkTags.ps1\

**Type this prompt:**
\\\powershell

# Apply tags to all resources in a resource group

# Support hashtable of tag name/value pairs

# Add dry-run mode to preview changes

# Use parallel processing for faster execution

# Show progress bar

\\\

**Accept Copilot's suggestion**

**Script:**
> "Copilot generated advanced features:
>
> - ForEach-Object -Parallel for 10x faster execution
> - -WhatIf parameter for safe testing
> - Progress tracking across parallel operations
> - Proper error handling in parallel blocks
>
> The parallel processing alone would take 15 minutes to implement correctly. Copilot did it instantly."

**Demo:**
\\\powershell

# Preview changes without applying

.\\Set-BulkTags.ps1 -ResourceGroupName 'rg-demo' -Tags @{Owner='IT Ops'; Environment='Production'} -WhatIf
\\\

---

### Phase 3: Key Takeaways & Q&A (7 minutes)

#### 3.1 Summarize Value (4 min)

**Script:**
> "Let's recap what GitHub Copilot enabled:
>
> **Speed**: 15 minutes vs. 70 minutes (79% faster)
>
> - Generated 400+ lines of code from natural language prompts
> - Zero syntax errors on first run
> - All functions have complete error handling
>
> **Quality**:
>
> - Comment-based help on every function
> - Parameter validation with proper attributes
> - Progress indicators for better UX
> - Parallel processing for performance
>
> **Learning Accelerator**:
>
> - No need to memorize cmdlet syntax
> - Learn PowerShell best practices by seeing examples
> - Context-aware suggestions teach proper patterns
>
> **Business Impact**:
>
> - 20+ hours saved per month per admin
> - \,600 annual savings for 12-person team
> - Better quality code = easier maintenance
> - Faster response to business needs"

**Show the comparison table:**

| Task | Manual | With Copilot | Improvement |
|------|--------|--------------|-------------|
| Parameter Validation | 10 min | 1 min | 90% |
| Error Handling | 15 min | 2 min | 87% |
| Core Logic | 20 min | 8 min | 60% |
| **Total** | **70 min** | **15 min** | **79%** |

#### 3.2 Live Demo (3 min)

**Run one of the scripts against your Azure subscription:**

\\\powershell

# Generate resource report

.\\Get-AzResourceReport.ps1 -OutputPath 'azure-resources.html'

# Open HTML report

Start-Process 'azure-resources.html'
\\\

**Show the formatted HTML report** with all resources listed

**Script:**
> "This report would typically require:
>
> - 30 minutes to build the PowerShell logic
> - 20 minutes to create HTML formatting
> - 10 minutes to debug and test
>
> With Copilot: 5 minutes total. And the HTML output looks professional with minimal effort."

---

### Phase 4: Next Steps (2 minutes)

**Script:**
> "Here's how to get started:
>
> **For IT Operations Teams:**
>
> 1. Clone this repository
> 2. Try the scripts in your environment
> 3. Customize for your specific needs
> 4. Build your own automation library
>
> **For Managers:**
>
> 1. Calculate your team's ROI
> 2. Use the cost savings data to justify Copilot licenses
> 3. Track time savings over first month
>
> **Next Demos:**
>
> - [Demo 3: Azure Arc Onboarding](../03-azure-arc-onboarding/) - Hybrid management at scale
> - [Demo 4: Troubleshooting Assistant](../04-troubleshooting-assistant/) - Faster problem resolution"

---

## Troubleshooting Guide

### Copilot Not Suggesting PowerShell

**Issue:** No suggestions appear

**Solutions:**

1. Ensure file has \.ps1\ extension
2. Check PowerShell extension is active (bottom right of VS Code)
3. Press \Ctrl+Enter\ to open Copilot panel
4. Try rephrasing your comment

### Azure Connection Issues

**Issue:** Scripts fail with authentication errors

**Solutions:**
\\\powershell

# Re-authenticate

Connect-AzAccount

# Check current context

Get-AzContext

# List available subscriptions

Get-AzSubscription

# Set specific subscription

Set-AzContext -SubscriptionId 'your-sub-id'
\\\

---

## Presentation Tips

### Engaging Your Audience

1. **Pause after Copilot suggestions**: Let the "wow" moment sink in
2. **Highlight specific features**: "Notice how Copilot added parallel processing automatically"
3. **Show before/after**: Compare manual cmdlet lookup vs. Copilot generation
4. **Live execution**: Actually run the scripts to show they work
5. **Real data**: Use actual Azure subscription for authentic demo

### Time Management

| Phase | Target Time | Flex Time |
|-------|-------------|-----------|
| Scene Setting | 5 min | +2 min |
| Copilot Dev | 18 min | -5 min |
| Takeaways | 7 min | +3 min |
| **Total** | **30 min** | **±5 min** |

---

**🎯 Goal**: Show that GitHub Copilot is an efficiency multiplier for PowerShell automation  
**💡 Key Message**: "15 minutes with Copilot = 70 minutes of manual work"  
**🚀 Call to Action**: "Start automating with Copilot today"

[🏠 Back to Demo README](./README.md) | [📚 View All Demos](../../README.md#-featured-demos)
