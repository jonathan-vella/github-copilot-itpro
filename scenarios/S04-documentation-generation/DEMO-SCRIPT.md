# Demo 5: Documentation Generator

**Duration**: 30 minutes  
**Audience**: IT Pros, Cloud Architects, System Integrators  
**Value Proposition**: Reduce documentation time from 25 hours to 3.3 hours (87% reduction), saving $26,000 annually

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
- Show Word document: "8 hours writing Day 2 operations guides"
- Open Excel: "5 hours compiling troubleshooting guides"
- Show empty README: "4 hours documenting APIs"
- Review & polish: "2 hours formatting and cleanup"
- **Total: 25 hours of tedious work**

**The Pain Points**:

1. ❌ **Time-consuming**: 25 hours per project (3+ workdays)
2. ❌ **Outdated immediately**: Infrastructure changes, docs don't
3. ❌ **Inconsistent**: Different formats, missing sections
4. ❌ **Never complete**: Always 60% done, "we'll finish it later"
5. ❌ **Tools dependency**: Visio licenses, formatting nightmares

**Business Impact**:

- **$3,750 in labor** per project (25 hours × $150/hr)
- **8 projects per year** = $30,000 in documentation costs
- **Customer dissatisfaction**: Incomplete handoffs
- **Knowledge loss**: When team members leave

### The Copilot Solution

**Show completed documentation**:
> "What if we could automate this? Generate docs from code, diagrams from Azure queries, runbooks from templates?"

**Value Proposition**:

- ⏱️ **Time**: 25 hours → 3.3 hours (87% reduction)
- 💰 **Cost**: $3,750 → $500 per project
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
./solution/ArchitectureDoc.ps1 `
    -ResourceGroupName "rg-techcorp-prod" `
    -OutputPath ".\docs" `
    -IncludeDiagrams `
    -IncludeDataFlow `
    -IncludeSecurity
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

- ✅ **Time**: ~15 min to generate prompt + 30 min Copilot generation vs. 6 hours manually (87.5% faster)
- ✅ **Completeness**: Every resource documented with context
- ✅ **Diagrams as code**: Copilot generates Mermaid diagrams - no Visio needed
- ✅ **Living documentation**: Regenerate prompt when infrastructure changes

---

## Demo Part 2: Day 2 Operations Guide (5 minutes)

### Step 1: Generate Operations Guide (2 min)

**Explain the approach**:
> "Instead of extracting from Bicep templates, we'll scan the deployed Azure resources and generate a comprehensive Day 2 operations guide covering monitoring, maintenance, backup, scaling, and troubleshooting."

**Generate runbook**:

```powershell
./solution/Day2OperationsGuide.ps1 `
    -ResourceGroupName "rg-techcorp-prod" `
    -OutputPath ".\docs"
```

### Step 2: Review Operations Guide (3 min)

**Open generated prompt file** (`day2-operations-prompt.txt`), then paste into Copilot Chat:

**Highlight what Copilot will generate**:

1. **Daily Operations**: "Health checks, log reviews, backup verification"
2. **Weekly Operations**: "Performance reviews, cost analysis, security audits"
3. **Monthly Operations**: "Capacity planning, DR testing, patch management"
4. **Scaling Procedures**: "Manual and auto-scale guidance"
5. **Backup & Recovery**: "Backup verification and restore procedures"

**Narration**:
> "This used to take 8 hours: documenting procedures, creating checklists, formatting. Now the script scans Azure resources and generates a context-rich prompt in minutes. Copilot then creates the final guide in under an hour."

---

## Demo Part 3: Troubleshooting Guide (4 minutes)

### Generate Troubleshooting Documentation

```powershell
./solution/TroubleshootingGuide.ps1 `
    -ResourceGroupName "rg-techcorp-prod" `
    -OutputPath ".\docs" `
    -IncludeDiagnostics `
    -IncludeRunbooks
```

**Narration**:
> "This script scans Azure resources and generates a comprehensive troubleshooting prompt. It identifies resource types, common issues for each, and builds a structured guide with diagnostic queries and runbooks."

**Review generated prompt** (paste into Copilot to generate final guide):

- Resource-specific troubleshooting sections
- Diagnostic KQL queries for Application Insights
- Azure CLI commands for investigation
- Step-by-step runbooks for common issues
- Decision trees (Copilot will generate in Mermaid format)

**Time saved**: 5 hours → 40 minutes (87% faster)

---

## Demo Part 4: API Documentation (4 minutes)

### Generate API Documentation

**Explain the approach**:
> "This script scans Azure for API-capable resources like App Services, Function Apps, API Management, and Container Apps. It generates a comprehensive prompt for documenting your APIs."

**Generate documentation**:

```powershell
./solution/APIDocumentation.ps1 `
    -ResourceGroupName "rg-techcorp-prod" `
    -OutputPath ".\docs" `
    -IncludeAuthentication `
    -IncludeExamples `
    -IncludeSDKs
```

