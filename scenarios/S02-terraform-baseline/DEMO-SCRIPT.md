# S02: Terraform for Azure - Demo Script

**Duration**: 30 minutes  
**Setup Required**: VS Code with GitHub Copilot Chat, Azure CLI (optional)  
**Backup**: `examples/copilot-terraform-conversation.md`

---

## Pre-Demo Checklist

- [ ] VS Code open with empty workspace
- [ ] GitHub Copilot Chat panel visible
- [ ] Azure CLI authenticated (optional)
- [ ] `examples/copilot-terraform-conversation.md` ready as backup
- [ ] Terraform CLI installed (`terraform version`)

---

## Phase 0: Scene Setting (2 minutes)

### The Story

> *"Let me introduce Jordan Martinez. Jordan is a DevOps Engineer at CloudBridge Consulting
> with 5 years of AWS experience. Jordan knows CloudFormation inside and out - nested stacks,
> change sets, cross-stack references - the whole ecosystem.*
>
> *Now CloudBridge is taking on Azure clients and wants to standardize on Terraform for
> multi-cloud capability. Jordan's been assigned the first Azure engagement and needs to
> get up to speed fast.*
>
> *How would Jordan traditionally learn Terraform?*
> - *Online courses (8-16 hours of video)*
> - *Documentation deep dives (scattered, inconsistent)*
> - *Trial and error with real deployments (risky, slow)*
> - *Stack Overflow when things break (reactive)*
>
> *Let's see how Copilot transforms this learning experience."*

### Key Point

> *"Jordan isn't starting from zero - there's deep IaC knowledge from CloudFormation.
> The goal is to **transfer that knowledge** to Terraform efficiently, not start over."*

---

## Phase 1: Understanding Terraform & HCL (5 minutes)

### Teaching Moment

> *"Jordan starts by mapping existing CloudFormation knowledge to Terraform concepts.
> This isn't about syntax - it's about understanding how the mental models align."*

### Live Demo

Open Copilot Chat and type:

```
I've been using AWS CloudFormation for years, but my company is adopting Terraform
for multi-cloud. I've never used Terraform before. Can you explain what it is and
how it differs from CloudFormation?
```

**Copilot explains**: Terraform is HashiCorp's multi-cloud IaC tool, uses HCL, etc.

### Follow-up

```
What does HCL look like compared to CloudFormation YAML? Can you show me a simple
example of the same resource in both?
```

**Teaching Moment**:
> *"Notice Jordan isn't asking 'how do I write Terraform.' Jordan is asking 'how does
> what I know translate to what I need to learn.' This accelerates everything."*

### State Management Question

```
You mentioned I have to manage state myself. In CloudFormation, AWS handles that
automatically. This sounds risky - what could go wrong?
```

**Key Point**:
> *"State management is THE big difference from CloudFormation. Copilot explains the
> risks and the solutions - remote backends with locking. Jordan learns the 'why'
> before the 'how'."*

---

## Phase 2: Provider & Backend Setup (5 minutes)

### Teaching Moment

> *"Before writing resources, Jordan needs to understand how Terraform talks to Azure.
> This is like configuring AWS credentials for CloudFormation."*

### Live Demo

```
How do I set up Terraform to talk to Azure? In CloudFormation, AWS credentials are
automatic. What are my options for Azure authentication?
```

**Copilot shows**: Azure CLI, Service Principal, Managed Identity, OIDC options

### Follow-up

```
Can you show me how to set up Azure Storage as a remote backend? I want state
locking like DynamoDB provides for AWS Terraform.
```

**Key Teaching Point**:
> *"Azure Storage provides automatic locking via blob leases. Jordan learns this is
> actually simpler than AWS where you need both S3 and DynamoDB."*

### Workflow Question

```
What's the Terraform workflow? Is it similar to 'aws cloudformation deploy'?
```

**Show the mapping**:
| CloudFormation | Terraform |
|----------------|-----------|
| `validate-template` | `terraform validate` |
| `create-change-set` | `terraform plan` |
| `execute-change-set` | `terraform apply` |
| `delete-stack` | `terraform destroy` |

---

## Phase 3: Building Network Module (7 minutes)

### Teaching Moment

> *"Now Jordan builds the first module. But instead of asking for code, Jordan asks
> Copilot to **teach** while building - explaining each part."*

### Live Demo

Create a new file `main.tf`:

```
I need to create a Virtual Network with three subnets for a three-tier app - web,
app, and data. In CloudFormation, I'd use a nested stack. What's the Terraform
equivalent and can you explain the structure?
```

**Copilot explains modules**: main.tf, variables.tf, outputs.tf structure

### Building Together

```
Let's build the VNet resource first. Can you show me and explain how it maps to
what I'd do in CloudFormation?
```

**Walk through the code**:
> *"See how `resource "azurerm_virtual_network" "main"` maps to CloudFormation's
> `Resources: MyVPC: Type: AWS::EC2::VPC`? Same concept, cleaner syntax."*

### NSG Addition

```
Now I need Network Security Groups. In AWS, I'd use Security Groups. How do NSGs
differ and what's the Terraform code?
```

**Key Security Point**:
> *"Notice Copilot suggests a deny-all rule at priority 4096. This is Azure best
> practice - explicit deny baseline. Jordan learns security patterns while building."*

---

## Phase 4: App & Data Modules (5 minutes)

### Teaching Moment

