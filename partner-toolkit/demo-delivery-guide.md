# Partner Demo Delivery Guide

## Overview

This guide helps System Integrator partners effectively deliver GitHub Copilot for IT Pros demonstrations to customers. Each demo is designed to be completed in 30 minutes with clear business value messaging.

---

## Pre-Demo Preparation

### 1. Environment Setup (15 minutes before demo)

**Required Tools:**

- [ ] VS Code with GitHub Copilot extension installed
- [ ] Azure CLI installed and authenticated
- [ ] PowerShell 7+ installed
- [ ] Bicep CLI installed
- [ ] Azure subscription with Contributor access
- [ ] GitHub account with Copilot license

**Test Your Setup:**

```powershell
# Verify Azure CLI
az --version
az account show

# Verify PowerShell Az modules
Get-Module -ListAvailable Az.* | Select-Object Name, Version

# Verify Bicep
bicep --version

# Verify GitHub Copilot
code --list-extensions | Select-String copilot
```

### 2. Customer Discovery (Before Demo)

Ask these questions to tailor your demo:

**Team Context:**

- How many IT professionals manage Azure infrastructure?
- What's the mix of senior vs. junior engineers?
- Average hourly rate for IT staff?

**Current Challenges:**

- How do you currently deploy Azure infrastructure?
- How long does it take to create a typical deployment template?
- How often do you encounter deployment errors?
- How much time is spent on operational scripts?
- Do you have orphaned resources or tagging issues?

**Hybrid Cloud:**

- Do you have on-premises servers?
- Are you using Azure Arc?
- Plans for hybrid cloud expansion?

**Documentation:**

- How do you maintain infrastructure documentation?
- How often is documentation out of date?
- Who creates runbooks and architecture docs?

---

## Demo 1: Bicep Quickstart (30 minutes)

### Target Audience

IT Pros responsible for infrastructure deployment, cloud architects, DevOps engineers

### Business Value Pitch

*"Reduce infrastructure deployment time by 78% while improving quality and security. What takes 45 minutes manually can be done in 10 minutes with Copilot, with zero errors on first deployment."*

### Delivery Flow

#### Phase 1: Scene Setting (5 minutes)

**Show the pain:**

```

"Before we start, let me show you what infrastructure deployment looks like WITHOUT Copilot..."

```

1. Open `demos/01-bicep-quickstart/manual-approach/time-tracking.md`
2. Walk through: 81 minutes, 3 failed deployments, syntax errors
3. Show complexity of ARM templates (confusing JSON)

**State the goal:**

```

"Today we'll deploy a secure Azure network with 3 subnets, 3 NSGs with security rules,
and a storage account with blob services. Typically 45 minutes. Let's do it in 10."

```

#### Phase 2: Live Copilot Development (18 minutes)

**Step 1: Network Infrastructure (7 minutes)**

1. Create `network.bicep` file
2. Type comment: `// Create a VNet with 3 subnets for app, data, and management tiers`
3. **PAUSE** - Let Copilot suggest the entire resource
4. Accept suggestion (Tab key)
5. Point out:
   - Correct API version automatically
   - Parameter names follow conventions
   - Location uses parameter pattern

**Copilot Magic Moments to Highlight:**

- "Notice Copilot added the `@description` decorator automatically"
- "It inferred we need address prefixes for each subnet"
- "The naming follows Azure best practices"

**Step 2: Network Security Groups (6 minutes)**

1. Type: `// Create NSG for app tier allowing HTTPS inbound`
2. Accept Copilot suggestion
3. Type: `// Add rule allowing port 443 from internet`
4. Show how Copilot suggests complete security rules

**Key Message:**

```

"Copilot knows Azure security best practices. It's suggesting priority 100 for allow rules,
priority 4096 for deny rules, and properly structured rule properties."

```

**Step 3: Storage Account (5 minutes)**

