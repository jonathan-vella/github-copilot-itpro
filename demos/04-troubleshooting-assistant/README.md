# Demo 4: Troubleshooting Assistant - Copilot for Azure Issue Resolution

## Overview

This demo shows how GitHub Copilot transforms Azure troubleshooting from a time-consuming, documentation-heavy process into an interactive, AI-assisted workflow. IT Pros can diagnose and resolve issues **83% faster** by leveraging Copilot's ability to generate diagnostic queries, analyze logs, and suggest solutions.

## Time Savings

| Approach | Time Required | Description |
|----------|---------------|-------------|
| **Manual** | 30 hours | Documentation search, trial & error, vendor support |
| **With Copilot** | 5 hours | AI-assisted diagnostics, instant queries, guided resolution |
| **Savings** | **25 hours (83%)** | $3,750 per incident × 12 incidents/year = **$45,000 annual savings** |

## Business Value

### Per-Incident Impact

- **Time Reduction**: 30 hours → 5 hours (83% faster)
- **Cost Savings**: $3,750 per incident (@ $150/hour)
- **MTTR Improvement**: Mean Time To Resolution reduced by 83%
- **Business Impact**: Minimize downtime costs ($50K-$500K per hour for critical systems)

### Annual Impact (12 Major Incidents)

- **Time Saved**: 300 hours (7.5 work weeks)
- **Cost Avoided**: $45,000 in labor
- **Downtime Reduction**: 300 hours of faster resolution = potential $15M-$150M business value saved
- **Knowledge Transfer**: Every troubleshooting session teaches best practices

## Scenario: E-Commerce Platform Incident

**Company**: RetailMax Online (Fortune 500 retailer)

- **Platform**: Azure-hosted e-commerce ($800M annual revenue)
- **Incident**: Intermittent checkout failures (15% error rate)
- **Business Impact**: $22K revenue loss per hour
- **SLA**: 99.9% uptime (max 8.7 hours downtime/year)
- **Pressure**: Black Friday in 3 days

### Typical Issues Covered

1. **Performance**: Slow API responses, high latency
2. **Availability**: Service outages, failed health checks
3. **Connectivity**: Network issues, DNS resolution
4. **Configuration**: Misconfigured resources, RBAC issues
5. **Resource Exhaustion**: CPU/memory/disk space limits

## What You'll Build

### Troubleshooting Scripts (With Copilot)

1. **Get-AzureHealthSnapshot.ps1** (15 min)
   - Resource health checks across subscriptions
   - Service availability validation
   - Quick incident triage

2. **Invoke-DiagnosticQuery.ps1** (20 min)
   - KQL query generation from natural language
   - Log Analytics automated analysis
   - Common pattern detection

3. **Resolve-CommonIssues.ps1** (10 min)
   - Automated remediation for known problems
   - Configuration validation and repair
   - Self-healing capabilities

4. **New-TroubleshootingReport.ps1** (15 min)
   - Incident timeline generation
   - Root cause analysis documentation
   - Post-mortem report creation

### Key Features

- **Natural Language Queries**: Describe symptoms → Get KQL queries
- **Pattern Recognition**: AI identifies common failure patterns
- **Solution Suggestions**: Context-aware remediation steps
- **Knowledge Capture**: Auto-document troubleshooting process

## Technologies Demonstrated

- **Azure Monitor**: Metrics, logs, alerts analysis
- **Log Analytics**: KQL query generation and execution
- **Application Insights**: Distributed tracing, dependency analysis
- **Azure Resource Graph**: Cross-subscription resource queries
- **PowerShell**: Automated diagnostics and remediation
- **KQL (Kusto Query Language)**: Log analysis and pattern detection

## Prerequisites

### Azure Resources

- Azure subscription with resources to monitor
- Log Analytics workspace with data
- Application Insights (optional, for demo depth)
- Resource Graph permissions (Reader role)

### Local Environment

- PowerShell 7.0+ (`$PSVersionTable.PSVersion`)
- Azure PowerShell module (`Install-Module -Name Az -AllowClobber`)
- VS Code with GitHub Copilot extension
- Azure CLI (optional, for some diagnostics)

### Permissions Required

- **Monitoring Reader** role (view metrics and logs)
- **Log Analytics Reader** role (query Log Analytics)
- **Resource Graph Reader** (query resources)
- **Application Insights Component Contributor** (if using App Insights)

## Demo Metrics

### Manual Approach Breakdown (30 hours)

- **Initial Triage** (2 hours): Check dashboards, alerts, recent changes
- **Documentation Search** (4 hours): Azure docs, Stack Overflow, forums
- **Log Analysis** (8 hours): Manual KQL query writing, log diving
- **Hypothesis Testing** (6 hours): Trial & error with fixes
- **Vendor Support** (4 hours): Open ticket, wait for response, follow-ups
- **Resolution & Validation** (4 hours): Apply fix, test, monitor
- **Documentation** (2 hours): Write post-mortem, update runbooks

### With Copilot Breakdown (5 hours)

