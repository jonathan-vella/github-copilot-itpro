# Demo Script: Azure Specialization Audit Preparation

## ⏱️ Duration: 30 Minutes

## 🎯 Learning Objectives

By the end of this demo, participants will understand how to:

1. Use GitHub Copilot's custom agents to accelerate audit preparation
2. Generate architectural decision records (ADRs)
3. Apply Well-Architected Framework assessments
4. Create infrastructure plans with Azure Verified Modules
5. Generate production-ready Bicep templates
6. Reduce specialization audit prep time by 80%+

## 👥 Target Audience

- System Integrator partners pursuing Azure specializations
- Azure architects preparing for audits
- IT professionals learning infrastructure as code

---

## 📋 Prerequisites

### Required Tools

- ✅ Visual Studio Code (latest version)
- ✅ GitHub Copilot extension
- ✅ GitHub Copilot Chat extension
- ✅ Azure CLI (version 2.50.0+)
- ✅ Bicep CLI (version 0.20.0+)
- ✅ PowerShell 7+
- ✅ Azure subscription with Contributor access

### Pre-Demo Setup

1. **Open VS Code** with the repository cloned
2. **Login to Azure**: `az login`
3. **Set subscription**: `az account set --subscription "Your-Subscription"`
4. **Verify Bicep**: `bicep --version`
5. **Load custom agents**: Ensure `.github/agents/` folder is present

---

## 🎬 Demo Flow

### **Phase 1: Scene Setting (5 minutes)**

#### The Challenge

**Scenario**: You're a consultant at a System Integrator partner preparing for the **Azure Infrastructure and Database Migration Specialization** audit.

**Customer**: Contoso Manufacturing needs to migrate their critical Task Manager application to Azure with a 99.99% SLA requirement.

**Your Challenge**: You need to prepare comprehensive audit evidence for:
- **Module A**: 6 control points (Azure Essentials Cloud Foundation)
- **Module B**: 7 control points (Infrastructure and Database Migration)
- **Typical time**: 40-80 hours of work

**The Solution**: Use GitHub Copilot's four custom agents to reduce this to 8-12 hours.

#### Show the Audit Requirements

```powershell
# Open the audit checklist
code demos/06-azure-specialization-prep/azure-specialization-audit-checklist.md
```

**Talking Points**:
- "Notice the extensive evidence requirements"
- "Each control point needs specific documentation"
- "Manual preparation is time-consuming and error-prone"
- "Let's see how Copilot agents accelerate this"

---

### **Phase 2: Four-Agent Workflow (18 minutes)**

#### Agent 1: ADR Generator (Optional - 3 minutes)

**Purpose**: Document architectural decisions for enterprise governance

**Press `Ctrl+Shift+A`** to open agent selector, choose **`adr_generator`**

**Prompt** (Copy exactly):
```
Document the architectural decision to use Azure SQL Database instead of SQL Managed Instance 
for the Contoso Task Manager application migration. Consider the following context:
- Application: ASP.NET web app with 2GB database
- Performance: 100 transactions per second required
- SLA: 99.99% uptime target
- Cost sensitivity: Mid-sized manufacturing company
- Management: Limited DBA resources available

Include: decision drivers, alternatives considered, consequences, and compliance implications.
```

**Expected Output**:
- Structured ADR document
- Decision rationale
- Trade-off analysis
- Compliance considerations

**Talking Points**:
- "This ADR satisfies Module A Control 2.1 documentation requirements"
- "Notice how Copilot structures the decision logically"
- "This is reusable for future audits"
- "Optional step, but valuable for enterprise governance"

---

#### Agent 2: Azure Principal Architect (5 minutes)

**Purpose**: Apply Azure Well-Architected Framework best practices

**Press `Ctrl+Shift+A`**, select **`azure-principal-architect`**

**Prompt** (Copy exactly):
```
Conduct a comprehensive Well-Architected Framework assessment for the following architecture:

**Infrastructure**:
- 2 Windows Server 2022 VMs running IIS with ASP.NET application
- Azure Load Balancer with public IP for high availability
- Azure SQL Database (Standard S2 tier)
- Network Security Groups for traffic control
- Azure Monitor for observability

**Requirements**:
- 99.99% availability SLA
- Support 100 transactions per second
- Security is a priority (but using public endpoints for demo)
- Cost optimization within reasonable limits

Assess all five WAF pillars (Reliability, Security, Cost Optimization, Operational Excellence, 
Performance Efficiency) and provide specific recommendations with priority levels.
```

