# S02: Terraform for Azure with GitHub Copilot

---

## Meet Jordan Martinez

> **Role**: DevOps Engineer at CloudBridge Consulting  
> **Experience**: 5 years AWS with CloudFormation, first Azure engagement  
> **Today's Challenge**: Company standardizing on Terraform for multi-cloud, needs Azure expertise fast  
> **The Twist**: Client engagement starts in 3 weeks—no time for lengthy courses

_"I've automated hundreds of AWS deployments. But Azure's networking model feels different,
and Terraform state management has me nervous. I need to understand the WHY, not just copy HCL."_

**What Jordan will discover**: How to leverage existing IaC knowledge while learning Azure-specific
patterns through conversation, building near-production-ready Terraform in 30 minutes.

---

## Overview

This scenario demonstrates how GitHub Copilot serves as a **learning partner** for Terraform on
Azure, particularly for engineers transitioning from other IaC tools like AWS CloudFormation or
Azure ARM templates.

**Duration**: 30 minutes  
**Target Audience**: DevOps Engineers, Cloud Architects, AWS/GCP engineers moving to Azure  
**Difficulty**: Intermediate  
**Prerequisites**: VS Code with GitHub Copilot Chat (Azure subscription optional for deployment)

## Learning Objectives

By the end of this demo, participants will understand:

1. **What Terraform is** and how HCL compares to CloudFormation/ARM
2. **Provider configuration** for Azure with authentication options
3. **State management** concepts and remote backend setup
4. **Module design** for reusable infrastructure components
5. **Network security** with NSGs and private endpoints
6. **Environment management** with workspaces and variable files
7. **Testing patterns** with Terratest and security scanning

## The Challenge: Multi-Cloud IaC Adoption

| Problem                         | Impact                      | Business Cost        |
| ------------------------------- | --------------------------- | -------------------- |
| **Different tools per cloud**   | Team fragmentation          | Siloed expertise     |
| **CloudFormation-only skills**  | Can't do Azure/GCP          | Lost opportunities   |
| **HCL learning curve**          | Slow onboarding             | Delayed projects     |
| **State management complexity** | Corruption, conflicts       | Production incidents |
| **Security gaps**               | Public endpoints, weak NSGs | Compliance failures  |

## The Solution: Conversation-Based Learning

Instead of generating Terraform templates blindly, we use Copilot to:

1. **Map existing knowledge** (CloudFormation → Terraform concepts)
2. **Understand state management** (why it matters, how to secure it)
3. **Learn module patterns** (not just syntax, but WHY)
4. **Build security-first** (private endpoints, NSGs explained)
5. **Master environment separation** (dev/staging/prod patterns)

## Scenario

**Architecture to Build**:

- Virtual Network with three subnets (web, app, data tiers)
- Network Security Groups with tier-to-tier rules
- App Service with private endpoint
- SQL Database with Azure AD authentication
- Remote state in Azure Storage

**Traditional Approach**: 8-16 hours of Terraform courses + trial-and-error  
**Conversation Approach**: 30 minutes learning + building with understanding

## Demo Components

```
S02-terraform-baseline/
├── README.md                                # This file
├── DEMO-SCRIPT.md                           # 30-minute presenter guide
├── examples/
│   └── copilot-terraform-conversation.md    # ⭐ Full conversation transcript
├── prompts/
│   └── effective-prompts.md                 # Discovery questions guide
├── scenario/
│   ├── requirements.md                      # Business requirements
│   └── architecture.md                      # Target architecture
├── solution/                                # Reference Terraform modules
│   ├── README.md                            # Legacy automation explanation
│   ├── modules/
│   │   ├── networking/
│   │   ├── app-service/
│   │   └── database/
│   ├── environments/
│   │   └── dev/
│   └── example-code/
└── validation/
    ├── deploy.sh                            # Deployment script
    ├── test.sh                              # Terratest runner
    └── cleanup.sh                           # Resource cleanup
```

## Quick Start

### Option 1: Conversation-First (Recommended)

1. Open VS Code with GitHub Copilot Chat
2. Review `examples/copilot-terraform-conversation.md` for the approach
3. Start your own conversation:

   ```
   I'm a DevOps engineer with AWS CloudFormation experience. My company is adopting
   Terraform for multi-cloud, and I'm starting my first Azure project. Can you help
   me understand how Terraform works and how my CloudFormation knowledge transfers?
   ```

