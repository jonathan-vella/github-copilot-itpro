# Demo Script: Four-Agent Workflow for Azure Infrastructure

**Duration**: 45-60 minutes (full) | 15-20 minutes (abbreviated)  
**Audience**: Solution Architects, Cloud Architects, Infrastructure Engineers  
**Presenter Prep Time**: 15 minutes

## 🎯 Demo Objectives

By the end of this demo, the audience will:

1. Understand how custom agents streamline infrastructure design
2. See the value of automatic context handoffs between agents
3. Recognize 95% time savings vs. traditional approaches
4. Feel confident trying the workflow on their own projects

## 📋 Pre-Demo Checklist

### Environment Setup (10 minutes before)

- [ ] VS Code open with GitHub Copilot installed
- [ ] Open `demos/07-five-agent-workflow/` directory
- [ ] GitHub Copilot Chat visible (`Ctrl+Shift+I`)
- [ ] Test agent selection (`Ctrl+Shift+A`) - verify all 4 agents available
- [ ] Have `prompts/workflow-prompts.md` ready in second window
- [ ] Azure Portal open (optional - for showing deployment validation)

### Presenter Preparation

- [ ] Review scenario (`scenario/business-requirements.md`)
- [ ] Rehearse agent transitions (handoff button clicks)
- [ ] Prepare answers to common questions (see below)
- [ ] Test Bicep validation commands (if doing live validation)

## 🎬 Demo Script

---

### Opening: The Challenge (3 minutes)

**[Slide or Verbal]**

"Let me show you a common scenario. You're meeting with a customer - Contoso Healthcare - and they need a patient portal. Let's look at their requirements..."

**[Open `scenario/business-requirements.md`]**

**Scroll through key points:**

- 10,000 patients, $800/month budget
- HIPAA mandatory
- 99.9% SLA requirement
- 12-week timeline

**The Traditional Approach:**

"Traditionally, this would take 2-3 days:

- Day 1: Architect reviews requirements, creates architecture document (4-6 hours)
- Day 2: Infrastructure engineer translates to Bicep templates (6-8 hours)
- Day 3: Security review, cost optimization, revisions (4 hours)

**Total: 14-18 hours of expert time**

But what if we could do this in 30-45 minutes?"

---

### Stage 1: Architecture Design (15 minutes)

**[Open GitHub Copilot Chat]**

"I'm going to use GitHub Copilot's custom agents to accelerate this. We have 4 specialized agents..."

**[Press `Ctrl+Shift+A` to show agent dropdown]**

"Let me select the **Azure Principal Architect** agent..."

**[Select `azure-principal-architect` from dropdown]**

**[Open `prompts/workflow-prompts.md` and copy Stage 1 prompt]**

**Paste prompt and submit:**

```text
You are designing Azure infrastructure for Contoso Healthcare's patient portal.

**Business Context:**
- Organization: Mid-sized healthcare provider
- Patients: 10,000 active patients
- Staff: 50 clinical and administrative users
- Compliance: HIPAA mandatory (BAA required)

**Technical Requirements:**
- Budget: $800/month maximum
- SLA: 99.9% uptime minimum
- Regions: US only (data sovereignty)
- Performance: Support 60+ concurrent users
...
```

**While agent processes (30-60 seconds):**

"The Azure Principal Architect agent is trained on the Azure Well-Architected Framework. It will assess this scenario across 5 pillars: Security, Reliability, Performance, Cost, and Operations."

**[Agent returns results - scroll through output]**

**Highlight key sections:**

1. **WAF Scores:**

```yaml
   Security: 9/10 (High confidence) - Private endpoints, managed identities
   Reliability: 7/10 (Medium) - Zone redundancy limited by budget
   Cost: 8/10 (High) - $334/month well under $800 budget
```

   "Notice it scored each pillar and provided confidence levels. This helps us understand trade-offs."

1. **Service Recommendations:**

```yaml
   - App Service Standard S1 (zone-redundant, 2 instances) - $146/month
   - SQL Database Standard S2 (50 DTUs) - $150/month
   - Key Vault for secrets management - $3/month
   ...
```

   "It recommended specific SKUs with justifications and costs."

1. **HIPAA Compliance:**

```text
   ✅ Encryption at rest (TDE for SQL Database)
   ✅ Encryption in transit (TLS 1.2 minimum)
   ✅ Private endpoints for network isolation
   ✅ Audit logging to Log Analytics
   ...
```

   "Compliance requirements are automatically mapped."

