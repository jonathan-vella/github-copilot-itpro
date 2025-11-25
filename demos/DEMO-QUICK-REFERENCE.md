# Demo Quick Reference Card

> Print this or keep it on a second screen during the demo.

## Timeline

| Time | Phase | Key Action |
|------|-------|------------|
| **0:00** | Opening | "14-18 hours → 30 minutes" |
| **3:00** | Agent 1 | `azure-principal-architect` → WAF + Cost |
| **11:00** | Agent 2 | `bicep-plan` → Mermaid diagram |
| **16:00** | Agent 3 | `bicep-implement` → Generate code |
| **26:00** | Wrap-up | Show files, state 95% savings |

---

## Copy-Paste Prompts

### Prompt 1: Architecture (Ctrl+Shift+A → azure-principal-architect)

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

### Prompt 2: Planning (Ctrl+Shift+A → bicep-plan)

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

### Prompt 3: Implementation (Ctrl+Shift+A → bicep-implement)

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

---

## Validation Command

```bash
bicep build infra/bicep/contoso-patient-portal/main.bicep && bicep lint infra/bicep/contoso-patient-portal/main.bicep
```

---

## Key Metrics to State

| Traditional | With Copilot | Savings |
|-------------|--------------|---------|
| 14-18 hours | 30 minutes | **95%** |

---

## If Things Go Wrong

| Problem | Say This | Do This |
|---------|----------|---------|
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
