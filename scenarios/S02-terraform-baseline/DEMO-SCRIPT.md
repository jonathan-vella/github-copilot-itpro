# Demo 3: Terraform Infrastructure - Demo Script

**Duration**: 30 minutes  
**Presenter Prep Time**: 10 minutes  
**Audience**: Infrastructure engineers, DevOps teams, cloud architects

---

## Pre-Demo Setup (10 minutes before presentation)

### Environment Check

```powershell
# Verify tools installed
terraform version      # Should be v1.5.0+
az version            # Azure CLI
code --version        # VS Code with Copilot

# Login to Azure
az login
az account set --subscription "<your-subscription-id>"

# Open VS Code in demo directory
code scenarios/S02-terraform-baseline
```

### Backup Plan

- Have completed Terraform code ready in `with-copilot/example-code/`
- Pre-deploy infrastructure if live deployment might fail
- Have screenshots of successful `terraform apply` output
- Prepare HTML validation report if time is limited

---

## Demo Flow (30 minutes)

### Phase 1: Scene Setting (5 minutes)

#### The Challenge

**Say**: "Imagine you're an infrastructure engineer at TechCorp Solutions, a SaaS provider with 15 development teams. Each team deploys infrastructure to Azure manually, taking 3-5 days per environment with a 40% error rate."

**Show**: `scenario/requirements.md` - Scroll through the pain points

**Pain Points to Emphasize**:

- ❌ 60 hours to build production-ready Terraform code manually
- ❌ Inconsistent patterns across teams
- ❌ Security misconfigurations discovered in audits
- ❌ High error rate due to syntax mistakes
- ❌ Poor code reusability

**Say**: "Your goal is to create standardized Terraform modules for a 3-tier web application that can deploy to dev, staging, and prod environments in under 1 hour."

#### Manual Approach

**Say**: "Let's look at what manually-written Terraform typically looks like..."

**Show**: `manual-approach/example-code/main.tf`

**Point Out**:

- Basic resource definitions
- Hard-coded values
- Minimal variable validation
- No outputs or documentation
- Missing security configurations
- No module structure

**Say**: "This took about 60 hours to create, and it's still missing critical features like private endpoints, proper tagging, and automated testing."

---

### Phase 2: Copilot-Assisted Development (15 minutes)

#### Step 1: Network Module (4 minutes)

**Say**: "Let's use GitHub Copilot to build a production-ready networking module. Watch how it suggests complete configurations based on best practices."

**Live Coding**:

1. Create `with-copilot/example-code/modules/networking/main.tf`
2. Type the prompt as a comment:

```hcl
# Create an Azure Virtual Network module with:
# - VNet with 3 subnets: web (10.0.1.0/24), app (10.0.2.0/24), data (10.0.3.0/24)
# - Network Security Groups for each subnet
# - NSG rules: web allows 443, app allows 8080 from web subnet, data allows 1433 from app subnet
# - All deny rules at priority 4096
# - Use variables for resource names, location, and tags
```

**Accept Copilot suggestions** - Point out:

- ✅ Complete resource blocks
- ✅ Proper subnet CIDR notation
- ✅ Security group associations
- ✅ Deny-by-default rules

1. Create `variables.tf` - Type comment:

```hcl
# Define variables for networking module:
# - resource_group_name (required)
# - location (default: swedencentral)
# - vnet_name (required)
# - address_space (default: ["10.0.0.0/16"])
# - tags (map of strings)
# Add validation for location (must be valid Azure region)
```

**Accept suggestions** - Highlight validation blocks

1. Create `outputs.tf` - Type comment:

```hcl
# Export outputs:
# - vnet_id
# - subnet_ids (map of subnet names to IDs)
# - nsg_ids (map of NSG names to IDs)
```

**Say**: "Notice how Copilot generated an entire module with proper variable validation and comprehensive outputs in about 3 minutes. Manually, this would take 4-6 hours."

