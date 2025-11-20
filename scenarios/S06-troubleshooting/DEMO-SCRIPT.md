# Demo 4: Troubleshooting Assistant - Presenter Guide

## Demo Overview

**Duration**: 30 minutes
**Complexity**: Intermediate
**Audience**: IT Pros, SREs, DevOps Engineers, Cloud Operations Teams

### Demo Objectives

By the end of this demo, participants will understand:

1. How GitHub Copilot accelerates Azure troubleshooting (83% time savings)
2. Techniques for generating KQL queries from natural language
3. Automated diagnostic script creation for common issues
4. AI-assisted incident documentation and post-mortems

### Value Proposition

"GitHub Copilot transforms Azure troubleshooting from a 30-hour documentation-heavy process into a 5-hour AI-assisted workflow, reducing Mean Time To Resolution (MTTR) by 83% and saving $45K annually while potentially avoiding millions in downtime costs."

## Pre-Demo Checklist

### 48 Hours Before

- [ ] **Azure Environment Setup**
  - Log Analytics workspace with sample data
  - Application Insights instance (optional but recommended)
  - Test resources in demo subscription
  - Ensure Monitoring Reader access

- [ ] **Local Development Setup**
  - VS Code with GitHub Copilot enabled
  - PowerShell 7.0+ installed
  - Azure PowerShell module (`Install-Module Az`)
  - Test Copilot responsiveness

- [ ] **Demo Content Preparation**
  - Review RetailMax scenario (scenario/requirements.md)
  - Familiarize with incident timeline
  - Practice Copilot prompts
  - Prepare backup queries (if Copilot unavailable)

### 30 Minutes Before

- [ ] **Technical Validation**
  - Connect to Azure: `Connect-AzAccount`
  - Set demo subscription context
  - Verify Log Analytics workspace accessible
  - Test query execution permissions

- [ ] **Presentation Setup**
  - Close unnecessary applications
  - VS Code in full screen, font size 18+
  - PowerShell terminal visible
  - Azure Portal in separate browser tab (backup)

- [ ] **Mindset Preparation**
  - Remember: Pauses are good (shows AI thinking)
  - Be ready to narrate what Copilot is suggesting
  - Have manual approach pain points memorized
  - Prepare for "what if Copilot fails" scenarios

## Demo Script (30 Minutes)

### Part 1: Scene Setting (5 minutes)

#### Opening Hook (60 seconds)

> "It's 2 AM. You're on-call. Your phone buzzes: **'E-commerce checkout failing - 15% error rate - revenue impact $22K per hour.'** And oh, by the way, Black Friday is in 3 days."
>
> "This is every IT Pro's nightmare. And typically, you're looking at 30 hours of troubleshooting: documentation searches, trial-and-error fixes, vendor support tickets."
>
> "Today, I'll show you how GitHub Copilot turns this 30-hour ordeal into a 5-hour resolution - that's **83% faster** - while teaching you best practices along the way."

#### Present the Scenario (2 minutes)

**Display**: Open `scenario/requirements.md`

> "Meet RetailMax Online, a Fortune 500 retailer with an $800M e-commerce platform on Azure."

**Key Points to Emphasize**:

- Platform criticality: $22K revenue loss per hour
- Business pressure: Black Friday in 3 days
- SLA at risk: 99.9% uptime commitment
- Team stress: On-call engineer needs to resolve fast

**Show**: `scenario/incident-timeline.md` (quickly scroll)

> "The incident started 2 hours ago with intermittent checkout failures. Users are angry, management is watching, and every minute counts."

#### Manual Approach Pain Points (2 minutes)

**Narrate the Typical Journey** (with visible frustration):

> "In the manual world, here's what happens:"

1. **Documentation Deep-Dive** (4 hours)
   - "You open 47 browser tabs of Azure documentation"
   - "Search Stack Overflow for similar issues"
   - "Read through 200-page troubleshooting guides"

2. **KQL Query Writing** (8 hours)
   - "You stare at blank Log Analytics window"
   - "Try to remember KQL syntax: `where`? `summarize`? `extend`?"
   - "Iterate through 15 queries before finding relevant data"

3. **Trial & Error** (6 hours)
   - "Change configuration, wait 10 minutes to see effect"
   - "Repeat with different hypothesis"
   - "Call vendor support, wait on hold"

4. **Documentation** (2 hours)
   - "Finally fix it at 6 AM"
   - "Too exhausted to write good post-mortem"
   - "Knowledge not captured for next person"

