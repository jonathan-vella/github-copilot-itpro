# Demo 3: Infrastructure as Code with Terraform & GitHub Copilot

## Overview

This demo showcases how GitHub Copilot accelerates Terraform development for Azure infrastructure. Building a production-ready, multi-environment infrastructure typically takes 60 hours manually. With Copilot, complete the same project in 6 hours - a **90% time reduction**.

**Duration**: 30 minutes  
**Target Audience**: Infrastructure engineers, DevOps teams, cloud architects, SI partners delivering Terraform projects  
**Difficulty**: Intermediate

---

## Business Value

### The Challenge

Organizations adopting Infrastructure as Code (IaC) with Terraform face:

- Steep learning curve for HCL syntax and Terraform patterns
- Time-consuming module development and testing
- Inconsistent code quality across team members
- Complex state management and backend configuration
- Security misconfigurations in infrastructure code
- Poor documentation and lack of code reusability

**Traditional Approach Problems:**

- Manual HCL coding with frequent syntax errors
- Copy-paste from outdated examples online
- Inconsistent naming and tagging conventions
- Missing variable validation and outputs
- No automated testing (Terratest)
- Security best practices often overlooked
- Time-consuming troubleshooting of plan/apply errors

### The Copilot Solution

GitHub Copilot accelerates every phase of Terraform development:

1. **Code Generation**: Generate HCL code with proper syntax and formatting
2. **Module Creation**: Build reusable modules following DRY principles
3. **Variable Management**: Create comprehensive variables with validation
4. **Security Hardening**: Suggest private endpoints, RBAC, encryption
5. **Testing**: Generate Terratest unit tests for infrastructure validation
6. **Documentation**: Auto-generate README files and architecture diagrams

### Metrics

| Metric | Manual Approach | With Copilot | Improvement |
|--------|----------------|--------------|-------------|
| **Module Development** | 20 hours | 2 hours | 90% reduction |
| **Resource Configuration** | 16 hours | 1.5 hours | 91% reduction |
| **Variable & Output Setup** | 8 hours | 1 hour | 88% reduction |
| **Testing Code** | 10 hours | 1 hour | 90% reduction |
| **Security Hardening** | 4 hours | 30 min | 88% reduction |
| **Documentation** | 2 hours | 10 min | 92% reduction |
| **TOTAL PROJECT** | **60 hours** | **6 hours** | **90% reduction** |

### ROI Calculation

**Project Savings (3-tier infrastructure):**

- Hours saved: 54 hours
- Cost at $150/hour: **$8,100 per project**
- Typical infrastructure projects per year: 6-10
- **Annual value: $48,600-$81,000**

**For Enterprise Scale (20+ projects/year):**

- **Annual value: $160,000+**

**Additional Benefits:**

- 95% reduction in syntax errors
- Consistent code quality across team
- Faster onboarding for new team members (learn by doing)
- Better security posture through automated suggestions
- Reusable modules accelerate future projects

---

## Prerequisites

### Required Access

- Azure subscription with Contributor access
- Permissions to create Service Principals (for backend state)
- GitHub account (for Actions CI/CD, optional)

### Required Tools

- VS Code with GitHub Copilot extension
- Terraform CLI (v1.5.0 or newer)
- Azure CLI (for authentication)
- (Optional) Go (for Terratest)
- (Optional) Checkov or tfsec (security scanning)

### Knowledge Requirements

- Basic Azure concepts (Resource Groups, VNets, App Service)
- Basic understanding of Infrastructure as Code
- Familiarity with command-line tools
- (Helpful) Basic HCL syntax knowledge

---

## Scenario Details

### Customer Profile

**Company**: TechCorp Solutions  
**Industry**: SaaS Provider  
**Challenge**: Standardize infrastructure deployment across 15 development teams

### Current State

- **15 development teams** deploying to Azure manually
- **Inconsistent infrastructure** patterns across teams
- **3-5 days** to provision new environments
- **High error rate** (40% of deployments need remediation)
- **No environment parity** between dev/staging/prod
- **Security issues** discovered in audits (public endpoints, weak NSGs)

### Desired State

- **Standardized Terraform modules** for all teams
- **1-hour deployment** for new environments
- **Multi-environment support** (dev, staging, prod)
- **Security by default** (private endpoints, NSGs, encryption)
- **Automated testing** with Terratest
- **GitOps workflow** with GitHub Actions
- **95% first-time success rate** for deployments

### Infrastructure Requirements

**3-Tier Web Application:**

1. **Network Tier**:
   - Virtual Network with 3 subnets (web, app, data)
   - Network Security Groups with least-privilege rules
   - Application Gateway with WAF

2. **Application Tier**:
   - Azure App Service (Linux) with zone redundancy
   - App Service Plan (P1v3 SKU)
   - Managed Identity for authentication
   - Private endpoint connections

