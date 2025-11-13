# Demo 2: PowerShell Automation - Accelerate Azure Operations

⏱️ **Duration**: 30 minutes  
🎯 **Difficulty**: Beginner to Intermediate  
💡 **Value**: 75% time reduction (60 min → 15 min)

## Overview

This demo showcases how GitHub Copilot accelerates PowerShell script development for Azure operations. You'll build a comprehensive resource management and reporting solution that traditionally takes an hour in just 15 minutes with Copilot assistance.

**Perfect for**: IT Ops teams, system administrators, cloud engineers automating Azure management tasks

## Learning Objectives

By completing this demo, participants will learn to:

1. ✅ Use GitHub Copilot to generate PowerShell functions with proper syntax
2. ✅ Create Azure automation scripts with error handling and logging
3. ✅ Build interactive PowerShell tools with parameter validation
4. ✅ Generate comprehensive reports from Azure resources
5. ✅ Implement best practices without memorizing cmdlet syntax

## Scenario

**Customer Profile**: Enterprise IT Operations team managing 200+ Azure subscriptions

**Challenge**: The team needs to audit and manage Azure resources across multiple subscriptions. Daily tasks include:
- Generating cost reports for finance team
- Finding and tagging untagged resources
- Identifying orphaned resources (unused NICs, disks, IPs)
- Bulk operations (start/stop VMs, apply tags)

**Traditional Approach**: 
- Write PowerShell scripts from scratch or copy-paste from docs
- Debug syntax errors and parameter issues
- Research Azure cmdlets and their parameters
- Test and fix error handling
- **Time: 60-90 minutes per script**

**With Copilot**:
- Describe what you need in natural language comments
- Accept Copilot's cmdlet suggestions
- Generate error handling automatically
- **Time: 15-20 minutes per script**

**Business Impact**: 
- ⚡ 75% faster script development
- 📊 Better quality with built-in error handling
- 🎓 Learn Azure PowerShell by doing
- 💰 20+ hours saved per month per engineer

## What You'll Build

A comprehensive PowerShell automation toolkit with:
- Resource reporting across subscriptions
- Compliance auditing (tagging)
- Orphaned resource cleanup
- Bulk operations (tags, VM management)

## Prerequisites

### Required Tools
- ✅ PowerShell 7+
- ✅ Azure PowerShell Module (Az)
- ✅ VS Code with GitHub Copilot
- ✅ Azure subscription with Reader access

## Quick Start

```powershell
# Navigate to with-copilot folder
cd demos/02-powershell-automation/with-copilot

# Connect to Azure
Connect-AzAccount

# Run resource report
.\Get-AzResourceReport.ps1 -SubscriptionId "your-sub-id"
```

## Success Metrics

| Metric | Manual | With Copilot | Improvement |
|--------|--------|--------------|-------------|
| Development Time | 60 min | 15 min | 75% reduction |
| Lines Typed | 300+ | 80 | 73% less |
| Syntax Errors | 5-10 | 0-1 | 90% fewer |

[🏠 Back to Main README](../../README.md)