#### Step 2: App Service Module (4 minutes)

**Live Coding**:

1. Create `modules/app-service/main.tf` with prompt:

```hcl
# Create Azure App Service module with:
# - App Service Plan (P1v3 SKU for zone redundancy)
# - Linux App Service with:
#   - Managed Identity enabled
#   - HTTPS only
#   - TLS 1.2 minimum
#   - Private endpoint connection
#   - App settings from variables
# - Private DNS zone for privatelink.azurewebsites.net
# - Private endpoint in app subnet
```

**Accept suggestions** - Point out:

- ✅ Zone-redundant SKU
- ✅ Security configurations
- ✅ Managed Identity
- ✅ Private endpoint setup

**Say**: "Copilot knows Azure best practices - private endpoints, zone redundancy, managed identities. This saves hours of research and testing."

#### Step 3: Database Module (3 minutes)

**Prompt**:

```hcl
# Create Azure SQL Database module with:
# - SQL Server with Azure AD admin
# - SQL Database (S0 tier for dev, S3 for prod)
# - Private endpoint in data subnet
# - Advanced Threat Protection enabled
# - Transparent Data Encryption enabled
# - Geo-redundant backup
# - Firewall rules: deny all public access
```

**Say**: "Security by default. Copilot suggests private endpoints, threat protection, and encryption automatically."

#### Step 4: Root Module (4 minutes)

**Live Coding**:

1. Create `environments/dev/main.tf`:

```hcl
# Root module that orchestrates all infrastructure:
# - Call networking module
# - Call app-service module (depends on networking)
# - Call database module (depends on networking)
# - Use terraform.tfvars for environment-specific values
# - Configure Azure provider with subscription ID
# - Set up Azure Storage backend for remote state
```

1. Create `terraform.tfvars`:

```hcl
# Development environment variables
environment = "dev"
location = "swedencentral"
resource_group_name = "rg-techcorp-dev"
```

**Say**: "Copilot helps structure multi-environment deployments. We can copy this to staging/ and prod/ with different variable values."

---

### Phase 3: Validation & Testing (8 minutes)

#### Terraform Commands

**Say**: "Now let's validate and deploy the infrastructure..."

```bash
# Initialize Terraform
cd environments/dev
terraform init

# Validate syntax
terraform validate

# Preview changes
terraform plan

# Show plan output
# Point out: 15-20 resources to be created
```

**Metrics to Call Out**:

- ⏱️ **Time elapsed**: ~6 minutes of development
- 📝 **Lines of code**: ~300-400 lines generated
- 🔒 **Security features**: 8+ security configurations automatic
- ♻️ **Reusability**: Modules work for staging/prod with variable changes

**Say**: "In a live environment, we'd run `terraform apply`, but let's look at what would be deployed..."

#### Show Architecture Diagram

**Display**: `scenario/architecture.md` - Mermaid diagram

**Walk Through**:

- 3-tier separation
- Private endpoints (no public access)
- NSG rules between tiers
- Managed Identity authentication
- Remote state management

---

### Phase 4: Comparison & ROI (2 minutes)

#### Side-by-Side Comparison

**Show Table**:

| Aspect | Manual (60 hours) | With Copilot (6 hours) |
|--------|-------------------|------------------------|
| **Module Structure** | ❌ Monolithic | ✅ Modular, reusable |
| **Variable Validation** | ❌ Basic | ✅ Comprehensive |
| **Security** | ❌ Public endpoints | ✅ Private, encrypted |
| **Outputs** | ❌ Minimal | ✅ Complete with descriptions |
| **Testing** | ❌ None | ✅ Terratest included |
| **Documentation** | ❌ Manual | ✅ Auto-generated |

#### ROI Calculation

**Say**: "Let's talk ROI..."

**Show**:

- **Time saved**: 54 hours per project
- **Cost savings**: $8,100 per project at $150/hour
- **Annual value**: 6-10 projects = **$48,600-$81,000**
- **Quality improvement**: 95% reduction in syntax errors
- **Security posture**: 8+ hardening features automatic

