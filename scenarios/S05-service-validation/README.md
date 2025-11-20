# Demo 06: Azure Specialization Audit Preparation

## 🎯 Overview

This demo showcases how GitHub Copilot's custom agents dramatically accelerate the Azure Infrastructure and Database Migration Specialization audit preparation process. By using a four-agent workflow, partners can reduce audit prep time from **40-80 hours to 8-12 hours** (85% time savings).

## 📊 Business Value

### Time Savings by Control Point

| Module | Control | Manual Time | With Copilot | Savings |
|--------|---------|-------------|--------------|---------|
| **Module A** | 1.1 Business Strategy | 4 hours | 45 min | 81% |
| **Module A** | 2.2 Well-Architected | 6 hours | 1 hour | 83% |
| **Module A** | 3.1 ALZ Deployment | 8 hours | 1.5 hours | 81% |
| **Module B** | 1.1 Workload Assessment | 5 hours | 1 hour | 80% |
| **Module B** | 2.1 Solution Design | 8 hours | 1.5 hours | 81% |
| **Module B** | 3.1 Infrastructure Deploy | 12 hours | 2 hours | 83% |
| **Total** | All Controls | **43 hours** | **7.75 hours** | **82%** |

### ROI Calculator

For a System Integrator partner with:

- **Consultant rate**: $150/hour
- **Projects per year**: 4 specialization audits
- **Time saved per audit**: 35 hours

**Annual savings**: 35 hours × 4 audits × $150/hour = **$21,000/year**

## 🏗️ Demo Architecture

This demo implements a high-availability web application with:

### Infrastructure Components

```bicep
┌─────────────────────────────────────────────────────────────┐
│                     Azure Subscription                       │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Resource Group (rg-audit-demo-prod)      │  │
│  │                                                         │  │
│  │  ┌──────────────────────────────────────────────────┐ │  │
│  │  │         Azure Load Balancer (Public IP)         │ │  │
│  │  └────────────────┬──────────────┬──────────────────┘ │  │
│  │                   │              │                     │  │
│  │       ┌───────────┴──────┐  ┌───┴──────────┐         │  │
│  │       │   VM 1 (IIS)     │  │  VM 2 (IIS)  │         │  │
│  │       │  Web Tier        │  │  Web Tier    │         │  │
│  │       └───────────┬──────┘  └───┬──────────┘         │  │
│  │                   │              │                     │  │
│  │                   └──────┬───────┘                     │  │
│  │                          │                             │  │
│  │                   ┌──────┴──────────┐                 │  │
│  │                   │  Azure SQL DB   │                 │  │
│  │                   │  (Database Tier)│                 │  │
│  │                   └─────────────────┘                 │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Business Requirements

- ✅ **SLA**: 99.99% uptime (52 minutes downtime/year)
- 🔐 **Security**: Security is a priority (NSGs, Azure SQL firewall)
- 🌐 **Public Access**: Public endpoints for demo simplicity
- 📊 **Performance**: Support 100 transactions per second (TPS)
- 💾 **Database**: Azure SQL Database backend
- 🔄 **High Availability**: 2 IIS VMs behind Azure Load Balancer

### Application

**Simple Task Manager Web App**

- ASP.NET web application running on IIS
- CRUD operations (Create, Read, Update, Delete)
- SQL Server backend
- Demonstrates database connectivity and performance

## 🤖 Four-Agent Workflow

This demo uses the four custom agents in sequence:

### 1️⃣ ADR Generator (Optional)

**Purpose**: Document architectural decisions for enterprise governance

**Example Prompts**:

```text
Document the decision to use Azure SQL Database instead of SQL Managed Instance 
for this web application workload, considering cost, performance, and management overhead.
```

### 2️⃣ Azure Principal Architect

**Purpose**: Apply Azure Well-Architected Framework best practices

**Example Prompts**:

```text
Review this architecture for a high-availability web application with 99.99% SLA target.
The solution uses 2 IIS VMs behind Azure Load Balancer with Azure SQL Database backend.
Assess against all five WAF pillars and provide recommendations.
```

### 3️⃣ Bicep Planning Specialist

**Purpose**: Create implementation plan using Azure Verified Modules

**Example Prompts**:

```text
Create an implementation plan for a high-availability web application infrastructure.
Requirements: 2 Windows VMs with IIS, Azure Load Balancer with public IP, Azure SQL Database 
supporting 100 TPS, NSGs for security. Use Azure Verified Modules where available.
```

### 4️⃣ Bicep Implementation Specialist

**Purpose**: Generate Bicep templates from the plan

**Example Prompts**:

```text
Generate Bicep templates based on the implementation plan. Include main.bicep and modules 
for network, compute, database, and load balancer. Follow security best practices and 
include comprehensive outputs for audit documentation.
```

## 📁 Demo Structure

```bicep
06-azure-specialization-prep/
├── README.md                          # This file
├── DEMO-SCRIPT.md                     # 30-minute walkthrough
├── azure-specialization-audit-checklist.md  # Audit requirements
├── scenario/
│   ├── business-requirements.md       # Customer scenario
│   └── architecture-diagram.md        # Target architecture
├── application/
│   ├── TaskManager.Web/              # ASP.NET web app
│   │   ├── Default.aspx              # UI
│   │   ├── Default.aspx.cs           # Code-behind
│   │   ├── Web.config                # Configuration
│   │   └── TaskManager.Web.csproj    # Project file
│   └── database/
│       └── schema.sql                # Database schema
├── prompts/
│   ├── 01-adr-prompts.md             # ADR Generator prompts
│   ├── 02-architect-prompts.md       # Azure Architect prompts
│   ├── 03-bicep-plan-prompts.md      # Planning prompts
│   └── 04-bicep-implement-prompts.md # Implementation prompts
├── infrastructure/
│   ├── main.bicep                    # Main template
│   ├── parameters/
│   │   ├── dev.bicepparam           # Dev parameters
│   │   └── prod.bicepparam          # Prod parameters
│   └── modules/
│       ├── network.bicep            # VNet, NSGs
│       ├── compute.bicep            # VMs, extensions
│       ├── database.bicep           # Azure SQL
│       └── loadbalancer.bicep       # Load Balancer
├── evidence/
│   ├── adr/                         # Architectural Decision Records
│   ├── waf-assessment/              # Well-Architected reviews
│   ├── deployment-logs/             # Deployment evidence
│   └── validation-reports/          # Post-deployment validation
└── scripts/
    ├── deploy.ps1                   # Deployment script
    ├── validate.ps1                 # Validation script
    └── cleanup.ps1                  # Resource cleanup