3. **Data Tier**:
   - Azure SQL Database with private endpoint
   - Geo-redundant backup
   - Advanced Threat Protection
   - Key Vault for secrets management

4. **Cross-Cutting Concerns**:
   - Remote state in Azure Storage
   - Environment-specific variables (dev/staging/prod)
   - Resource tagging (CostCenter, Owner, Environment)
   - RBAC assignments

---

## What You'll Build

### Terraform Module Structure

```
terraform/
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── app-service/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── database/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   └── prod/
├── tests/
│   └── terraform_test.go
└── docs/
    └── architecture.md
```

### Key Features

✅ **Modular Design** - Reusable components  
✅ **Environment Separation** - Dev/Staging/Prod isolation  
✅ **Remote State** - Azure Storage backend with locking  
✅ **Variable Validation** - Input constraints and defaults  
✅ **Comprehensive Outputs** - Resource IDs, endpoints, connection strings  
✅ **Security Hardening** - Private endpoints, NSGs, encryption  
✅ **Automated Testing** - Terratest integration  
✅ **CI/CD Ready** - GitHub Actions workflow

---

## Success Criteria

### Technical Success

- [ ] Infrastructure deploys successfully to all 3 environments
- [ ] All resources use private endpoints (no public access)
- [ ] Remote state managed in Azure Storage
- [ ] Terratest validates infrastructure
- [ ] Zero security findings from Checkov/tfsec
- [ ] Application accessible via Application Gateway

### Business Success

- [ ] Project completed in 6-8 hours (vs. 60 hours manual)
- [ ] 90%+ time savings demonstrated
- [ ] Modules reusable across teams
- [ ] Team trained on Terraform + Copilot workflow
- [ ] Documentation auto-generated

---

## Key Talking Points

### Why This Matters

- **Multi-cloud strategy**: Terraform is vendor-neutral (Azure, AWS, GCP)
- **Industry standard**: Most enterprises adopt Terraform for IaC
- **Skills gap**: HCL expertise is scarce and expensive
- **Consistency is critical**: Infrastructure drift = security risk

### Copilot Value Props

- **Knows Terraform patterns**: Trained on best practices and provider docs
- **Multi-provider support**: Works with Azure, AWS, GCP, Kubernetes
- **Module scaffolding**: Generates complete module structure instantly
- **Security awareness**: Suggests private endpoints, encryption, RBAC
- **Testing automation**: Creates Terratest code alongside infrastructure
- **Documentation generation**: README files, variable descriptions, examples

### Differentiation from Demo 01 (Bicep)

- **Multi-cloud**: Terraform works beyond Azure
- **Broader audience**: DevOps teams often standardize on Terraform
- **Ecosystem**: Rich module registry and tooling (Terragrunt, Atlantis)
- **Market share**: Larger install base than Bicep in enterprise
- **SI partner preference**: Most SI partners deliver Terraform projects

---

## Files in This Demo

```
scenarios/S02-terraform-baseline/
├── README.md                        # This file
├── DEMO-SCRIPT.md                   # Step-by-step walkthrough
├── scenario/
│   ├── requirements.md              # Detailed customer scenario
│   └── architecture.md              # Target architecture diagrams
├── solution/
│   ├── modules/                     # Terraform modules
│   └── environments/                # Environment configurations
├── prompts/
│   └── effective-prompts.md         # Curated Copilot prompts
└── validation/
    ├── deploy.sh                    # Deployment script
    ├── test.sh                      # Terratest runner
    └── cleanup.sh                   # Resource cleanup
```

---

## Learning Outcomes

By completing this demo, you will learn:

1. **Terraform Basics**: HCL syntax, providers, resources, modules
2. **Copilot for IaC**: Effective prompting for infrastructure code
3. **Module Design**: Creating reusable, testable components
4. **Security Hardening**: Private endpoints, NSGs, RBAC, encryption
5. **State Management**: Remote backends, locking, workspaces
6. **Testing**: Terratest for infrastructure validation
7. **CI/CD**: GitHub Actions for automated deployments

---

## Next Steps

After completing this demo:

1. **Extend Modules**: Add more infrastructure components (AKS, Redis, CDN)
2. **Multi-Region**: Deploy to multiple Azure regions
3. **Advanced Testing**: Add compliance tests with Sentinel
4. **GitOps**: Implement Atlantis for PR-based workflows
5. **Cost Optimization**: Add Infracost integration
6. **Security Scanning**: Integrate Checkov in CI pipeline

---

## Resources

- [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Verified Terraform Modules](https://registry.terraform.io/namespaces/Azure)
- [Terratest Documentation](https://terratest.gruntwork.io/)
- [GitHub Copilot Best Practices](https://docs.github.com/en/copilot)
- [Azure Landing Zones (Terraform)](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale)

---

**Repository Mission**: Empower IT Professionals to leverage GitHub Copilot as an efficiency multiplier for Infrastructure as Code, demonstrating 90% time savings through hands-on Terraform scenarios.