**Expected Output**:
- Assessment against all 5 WAF pillars
- Prioritized recommendations
- Risk identification
- Best practice alignment

**Talking Points**:
- "This satisfies Module A Control 2.2 (Well-Architected Workloads)"
- "And Module B Control 2.2 (Well-Architected Review)"
- "Notice the specific, actionable recommendations"
- "Copilot identifies risks we might miss manually"

**Save the output**:
```powershell
# Create evidence folder
New-Item -ItemType Directory -Path evidence/waf-assessment -Force

# Save Copilot output to file
# Copy the chat response to: evidence/waf-assessment/contoso-taskmanager-waf-assessment.md
```

---

#### Agent 3: Bicep Planning Specialist (5 minutes)

**Purpose**: Create infrastructure implementation plan using Azure Verified Modules (AVM)

**Press `Ctrl+Shift+A`**, select **`bicep-plan`**

**Prompt** (Copy exactly):
```
Create a detailed Bicep implementation plan for the following Azure infrastructure deployment:

**Requirements**:
1. Virtual Network with two subnets (web tier, data tier)
2. Two Windows Server 2022 VMs with IIS installed
3. Azure Load Balancer (Standard SKU) with public IP
4. Azure SQL Database (Standard S2, 10GB)
5. Network Security Groups for both subnets
6. Azure Monitor diagnostics for all resources

**Configuration Details**:
- VM Size: Standard_D2s_v3 (2 vCPU, 8 GB RAM)
- OS Disks: Premium SSD (P10, 128 GB)
- Location: East US
- Availability: Availability Set for VMs
- Naming: Follow Azure best practices (rg-audit-demo-prod, vm-web01-prod, etc.)
- Tags: Environment=Production, Project=TaskManager, ManagedBy=Bicep

**Constraints**:
- Use Azure Verified Modules (AVM) where available
- Follow security best practices (NSG rules, SQL firewall)
- Include deployment scripts and validation
- Generate reusable, modular Bicep code

Provide: module structure, parameter strategy, deployment sequence, and validation approach.
```

**Expected Output**:
- Detailed implementation plan
- Module breakdown
- Parameter strategy
- Deployment sequence
- AVM module recommendations

**Talking Points**:
- "This plan satisfies Module A Control 3.1 (Repeatable Deployment)"
- "Notice the use of Azure Verified Modules"
- "Copilot structures the deployment logically"
- "This becomes our blueprint for implementation"

**Save the plan**:
```powershell
# Save to planning document
# Copy chat output to: infrastructure/IMPLEMENTATION-PLAN.md
```

---

#### Agent 4: Bicep Implementation Specialist (5 minutes)

**Purpose**: Generate production-ready Bicep templates

**Press `Ctrl+Shift+A`**, select **`bicep-implement`**

**Prompt** (Copy exactly):
```
Generate complete Bicep templates based on the implementation plan provided by the 
Bicep Planning Specialist. 

Create the following structure:
1. main.bicep - Main orchestration template
2. modules/network.bicep - VNet, subnets, NSGs
3. modules/compute.bicep - VMs, availability set, VM extensions for IIS
4. modules/database.bicep - Azure SQL Server and Database
5. modules/loadbalancer.bicep - Load balancer with backend pool and health probe
6. parameters/prod.bicepparam - Production parameters

**Requirements**:
- Use latest API versions (2023-05-01 or newer)
- Include comprehensive @description decorators
- Add security by default (HTTPS only, TLS 1.2, firewall rules)
- Generate outputs for audit documentation (resource IDs, endpoints)
- Follow naming conventions from the plan
- Include all required tags

Start with main.bicep and provide complete, deployable code.
```

**Expected Output**:
- Complete Bicep templates
- Modular structure
- Security configurations
- Comprehensive outputs

**Talking Points**:
- "This generates audit-ready infrastructure code"
- "Satisfies Module B Control 3.1 (Infrastructure Deployment)"
- "And Control 3.4 (Automated Deployment)"
- "Notice the security defaults and best practices"
- "Templates are immediately deployable"

**Accept and save templates**:

1. **Click the file icons** in Copilot Chat to accept each generated file
2. **Verify the structure**:
   ```powershell
   tree infrastructure /F
   ```

---

### **Phase 3: Validation & Deployment (5 minutes)**

#### Validate Bicep Templates

```powershell
# Validate the main template
bicep build infrastructure/main.bicep

# Check for errors
az deployment group validate `
  --resource-group rg-audit-demo-prod `
  --template-file infrastructure/main.bicep `
  --parameters infrastructure/parameters/prod.bicepparam