1. Create `storage.bicep`
2. Type: `// Create secure storage account with blob services, HTTPS only, TLS 1.2+`
3. Show Copilot suggesting:
   - `supportsHttpsTrafficOnly: true`
   - `minimumTlsVersion: 'TLS1_2'`
   - `allowBlobPublicAccess: false`

**Key Message:**

```

"Security by default. Copilot learned from millions of repositories and knows
that modern storage accounts should have these security settings."

```

#### Phase 3: Validation & Deployment (5 minutes)

**Option A: Live Deploy (if time permits)**

```powershell
cd demos/01-bicep-quickstart/validation
.\deploy.ps1 -ResourceGroupName "rg-demo-001" -Environment dev
```

**Option B: Show Pre-Deployed (safer)**

1. Switch to Azure Portal
2. Show deployed resources
3. Walk through security configurations
4. Show NSG rules that Copilot generated

#### Phase 4: Business Value Wrap-Up (2 minutes)

**Show the metrics:**

```yaml
Manual Approach: 81 minutes, 3 failed deployments
With Copilot: 10 minutes, zero errors
Time Savings: 78%

For a team of 5 engineers doing this 24 times per year:
Annual savings: $40,500
```

**Ask for commitment:**

```javascript
"Based on what you've seen, how many infrastructure deployments does your team do per month?
Let me calculate your specific ROI..."
```

---

## Demo 2: PowerShell Automation (30 minutes)

### Target Audience

IT operations teams, Azure administrators, compliance officers

### Business Value Pitch

*"Eliminate 2 hours per day of manual Azure operations. Automate resource reporting, compliance auditing, and cost optimization with production-ready scripts generated in minutes."*

### Delivery Flow

#### Phase 1: Scene Setting (5 minutes)

**Show the pain:**

```javascript
"Let me show you what IT operations teams tell us they struggle with..."
```

1. Open `demos/02-powershell-automation/scenario/requirements.md`
2. Highlight:
   - 2 hours/day manual reporting
   - $5K/month wasted on orphaned resources
   - 4 hours/week compliance auditing
3. Show manual development time: 130 minutes

**State the goal:**

```bicep
"We'll build 4 production-ready PowerShell scripts in 15 minutes:
1. Resource reporting with multiple export formats
2. Compliance auditing for untagged resources
3. Orphaned resource cleanup with cost estimates
4. Bulk tagging with parallel processing"
```

#### Phase 2: Live Copilot Development (18 minutes)

**Script 1: Resource Reporting (5 minutes)**

1. Create `Get-AzResourceReport.ps1`
2. Type:

```powershell
<#
.SYNOPSIS
    Generate comprehensive Azure resource inventory report
#>
```

3. Accept Copilot's comment-based help completion
4. Type: `[CmdletBinding()]` and let Copilot suggest parameters
5. Type: `# Get all resources in subscription` and accept function logic

**Copilot Magic Moments:**

- "See how Copilot added proper parameter validation?"
- "It included progress bars automatically"
- "Multiple export formats without us asking"

**Script 2: Orphaned Resource Cleanup (6 minutes)**

1. Create `Remove-OrphanedResources.ps1`
2. Type: `# Find unattached managed disks`
3. Show Copilot suggesting: `Get-AzDisk | Where-Object { $null -eq $_.ManagedBy }`
4. Type: `# Calculate cost savings`
5. Show Copilot adding cost estimation logic

**Key Message:**

```

"This script will save you $244,000 per year by finding and removing orphaned resources.
Copilot just generated the logic to identify them and calculate savings."

```

**Script 3: Bulk Tagging (7 minutes)**

1. Create `Set-BulkTags.ps1`
2. Type: `# Tag multiple resources in parallel with merge mode`
3. Show Copilot suggesting Start-Job parallelization
4. Type: `# Add dry-run mode for validation`
5. Show Copilot adding confirmation prompts

**Key Message:**