**Pause for Effect**:
> "30 hours total. 3-4 work days. Brutal. **But there's a better way.**"

---

### Part 2: Copilot Demo - Building the Troubleshooting Toolkit (18 minutes)

#### Script 1: Health Snapshot Generator (5 minutes)

**Objective**: Show Copilot generating comprehensive Azure health check script

**Action**: Create new file `Get-AzureHealthSnapshot.ps1`

**Prompt to Copilot** (type slowly, narrate):

```bicep
# Create a PowerShell function to check Azure resource health
# Function name: Get-AzureHealthSnapshot
# Parameters: ResourceGroupName (mandatory), IncludeNetworking (switch)
# Check: Resource health status, service availability, recent alerts, metrics anomalies
# Output: Structured health report with color-coded status
```

**Narrate While Copilot Generates**:
> "Watch this. Instead of searching documentation for 30 minutes on how to check resource health, I'm asking Copilot to build the script for me."
>
> "Notice how it's suggesting parameter validation, proper error handling, and even color-coded output for better readability."

**Accept Suggestions** (demonstrate tab-completion):

- Accept function scaffold
- Accept parameter block
- Accept resource health query logic
- Accept formatting logic

**Pause to Explain** (30 seconds):
> "In 3 minutes, we have a production-ready diagnostic script. Manually, this would take 2 hours to research, write, and debug."

**Quick Test**:

```powershell
# Load the function
. .\Get-AzureHealthSnapshot.ps1

# Run against demo resource group
Get-AzureHealthSnapshot -ResourceGroupName "rg-retailmax-prod"
```

**Narrate Results**:
> "Look at this output: We instantly see that our App Service is healthy, but there's a SQL Database with 'Degraded' status. That's our first clue."

---

#### Script 2: Diagnostic Query Generator (8 minutes) - **Main Event**

**Objective**: Show natural language → KQL query generation

**Action**: Create new file `Invoke-DiagnosticQuery.ps1`

**Prompt to Copilot**:

```

# Create a PowerShell function to generate and execute KQL diagnostic queries

# Function name: Invoke-DiagnosticQuery

# Parameters: Symptom (string), WorkspaceName, TimeRange (default 2 hours)

# The function should

# 1. Translate natural language symptom into appropriate KQL query

# 2. Execute against Log Analytics workspace

# 3. Return results in structured format

# 4. Suggest next troubleshooting steps based on findings

```

**This is the "WOW" Moment** - Talk Through It:

> "Here's where Copilot really shines. Watch how it understands the intent: we're taking a natural language description of a problem and translating it into precise KQL queries."

**Accept Suggestions, Highlighting Key Parts**:

1. **Symptom Translation Logic**:

   ```powershell
   switch -Wildcard ($Symptom) {
       "*high latency*" { $query = "requests | where..." }
       "*5xx errors*" { $query = "requests | where resultCode startswith '5'..." }
       "*timeout*" { $query = "exceptions | where type contains 'Timeout'..." }
   }

```

   > "Copilot generated pattern matching for common symptoms. This is knowledge capture happening in real-time."

2. **KQL Query Structure**:

   ```kql
   requests
   | where timestamp > ago(2h)
   | where resultCode startswith '5'
   | summarize FailureCount = count(), AvgDuration = avg(duration) by operation_Name
   | order by FailureCount desc

```

   > "Look at this KQL - perfectly formatted, with time filtering, aggregation, and sorting. Writing this manually would take 20-30 minutes if you're experienced, hours if you're learning KQL."

1. **Next Steps Suggestions**:

   ```powershell
   Write-Host "Suggested Next Steps:" -ForegroundColor Yellow
   Write-Host "1. Check backend dependencies: $query2"
   Write-Host "2. Review recent deployments"
   Write-Host "3. Analyze database performance"

```

   > "Copilot isn't just diagnosing - it's teaching. It suggests what to check next based on common troubleshooting patterns."

**Live Test with Real Symptom**:

```powershell
# Simulate the RetailMax incident
Invoke-DiagnosticQuery -Symptom "Intermittent 5xx errors during checkout, started 2 hours ago" -WorkspaceName "law-retailmax-prod"
```

**Narrate Results** (even if demo data is synthetic):
> "Within seconds, we have actionable intelligence: 127 failures in the payment processing operation, average duration spiked from 200ms to 3400ms. Without Copilot, we'd still be crafting the first query."