**[Scroll to bottom - find handoff button]**

"Now here's the magic - see this **'Plan Bicep Implementation'** button? This hands off to the next agent with full context preserved."

**[Click handoff button]**

---

### Stage 2: Implementation Planning (10 minutes)

**[Bicep Planning Specialist agent auto-selects]**

"The Bicep Planning Specialist is now active. It received the entire architecture assessment automatically - no copy/paste needed!"

**[Agent processes and returns implementation plan]**

**Scroll through output, highlighting:**

1. **Resource Definitions:**

   ```yaml
   - resourceGroup:
       name: rg-contoso-patient-portal
       kind: Raw
       purpose: Foundation container for all resources
       estimatedCost:
         sku: N/A
         monthlyRange: $0

```

   "Each resource is fully specified with purpose, dependencies, parameters, and costs."

2. **Mermaid Dependency Diagram:**

   ```mermaid
   graph TD
       RG[Resource Group] --> VNet[Virtual Network]
       VNet --> NSGs[Network Security Groups]
       ...
```

   "Visual dependency graph shows deployment order."

1. **4-Phase Implementation:**

```yaml
   Phase 1: Foundation (8 tasks)
   Phase 2: Platform Services (8 tasks)
   Phase 3: Security & Application (9 tasks)
   Phase 4: Configuration & Access (10 tasks)
```

   "Progressive deployment ensures dependencies are met."

1. **Cost Table:**

```bicep
   | Resource | Monthly Cost |
   |----------|--------------|
   | App Service Plan | $146 |
   | SQL Database | $150 |
   | Total | $331-346 |
```

   "Detailed cost breakdown with optimization opportunities."

**[Find handoff button at bottom]**

"Now we hand off to the Bicep Implementation Specialist..."

**[Click 'Generate Bicep Code' button]**

---

### Stage 3: Bicep Template Generation (15 minutes)

**[Bicep Implementation Specialist agent auto-selects]**

"The implementation specialist generates production-ready Bicep templates from the plan."

**[Agent generates templates]**

**[Navigate to `../../infra/bicep/contoso-patient-portal/` in Explorer]**

"Let's look at what was generated..."

**[Open `main.bicep`]**

```bicep
// Main orchestration template
targetScope = 'subscription'

param location string = 'eastus2'
param environment string = 'prod'
...
```

"Clean, modular main orchestrator with clear structure."

**[Open `modules/` directory]**

"11 separate module files - each with single responsibility:

- `networking.bicep` - VNet, subnets, NSGs
- `app-service.bicep` - Web application hosting
- `sql-database.bicep` - Database with TDE encryption
- `key-vault.bicep` - Secrets management
- `private-endpoints.bicep` - Secure connectivity
..."

**[Open `deploy.ps1`]**

```powershell
# Deployment script with validation
function Test-Prerequisites {
    # Check Azure CLI...
    # Check Bicep CLI...
    # Check authentication...
}
```

"Deployment automation with pre-flight checks, validation, and error handling."

**[Optional: Live Validation]**

**If time permits, run validation:**

```powershell
cd infra/bicep/contoso-patient-portal
bicep build main.bicep --stdout --no-restore
```

**[Show successful compilation]**

"Zero errors - production-ready on first attempt!"

```powershell
bicep lint main.bicep
```

"Linting passes - follows Azure best practices."

**[Optional: Show what-if]**

```powershell
.\deploy.ps1 -WhatIf
```

"What-if shows exactly what would be deployed - no surprises."

---

### Value Summary (5 minutes)

**[Switch back to presentation or verbal summary]**

"Let's recap what we just accomplished in 30-45 minutes:

**Traditional Approach:**

- Architecture Assessment: 4-6 hours
- Implementation Planning: 3-6 hours  
- Bicep Template Creation: 6-8 hours
- **Total: 13-20 hours**

**With 4-Agent Workflow:**

- Stage 1 (Architecture): 5 minutes
- Stage 2 (Planning): 5 minutes
- Stage 3 (Implementation): 10 minutes
- **Total: 30-45 minutes**

**Time Savings: 95%**

**ROI Calculation:**

- SI Partner Rate: $150/hour
- Traditional: 20 hours × $150 = **$3,000**
- With Copilot: 1 hour × $150 = **$150**
- **Savings: $2,850 per project**

**But it's not just speed...**

