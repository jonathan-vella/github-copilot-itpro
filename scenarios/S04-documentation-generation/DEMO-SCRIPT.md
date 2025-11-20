# Demo 5: Documentation Generator

**Duration**: 30 minutes  
**Audience**: IT Pros, Cloud Architects, System Integrators  
**Value Proposition**: Reduce documentation time from 20 hours to 2 hours (90% reduction), saving $21,600 annually

---

## Pre-Demo Setup (15 minutes before)

### Environment Preparation

- [ ] VS Code open with GitHub Copilot enabled
- [ ] Azure subscription with sample resources deployed
- [ ] PowerShell terminal ready (Az module loaded)
- [ ] Sample Bicep template prepared
- [ ] Browser tabs: Azure Portal, Architecture Center

### Validation

```powershell
# Verify Copilot is working
Get-AzContext  # Should show subscription
Get-AzResource -ResourceGroupName "rg-demo"  # Verify resources exist
```

---

## Scene Setting (5 minutes)

### The Documentation Problem

**Narrator Script**:
> "Let's talk about everyone's favorite task... documentation." *(pause for laughs)*  
> "TechCorp, a mid-market MSP, just finished migrating 50 servers to Azure for a client. Great! But now they need to deliver comprehensive documentation: architecture diagrams, operational runbooks, troubleshooting guides, and API documentation."

**Show Manual Approach**:

- Open PowerPoint/Visio: "6 hours creating architecture diagrams"
- Show Word document: "5 hours writing runbooks with screenshots"
- Open Excel: "4 hours compiling troubleshooting guides"
- Show empty README: "3 hours documenting APIs"
- **Total: 20 hours of tedious work**

**The Pain Points**:

1. ❌ **Time-consuming**: 20 hours per project (2.5 workdays)
2. ❌ **Outdated immediately**: Infrastructure changes, docs don't
3. ❌ **Inconsistent**: Different formats, missing sections
4. ❌ **Never complete**: Always 60% done, "we'll finish it later"
5. ❌ **Tools dependency**: Visio licenses, formatting nightmares

**Business Impact**:

- **$3,000 in labor** per project (20 hours × $150/hr)
- **8 projects per year** = $24,000 in documentation costs
- **Customer dissatisfaction**: Incomplete handoffs
- **Knowledge loss**: When team members leave

### The Copilot Solution

**Show completed documentation**:
> "What if we could automate this? Generate docs from code, diagrams from Azure queries, runbooks from templates?"

**Value Proposition**:

- ⏱️ **Time**: 20 hours → 2 hours (90% reduction)
- 💰 **Cost**: $3,000 → $300 per project
- 📊 **Quality**: 95% completeness vs. 60% manual
- 🔄 **Updates**: Regenerate in 30 minutes vs. 5 hours rewrite

---

## Demo Part 1: Architecture Documentation (5 minutes)

### Scenario Setup
>
> "Let's document TechCorp's Azure infrastructure. They have App Services, databases, storage, networking - typical cloud migration."

### Step 1: Generate Architecture Docs (2 min)

**In VS Code, open PowerShell terminal**:

```powershell
# Connect to Azure
Connect-AzAccount
Set-AzContext -Subscription "Demo-Subscription"

# Generate architecture documentation
./New-ArchitectureDoc.ps1 `
    -ResourceGroupName "rg-techcorp-prod" `
    -OutputPath ".\docs" `
    -IncludeDiagrams `
    -IncludeNetworkTopology `
    -IncludeCostAnalysis
```

**Narration while running**:
> "Notice how Copilot helped write this script. It's querying Azure Resource Graph, generating Mermaid diagrams, and building comprehensive documentation - all from a simple command."

### Step 2: Review Generated Documentation (3 min)

**Open generated `architecture-documentation.md`**:

**Highlight key sections**:

1. **Executive Summary**: "Automatically generated from Azure"
2. **Resource Inventory**: "Complete table with types, locations, purposes"
3. **Architecture Diagram**: "Mermaid syntax - no Visio needed!"

   ```mermaid
   graph TB
       app[App Service] --> db[SQL Database]
       app --> storage[Blob Storage]
   ```

4. **Network Topology**: "Subnets, address spaces, NSGs"
5. **Cost Analysis**: "Estimated monthly/annual costs"
6. **Best Practices**: "Automatically included - security, HA, performance"

**Key Takeaways**:

- ✅ **Time**: 5 minutes vs. 6 hours manually (98% faster)
- ✅ **Completeness**: Every resource documented
- ✅ **Diagrams as code**: Version controlled, easy to update
- ✅ **Living documentation**: Regenerate when infrastructure changes

---

## Demo Part 2: Runbook Generation (5 minutes)

### Step 1: Generate Operational Runbook (2 min)

**Show Bicep template**:

```bicep
// main.bicep - Infrastructure as Code
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-prod'
  // ... configuration
}
```

**Generate runbook**:

```powershell
./New-RunbookDoc.ps1 `
    -TemplatePath ".\main.bicep" `
    -OutputPath ".\docs" `
    -IncludeDeploymentSteps `
    -IncludeValidation `
    -IncludeTroubleshooting
```

### Step 2: Review Runbook (3 min)

**Open generated runbook**:

**Highlight sections**:

1. **Deployment Procedure**: "Step-by-step extracted from template"
2. **Validation Checklist**: "Post-deployment checks"
3. **Troubleshooting Guide**: "Common issues and resolutions"
4. **Operational Tasks**: "Daily, weekly, monthly procedures"
5. **Rollback Procedure**: "Emergency procedures"

**Narration**:
> "This used to take 5 hours: deploying manually, taking screenshots, writing procedures, formatting. Now it's extracted directly from infrastructure code in 20 minutes."