**Show Time Comparison**:
> "Manual KQL writing: 45 minutes per query × 5 queries = **3.75 hours**
> With Copilot: 2 minutes per query × 5 queries = **10 minutes**
> That's **96% faster**."

---

#### Script 3: Automated Remediation (3 minutes)

**Objective**: Show Copilot generating remediation script

**Action**: Create `Resolve-CommonIssues.ps1`

**Prompt** (faster now, show momentum):

```

# Create a function to automatically resolve common Azure issues

# Function name: Resolve-CommonIssues

# Parameter: Issue (ValidateSet: 'HighCPU', 'OutOfMemory', 'ConnectionTimeout', 'SlowQueries')

# Include: Issue detection, automated fix application, validation

# Add WhatIf support for safe testing

```

**Quick Generation** - Narrate Highlights:
> "Copilot is now generating remediation logic. Notice the `WhatIf` support - best practice for production scripts."
>
> "It's suggesting solutions: CPU scaling, connection pool adjustment, query optimization. This is years of Azure operational knowledge, accessible instantly."

**Quick Demo**:

```powershell
# Dry run first
Resolve-CommonIssues -Issue 'ConnectionTimeout' -WhatIf

# Apply fix
Resolve-CommonIssues -Issue 'ConnectionTimeout' -Confirm:$false
```

---

#### Script 4: Incident Report Generator (2 minutes)

**Objective**: Show auto-documentation

**Action**: Create `New-TroubleshootingReport.ps1`

**Prompt**:

```powershell
# Generate incident post-mortem report
# Function: New-TroubleshootingReport
# Parameters: IncidentTitle, Timeline (array of events), RootCause, Resolution, LessonsLearned
# Output: Markdown report with sections: Summary, Timeline, Root Cause Analysis, Resolution Steps, Prevention Recommendations
```

**Quick Generation**:
> "Last pain point: Documentation. Manually writing a post-mortem takes 2 hours when you're exhausted after a long incident. Copilot does it in 15 minutes."

**Show Example Output**:

```powershell
New-TroubleshootingReport -IncidentTitle "RetailMax Checkout Failures" -OutputPath "incident-report.md"
```

> "Professional, comprehensive documentation. Ready to share with management and teammates."

---

### Part 3: Validation & Results (5 minutes)

#### Live Execution (3 minutes)

**Run the Complete Workflow**:

1. **Health Check**:

   ```powershell
   Get-AzureHealthSnapshot -ResourceGroupName "rg-retailmax-prod"

```

   > "Step 1: Quick triage - identify degraded SQL Database in 30 seconds vs. 15 minutes manually."

2. **Diagnostic Query**:

   ```powershell
   Invoke-DiagnosticQuery -Symptom "High database CPU with slow queries"

```

   > "Step 2: KQL analysis - found top 5 CPU-intensive queries in 2 minutes vs. 45 minutes manually."

1. **Remediation**:

   ```powershell
   Resolve-CommonIssues -Issue 'SlowQueries' -AddMissingIndexes

```

   > "Step 3: Applied index recommendations in 5 minutes vs. 2 hours of manual optimization."

4. **Documentation**:

   ```powershell
   New-TroubleshootingReport -IncidentTitle "Checkout Performance Degradation"

```

   > "Step 4: Generated comprehensive post-mortem in 10 minutes vs. 2 hours of writing."

#### Show Time Savings Visual (1 minute)

**Display Comparison Table**:

| Task | Manual | With Copilot | Savings |
|------|--------|--------------|---------|
| Initial Triage | 2 hours | 20 min | 85% |
| KQL Query Writing | 8 hours | 1 hour | 88% |
| Hypothesis Testing | 6 hours | 2 hours | 67% |
| Solution Implementation | 4 hours | 1 hour | 75% |
| Documentation | 2 hours | 40 min | 67% |
| **TOTAL** | **30 hours** | **5 hours** | **83%** |

**Emphasize Business Impact**:
> "Let's talk real dollars:"
>
> - **Labor savings**: $3,750 per incident
> - **Annual savings** (12 incidents): **$45,000**
> - **Downtime cost avoidance**: 25 hours faster resolution = **$2.5M saved per incident**
> - **Total annual business value**: **$30M+**

#### Address Learning Value (1 minute)

> "But here's what's not on the spreadsheet: **Copilot is teaching you throughout this process.**"
>
> "Every KQL query it generates, you learn KQL syntax. Every remediation script, you learn Azure best practices. It's like having a senior Azure architect pair-programming with you 24/7."