```

**Talking Points**:
- "Validation catches errors before deployment"
- "Bicep provides better error messages than ARM"
- "This validates syntax and parameter types"

#### Deploy to Azure (If time permits)

```powershell
# Create resource group
az group create --name rg-audit-demo-prod --location eastus

# Deploy infrastructure
az deployment group create `
  --resource-group rg-audit-demo-prod `
  --template-file infrastructure/main.bicep `
  --parameters infrastructure/parameters/prod.bicepparam `
  --name contoso-taskmanager-deployment
```

**Talking Points**:
- "Deployment typically takes 10-15 minutes"
- "All resources created with consistent configuration"
- "Outputs provide documentation for audit evidence"

**Alternative** (If not deploying live):
```powershell
# Show what-if analysis instead
az deployment group what-if `
  --resource-group rg-audit-demo-prod `
  --template-file infrastructure/main.bicep `
  --parameters infrastructure/parameters/prod.bicepparam
```

---

### **Phase 4: Evidence Generation (2 minutes)**

#### Show Generated Audit Evidence

```powershell
# List generated evidence files
Get-ChildItem evidence/ -Recurse | Select-Object FullName
```

**Audit Evidence Created**:

1. ✅ **ADR** (Module A 2.1): Architectural Decision Record
2. ✅ **WAF Assessment** (Module A 2.2, Module B 2.2): Well-Architected Review
3. ✅ **Implementation Plan** (Module A 3.1): ALZ deployment approach
4. ✅ **Bicep Templates** (Module B 3.1, 3.4): Infrastructure deployment code
5. ✅ **Deployment Logs** (Module B 3.1): Evidence of successful deployment

**Talking Points**:
- "All evidence generated in under 30 minutes"
- "Manual process would take 8-12 hours for these artifacts"
- "Templates are reusable for future projects"
- "Documentation is audit-ready and professional"

---

## 📊 Demo Wrap-Up (2 minutes)

### Time Savings Summary

| Task | Manual Time | With Copilot | Savings |
|------|-------------|--------------|---------|
| ADR Documentation | 2 hours | 10 min | 92% |
| WAF Assessment | 6 hours | 15 min | 96% |
| Implementation Plan | 4 hours | 15 min | 94% |
| Bicep Templates | 8 hours | 20 min | 96% |
| **Total** | **20 hours** | **60 min** | **95%** |

### Key Takeaways

1. 🚀 **95% time savings** on infrastructure documentation and code
2. 📋 **Audit-ready evidence** generated automatically
3. 🎓 **Learning tool**: Copilot teaches Azure best practices
4. ♻️ **Reusable**: Templates work for future audits
5. 💡 **Quality**: Consistent, professional documentation

### Business Impact

For a partner completing **4 specialization audits per year**:
- **Time saved**: 80 hours/year
- **Cost savings**: $12,000/year (at $150/hour)
- **ROI**: 10x return on Copilot investment
- **Competitive edge**: Faster specialization achievement

---

## 🎯 Next Steps for Participants

1. **Try it yourself**: Clone the repository and run through the agents
2. **Customize**: Adapt prompts for your specific customer scenarios
3. **Practice**: Build muscle memory with the four-agent workflow
4. **Share**: Show your team and management the time savings
5. **Expand**: Use agents for other Azure specializations

---

## ❓ Q&A Talking Points

**Q: "Do I need all four agents?"**  
A: No, the core value is in agents 2-4. ADR Generator is optional but valuable for enterprise governance.

**Q: "Can I use this for other Azure specializations?"**  
A: Absolutely! The workflow applies to all Module A+B specializations (Analytics, AI, SAP, etc.).

**Q: "What if Copilot generates incorrect code?"**  
A: Always validate with `bicep build` and `az deployment validate`. Treat Copilot as a highly skilled assistant, not autopilot.

**Q: "Can I customize the agents?"**  
A: Yes! Agent files are in `.github/agents/`. Modify them for your organization's standards.

**Q: "How do I get started?"**  
A: Clone this repo, install prerequisites, and work through this demo script. Practice makes perfect!

---

## 📚 Resources

- [Azure Specializations](https://partner.microsoft.com/partnership/specialization)
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
- [Azure Verified Modules](https://aka.ms/avm)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [GitHub Copilot for Azure](https://learn.microsoft.com/azure/developer/github/github-copilot-azure)

---

**Demo prepared by**: Azure Specialist Team  
**Last updated**: November 2025  
**Version**: 1.0