---

## Demo Part 3: Troubleshooting Guide (4 minutes)

### Generate Troubleshooting Documentation

```powershell
./New-TroubleshootingGuide.ps1 `
    -ResourceGroupName "rg-techcorp-prod" `
    -LookbackDays 30 `
    -OutputPath ".\docs"
```

**Narration**:
> "This script queries Application Insights for the past 30 days, identifies common errors and patterns, and generates a troubleshooting guide with decision trees."

**Review generated content**:

- Common error patterns (automatically detected)
- Resolution steps (from historical fixes)
- Decision trees (in Mermaid format)
- Related KQL queries

**Time saved**: 4 hours → 30 minutes (87.5% faster)

---

## Demo Part 4: API Documentation (4 minutes)

### Generate API Docs from Code

**Show code with comments**:

```csharp
/// <summary>
/// Retrieves customer order by ID
/// </summary>
/// <param name="orderId">Unique order identifier</param>
/// <returns>Order details</returns>
[HttpGet("orders/{orderId}")]
public async Task<IActionResult> GetOrder(string orderId)
{
    // Implementation
}
```

**Generate documentation**:

```powershell
./New-APIDocumentation.ps1 `
    -ProjectPath ".\src\api" `
    -OutputPath ".\docs" `
    -Format "Markdown" `
    -IncludeExamples
```

**Review output**:

- API endpoints (automatically extracted)
- Request/response examples
- Authentication requirements
- Error codes and handling

**Time saved**: 3 hours → 30 minutes (83% faster)

---

## Validation & ROI (5 minutes)

### Show the Numbers

**Time Comparison**:

| Task | Manual | With Copilot | Savings |
|------|--------|--------------|---------|
| Architecture Diagrams | 6 hrs | 20 min | 96% |
| Runbooks | 5 hrs | 20 min | 93% |
| Troubleshooting | 4 hrs | 30 min | 87.5% |
| API Documentation | 3 hrs | 30 min | 83% |
| Review & Refinement | 2 hrs | 20 min | 83% |
| **TOTAL** | **20 hrs** | **2 hrs** | **90%** |

**ROI Calculation**:

- **Per Project**: $3,000 → $300 = **$2,700 saved**
- **Annual (8 projects)**: **$21,600 saved**
- **Time recovered**: 144 hours/year = **3.6 work weeks**

**Quality Improvements**:

- **Completeness**: 60% → 95% (+35 percentage points)
- **Consistency**: 70% → 100% (template-driven)
- **Update speed**: 5 hours → 30 minutes (90% faster)
- **Accuracy**: Fewer errors (automated extraction)

### Live Validation

**Show in Azure Portal**:

- Compare generated docs to actual resources
- Verify diagrams match reality
- Confirm cost estimates are reasonable

---

## Wrap-Up & Next Steps (2 minutes)

### Key Takeaways

1. **Efficiency Multiplier**: 90% time reduction on documentation
2. **Living Documentation**: Regenerate when infrastructure changes
3. **Version Controlled**: Docs alongside code in Git
4. **Template-Driven**: Consistent, complete, professional

### The Copilot Advantage

**Traditional Approach**:

- ❌ Manual inventory of resources
- ❌ Create diagrams in Visio
- ❌ Write procedures from memory
- ❌ Format in Word/Confluence
- ❌ Outdated within weeks

**Copilot Approach**:

- ✅ Automated resource discovery
- ✅ Diagrams as code (Mermaid)
- ✅ Extract from infrastructure code
- ✅ Markdown (version controlled)
- ✅ Regenerate in minutes

### Partner Value Proposition

> "For MSPs and SIs, documentation quality differentiates you in customer engagements. Copilot lets you deliver professional, comprehensive documentation in 10% of the time - allowing you to take on more projects while improving quality."

### Objection Handling

**Q: "Is the auto-generated documentation good enough?"**  
A: "95% completeness out of the box. The 2 hours with Copilot includes human review and customization - far better than the 60% you get after 20 hours manually."

**Q: "What about custom diagrams and visuals?"**  
A: "Mermaid generates professional diagrams as code. For specialized visuals, use the saved 18 hours to create them."

**Q: "Does this work with existing infrastructure?"**  
A: "Yes! Scans existing Azure resources, extracts from ARM/Bicep templates, and works with any code that has XML/comments."

### Next Actions

1. **Try it**: Generate docs for your Azure environment
2. **Customize**: Adapt templates to your standards
3. **Integrate**: Add to CI/CD pipeline for automated updates
4. **Share**: Establish documentation standards across team

---

## Demo Delivery Tips

### Timing Checkpoints

- ✅ 5 min: Scene setting complete
- ✅ 10 min: Architecture docs generated
- ✅ 15 min: Runbook generated
- ✅ 19 min: Troubleshooting guide complete
- ✅ 23 min: API docs shown
- ✅ 28 min: ROI validated
- ✅ 30 min: Wrap-up and Q&A

### Key Pauses

- After showing 20-hour manual estimate: "Anyone groaning yet?"
- After first doc generates in 5 minutes: "That just saved 6 hours"
- When showing Mermaid diagrams: "No Visio license required"
- At final ROI slide: "144 hours per year - that's almost a month"

### Energy Points

- **High energy**: Opening (documentation pain), ROI reveal
- **Medium energy**: Demo execution (let tool speak for itself)
- **Building energy**: Wrap-up and call to action

### Backup Plans

- **If Azure connection fails**: Use pre-generated documentation examples
- **If script errors**: Have backup screenshots of successful runs
- **If time runs short**: Skip API documentation demo (least critical)

---

*Demo script generated with GitHub Copilot. Delivery time: ~15 minutes to create vs. 3-4 hours manually.*