```

"Notice the safety features Copilot added? Dry-run mode, confirmation prompts,
parallel processing - these are production-ready patterns."

```

#### Phase 3: Show Results (5 minutes)

**Demonstrate script quality:**

1. Open one complete script
2. Show comment-based help
3. Show parameter validation
4. Show error handling
5. Show progress indicators

**Compare to manual:**

- Manual: 130 minutes, multiple syntax errors, incomplete error handling
- Copilot: 15 minutes, production-ready, comprehensive features

#### Phase 4: Business Value Wrap-Up (2 minutes)

**Show the metrics:**

```

Manual Development: 130 minutes
With Copilot: 15 minutes
Time Savings: 88%

Operational Savings:

- 2 hours/day reporting → 15 minutes: $842,400/year for 12-person team
- Orphaned resource cleanup: $244,000/year Azure cost reduction
Total Annual Value: $1,086,000

```

---

## Demo 3: Azure Arc Onboarding (30 minutes)

*(Coming soon - Highest impact demo showing 90% time savings)*

---

## Handling Common Objections

### Objection 1: "Is the code secure?"

**Response:**

```

"Great question. Copilot learns from millions of public repositories, including Microsoft's own
Azure patterns. Notice how it automatically suggested:

- HTTPS only on storage accounts
- TLS 1.2 minimum
- No public blob access
- Proper NSG deny rules

These are security best practices built-in. Plus, YOU review every suggestion before accepting it.
Copilot accelerates, but you're still in control."

```

### Objection 2: "What about our junior engineers?"

**Response:**

```

"This is actually one of the biggest benefits! Junior engineers learn WHILE they work. Copilot
suggests best practices, proper patterns, and correct syntax. It's like having a senior engineer
pair programming with them. We've seen junior engineers become productive 60% faster."

```

### Objection 3: "We have specific company standards"

**Response:**

```

"Perfect! Copilot learns from your existing codebase. Store your templates and scripts in the
same repository, and Copilot will suggest patterns that match YOUR standards. You can also use
.copilot-instructions.md files to specify company-specific guidelines."

```

### Objection 4: "How much does it cost?"

**Response:**

```

"GitHub Copilot is $39/user/month for enterprise. Let's do the math:

- Investment for 15-person team: $7,020/year
- Savings based on what we just demonstrated: $930,600/year
- ROI: 13,156%
- Payback period: 3 days

And that's just time savings. We haven't counted reduced errors, better security,
or the Azure cost reduction from orphaned resource cleanup."

```

### Objection 5: "Our code is proprietary/confidential"

**Response:**

```

"Your code never leaves your environment for training. Copilot uses the model Microsoft trained,
but your proprietary code stays private. You can also use GitHub Copilot Enterprise which has
additional compliance and privacy features."

```

---

## Post-Demo Action Items

### Immediate Next Steps (Share with Customer)

1. **ROI Calculation**
   - Use `partner-toolkit/roi-calculator.md`
   - Fill in customer's team size and rates
   - Calculate specific annual savings
   - Send customized ROI summary

2. **Pilot Program Proposal**

```

   Suggested Pilot:

- Duration: 30 days
- Team: 5-10 early adopters
- Success Metrics:
  - Time savings on 3 specific tasks
  - Error reduction rate
  - Developer satisfaction survey
- Cost: $195-390 for pilot period

```

3. **Technical Setup**
   - Schedule 30-minute setup session
   - Install VS Code and Copilot extension
   - Configure Azure CLI authentication
   - Walk through first task together

4. **Follow-Up Demo**
   - Schedule demo of remaining scenarios
   - Show Troubleshooting Assistant
   - Show Documentation Generator
   - Demonstrate on customer's actual use cases

---

## Success Metrics to Track

### Quantitative Metrics

1. **Time Savings**
   - Task completion time: Before vs. After
   - Weekly hours saved per engineer
   - Annual hours saved across team

