# S02 Reference Solution

This folder contains **pre-built Terraform modules** that represent the output of the
conversation-based learning approach demonstrated in this scenario.

## Purpose

These templates serve as:

1. **Reference Implementation** - See the expected output of the learning conversation
2. **Deployment Verification** - Test the modules work in your environment
3. **Comparison Point** - Compare your conversation-generated code to production patterns
4. **Backup for Demos** - Presenter fallback if live conversation needs acceleration

## When to Use These Modules

### ✅ Use the Pre-Built Modules When

- **Validating the demo environment** - Ensure Azure subscription can deploy the resources
- **Time-constrained sessions** - Need to show results without live coding
- **Post-demo reference** - Participants want to study the code later
- **CI/CD examples** - Showing automated deployment patterns

### ✅ Use the Conversation Approach When

- **Learning Terraform** - Building understanding of HCL and patterns
- **Teaching others** - Demonstrating the learning value of Copilot
- **Mapping from CloudFormation** - Understanding how concepts translate
- **Custom scenarios** - Your requirements differ from the demo

## Module Structure

```
solution/
├── README.md                    # This file
├── modules/
│   ├── networking/              # VNet, subnets, NSGs
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── app-service/             # App Service Plan, Web App
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── database/                # SQL Server, Database
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   └── dev/                     # Development environment
│       ├── main.tf              # Root module
│       ├── variables.tf
│       ├── outputs.tf
│       ├── terraform.tfvars
│       └── backend.tf
└── example-code/                # Additional examples
```

### modules/networking/

Creates the network foundation:

- Virtual Network with configurable address space
- Three subnets (web, app, data)
- Network Security Groups for each tier
- Tier-to-tier traffic rules (web→app→data)
- Deny-all baseline rules

### modules/app-service/

Creates the application tier:

- App Service Plan (Linux, Premium SKU)
- Linux Web App with security hardening
- Managed Identity for Azure resource access
- Private endpoint for VNet-only access
- Integration with Private DNS zone

### modules/database/

Creates the data tier:

- Azure SQL Server with Azure AD admin
- SQL Database with threat protection
- Private endpoint for VNet-only access
- Backup retention policies
- Encryption at rest

## Recommended Workflow

### For Learners

```
1. Work through the conversation (examples/copilot-terraform-conversation.md)
2. Build your own modules through dialog with Copilot
3. Compare your output to these reference modules
4. Understand the differences and learn from them
```

### For Teams

```
1. Learn the patterns through conversation approach
2. Customize these modules for your organization
3. Add your naming conventions and tag policies
4. Publish to internal Terraform Registry
```

### For Demos

```
1. Start with live conversation (builds engagement)
2. If running short on time, pivot to these modules
3. Use validation scripts to show actual deployment
4. Reference these files for post-demo questions
```

## Deployment

```bash
# Navigate to dev environment
cd environments/dev

# Configure backend (update storage account name)
# Edit backend.tf with your storage account details

# Initialize
terraform init

# Preview changes
terraform plan

# Deploy
terraform apply

# Destroy when done
terraform destroy
```

## Architecture Reference

The modules create this architecture:

```
┌─────────────────────────────────────────────────────────────────┐
│  Resource Group: rg-cloudbridge-dev                             │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Virtual Network: vnet-cloudbridge-dev                    │  │
│  │  Address Space: 10.0.0.0/16                              │  │
│  │                                                           │  │
│  │  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────┐ │  │
│  │  │ snet-web        │ │ snet-app        │ │ snet-data   │ │  │
│  │  │ 10.0.1.0/24     │ │ 10.0.2.0/24     │ │ 10.0.3.0/24 │ │  │
│  │  │ NSG: nsg-web    │ │ NSG: nsg-app    │ │ NSG: nsg-data│ │  │
│  │  │ ↓ HTTPS 443     │ │ ↓ 8080 from web │ │ ↓ 1433 from │ │  │
│  │  │                 │ │                 │ │   app       │ │  │
│  │  └────────┬────────┘ └────────┬────────┘ └──────┬──────┘ │  │
│  │           │                   │                  │        │  │
│  └───────────│───────────────────│──────────────────│────────┘  │
│              │                   │                  │           │
│              │                   │ PE              │ PE        │
│              │                   ▼                  ▼           │
│  ┌───────────▼──────────────────────────────────────────────┐  │
│  │ App Service: app-cloudbridge-dev-XXXXX                   │  │
│  │ - Managed Identity                                        │  │
│  │ - Private Endpoint                                        │  │
│  │ - HTTPS Only, TLS 1.2                                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ SQL Server: sql-cloudbridge-dev-XXXXX                    │  │
│  │ - Azure AD Auth Only                                      │  │
│  │ - Private Endpoint                                        │  │
│  │ - Threat Protection                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Security Features Implemented

| Feature           | Implementation                | Why It Matters               |
| ----------------- | ----------------------------- | ---------------------------- |
| NSG Deny-All      | Priority 4096 deny rules      | Block unexpected traffic     |
| Tier Isolation    | Web→App, App→Data rules       | Prevent lateral movement     |
| HTTPS Only        | `https_only = true`           | Encrypt in transit           |
| TLS 1.2           | `minimum_tls_version = "1.2"` | Modern encryption            |
| Private Endpoints | All PaaS via PE               | No public exposure           |
| Azure AD Auth     | SQL AD-only                   | No passwords to leak         |
| Managed Identity  | System-assigned               | No credential management     |
| Threat Detection  | SQL enabled                   | Alert on suspicious activity |

## CloudFormation Comparison

| CloudFormation  | Terraform         | Implementation          |
| --------------- | ----------------- | ----------------------- |
| Nested Stacks   | `module` blocks   | `modules/` directory    |
| Parameters      | `variable` blocks | `variables.tf` files    |
| Outputs         | `output` blocks   | `outputs.tf` files      |
| Mappings        | `locals` block    | In `main.tf`            |
| Exports/Imports | Module outputs    | `module.name.output`    |
| Change Sets     | `terraform plan`  | Always run before apply |
| Stack State     | State file        | `backend.tf` config     |

## Environment Differences

| Setting            | Dev   | Staging | Prod |
| ------------------ | ----- | ------- | ---- |
| `app_service_sku`  | P1v3  | P2v3    | P3v3 |
| `sql_sku`          | S0    | S2      | S3   |
| `zone_redundant`   | false | false   | true |
| `backup_retention` | 7     | 14      | 35   |
| `log_retention`    | 30    | 60      | 90   |

## Customization Points

### Organization-Specific Changes

```hcl
// Add your organization's:
- Naming conventions (prefix/suffix patterns)
- Required tags (CostCenter, Owner, Compliance)
- Allowed regions (geographic restrictions)
- SKU constraints (approved sizes)
```

### Security Enhancements

```hcl
// For production, consider adding:
- Azure Firewall or Network Virtual Appliance
- DDoS Protection Standard
- Azure Policy assignments
- Diagnostic settings to Log Analytics
- Azure Key Vault for secrets
```

---

_These modules demonstrate near-production-ready Terraform patterns for Azure. Use them as a
reference after learning the concepts through conversation with Copilot._