---

### Part 4: Wrap-Up & Call to Action (2 minutes)

#### Key Takeaways (60 seconds)

**Summarize the Transformation**:

1. **Speed**: 30 hours → 5 hours (83% reduction)
2. **Cost**: $45K annual savings in labor alone
3. **Risk**: Millions in downtime costs avoided
4. **Knowledge**: Continuous learning during troubleshooting
5. **Stress**: On-call becomes manageable, not miserable

**Quote to Close**:
> "GitHub Copilot doesn't replace your Azure expertise - it multiplies it. You're still the problem solver, but now you have an AI assistant that knows every Azure service, every KQL function, and every troubleshooting pattern."

#### Next Steps (30 seconds)

**For the Audience**:

- Try the scripts in your environment (all open source)
- Customize for your specific issues
- Track your MTTR improvements
- Share results with your team

**For Partners**:

- Integrate into managed services offering
- Use in customer incident response
- Demonstrate during Azure support engagements
- Include in Azure optimization packages

#### Q&A Teaser (30 seconds)

> "Questions I often get:"
>
> - "What if Copilot suggests wrong solution?" → You're the expert, validate before applying
> - "Does it work with non-Azure resources?" → Yes, same principles for AWS, on-prem, etc.
> - "Security concerns?" → Code stays in your environment, Microsoft privacy policy applies
>
> "Let's open it up for questions."

---

## Backup Plans & Troubleshooting

### If Copilot is Slow/Unresponsive

**Plan B**: Use Pre-Generated Scripts

- All 4 scripts are pre-built in `with-copilot/` folder
- Narrate: "I pre-generated this earlier with Copilot..."
- Focus demo on **explaining the code** Copilot created
- Still emphasizes value: "This script took 3 minutes with Copilot vs. 2 hours manually"

### If Azure Connection Fails

**Plan C**: Use Screenshots/Recordings

- Show pre-recorded video of script execution
- Walk through code in VS Code (no execution needed)
- Emphasize: "The real value is in the code generation speed, which we already demonstrated"

### If Audience Questions KQL Complexity

**Response Strategy**:
> "Great observation. Yes, KQL has a learning curve - that's exactly why Copilot is valuable. Instead of spending 20 hours learning KQL syntax, Copilot generates it for you while teaching you through examples. After a few incidents, you'll be writing KQL yourself."

### If Someone Says "I Don't Trust AI-Generated Code"

**Response**:
> "Absolutely right to be skeptical. Here's the key: Copilot is a **starting point**, not a blind auto-pilot. You review every suggestion, test in non-production, and validate results. But starting from Copilot's 80% solution beats starting from a blank file 100% of the time. You're still the expert making the final decision."

---

## Objection Handling

### Objection 1: "Our Issues Are Too Unique for AI"

**Response**:
> "I hear that often. But here's the reality: 80% of Azure issues follow common patterns - configuration mistakes, resource exhaustion, network connectivity. Copilot handles those exceptionally well. For your truly unique 20%, Copilot still helps by generating the diagnostic framework - you just customize the logic."

**Proof Point**:
> "In this demo, RetailMax's issue (SQL performance) is incredibly common. But even rare issues like SNAT exhaustion or Azure AD token expiration - Copilot has seen those in its training and can suggest starting points."

### Objection 2: "KQL Queries Look Too Simple"

**Response**:
> "These are intentionally beginner-friendly queries for demo purposes. In production, ask Copilot for advanced scenarios:"
>
> - "Create KQL with percentile calculations and anomaly detection"
> - "Generate query with cross-workspace joins"
> - "Write time-series analysis with regression"
>
> "Copilot scales with your requirements."

### Objection 3: "What About Cost of Copilot?"

**Response**:
> "GitHub Copilot is $19/user/month ($228/year). We're saving $45K annually in labor plus millions in downtime costs. That's a 197× ROI on the subscription cost. Even if you resolve just ONE major incident per year, it pays for itself 16× over."

### Objection 4: "Our Team Needs to Learn Azure, Not Use Shortcuts"

**Response**:
> "I love that you prioritize learning - but Copilot accelerates it, doesn't bypass it. Think of it like Stack Overflow that teaches while you code. Your team learns faster because they see best practices in context during real troubleshooting. It's learn-by-doing, not memorizing docs."

### Objection 5: "Security/Compliance Concerns with AI"