**Additional Benefits**:

- ✅ Faster onboarding for new team members
- ✅ Consistent code quality across teams
- ✅ Reusable modules accelerate future projects
- ✅ Learn Terraform best practices while coding

---

## Wrap-Up & Q&A

### Key Takeaways

**Summarize**:

1. 📉 **90% time reduction** - 60 hours → 6 hours
2. 🔒 **Security by default** - Copilot suggests best practices
3. ♻️ **Reusable modules** - Write once, use for all environments
4. 📚 **Learn while coding** - Copilot teaches Terraform patterns
5. 💰 **Clear ROI** - $48K-$81K annual value per engineer

### Common Questions

**Q: Does Copilot work with other Terraform providers (AWS, GCP)?**  
A: Yes! Copilot is trained on multi-cloud providers. It works with AWS, GCP, Kubernetes, and 1,000+ providers.

**Q: What about Terraform state management?**  
A: Copilot can generate backend configurations for Azure Storage, S3, Terraform Cloud, etc.

**Q: Does it generate Terratest code?**  
A: Yes! Copilot can create Go-based Terratest for infrastructure validation.

**Q: How does it compare to Bicep (Demo 01)?**  
A: Bicep is Azure-native and simpler. Terraform is multi-cloud and has a richer ecosystem. Choose based on your multi-cloud strategy.

**Q: Can it refactor existing Terraform code?**  
A: Absolutely. Copilot can suggest module extraction, variable improvements, and security hardening for existing code.

### Next Steps

**For Attendees**:

1. Try the demo yourself: `scenarios/S02-terraform-baseline/`
2. Review prompts: `prompts/effective-prompts.md`
3. Explore other demos: Bicep (S01), Five Agent Workflow (S03), Troubleshooting (S06)
4. Access partner toolkit: Sales decks, ROI calculators, customer pitch templates

**For Partners**:

- **Customer pitch deck** available in `partner-toolkit/`
- **ROI calculator** customizable for your engagements
- **Demo delivery guide** with timing and backup plans
- **Success stories** in `case-studies/`

---

## Troubleshooting Guide

### If Copilot Suggestions Don't Appear

1. Check Copilot status in VS Code (bottom right)
2. Reload window: `Ctrl+Shift+P` → "Reload Window"
3. Use more specific comments as prompts
4. Try inline completion: Start typing resource names

### If Terraform Plan Fails

- **Subscription access**: Verify `az account show`
- **Provider registration**: Run `az provider register --namespace Microsoft.Network`
- **Name conflicts**: Ensure unique resource names (use random suffix)
- **Quota limits**: Check subscription quotas for SKUs

### If Time Runs Short

- Skip live coding, show completed code in `with-copilot/example-code/`
- Show pre-generated `terraform plan` output
- Focus on ROI metrics and comparison table
- Use backup HTML report in `validation/`

---

## Post-Demo Cleanup

```bash
# Destroy resources (if deployed)
cd environments/dev
terraform destroy --auto-approve

# Or use cleanup script
../../validation/cleanup.sh
```

**Estimated cleanup time**: 5 minutes

---

## Files Needed for Demo

- ✅ `scenario/requirements.md` - Customer scenario
- ✅ `scenario/architecture.md` - Architecture diagrams
- ✅ `manual-approach/example-code/` - Manual Terraform code
- ✅ `with-copilot/example-code/` - Copilot-generated code (backup)
- ✅ `prompts/effective-prompts.md` - Prompt library
- ✅ `validation/deploy.sh` - Deployment automation

**Presenter Checklist**:

- [ ] VS Code with Copilot active
- [ ] Azure CLI logged in
- [ ] Terraform CLI installed
- [ ] Demo repository cloned
- [ ] Backup code ready in `with-copilot/`
- [ ] Timer set (30 minutes)
