# GitHub Copilot Supplementary Chat Modes

This directory contains supplementary chat modes that enhance GitHub Copilot's capabilities for Azure infrastructure development.

## ⚠️ Important: Primary Workflow Uses Custom Agents

This repository's **primary workflow** uses **Custom Agents** (not chat modes) located in `.github/agents/`:

- **@adr-generator** - Document architectural decisions
- **@azure-principal-architect** - Azure Well-Architected Framework guidance
- **@bicep-plan** - Infrastructure planning with AVM modules
- **@bicep-implement** - Bicep code generation

📖 See [FOUR-MODE-WORKFLOW.md](../FOUR-MODE-WORKFLOW.md) for the complete agent-based workflow.

## Overview

This directory contains **supplementary chat modes** for specialized scenarios not covered by the primary agent workflow. These modes provide context-specific expertise for alternative Infrastructure as Code approaches (Terraform), debugging, and Azure Verified Module exploration.

### Archived Modes

Three chat modes (azure-principal-architect, bicep-plan, bicep-implement) have been **superseded by Custom Agents** and moved to `archive/`. See [archive/README.md](archive/README.md) for migration guidance.

## Available Supplementary Chat Modes

---

#### bicep-plan.chatmode.md

**Purpose:** Create structured, machine-readable infrastructure plans

**Use When:**

- Planning complex Azure deployments before coding
- Breaking down requirements into implementation tasks
- Creating reusable planning artifacts
- Collaborating with teams on infrastructure design

**Output Location:** `.bicep-planning-files/INFRA.{project-name}.md`

**Example:**

```markdown
Using bicep-plan mode, create a plan for deploying a hub-spoke network 
with 3 spokes, Azure Firewall, and Private DNS zones.
```

---

#### bicep-implement.chatmode.md

**Purpose:** Generate production-ready Bicep templates

### Azure Verified Modules (AVM) Modes

#### azure-verified-modules-bicep.chatmode.md

**Purpose:** Integrate Azure Verified Modules (Bicep) for enterprise-grade infrastructure

**Use When:**

- Building production infrastructure with Microsoft-verified patterns
- Need enterprise features (RBAC, monitoring, compliance)
- Want consistent, well-tested modules
- Following Microsoft Cloud Adoption Framework
- **Supplementing** the primary @bicep-implement agent with specific AVM guidance

**Example:**

```markdown
Using azure-verified-modules-bicep mode, create a Virtual Network using 
the AVM pattern with proper tagging and diagnostic settings.
```

---

#### azure-verified-modules-terraform.chatmode.md

**Purpose:** Integrate Azure Verified Modules (Terraform) for multi-cloud infrastructure

**Use When:**

- Managing multi-cloud environments
- Existing Terraform investment
- Need Terraform-specific patterns
- **Alternative to** the Bicep-based primary workflow

---

### SaaS Architecture Mode

#### azure-saas-architect.chatmode.md

**Purpose:** Multi-tenant SaaS architecture on Azure

**Use When:**

- Designing SaaS applications
- Implementing tenant isolation strategies
- Planning SaaS pricing models
- Handling SaaS data architecture
- **Specialized guidance** beyond the general @azure-principal-architect agent

**Example:**

```markdown
Using azure-saas-architect mode, design a tenant isolation strategy 
using Azure AD B2C and database-per-tenant pattern.
```

---

### Terraform Modes (Alternative IaC Workflow)

#### terraform-azure-planning.chatmode.md

**Purpose:** Create Terraform infrastructure plans for Azure

**Use When:**

- Planning Terraform-based Azure deployments (alternative to Bicep)
- Converting existing infrastructure to Terraform
- Creating reusable Terraform modules

---

#### terraform-azure-implement.chatmode.md

**Purpose:** Generate production-ready Terraform code for Azure

**Use When:**

- Implementing Terraform plans (alternative to Bicep)
- Creating Azure provider configurations
- Building Terraform modules

---

### Utility Modes

#### plan.chatmode.md

**Purpose:** General task planning and decomposition

**Use When:**

- Breaking down complex tasks
- Creating implementation roadmaps
- Planning multi-phase projects
- **Alternative to** @bicep-plan for non-infrastructure planning

---

#### planner.chatmode.md

**Purpose:** Strategic planning and roadmapping

**Use When:**

- Long-term technical planning
- Architecture evolution planning
- Technology adoption strategies

---

#### debug.chatmode.md

**Purpose:** Troubleshooting and diagnostics assistance

#### debug.chatmode.md

**Purpose:** Debug infrastructure deployment issues

**Use When:**

- Debugging Bicep/Terraform deployment failures
- Analyzing Azure resource errors
- Troubleshooting infrastructure issues
- Interpreting error messages
- **Supplementing** the primary agents with debugging expertise

**Example:**

```markdown
Using debug mode, analyze this Bicep deployment error: 
"The subscription is not registered to use namespace Microsoft.Network"
```

---

## Usage Guidelines

### Primary Workflow: Use Custom Agents First

For the main Azure infrastructure workflow, **always use Custom Agents** (invoked with `@agent-name`):

```text
@adr-generator Document the decision to use hub-spoke topology
@azure-principal-architect Assess the security implications of this design
@bicep-plan Create an implementation plan for the hub-spoke network
@bicep-implement Generate the Bicep templates from the plan
```

### When to Use Chat Modes

Use these **supplementary chat modes** for:

- ✅ Alternative IaC approaches (Terraform)
- ✅ Specialized scenarios (SaaS architecture, AVM deep-dives)
- ✅ Debugging and troubleshooting
- ✅ General planning (non-infrastructure)

### Activating Chat Modes

**In VS Code:**