**Response**:
> "Valid concern. Key facts:"
>
> - Code stays in your VS Code environment
> - Microsoft's privacy policy: No code retention for training without permission
> - You control what code is shared (prompts only, not full codebase)
> - Same security model as GitHub (which most enterprises already use)
> - Can disable for sensitive repositories if needed

---

## Advanced Tips

### Maximizing Copilot Effectiveness

1. **Be Specific in Prompts**:
   - Bad: `# Check database performance`
   - Good: `# Check Azure SQL Database CPU, DTU usage, and top 5 slowest queries in last 2 hours`

2. **Use Iterative Refinement**:
   - Start with basic query
   - Ask Copilot to enhance: "Add error handling", "Include progress bars", "Export to CSV"

3. **Leverage Comments for Context**:

   ```powershell
   # RetailMax uses Premium P2 tier SQL Database in East US region
   # High CPU detected during peak hours (6PM-9PM UTC)
   # Need query to identify blocking queries and missing indexes

```

4. **Request Multiple Options**:
   - Type prompt, then: "Show me 3 different approaches to this"
   - Copilot will suggest variations

### Demo Personalization

**Customize for Different Audiences**:

- **For Developers**: Emphasize Application Insights integration, distributed tracing
- **For Ops Teams**: Focus on automated remediation, runbook generation
- **For Management**: Lead with ROI numbers, downtime cost avoidance
- **For Partners**: Highlight managed services differentiation, margin improvement

**Industry-Specific Scenarios**:

- **Financial Services**: Replace "e-commerce" with "trading platform" ($500K/hour downtime)
- **Healthcare**: Focus on patient portal availability, HIPAA compliance
- **Manufacturing**: IoT device connectivity issues, predictive maintenance

---

## Post-Demo Follow-Up

### Resources to Share

1. **GitHub Repository**: [Link to this repo]
2. **Microsoft Learn**: [KQL Quick Reference](https://learn.microsoft.com/azure/azure-monitor/logs/kql-quick-reference)
3. **Copilot Documentation**: [GitHub Copilot for Azure](https://docs.github.com/copilot)
4. **Azure Well-Architected**: [Operational Excellence](https://learn.microsoft.com/azure/well-architected/operational-excellence/)

### Success Metrics to Track

Encourage participants to measure:

- **MTTR Before/After**: Baseline current incident resolution time
- **First-Time Fix Rate**: Percentage of issues resolved without escalation
- **Documentation Quality**: Time spent writing post-mortems
- **Knowledge Retention**: Team's Azure proficiency growth rate

### Community Engagement

- **LinkedIn Post Template**: "Just saw GitHub Copilot reduce Azure troubleshooting from 30 hours to 5 hours. Here's what impressed me..."
- **Internal Champions**: Identify enthusiastic participants for pilot program
- **Feedback Loop**: Collect success stories for case studies

---

## Appendix: Quick Reference

### Essential PowerShell Commands

```powershell
# Connect to Azure
Connect-AzAccount
Set-AzContext -SubscriptionId "<subscription-id>"

# List Log Analytics Workspaces
Get-AzOperationalInsightsWorkspace

# Execute KQL Query
Invoke-AzOperationalInsightsQuery -WorkspaceId "<workspace-id>" -Query "requests | take 10"

# Check Resource Health
Get-AzResourceHealth -ResourceId "<resource-id>"
```

### Common KQL Patterns

```kql
// Error rate by operation
requests
| where timestamp > ago(2h)
| summarize TotalRequests = count(), Failures = countif(success == false) by operation_Name
| extend FailureRate = Failures * 100.0 / TotalRequests
| order by FailureRate desc

// P95 latency trend
requests
| where timestamp > ago(24h)
| summarize P95Latency = percentile(duration, 95) by bin(timestamp, 1h)
| render timechart

// Exception analysis
exceptions
| where timestamp > ago(1d)
| summarize Count = count() by type, outerMessage
| order by Count desc
```

### Time-Saving Copilot Prompts

- "Generate KQL query to find slow database queries in last 2 hours"
- "Create PowerShell function to check Azure SQL DTU usage"
- "Write script to restart App Service if health check fails"
- "Generate post-mortem report template with timeline and root cause sections"

---

**Presenter Confidence Booster**: You've got this! Remember, even if Copilot doesn't perform perfectly, the STORY is what matters: 30 hours vs. 5 hours. That value proposition sells itself. Your job is to bring the pain of manual troubleshooting to life, then show Copilot as the hero. The scripts are just the proof.

Good luck! 🚀