- **AI-Assisted Triage** (20 min): Copilot generates health check script
- **Automated Log Analysis** (1 hour): Copilot creates KQL queries from symptoms
- **Guided Remediation** (2 hours): Copilot suggests fixes, validates configuration
- **Solution Implementation** (1 hour): Apply recommended fixes with confidence
- **Auto-Documentation** (40 min): Copilot generates incident report

## Key Differentiators

| Aspect | Manual Approach | With Copilot | Advantage |
|--------|-----------------|--------------|-----------|
| **KQL Query Creation** | 45 min per query | 2 min per query | 96% faster |
| **Documentation Search** | 4 hours | 10 minutes | 96% reduction |
| **Solution Confidence** | Trial & error | Best practice suggestions | Higher first-time fix rate |
| **Knowledge Capture** | Manual write-up (2 hrs) | Auto-generated (15 min) | 88% faster |
| **Learning Curve** | Steep (KQL, Azure internals) | Guided (Copilot teaches) | Accelerated expertise |

## Target Audience

### Primary

- **Site Reliability Engineers**: On-call incident response
- **Platform Engineers**: Azure infrastructure troubleshooting
- **DevOps Engineers**: Application performance issues
- **Cloud Operations Teams**: Day-to-day Azure support

### Secondary

- **IT Support Teams**: Escalated issue resolution
- **Solutions Architects**: Production issue assistance
- **Development Teams**: Debugging Azure integrations

## ROI Calculation

### Single Incident

- Manual time: 30 hours × $150/hour = **$4,500**
- Copilot time: 5 hours × $150/hour = **$750**
- **Savings per incident: $3,750**

### Annual Impact (Conservative: 12 Major Incidents)

- Manual cost: 360 hours × $150 = **$54,000**
- Copilot cost: 60 hours × $150 = **$9,000**
- **Annual savings: $45,000**

### Downtime Value

- Average incident MTTR reduction: 25 hours
- Business downtime cost: $100K/hour (conservative for e-commerce)
- **Downtime cost avoided: $2.5M per incident**
- **Annual downtime savings: $30M** (12 incidents)

### Intangible Benefits

- **Reduced Stress**: 83% faster resolution = better work-life balance
- **Knowledge Transfer**: Every Copilot interaction teaches best practices
- **Confidence**: AI-suggested solutions have higher success rates
- **Innovation Time**: 300 hours/year freed for strategic work

## Success Criteria

### Technical Metrics

- ✅ Generate working KQL queries in <3 minutes
- ✅ Identify root cause 83% faster than manual approach
- ✅ First-time fix rate >70% (vs. 40% manual trial-and-error)
- ✅ Complete incident report in <20 minutes

### Business Metrics

- ✅ Reduce MTTR from 30 hours to 5 hours
- ✅ Save $45K annually in labor costs
- ✅ Avoid $30M annually in downtime costs
- ✅ Improve SLA compliance (fewer breaches)

### Qualitative Outcomes

- ✅ Engineers feel more confident troubleshooting
- ✅ On-call stress reduced (faster resolution)
- ✅ Knowledge gaps closed (Copilot teaches during incidents)
- ✅ Better documentation quality (auto-generated)

## Demo Flow (30 Minutes)

1. **Scene Setting** (5 min)
   - Present RetailMax incident scenario
   - Show typical manual troubleshooting pain points
   - Demonstrate pressure: Black Friday approaching

2. **Copilot Demo** (18 min)
   - **Part 1** (5 min): Generate health check script with Copilot
   - **Part 2** (8 min): Create diagnostic KQL queries from symptoms
   - **Part 3** (3 min): Auto-generate remediation script
   - **Part 4** (2 min): Create incident report

3. **Validation** (5 min)
   - Run health check against Azure resources
   - Execute KQL queries in Log Analytics
   - Show generated documentation

4. **Wrap-Up** (2 min)
   - Review time savings: 30 hours → 5 hours
   - Calculate ROI: $45K annual savings
   - Emphasize downtime cost avoidance: $30M potential

## Files in This Demo

```
04-troubleshooting-assistant/
├── README.md                           # This file
├── DEMO-SCRIPT.md                      # Detailed presenter guide
├── scenario/
│   ├── requirements.md                 # RetailMax incident details
│   └── incident-timeline.md            # Problem progression
├── manual-approach/
│   ├── time-tracking.md                # 30-hour baseline breakdown
│   └── typical-process.md              # Manual troubleshooting workflow
├── with-copilot/
│   ├── Get-AzureHealthSnapshot.ps1     # Resource health diagnostics
│   ├── Invoke-DiagnosticQuery.ps1      # KQL query generator
│   ├── Resolve-CommonIssues.ps1        # Automated remediation
│   └── New-TroubleshootingReport.ps1   # Incident documentation
├── prompts/
│   └── effective-prompts.md            # Copilot prompting guide
└── validation/
    ├── test-queries.kql                # Sample KQL for testing
    └── cleanup.ps1                     # Remove test resources
```

## Getting Started

### Quick Start (10 Minutes)