4. Follow the 5-phase conversation flow (see below)

### Option 2: Watch the Demo

Review `examples/copilot-terraform-conversation.md` to see a complete 30-minute conversation:

- CloudFormation to Terraform concept mapping
- Azure provider and authentication setup
- State management with Azure Storage backend
- Module design with security best practices
- Environment configuration patterns

### Option 3: Deploy the Reference Solution

```bash
# Navigate to dev environment
cd scenarios/S02-terraform-baseline/solution/environments/dev

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy (requires Azure CLI login)
terraform apply

# Clean up when done
terraform destroy
```

## Key Copilot Features Demonstrated

| Feature               | How It's Used                                    |
| --------------------- | ------------------------------------------------ |
| **Concept Mapping**   | Translates CloudFormation knowledge to Terraform |
| **State Explanation** | Explains remote backends, locking, security      |
| **Provider Setup**    | Shows authentication options (CLI, SP, OIDC)     |
| **Module Design**     | Teaches composition, outputs, dependencies       |
| **Security Patterns** | Private endpoints, NSGs, Azure AD auth           |
| **Testing Guidance**  | Terratest patterns, tfsec, Checkov               |

## 5-Phase Conversation Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 1: Understanding Terraform & HCL (5 min)                     │
│  "What is Terraform? How does it compare to CloudFormation?"        │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 2: Provider & Backend Setup (5 min)                          │
│  "How does Azure authentication work? What about state?"            │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 3: Building Network Module (7 min)                           │
│  "Let's build a VNet module - explain each part."                   │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 4: App & Data Modules (5 min)                                │
│  "Now App Service and SQL - what security settings matter?"         │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Phase 5: Module Composition & Best Practices (8 min)               │
│  "How do I wire modules together? Environments? Testing?"           │
└─────────────────────────────────────────────────────────────────────┘
```

## Success Metrics

### Time Efficiency

| Metric                    | Traditional | With Copilot | Improvement |
| ------------------------- | ----------- | ------------ | ----------- |
| Learning Terraform basics | 8-16 hours  | 30 min       | 95% faster  |
| First Azure deployment    | Days        | Same session | Immediate   |
| Module development        | 4-6 hours   | 30 min       | 90% faster  |
| Environment setup         | 2-3 hours   | 15 min       | 90% faster  |

### Knowledge Transfer

| Metric                 | Course-Based    | Conversation Approach   |
| ---------------------- | --------------- | ----------------------- |
| CloudFormation mapping | Manual research | Automatic comparisons   |
| Understanding depth    | Surface level   | Deep (WHY explained)    |
| Can troubleshoot       | Limited         | Yes                     |
| Can teach others       | No              | Yes                     |
| Retains for future     | Often forgotten | Applied learning sticks |

### Security Improvements

- ✅ Private endpoints for all PaaS services
- ✅ NSG deny-all baseline with explicit allows
- ✅ Azure AD authentication (no SQL passwords)
- ✅ TLS 1.2 minimum everywhere
- ✅ Remote state with locking
- ✅ Managed identities for service-to-service auth

## CloudFormation to Terraform Translation

| CloudFormation | Terraform                | Notes                      |
| -------------- | ------------------------ | -------------------------- |
| Template       | `.tf` files              | Multiple files recommended |
| `Resources:`   | `resource` blocks        | Same concept               |
| Parameters     | `variable` blocks        | Better validation          |
| Outputs        | `output` blocks          | Module composition         |
| Conditions     | `count`, `for_each`      | More flexible              |
| Mappings       | `locals` with `lookup()` | Computed values            |
| Nested Stacks  | Modules                  | True reusability           |
| Change Sets    | `terraform plan`         | Always shows changes       |
| Stack          | State file               | You manage storage         |
| `!Ref`         | Direct reference         | `resource.name.attribute`  |
| `!GetAtt`      | Same syntax              | `resource.name.attribute`  |

## Business Value & ROI

### For Engineers

- **Faster multi-cloud adoption** - Learn Terraform patterns once, apply everywhere
- **Transfer existing knowledge** - AWS/CloudFormation skills translate directly
- **Build understanding** - Not just templates, but WHY things work
- **Career growth** - Terraform is the industry standard for multi-cloud

### For Organizations

| Metric | Value |
|--------|-------|\n| Time reduction per project | 75-90% |
| Annual hours saved (team of 5) | 40+ hours |
| Learning curve | 30 min |
| Knowledge retention | Permanent |

**Additional Benefits**: Multi-cloud capability, reduced errors, faster onboarding

## Use Cases

### 1. CloudFormation → Terraform Migration

**Need**: AWS engineer learning Terraform for multi-cloud  
**Approach**: Map existing knowledge → Build with comparisons  
**Outcome**: Productive in hours, not weeks

### 2. First Azure Terraform Project

**Need**: Build near-production-ready Azure infrastructure  
**Approach**: Learn modules, state, security through conversation  
**Outcome**: Secure infrastructure + deep understanding

### 3. Team Standardization

**Need**: Consistent Terraform patterns across cloud teams  
**Approach**: Learn module design, testing, environment patterns  
**Outcome**: Reusable modules, shared practices

### 4. Security Hardening

**Need**: Migrate from public endpoints to private  
**Approach**: Learn private endpoints, NSGs, managed identities  
**Outcome**: Secure-by-default infrastructure

## Troubleshooting

### Copilot Gives Generic Terraform Advice

**Solution**: Provide AWS context:

```
I'm very familiar with AWS and CloudFormation. Can you explain [concept] by
comparing it to what I already know?
```

### State Locking Errors

**Symptom**: "Error acquiring the state lock"

**Solution**: Ask Copilot:

```
I'm getting a state lock error in Terraform. What causes this and how do I fix it?
```

### Provider Authentication Fails

**Symptom**: "Error building AzureRM Client"

**Solution**: Ask Copilot:

```
Terraform can't authenticate to Azure. I'm using Azure CLI locally. What should
I check?
```

### Module Reference Errors

**Symptom**: "Reference to undeclared resource"

**Solution**: Ask Copilot:

```
I'm getting a reference error when calling this module. Can you help me understand
how module outputs work?
```

---

📖 **For general issues** (Dev Container, Azure auth, Copilot problems), see the [Troubleshooting Guide](../../docs/troubleshooting.md).

## Next Steps

### For Presenters

1. Review `DEMO-SCRIPT.md` for the 30-minute walkthrough
2. Practice the conversation flow with Copilot
3. Prepare your own infrastructure example
4. Have backup: `examples/copilot-terraform-conversation.md`

### For Learners

1. Start with `examples/copilot-terraform-conversation.md`
2. Try building your own VNet module through conversation
3. Deploy `solution/` templates to see the output
4. Experiment with environment configurations

### For Teams

1. Establish Terraform naming conventions
2. Create shared module repository
3. Set up CI/CD with GitHub Actions
4. Implement Terratest for validation
5. Add tfsec/Checkov to pipelines

## Key Takeaways

### For DevOps Engineers

- **Terraform is multi-cloud HCL** - Same patterns for Azure, AWS, GCP
- **State is critical** - Remote backend with locking is essential
- **Modules are functions** - Input variables, resource logic, output values
- **Security by default** - Private endpoints, NSGs, managed identities

### For Leaders

- **Faster multi-cloud adoption** - Engineers productive in hours
- **Reduced risk** - Security patterns built into learning
- **Team flexibility** - Same skills work across cloud providers
- **Industry standard** - Terraform skills are highly portable

### For Partners

- **Universal applicability** - Every multi-cloud customer needs this
- **Quick wins** - Visible results in 30 minutes
- **Skills enablement** - Customers become self-sufficient
- **Differentiation** - Conversation approach is unique

---

## Related Resources

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Verified Modules](https://registry.terraform.io/namespaces/Azure)
- [Terratest Documentation](https://terratest.gruntwork.io/)
- [S01: Bicep Baseline](../S01-bicep-baseline/)
- [S03: Five-Agent Workflow](../S03-five-agent-workflow/)

---

_This scenario demonstrates using GitHub Copilot as a learning partner for Terraform on Azure.
The focus is on understanding, not just code generation._