2. **Quality Improvements**
   - First-deployment success rate
   - Number of deployment errors
   - Security findings in code reviews
   - Script reusability rate

3. **Cost Savings**
   - Labor cost reduction (hours × rate)
   - Azure cost reduction (orphaned resources, right-sizing)
   - Reduced incident response time

### Qualitative Metrics

1. **Developer Satisfaction**
   - NPS survey before/after
   - Feedback on productivity
   - Willingness to recommend

2. **Knowledge Transfer**
   - Junior engineer ramp-up time
   - Cross-team knowledge sharing
   - Documentation quality

3. **Innovation Capacity**
   - Time available for strategic projects
   - New capabilities delivered
   - Automation initiatives completed

---

## Partner Resources

### Materials to Bring

- [ ] Laptop with demos configured
- [ ] Backup: Screenshots of key moments
- [ ] ROI calculator (printed or digital)
- [ ] Case studies (3 success stories)
- [ ] GitHub Copilot pricing sheet
- [ ] Pilot program template
- [ ] Business cards

### Follow-Up Materials to Send

1. **Immediate (Same Day)**
   - Thank you email
   - Demo recording link
   - ROI calculation specific to customer
   - Pilot program proposal

2. **Within 48 Hours**
   - Technical setup guide
   - Links to GitHub Copilot documentation
   - Case studies relevant to their industry
   - Suggested next meeting date

3. **Within 1 Week**
   - Customized implementation roadmap
   - Training plan for their team
   - Success metrics dashboard template
   - Executive summary deck

---

## Tips for Success

### Do's ✅

- **DO** pause after Copilot suggestions to let them see the "magic"
- **DO** make mistakes and show how Copilot helps fix them
- **DO** use customer's actual scenarios when possible
- **DO** quantify every claim with specific metrics
- **DO** emphasize this is for IT Pros, not just developers
- **DO** show before/after comparisons
- **DO** let customer drive if they want to try

### Don'ts ❌

- **DON'T** rush through code - let them see it being generated
- **DON'T** show only perfect scenarios - real work has challenges
- **DON'T** over-promise on time savings - be realistic
- **DON'T** skip the business value discussion
- **DON'T** get too technical too fast - match their level
- **DON'T** demo features that aren't relevant to their needs

---

## Timing Breakdown (30-Minute Demo)

| Phase | Duration | Activity |
|-------|----------|----------|
| **Scene Setting** | 5 min | Customer pain points, manual approach struggles |
| **Copilot Demo** | 18 min | Live code generation, highlight key features |
| **Validation** | 5 min | Show/deploy results, verify quality |
| **Business Value** | 2 min | Metrics, ROI, next steps |

**Total:** 30 minutes (with buffer)

---

## Emergency Backup Plan

### If Live Demo Fails

1. **Have pre-recorded video ready** (5 minutes per demo)
2. **Show completed code** from `with-copilot/` folders
3. **Walk through time-tracking.md** to show the value
4. **Focus on business outcomes** rather than live coding

### If Customer Asks Question You Can't Answer

```

"That's a great question. Let me make a note and get you a detailed answer
from our technical team within 24 hours. In the meantime, let me show you..."

```

### If Running Long

**Prioritize:**

1. Business value discussion (don't skip)
2. One complete demo (quality over quantity)
3. ROI calculation
4. Next steps commitment

---

## Contact & Support

**Partner Questions:**

- Partner Portal: [Link]
- Technical Support: partners@github.com
- Sales Support: Your Microsoft/GitHub account team

**Customer Resources:**

- GitHub Copilot Documentation: https://docs.github.com/copilot
- Azure Bicep Documentation: https://learn.microsoft.com/azure/azure-resource-manager/bicep/
- Azure PowerShell Documentation: https://learn.microsoft.com/powershell/azure/

---

**Version:** 1.0  
**Last Updated:** November 2025  
**Maintained By:** Microsoft Partner Team
