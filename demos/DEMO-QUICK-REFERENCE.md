# Demo Quick Reference Card

> Print this or keep it on a second screen during the demo.
> **Plan Agent Docs:** [VS Code Chat Planning](https://code.visualstudio.com/docs/copilot/chat/chat-planning)

## Timeline

| Time | Step | Agent | Key Action |
|------|------|-------|------------|
| **0:00** | Opening | - | "18-24 hours → 30 minutes" |
| **3:00** | Step 1 | `@plan` (built-in) | Research & breakdown → **Approve** |
| **8:00** | Step 2 | `azure-principal-architect` | WAF + Cost → **Approve** |
| **14:00** | Step 3 | `bicep-plan` | Mermaid diagram → **Approve** |
| **19:00** | Step 4 | `bicep-implement` | Generate code → **Approve** |
| **24:00** | Optional | `diagram-generator` | Architecture diagram (PNG) |
| **26:00** | Wrap-up | - | Show files, state 95% savings |

---

## Copy-Paste Prompts

### Step 1: Plan Agent (Agents dropdown → Plan)

```text
I need to design and implement a HIPAA-compliant patient portal for Contoso Healthcare.

**Context:**
- 10,000 patients, 50 staff members
- $800/month budget constraint
- HIPAA compliance required
- 3-month timeline

Please help me:
1. Break down this project into implementation phases
2. Identify key architectural decisions
3. List open questions that need clarification
4. Recommend which specialized agents to use for each phase
```

> **Approval Gate**: Review plan and reply "approve" or provide feedback

### Step 2: Architecture (Ctrl+Shift+A → azure-principal-architect)

```text
Design an Azure architecture for the Contoso Healthcare patient portal based on our plan.

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
- Region: swedencentral (sustainable operations)

Please provide:
1. WAF assessment with scores for all 5 pillars
2. Recommended Azure services with SKUs
3. Monthly cost estimate
4. Security considerations

After assessment, hand off to the Bicep Planning Specialist.
```

> **Approval Gate**: Review WAF assessment and reply "approve" or provide feedback

### Step 3: Planning (Ctrl+Shift+A → bicep-plan)

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

> **Approval Gate**: Review implementation plan and reply "approve" or provide feedback

### Step 4: Implementation (Ctrl+Shift+A → bicep-implement)

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

> **Approval Gate**: Review generated code, run `bicep build`, and reply "approve" or "deploy"

### Optional: Architecture Diagram (Ctrl+Shift+A → diagram-generator)

```text
Generate a Python architecture diagram for the Contoso Healthcare patient portal.

Include:
- Azure Front Door for global load balancing
- App Service in Sweden Central
- Azure SQL Database
- Key Vault for secrets
- Application Insights for monitoring
- Virtual Network with private endpoints
```

---

## Validation Command

```bash
bicep build infra/bicep/contoso-patient-portal/main.bicep && bicep lint infra/bicep/contoso-patient-portal/main.bicep
```

---

## Key Metrics to State

| Traditional | With Copilot | Savings |
|-------------|--------------|-------|
| 18-24 hours | 30 minutes | **95%** |

**Key Insight:** "We started with Plan Agent, which researched before any code. That plan is now a reusable `*.prompt.md` file."

---

## If Things Go Wrong

| Problem | Say This | Do This |
|---------|----------|--------|
| Plan Agent missing | "Let me update VS Code..." | Ensure VS Code + Copilot extension are current |
| Agent slow | "Complex architecture takes a moment..." | Keep talking about WAF pillars |
| Agent fails | "Let me show the pre-built output..." | Open `infra/bicep/contoso-patient-portal/` |
| Code error | "Even AI needs review—let's fix it" | Show `bicep lint` catching issues |

---

## Backup Files Location

```
infra/bicep/contoso-patient-portal/
├── main.bicep          ← Show uniqueSuffix generation
├── deploy.ps1          ← Show WhatIf support
└── modules/
    ├── key-vault.bicep ← Show AVM module usage
    └── networking.bicep ← Show CAF naming pattern
```