```

## 🚀 Quick Start

### Prerequisites

- Azure subscription with Contributor access
- Visual Studio Code with extensions:
  - GitHub Copilot
  - GitHub Copilot Chat
  - Azure Bicep
  - PowerShell
- Azure CLI (`az version 2.50.0+`)
- PowerShell 7+
- Bicep CLI (`bicep version 0.20.0+`)

### Deploy the Demo

1. **Clone the repository**:

   ```powershell
   git clone https://github.com/jonathan-vella/github-copilot-itpro.git
   cd github-copilot-itpro/scenarios/06-azure-specialization-prep

```

2. **Login to Azure**:

   ```powershell
   az login
   az account set --subscription "Your-Subscription-Name"
```

1. **Run the demo script**:

   ```powershell
   # Follow the demo script
   code DEMO-SCRIPT.md

```

4. **Deploy infrastructure** (generated with agents):

   ```powershell
   ./scripts/deploy.ps1 -Environment prod -Location eastus
```

1. **Validate deployment**:

   ```powershell
   ./scripts/validate.ps1 -ResourceGroupName rg-audit-demo-prod

```

6. **Cleanup resources**:

   ```powershell
   ./scripts/cleanup.ps1 -ResourceGroupName rg-audit-demo-prod
```

## 📚 Learning Objectives

By completing this demo, you will learn how to:

1. ✅ Use custom agents to accelerate audit preparation
2. ✅ Generate audit-compliant documentation (ADRs, WAF assessments)
3. ✅ Create infrastructure plans using Azure Verified Modules
4. ✅ Generate production-ready Bicep templates
5. ✅ Document evidence for Module A and Module B controls
6. ✅ Reduce audit prep time by 80%+

## 🎓 Target Audience

- **System Integrator Partners** pursuing Azure specializations
- **Azure Architects** preparing for customer audits
- **Cloud Engineers** learning infrastructure as code
- **IT Professionals** adopting GitHub Copilot for Azure work

## ⏱️ Demo Duration

- **Quick demo**: 15 minutes (show key concepts)
- **Standard demo**: 30 minutes (full workflow)
- **Deep dive**: 60 minutes (build infrastructure live)

## 📖 Related Resources

- [Azure Infrastructure and Database Migration Specialization](https://partner.microsoft.com/en-us/partnership/specialization/infrastructure-database-migration-azure)
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
- [Azure Verified Modules](https://aka.ms/avm)
- [Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/)
- [GitHub Copilot for Azure](https://learn.microsoft.com/azure/developer/github/github-copilot-azure)

## 💡 Key Takeaways

1. **Efficiency Multiplier**: 82% time savings on audit preparation
2. **Quality Improvement**: Consistent, best-practice documentation
3. **Reusability**: Templates and evidence for future audits
4. **Learning Tool**: Copilot teaches Azure best practices as you work
5. **Competitive Advantage**: Faster audit completion = more specializations

---

**Questions?** Open an issue or contact the repository maintainer.
