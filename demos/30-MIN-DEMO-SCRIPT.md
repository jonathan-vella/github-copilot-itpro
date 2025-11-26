# High-Impact 30-Minute Demo Script

> **Audience:** Technical professionals (architects, engineers, IT pros)
> **Goal:** Show GitHub Copilot as an efficiency multiplier for Azure infrastructure
> **Key Metric:** 18 hours → 45 minutes (95% time savings)

---

## Pre-Demo Setup (Do This 15 Minutes Before)

### Environment Check

```bash
# 1. Verify Dev Container is running
az --version && az bicep version

# 2. Verify Azure login
az account show --query name -o tsv

# 3. Pre-open these files in VS Code tabs:
#    - scenarios/S03-five-agent-workflow/scenario/requirements.md
#    - infra/bicep/contoso-patient-portal/main.bicep (as backup)

# 4. Open Copilot Chat panel (Ctrl+Shift+I)
# 5. Clear chat history for clean start
```

### Browser Tabs Ready

1. This demo script (for timing reference)
2. Azure Portal (logged in, ready to show resources if needed)

### Backup Plan

If live demo fails, switch to walking through the completed output in `infra/bicep/contoso-patient-portal/`.

---

## Demo Timeline

| Time  | Phase   | What You're Doing                          |
| ----- | ------- | ------------------------------------------ |
| 0:00  | Opening | Set the scene, show the problem            |
| 3:00  | Agent 1 | Azure Principal Architect designs solution |
| 11:00 | Agent 2 | Bicep Planner creates implementation plan  |
| 16:00 | Agent 3 | Bicep Implement generates production code  |
| 26:00 | Wrap-up | Show results, metrics, Q&A                 |

---

## 🎬 Opening: The Challenge (0:00 - 3:00)

### What to Say

> "Imagine you're a cloud architect at Contoso Healthcare. Your CTO just walked into your office with an urgent request: 'We need a HIPAA-compliant patient portal. Patients should be able to schedule appointments, view their records, and message their doctors. We need this architected by end of week.'
>
> Traditionally, this would take you 2-3 days:
>
> - **Day 1:** Research Azure services, check compliance requirements
> - **Day 2:** Design architecture, create Bicep templates
> - **Day 3:** Test, validate, document
>
> That's 14-18 hours of focused work. Today, I'll show you how to do this in 30 minutes."

### What to Show

1. Open `scenarios/S03-five-agent-workflow/scenario/requirements.md`
2. Highlight the business requirements (quick scroll)
3. Mention: "HIPAA compliance, 99.9% SLA, $800/month budget"

### Transition

> "Let's start with the architecture. I'm going to use our Azure Principal Architect agent."

---

## 🏗️ Stage 1: Azure Principal Architect (3:00 - 11:00)

### What to Do

1. Press `Ctrl+Shift+A` to open Agent selector
2. Select **azure-principal-architect**
3. Paste this prompt:

```text
Design an Azure architecture for Contoso Healthcare's patient portal.

**Business Context:**
- Secure patient portal for appointment scheduling
- 10,000 patients, 50 staff members
- HIPAA compliance mandatory
- Budget: $800/month operating cost

**Technical Requirements:**
- 99.9% availability SLA
- Encryption at rest and in transit
- Audit logging for compliance
- Private network access for databases

Please provide:
1. WAF assessment with scores for all 5 pillars
2. Recommended Azure services with SKUs
3. Monthly cost estimate
4. Security considerations

After assessment, hand off to the Bicep Planning Specialist.
```

### What to Highlight While Agent Works

> "Notice a few things happening here:
>
> - The agent is analyzing our requirements against all 5 pillars of the Azure Well-Architected Framework
> - It's selecting specific SKUs—not just 'use App Service' but 'use S1 for dev, P1v3 for production'
> - It's calculating estimated monthly costs
> - And it's thinking about HIPAA compliance from the start"

### Pause Points (Let Audience See)

- **WAF Scores:** "Look at this—we're getting scored on Security, Reliability, Cost, Performance, and Operational Excellence"
- **Cost Estimate:** "It's telling us $331-346/month, well under our $800 budget"
- **Security Features:** "Notice it's already specifying TLS 1.2, encryption, managed identities"