1. Open GitHub Copilot Chat
2. Type `@workspace` to invoke workspace context (optional)
3. Reference the mode: "Using terraform-azure-planning mode, create a plan for..."

**Note:** Chat mode activation varies by Copilot interface. Custom Agents (`@agent-name`) have consistent invocation across all platforms.

### Mode Selection Decision Tree

```mermaid
graph TD
    A[What do you need?] --> B{Document Decision?}
    B -->|Yes| C[@adr-generator Agent]
    B -->|No| D{Need Architecture Guidance?}
    D -->|Yes| E{For SaaS?}
    E -->|Yes| F[azure-saas-architect mode]
    E -->|No| G[@azure-principal-architect Agent]
    
    D -->|No| H{Infrastructure as Code?}
    H -->|Bicep| I{Have Plan?}
    I -->|No| J[@bicep-plan Agent]
    I -->|Yes| K[@bicep-implement Agent]
    
    H -->|Terraform| L[terraform-azure-planning mode]
    L --> M[terraform-azure-implement mode]
    
    H -->|Troubleshooting| N[debug mode]
    
    style C fill:#4CAF50,color:#fff
    style G fill:#4CAF50,color:#fff
    style J fill:#4CAF50,color:#fff
    style K fill:#4CAF50,color:#fff
    style F fill:#FFC107
    style L fill:#FFC107
    style M fill:#FFC107
    style N fill:#FFC107
```

**Legend:**

- 🟢 **Green** = Custom Agents (Primary Workflow)
- 🟡 **Yellow** = Chat Modes (Supplementary Tools)
    style G fill:#e8f5e8
    style H fill:#ffe8f5

```

### Best Practices

**1. Follow the Workflow Sequence**

- Start with decisions (ADR Generator)
- Get architectural guidance (Principal Architect)
- Create a plan (Bicep Planning)
- Implement code (Bicep Implementation)

**2. Use Mode-Specific Outputs**

- ADR Generator → `/docs/adr/adr-NNNN-*.md`
- Bicep Planning → `.bicep-planning-files/INFRA.*.md`
- Bicep Implementation → `infrastructure/*.bicep`

**3. Combine Modes for Complex Tasks**

```

# Step 1: Architecture Assessment

Using azure-principal-architect mode, evaluate security requirements
for PCI-DSS compliant infrastructure.

# Step 2: Create Plan

Using bicep-plan mode, create a plan implementing the security
recommendations from the architecture assessment.

# Step 3: Implement

Using bicep-implement mode, generate Bicep templates from the plan.

```sql

**4. Mode-Specific Context**

- Each mode has access to workspace context
- Reference existing files: `.bicep-planning-files/`, `/docs/adr/`
- Modes understand Azure naming conventions and tagging standards

## Maintenance

### Adding New Modes

1. Create `{mode-name}.chatmode.md` in this directory
2. Follow the structure of existing modes
3. Document in this README
4. Add to workflow diagram if it's part of core workflow
5. Create ADR documenting the decision to add the mode

### Updating Existing Modes

1. Test changes with demo scenarios
2. Update relevant ADRs if behavior changes significantly
3. Update this README if usage changes
4. Notify team via pull request

## Examples

### Complete Workflow Example: Three-Tier Network

**Step 1: Document Decision**

```

@adr-generator Create an ADR for using hub-spoke network topology
vs. virtual WAN for a multi-region deployment.

```

**Step 2: Architecture Guidance**

```

Using azure-principal-architect mode, assess the hub-spoke design
against WAF pillars for a requirement of 99.95% SLA.

```yaml

**Step 3: Create Plan**

```

Using bicep-plan mode, create a detailed plan for implementing
a hub-spoke network with:

- Hub VNet in West Europe with Azure Firewall
- 3 spoke VNets (production, staging, development)
- VNet peering with proper route tables
- Private DNS zones for Azure PaaS services

```

**Step 4: Implement**

```

Using bicep-implement mode, implement the hub network from
.bicep-planning-files/INFRA.hub-spoke-network.md

```yaml

---

### Debugging Example

**Scenario:** Bicep deployment fails with cryptic error

```

Using debug mode, analyze this deployment error and suggest fixes:

Error: InvalidTemplateDeployment
Message: The template deployment failed because of policy violation.
Please see details for more information.
Details: Policy violation: "Deny-Subnet-Without-Nsg" -
Subnets must have an NSG attached.

```

**Debug Mode Response:**

```

Analysis:

- Azure Policy is blocking subnet creation without NSG
- Policy name: "Deny-Subnet-Without-Nsg"
- Common in enterprise environments

Solution:

1. Create NSG resource before subnet
2. Reference NSG in subnet properties
3. Or request policy exemption

Code Fix:
[Provides corrected Bicep with NSG dependency]

```

---

## Troubleshooting

### Common Issues

**Issue:** Mode not activating
**Solution:** Ensure you're using `@workspace` context and exact mode name

**Issue:** Mode doesn't have expected context
**Solution:** Reference specific files in your prompt

**Issue:** Multiple modes conflicting
**Solution:** Use one mode at a time, deactivate before switching

### Getting Help

- Check `/docs/adr/` for architectural decisions
- Review `.bicep-planning-files/` for planning examples
- See `resources/copilot-customizations/FOUR-MODE-WORKFLOW.md` for detailed workflow documentation
- Reference demo scripts in `scenarios/` for practical examples

## Resources

- [GitHub Copilot Custom Chat Modes Documentation](https://docs.github.com/en/copilot/customizing-copilot/custom-chat-modes)
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
- [Azure Verified Modules](https://aka.ms/avm)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [awesome-copilot Repository](https://github.com/github/awesome-copilot)

---

**Last Updated:** 2025-11-17  
**Maintained By:** GitHub Copilot IT Pro Repository Team