> *"Jordan now builds the App Service and Database modules. The focus is on security
> settings that Copilot explains while generating."*

### Live Demo

```
Now I need an App Service. In AWS, I'd use Elastic Beanstalk or ECS. What's the
equivalent in Azure and what security settings should I configure?
```

**Copilot shows**: App Service Plan, Linux Web App, security settings

**Highlight security**:
> *"See these settings? `https_only = true`, `public_network_access_enabled = false`,
> `identity { type = "SystemAssigned" }`. These aren't random - each has a security
> purpose that Jordan now understands."*

### Database Module

```
For the database, I need Azure SQL. What's the most secure configuration? In AWS,
I'd use RDS with IAM auth.
```

**Key Point**:
> *"Azure AD authentication only - no SQL passwords. This is like IAM database auth
> in AWS. Jordan learns the Azure equivalent of patterns already known."*

---

## Phase 5: Module Composition & Best Practices (8 minutes)

### Teaching Moment

> *"Jordan has three modules. Now: how to wire them together and manage environments.
> This is like CloudFormation nested stacks with outputs/imports."*

### Live Demo

```
I have networking, app-service, and database modules. How do I wire them together?
In CloudFormation, I'd use nested stacks with exports and imports.
```

**Copilot shows root module pattern**:
```hcl
module "networking" { ... }
module "app_service" {
  subnet_id = module.networking.subnet_ids["app"]
}
```

**Teaching Point**:
> *"No exports/imports needed! Module outputs are directly referenced. This is cleaner
> than CloudFormation's cross-stack references."*

### Environment Management

```
My team needs dev, staging, and prod environments. In CloudFormation, I'd use
parameter files or stack sets. What's the Terraform pattern?
```

**Show environment structure**:
```
environments/
├── dev/
│   ├── main.tf
│   └── terraform.tfvars
├── staging/
└── prod/
```

### Testing Discussion

```
How do I test Terraform code? In CloudFormation, we'd use TaskCat or cfn-lint.
```

**Copilot explains**: Terratest for integration tests, tfsec/Checkov for security

---

## Phase 6: Wrap-Up (3 minutes)

### Demo Deployment (Optional)

If time permits:

```bash
# Initialize
cd environments/dev
terraform init

# Validate
terraform validate

# Plan (show output)
terraform plan
```

### Value Recap

> *"Let's review what Jordan accomplished in 30 minutes:*
>
> **Traditional Learning** (8-16 hours):
> - Watch Terraform courses: 8+ hours
> - Read documentation: 4+ hours
> - Trial and error: 4+ hours
> - Still no CloudFormation mapping
>
> **Conversation Approach** (30 minutes):
> - Terraform vs CloudFormation mapping: 5 min
> - Provider and state management: 5 min
> - Network module with security: 7 min
> - App and database modules: 5 min
> - Composition and environments: 8 min
>
> **The difference**: Jordan can now troubleshoot Terraform issues, explain choices
> to teammates, and apply patterns to AWS Terraform too. The knowledge transfers both ways."*

### Key Metrics

| Metric | Traditional | Conversation | Improvement |
|--------|-------------|--------------|-------------|
| Learning time | 8-16 hours | 30 min | 95% faster |
| First deployment | Days | Same session | Immediate |
| CloudFormation mapping | Manual research | Automatic | Built-in |
| Security patterns | Often missed | Explained | Comprehensive |
| Can troubleshoot | Limited | Yes | ✅ |

### Call to Action

> *"Jordan's journey shows how Copilot accelerates multi-cloud adoption. The value isn't
> just faster code generation - it's **knowledge transfer** that makes engineers
> productive across platforms.*
>
> *Next: Try this yourself. Start with your existing IaC knowledge and let Copilot help
> you translate it to new tools and platforms."*

---

## Backup Scenarios

### If Copilot Gives Generic Responses

**Reset with context**:
```
I have 5 years of AWS experience with CloudFormation - nested stacks, change sets,
cross-stack references. I'm learning Terraform for Azure. Can you explain [concept]
by comparing it to CloudFormation patterns I already know?
```

### If Participant Asks About Bicep

> *"Great question! Bicep is Azure-native and simpler for Azure-only deployments.
> Terraform is the choice when you need multi-cloud or have existing Terraform investment.
> We cover Bicep in S01."*

### If Participant Asks About Terragrunt

> *"Terragrunt is a wrapper that adds features like automatic backend configuration
> and module dependencies. It's great for large-scale Terraform, but let's master
> vanilla Terraform first."*

### If State Questions Come Up

```
Can you explain what happens if two people run terraform apply at the same time?
How does state locking prevent problems?
```

---

## Post-Demo Resources

### For Participants
- `examples/copilot-terraform-conversation.md` - Full conversation transcript
- `solution/` - Reference Terraform modules
- `validation/` - Deployment and test scripts

### For Presenters
- `prompts/effective-prompts.md` - Discovery questions for each phase
- `scenario/requirements.md` - Business requirements
- `scenario/architecture.md` - Target architecture

### Extended Learning
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [S01: Bicep Baseline](../S01-bicep-baseline/) - Azure-native alternative
- [S03: Five-Agent Workflow](../S03-five-agent-workflow/) - Enterprise patterns

---

*This demo script guides presenters through a 30-minute conversation-based learning experience
for Terraform on Azure. Focus on knowledge transfer, not just code generation.*