### Transition

> "The architect has done the design. Now let's hand off to our Bicep Planning Specialist to create an implementation plan."

---

## 📋 Stage 2: Bicep Planning (11:00 - 16:00)

### What to Do

1. Click "Plan Bicep Implementation" button (if handoff button appears)
   - OR select **bicep-plan** agent and paste:

```text
Create a Bicep implementation plan for the Contoso Healthcare patient portal.

**Planning Requirements:**
1. Evaluate Azure Verified Modules (AVM) for each resource
2. Resource breakdown with deployment order and dependencies
3. Mermaid dependency diagram
4. Module structure (networking, compute, data, security)
5. Phase-based deployment approach
6. Cost estimates for all resources

Save the plan to: .bicep-planning-files/INFRA.contoso-patient-portal.md
Then hand off to the Bicep Implementation Specialist.
```

### What to Highlight

> "This agent is doing something really powerful—it's thinking about **dependencies**.
> You can't create a private endpoint before the VNet exists.
> You can't store secrets in Key Vault before Key Vault is deployed.
> Getting this order wrong is one of the most common deployment failures."

### Show the Mermaid Diagram

When the agent generates the dependency diagram, point out:

> "This visual shows us exactly what depends on what. Resource Group first, then networking, then platform services, then application tier, then configuration. This is the kind of diagram that usually takes an hour to create manually."

### Transition

> "We have our design and our plan. Now let's generate the actual Bicep code."

---

## 💻 Stage 3: Bicep Implementation (16:00 - 26:00)

### What to Do

1. Click "Generate Bicep Code" button (if handoff button appears)
   - OR select **bicep-implement** agent and paste:

```text
Implement the Bicep templates for the Contoso Healthcare patient portal.

**Output path:** infra/bicep/contoso-patient-portal/

**Requirements:**
1. Use Azure Verified Modules (AVM) where available
2. Generate uniqueSuffix from resourceGroup().id in main.bicep
3. Pass uniqueSuffix to ALL modules for globally unique names
4. Modular structure with modules/ folder
5. Security defaults: HTTPS only, TLS 1.2, private endpoints, managed identities
6. CAF naming conventions: {type}-{project}-{env}-{suffix}
7. Deployment script (deploy.ps1) with WhatIf support
8. README.md with deployment instructions

Tags: Environment, ManagedBy, Project, Owner
Default region: swedencentral
```

### What to Highlight (As Files Are Generated)

**When main.bicep appears:**

> "This is the orchestration file. See how it generates a `uniqueSuffix` from the resource group ID? That's critical—it ensures globally unique names for Key Vault, Storage, and SQL Server. The suffix gets passed to every module, preventing deployment failures from naming collisions."

**When modules/ folder populates:**

> "Notice we're using Azure Verified Modules where available—these are Microsoft's official, tested modules from the Bicep registry. When AVM isn't available, we get well-structured custom modules. Each one is reusable and follows best practices."

**When deploy.ps1 appears:**

> "And here's our deployment script with WhatIf support, validation, and cost estimation built in."

### Live Validation (If Time Permits)

```bash
# In terminal, run:
bicep build infra/bicep/contoso-patient-portal/main.bicep
bicep lint infra/bicep/contoso-patient-portal/main.bicep
```

> "Zero errors, zero warnings. This code is ready to deploy."

### Transition

> "Let's look at what we accomplished."

---

## 🎯 Wrap-Up: The Results (26:00 - 30:00)

### Show the File Structure

Open the Explorer panel and expand `infra/bicep/contoso-patient-portal/`:

```
contoso-patient-portal/
├── main.bicep                 # Orchestration + uniqueSuffix generation
├── main.bicepparam            # Parameter values
├── deploy.ps1                 # PowerShell deployment with WhatIf
├── README.md                  # Documentation
└── modules/
    ├── networking.bicep       # VNet, subnets, NSGs (AVM-based)
    ├── log-analytics.bicep    # Log Analytics workspace
    ├── app-insights.bicep     # Application Insights
    ├── app-service.bicep      # Web app with managed identity
    ├── sql-server.bicep       # Azure SQL with AD auth
    ├── key-vault.bicep        # Key Vault (AVM-based)
    └── private-endpoints.bicep # Private endpoints for data tier
```