**Review generated prompt** (paste into Copilot to create final API docs):

- API resource inventory (Web Apps, Functions, APIM, Container Apps)
- Authentication and authorization guidance
- Code examples in multiple languages (JS, Python, C#, PowerShell)
- SDK generation instructions (OpenAPI/Swagger)
- Error handling patterns

**Time saved**: 4 hours → 30 minutes (87.5% faster)

---

## Validation & ROI (5 minutes)

### Show the Numbers

**Time Comparison**:

| Task | Manual | With Copilot | Savings |
|------|--------|--------------|---------|
| Architecture Documentation | 6 hrs | 45 min | 87.5% |
| Day 2 Operations Guide | 8 hrs | 1 hr | 87.5% |
| Troubleshooting Guide | 5 hrs | 40 min | 87% |
| API Documentation | 4 hrs | 30 min | 87.5% |
| Review & Refinement | 2 hrs | 25 min | 80% |
| **TOTAL** | **25 hrs** | **3 hrs 20 min** | **87%** |

**ROI Calculation**:

- **Per Project**: $3,750 → $500 = **$3,250 saved** (25 hrs @ $150/hr → 3.33 hrs)
- **Annual (8 projects)**: **$26,000 saved**
- **Time recovered**: 173 hours/year = **4.3 work weeks**

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

1. **Efficiency Multiplier**: 87% time reduction on documentation (25 hrs → 3.3 hrs)
2. **Prompt-Based Generation**: Scripts scan Azure and build context-rich prompts for Copilot
3. **Living Documentation**: Regenerate prompts when infrastructure changes
4. **Version Controlled**: Prompts and generated docs alongside code in Git

### The Copilot Advantage

**Traditional Approach**:

- ❌ Manual inventory of resources
- ❌ Create diagrams in Visio
- ❌ Write procedures from memory
- ❌ Format in Word/Confluence
- ❌ Outdated within weeks

**Copilot Approach**:

- ✅ Automated resource discovery (scripts scan Azure)
- ✅ Context-rich prompts (not final docs)
- ✅ Copilot generates docs with diagrams (Mermaid)
- ✅ Markdown (version controlled)
- ✅ Regenerate prompts in seconds, final docs in minutes

### Partner Value Proposition

> "For MSPs and SIs, documentation quality differentiates you in customer engagements. Copilot lets you deliver professional, comprehensive documentation in 13% of the time - saving $3,250 per project. This allows you to take on more projects while improving quality and customer satisfaction."

### Objection Handling

**Q: "Is the auto-generated documentation good enough?"**  
A: "The scripts generate context-rich prompts (not final docs). You paste these into Copilot Chat, which creates 95% complete documentation. The 3.3 hours includes prompt generation, Copilot interaction, and review - far better than 60% completeness after 25 hours manually."

**Q: "What about custom diagrams and visuals?"**  
A: "Copilot generates Mermaid diagrams automatically from the prompts. For specialized visuals, use the saved 22 hours to create them."

**Q: "Does this work with existing infrastructure?"**  
A: "Yes! Scripts use Azure Resource Graph to scan your deployed resources. No Bicep/ARM templates required - works with any Azure environment."

### Next Actions

1. **Try it**: Generate docs for your Azure environment
2. **Customize**: Adapt templates to your standards
3. **Integrate**: Add to CI/CD pipeline for automated updates
4. **Share**: Establish documentation standards across team

---

## Demo Delivery Tips

### Timing Checkpoints

- ✅ 5 min: Scene setting complete
- ✅ 10 min: Architecture prompt generated
- ✅ 15 min: Day 2 ops prompt generated
- ✅ 19 min: Troubleshooting prompt complete
- ✅ 23 min: API docs prompt shown
- ✅ 28 min: ROI validated
- ✅ 30 min: Wrap-up and Q&A

### Key Pauses

- After showing 25-hour manual estimate: "Anyone groaning yet?"
- After first prompt generates in seconds: "That just created the context Copilot needs"
- When showing prompt files: "These become living documentation - regenerate anytime"
- At final ROI slide: "173 hours per year - over a month of recovered time"

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