✅ **Consistent Quality**: Best practices applied automatically  
✅ **No Context Loss**: Architecture drives implementation  
✅ **Security Defaults**: HIPAA compliance built-in  
✅ **Production Ready**: Deployable immediately  
✅ **Always Documented**: Living documentation

---

### Q&A and Next Steps (5-10 minutes)

**Common Questions:**

**Q: Does this work for other compliance frameworks?**
A: Yes! Swap HIPAA for PCI-DSS, SOC 2, or ISO 27001 in Stage 1 prompt.

**Q: Can I customize agent behavior?**
A: Absolutely. Edit `.github/agents/*.agent.md` files to adjust instructions.

**Q: What if I disagree with recommendations?**
A: You control the process - edit outputs before proceeding to next stage or regenerate with different constraints.

**Q: Does this replace architects?**
A: No - it augments them. Architects make decisions; agents handle time-consuming documentation and code generation.

**Q: What about other clouds (AWS, GCP)?**
A: The workflow pattern applies universally. You'd need to create cloud-specific agents with appropriate best practices.

**Next Steps for Audience:**

1. **Try It**: Use this demo scenario on your own machine
2. **Customize**: Edit prompts for your customer scenarios
3. **Experiment**: Adjust budgets, compliance requirements, complexity
4. **Share**: Show colleagues and customers the ROI

**Where to Find Everything:**

- Demo Files: `demos/07-five-agent-workflow/`
- Agent Configuration: `.github/agents/`
- Full Workflow Guide: `resources/copilot-customizations/FIVE-MODE-WORKFLOW.md`
- Bicep Templates: `infra/bicep/contoso-patient-portal/`

---

## 🎭 Abbreviated Demo (15-20 minutes)

If short on time, use this condensed version:

1. **Opening (2 min)**: Show requirements, state traditional timeline
2. **Stage 1 (5 min)**: Submit prompt, highlight WAF scores and cost estimate only, click handoff
3. **Stage 2 (3 min)**: Show resource list and Mermaid diagram only, click handoff
4. **Stage 3 (5 min)**: Show generated file structure and one module file only
5. **Wrap-up (3 min)**: ROI metrics and Q&A

## 🎨 Presentation Variations

### For Executives

- Focus on ROI ($2,850 savings per project)
- Emphasize speed to market (12-week timeline achievable)
- Highlight risk reduction (security defaults, compliance automation)

### For Architects

- Deep-dive WAF scores and trade-off analysis
- Show architecture diagram generation
- Discuss customization of agent instructions

### For Developers

- Focus on code quality (modular templates, security defaults)
- Show validation commands (bicep build/lint)
- Demonstrate deployment automation

### For IT Pros

- Emphasize operational benefits (standardization, reproducibility)
- Show deployment script pre-flight checks
- Discuss rollback and troubleshooting procedures

## 🧪 Interactive Elements

### Audience Participation Ideas

1. **Change a Requirement**: Ask audience to suggest budget change ($200 or $2,000) and regenerate Stage 1
2. **Add Compliance**: Ask what industry they're in and add compliance requirement (PCI-DSS, SOC 2)
3. **Complexity Vote**: Ask if they want simpler (Basic tier) or more complex (multi-region) version

### Live Demos

- Deploy to actual Azure subscription (requires 30-45 min total)
- Show Azure Portal resources after deployment
- Test App Service URL accessibility

## 📝 Presenter Notes

### Timing Tips

- **Stage 1 generation**: ~30-60 seconds (talk about WAF pillars while waiting)
- **Stage 2 generation**: ~45-90 seconds (explain Mermaid diagram benefits)
- **Stage 3 generation**: ~60-120 seconds (discuss modular design principles)

### Things That Can Go Wrong

- **Agent not available**: Verify GitHub Copilot subscription and agent configuration
- **Handoff button missing**: Manually copy Stage 2 prompt with architecture output
- **Bicep validation fails**: Use pre-generated templates from `outputs/` directory
- **Audience questions derail timing**: "Great question - let's discuss after the demo"

### Energy Management

- Pause after each agent output to let audience absorb
- Use humor: "I'm pressing a button and getting production-ready code - this still amazes me"
- Invite reactions: "Have you seen anything like this before?"

---

**Demo Version**: 1.0.0  
**Last Updated**: November 18, 2025  
**Tested By**: GitHub Copilot team  
**Feedback**: Open an issue in the repo