### State the Metrics

> "Let's talk about what just happened:
>
> | Metric        | Traditional   | With Copilot                      |
> | ------------- | ------------- | --------------------------------- |
> | Time          | 14-18 hours   | 30 minutes                        |
> | Files         | Varies        | 10+ near-production-ready modules |
> | Security      | Manual review | Built-in from the start           |
> | Documentation | Often skipped | Auto-generated                    |
>
> That's a **95% time reduction**. And this isn't prototype code—it's near-production-ready with HIPAA compliance, private endpoints, and managed identities."

### Call to Action

> "If you want to try this yourself:
>
> 1. Clone this repository: `github.com/jonathan-vella/github-copilot-itpro`
> 2. Open in Dev Container—everything is pre-configured
> 3. Start with S01-bicep-baseline if you're new, or S03-five-agent-workflow to see the full power
>
> Questions?"

---

## 🆘 Troubleshooting During Demo

| Problem                 | Quick Fix                                                          |
| ----------------------- | ------------------------------------------------------------------ |
| Agent not responding    | Switch to different model (GPT-4o) or use pre-generated output     |
| Slow generation         | Keep talking about what's happening, explain the complexity        |
| Error in generated code | "This is realistic—even AI needs review. Let's fix this together." |
| Network issues          | Switch to offline walkthrough of `contoso-patient-portal/`         |

### Backup: Pre-Generated Output Walkthrough

If live demo fails completely, spend 10 minutes walking through:

1. `main.bicep` - Show modular structure
2. `modules/networking.bicep` - Show NSG rules, subnet design
3. `modules/key-vault.bicep` - Show security settings
4. `deploy.ps1` - Show deployment automation

---

## 📝 Anticipated Q&A

### "How does context pass between agents?"

> "Each agent is configured with specific instructions in `.github/agents/`. When one agent 'hands off' to another, it's actually passing the conversation history plus its output. The next agent sees everything the previous one produced."

### "Can I customize the agents?"

> "Absolutely. The agent files are just markdown. You can modify the instructions, add your own security requirements, or create entirely new agents for your specific workflows."

### "What about hallucinations or wrong code?"

> "Great question. That's why we always run `bicep build` and `bicep lint` before deploying. The AI generates the code; you validate and approve it. Your expertise is still essential."

### "Does this work with Terraform?"

> "Yes! Check out S02-terraform-baseline for the same hub-spoke demo in Terraform. The workflow is similar, just different agents."

### "What's the learning curve?"

> "Most people are productive within a day. The Dev Container handles all tool setup. The real skill is learning to write good prompts—and we have examples for that in every scenario."

---

## 📊 Quick Reference Card

### Agent Commands

| Agent                     | Access       | Purpose                                   |
| ------------------------- | ------------ | ----------------------------------------- |
| @plan                     | Built-in     | Create strategy with cost estimates       |
| azure-principal-architect | Ctrl+Shift+A | WAF assessment, architecture design       |
| bicep-plan                | Ctrl+Shift+A | Implementation planning, Mermaid diagrams |
| bicep-implement           | Ctrl+Shift+A | Generate production Bicep code            |

### Key Talking Points

- **"Efficiency multiplier"** - Not replacing you, augmenting you
- **"Azure Verified Modules"** - Using Microsoft's official, tested modules
- **"uniqueSuffix pattern"** - Prevents naming collisions in Azure
- **"Context-aware"** - Agents hand off knowledge to each other
- **"Verifiable"** - Run `bicep build` and `bicep lint` to prove quality

### Time Savings by Task

| Task                | Manual          | With Copilot | Savings |
| ------------------- | --------------- | ------------ | ------- |
| Architecture design | 4-6 hours       | 10 min       | 90%     |
| Bicep templates     | 6-8 hours       | 15 min       | 95%     |
| Documentation       | 2-4 hours       | 5 min        | 90%     |
| **Total**           | **14-18 hours** | **30 min**   | **95%** |