```powershell
# 1. Clone repository
git clone https://github.com/your-org/github-copilot-itpro.git
cd github-copilot-itpro/demos/04-troubleshooting-assistant

# 2. Connect to Azure
Connect-AzAccount
Set-AzContext -SubscriptionId "<your-subscription-id>"

# 3. Run health snapshot
.\with-copilot\Get-AzureHealthSnapshot.ps1 -ResourceGroupName "rg-production"

# 4. Generate diagnostic query
.\with-copilot\Invoke-DiagnosticQuery.ps1 -Symptom "High API latency in last 2 hours"
```

### Full Demo Setup (20 Minutes)

See [DEMO-SCRIPT.md](./DEMO-SCRIPT.md) for complete setup instructions.

## Common Use Cases

### 1. Performance Degradation

**Symptom**: "API response times increased from 200ms to 3000ms"

**Manual Approach** (8 hours):

- Check Azure Monitor metrics manually
- Write KQL queries to find slow requests
- Analyze Application Insights traces
- Correlate with infrastructure changes
- Test hypothesis with configuration changes

**With Copilot** (45 minutes):

```powershell
# Copilot generates diagnostic query from natural language
Invoke-DiagnosticQuery -Symptom "API response times increased from 200ms to 3000ms"

# AI suggests: Check App Insights dependencies, review recent deployments, analyze DTU consumption
# Generates KQL: requests | where timestamp > ago(2h) | where duration > 3000 | summarize...
```

### 2. Intermittent Connectivity Issues

**Symptom**: "Users report 5xx errors during checkout (15% failure rate)"

**Manual Approach** (6 hours):

- Check load balancer health probes
- Review NSG/firewall rules
- Analyze network flow logs
- Test connectivity from various regions
- Review DNS resolution

**With Copilot** (30 minutes):

```powershell
# Copilot creates comprehensive connectivity check
Get-AzureHealthSnapshot -ResourceGroupName "rg-ecommerce" -IncludeNetworking

# Suggests checking: Backend pool health, timeout settings, SNAT exhaustion
# Auto-generates remediation: Resolve-CommonIssues -Issue "LoadBalancerSNAT"
```

### 3. Resource Exhaustion

**Symptom**: "Database CPU at 100%, queries timing out"

**Manual Approach** (4 hours):

- Check Azure SQL metrics
- Review query performance insights
- Analyze missing indexes
- Consider scaling options
- Test different tier configurations

**With Copilot** (20 minutes):

```powershell
# Copilot generates SQL diagnostics
Invoke-DiagnosticQuery -Symptom "Database CPU at 100%, queries timing out" -ResourceType "SqlDatabase"

# AI suggests: Review top CPU queries, check DTU limits, analyze index usage
# Provides: Auto-scale recommendation, index creation scripts, query optimization tips
```

## Key Takeaways

### For IT Professionals

- ✅ **Faster Resolution**: 83% time reduction (30 hours → 5 hours)
- ✅ **Less Stress**: Guided troubleshooting reduces on-call burden
- ✅ **Continuous Learning**: Copilot teaches best practices during incidents
- ✅ **Better Documentation**: Auto-generated reports save 88% time

### For Management

- ✅ **Cost Savings**: $45K annual labor + $30M downtime cost avoidance
- ✅ **Improved SLAs**: 83% faster MTTR improves uptime
- ✅ **Team Efficiency**: 300 hours/year freed for strategic work
- ✅ **Risk Reduction**: Higher first-time fix rates reduce escalations

### For Partners

- ✅ **Differentiation**: Offer AI-assisted support services
- ✅ **Margin Improvement**: Resolve incidents 83% faster = better profitability
- ✅ **Customer Satisfaction**: Faster resolution = happier customers
- ✅ **Scalability**: Handle more incidents with same team size

## Next Steps

1. **Run the Demo**: Follow [DEMO-SCRIPT.md](./DEMO-SCRIPT.md)
2. **Customize for Your Scenario**: Adapt scripts to your Azure environment
3. **Integrate with Runbooks**: Add Copilot-generated scripts to your operations
4. **Train Your Team**: Share effective prompting techniques
5. **Measure Results**: Track MTTR improvements and cost savings

## Related Demos

- **Demo 1**: Bicep Quickstart - Infrastructure troubleshooting
- **Demo 2**: PowerShell Automation - Automated remediation
- **Demo 3**: Azure Arc Onboarding - Hybrid cloud diagnostics
- **Demo 5**: Documentation Generator - Post-incident reports

## Resources

- [Azure Monitor KQL Documentation](https://learn.microsoft.com/azure/azure-monitor/logs/kql-quick-reference)
- [Application Insights Troubleshooting](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [Azure Resource Graph Queries](https://learn.microsoft.com/azure/governance/resource-graph/samples/starter)
- [GitHub Copilot for Azure](https://learn.microsoft.com/azure/developer/github/github-copilot-azure)

---

**Demo Mission**: Demonstrate how GitHub Copilot transforms Azure troubleshooting from a 30-hour documentation-heavy ordeal into a 5-hour AI-assisted workflow, reducing MTTR by 83% and saving $45K annually while avoiding millions in downtime costs.
