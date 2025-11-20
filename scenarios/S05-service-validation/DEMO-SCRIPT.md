# Demo Script: Azure Specialization Audit Preparation

## ⏱️ Duration: 40 Minutes

## 🎯 Learning Objectives

By the end of this demo, participants will understand how to:

1. Use GitHub Copilot's custom agents to accelerate audit preparation
2. Generate architectural decision records (ADRs)
3. Apply Well-Architected Framework assessments
4. Create infrastructure plans with Azure Verified Modules
5. Generate production-ready Bicep templates
6. Implement comprehensive validation strategies (chaos engineering, load testing, UAT)
7. Reduce specialization audit prep time by 80%+

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
code scenarios/S05-service-validation/azure-specialization-audit-checklist.md
```

**Talking Points**:

- "Notice the extensive evidence requirements"
- "Each control point needs specific documentation"
- "Manual preparation is time-consuming and error-prone"
- "Let's see how Copilot agents accelerate this"

---

### **Phase 2: Four-Agent Workflow (15 minutes)**

#### Agent 1: ADR Generator (Optional - 2 minutes)

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

#### Agent 2: Azure Principal Architect (4 minutes)

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
New-Item -ItemType Directory -Path solution/evidence/waf-assessment -Force

# Save Copilot output to file
# Copy the chat response to: solution/evidence/waf-assessment/contoso-taskmanager-waf-assessment.md
```

---

#### Agent 3: Bicep Planning Specialist (5 minutes)

**Purpose**: Create infrastructure implementation plan using Azure Verified Modules (AVM)

**Press `Ctrl+Shift+A`**, select **`bicep-plan`**

**Prompt** (Copy exactly):

```bicep
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
# Copy chat output to: solution/infrastructure/IMPLEMENTATION-PLAN.md
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
   tree solution/infrastructure /F

```

---

### **Phase 3: Deployment Validation (4 minutes)**

#### Validate Bicep Templates

```powershell
# Validate the main template
bicep build solution/infrastructure/main.bicep

# Check for errors
az deployment group validate `
  --resource-group rg-audit-demo-prod `
  --template-file solution/infrastructure/main.bicep `
  --parameters solution/infrastructure/parameters/prod.bicepparam
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
  --template-file solution/infrastructure/main.bicep `
  --parameters solution/infrastructure/parameters/prod.bicepparam `
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
  --template-file solution/infrastructure/main.bicep `
  --parameters solution/infrastructure/parameters/prod.bicepparam
```

---

### **Phase 4: Validation & Testing Demonstrations (10 minutes)**

**Purpose**: Demonstrate comprehensive migration validation aligned with CAF Migrate methodology

#### Overview of Validation Framework

**Open validation guide**:

```powershell
code solution/validation/VALIDATION-TESTING-GUIDE.md
```

**Talking Points**:

- "Microsoft CAF Migrate requires comprehensive testing across all migration phases"
- "We've created a complete validation framework aligned with Well-Architected Framework RE:08"
- "This covers chaos engineering, load testing, UAT, and continuous validation"
- "Let's walk through each validation type"

---

#### 1. Chaos Engineering with Azure Chaos Studio (3 minutes)

**Purpose**: Validate resilience by intentionally injecting faults

**Press `Ctrl+Shift+A`**, select **`azure-principal-architect`**

**Prompt** (Copy exactly):

```yaml
Using Well-Architected Framework RE:08 principles, design a chaos engineering experiment 
for our deployed Task Manager infrastructure to test load balancer failover resilience.

**Current Infrastructure**:
- 2 Windows VMs behind Azure Load Balancer
- Azure SQL Database backend
- 99.99% availability SLA requirement

**Test Scenario**: VM failure simulation
- Expected Result: Automatic failover to healthy VM within 30-60 seconds
- Success Criteria: Zero data loss, minimal user impact

Provide: Azure Chaos Studio experiment configuration, monitoring approach, and success validation.
```

**Show existing chaos scenario**:

```powershell
# Open the comprehensive guide section on chaos engineering
code solution/validation/VALIDATION-TESTING-GUIDE.md
# Navigate to Section 4: Chaos Engineering & Fault Injection
```

**Talking Points**:

- "This satisfies Module B Control 3.1 (post-migration validation)"
- "Well-Architected Framework RE:08 recommends chaos engineering for production readiness"
- "Azure Chaos Studio allows controlled fault injection without manual intervention"
- "Four scenarios included: VM failure, database connection failure, high CPU stress, network latency"
- "Each experiment includes JSON template, PowerShell deployment, and KQL monitoring queries"

**Key Features to Highlight**:

- **VM Failure Test**: Validates load balancer automatic failover (30-60s recovery)
- **Database Connection Failure**: Tests retry logic and graceful degradation
- **High CPU Stress**: Validates auto-scaling triggers (scale-out within 5 min)
- **Network Latency Injection**: Tests timeout configuration (200ms tolerance)

---

#### 2. Performance & Load Testing with Azure Load Testing (2 minutes)

**Purpose**: Validate performance under various load conditions

**Prompt for Azure Principal Architect** (Copy exactly):

```

Design a comprehensive load testing strategy for the Task Manager application using
Azure Load Testing service.

**Requirements**:

- Baseline: 100 concurrent users, 30 minutes, <2s response time
- Peak Load: 500 concurrent users, 1 hour, validate SLA
- Stress Test: Incremental to 1000 users, identify breaking point
- Endurance: 200 concurrent users, 8 hours, validate stability

**Application Profile**:

- ASP.NET web app with database backend
- Critical operations: Login, task CRUD, search, reporting
- SLA: 99.99% availability, <2s response time for 95th percentile

Provide: JMeter test plan structure, failure criteria, and resource utilization thresholds.

```

**Show load testing documentation**:

```powershell
# Navigate to Section 5 in validation guide
code solution/validation/VALIDATION-TESTING-GUIDE.md
# Show the 4 load testing scenarios
```

**Talking Points**:

- "Azure Load Testing provides cloud-scale performance validation"
- "Four test types cover different performance aspects"
- "Baseline test validates normal operations meet SLA requirements"
- "Stress test identifies breaking points before they impact production"
- "Endurance test catches memory leaks and degradation over time"

**Key Metrics to Monitor**:

- Response time: 95th percentile <2s (baseline), <3s (peak)
- Error rate: <1% (baseline), <5% (stress)
- Throughput: 100 TPS (baseline), 250 TPS (peak)
- Resource utilization: CPU <70%, Memory <80%, Database DTU <80%

---

#### 3. User Acceptance Testing (UAT) Framework (3 minutes)

**Purpose**: Demonstrate business user validation with realistic test data

**Show UAT tracking templates**:

```powershell
# Open UAT templates in Excel (or show CSV)
Start-Process "solution/validation/uat-tracking-template.csv"
Start-Process "solution/validation/uat-defect-tracking.csv"
Start-Process "solution/validation/uat-summary-by-category.csv"
Start-Process "solution/validation/uat-tester-assignments.csv"
```

**Walk through the realistic dummy data**:

1. **Main Test Tracker** (`uat-tracking-template.csv`):
   - 40 detailed test scenarios across 22 functional categories
   - **Results**: 37 Pass (92.5%), 1 Fail, 5 Pass with Comments = **95% pass rate**
   - **Categories**: Authentication, CRUD, Search, Reporting, Performance, Mobile, Security, API, Accessibility
   - **Execution**: 17 unique testers from multiple departments (Jan 15-22, 2024)
   - **Example Tests**:
     - UAT-001: User Login - Valid Credentials (Pass, 1.5 min)
     - UAT-021: Task Title Validation (Fail → DEF-001, fixed in v1.0.1)
     - UAT-035: System Under 500 Concurrent Users (Pass, 45 min load test)

2. **Defect Tracking** (`uat-defect-tracking.csv`):
   - **15 realistic defects** with complete lifecycle
   - **Severity**: 1 P0 (Critical), 4 P1 (High), 6 P2 (Medium), 4 P3 (Low)
   - **Status Distribution**: 7 Fixed, 3 Open, 1 In Progress, 1 Deferred, 1 Won't Fix, 1 Closed (False Positive)
   - **Examples**:
     - DEF-001 (P1, Fixed): Task title validation missing client-side check → fixed in v1.0.1
     - DEF-003 (P2, Deferred): Search slow with 10K+ tasks → deferred to v1.1 performance optimization
     - DEF-015 (P0, False Positive): SQL injection vulnerability → verified using parameterized queries

3. **Category Summary** (`uat-summary-by-category.csv`):
   - **22 functional categories** with statistics
   - **Overall**: 40 tests, 100% executed, 95% pass rate
   - **Status**: ✅ Complete (categories with 100% pass), ⚠️ Issues Found (failures/comments)
   - **Production Ready**: Met all criteria (95%+ pass rate, 0 P0 defects, business sign-off)

4. **Tester Assignments** (`uat-tester-assignments.csv`):
   - **18 testers from 8 departments**: Operations, Maintenance, QA, IT, Security, Compliance, HR
   - **100% completion rate** across all testers
   - **Top Contributors**: Sarah Miller (3 defects), Mike Chen (2 defects), Rachel Green (2 defects)
   - **Cross-functional involvement**: Manufacturing supervisors, plant managers, business analysts, security analysts

**Talking Points**:

- "This demonstrates comprehensive business user involvement, not just IT testing"
- "18 testers from 8 departments show cross-functional validation"
- "95% pass rate meets production go-live criteria"
- "Realistic defect lifecycle shows proper triage and resolution process"
- "All P1 defects fixed before production deployment"
- "This satisfies Module B Control 1.1 (Workload Assessment with UAT evidence)"
- "Excel import methods provided for easy reporting and dashboards"

**Show usage guide**:

```powershell
code solution/validation/UAT-TEMPLATES-README.md
```

**Key Features**:

- Three use cases: Demos, actual projects, audit evidence
- PowerShell scripts for Excel import with formatting
- Pivot table examples for pass rate by category
- Sign-off criteria checklist with all requirements met

---

#### 4. Data Integrity Validation (1 minute)

**Purpose**: Automated database validation for migration scenarios

**Show validation script**:

```powershell
code solution/scripts/validate-data-integrity.ps1
```

**Demo the script** (if source/target DBs available):

```powershell
.\solution\scripts\validate-data-integrity.ps1 `
  -SourceServer "on-prem-sql.contoso.com" `
  -TargetServer "sql-taskmanager-prod.database.windows.net" `
  -DatabaseName "TaskManagerDB" `
  -OutputReport "solution/evidence/data-integrity-report.html"
```

**Script Features**:

- **Connection validation**: Tests source + target connectivity
- **Schema validation**: Table count comparison, identifies missing/extra tables
- **Row count comparison**: Per-table counts with color-coded output
- **Checksum validation**: CHECKSUM_AGG for data integrity (not just counts)
- **HTML report generation**: Professional report with embedded CSS

**Talking Points**:

- "This satisfies Module B Control 3.2 (Database Migration validation)"
- "Automated validation eliminates manual comparison errors"
- "Checksums catch data corruption that row counts miss"
- "HTML reports provide audit-ready evidence"
- "Script supports both Windows and SQL Authentication"

---

#### 5. Continuous Validation (1 minute)

**Purpose**: Ongoing production monitoring and synthetic testing

**Show continuous validation section**:

```powershell
code solution/validation/VALIDATION-TESTING-GUIDE.md
# Navigate to Section 7: Continuous Validation
```

**Key Components**:

1. **Synthetic Monitoring**:
   - Multi-step availability tests using Playwright
   - Simulates user journeys (login → create task → search → logout)
   - Runs every 5 minutes from multiple Azure regions

2. **Alert Rules Configuration**:
   - Response time alerts (<2s threshold breach)
   - Availability alerts (<99.99% SLA breach)
   - Error rate alerts (>1% threshold)
   - Bicep templates provided for deployment

3. **Azure Monitor Workbooks**:
   - Performance metrics dashboard
   - Error analysis and drill-down
   - User experience monitoring
   - JSON template included in guide

4. **Automated Validation Reports**:
   - Daily summary reports
   - Weekly trend analysis
   - Monthly SLA compliance reporting

**Talking Points**:

- "Continuous validation ensures production remains healthy post-migration"
- "Satisfies Module B Control 3.4 (Automated Deployment monitoring)"
- "Synthetic tests catch issues before real users experience them"
- "Automated alerts enable proactive response to degradation"
- "Workbooks provide executive-friendly dashboards for stakeholders"

---

### **Phase 5: Evidence Generation (3 minutes)**

#### Show Generated Audit Evidence

```powershell
# List generated evidence files
Get-ChildItem solution/evidence/ -Recurse | Select-Object FullName
```

**Audit Evidence Created**:

1. ✅ **ADR** (Module A 2.1): Architectural Decision Record
2. ✅ **WAF Assessment** (Module A 2.2, Module B 2.2): Well-Architected Review
3. ✅ **Implementation Plan** (Module A 3.1): ALZ deployment approach
4. ✅ **Bicep Templates** (Module B 3.1, 3.4): Infrastructure deployment code
5. ✅ **Deployment Logs** (Module B 3.1): Evidence of successful deployment
6. ✅ **Validation Testing Guide** (Module B 1.1, 3.1, 3.2, 3.4): Comprehensive testing framework
7. ✅ **Chaos Engineering Experiments** (Module B 3.1): Resilience validation with Azure Chaos Studio
8. ✅ **Load Testing Results** (Module B 3.1): Performance validation with Azure Load Testing
9. ✅ **UAT Documentation** (Module B 1.1): 40 scenarios, 95% pass rate, business sign-off
10. ✅ **Data Integrity Validation** (Module B 3.2): Automated database validation script and reports
11. ✅ **Continuous Monitoring** (Module B 3.4): Synthetic tests, alerts, dashboards

**Talking Points**:

- "All evidence generated in under 40 minutes including comprehensive validation framework"
- "Manual process would take 60-80 hours for these artifacts"
- "Validation content aligned with Microsoft CAF Migrate methodology and Well-Architected Framework RE:08"
- "Templates and scripts are reusable for future migration projects"
- "Documentation is audit-ready and professional"
- "Validation framework covers all migration phases: pre-migration, migration, and post-migration testing"
- "Realistic UAT data with 18 testers from 8 departments demonstrates business involvement"

---

## 📊 Demo Wrap-Up (3 minutes)

### Time Savings Summary

| Task | Manual Time | With Copilot | Savings |
|------|-------------|--------------|------|
| ADR Documentation | 2 hours | 10 min | 92% |
| WAF Assessment | 6 hours | 15 min | 96% |
| Implementation Plan | 4 hours | 15 min | 94% |
| Bicep Templates | 8 hours | 20 min | 96% |
| **Validation Framework** | **40 hours** | **90 min** | **96%** |
| Chaos Engineering Setup | 8 hours | 15 min | 97% |
| Load Testing Configuration | 12 hours | 20 min | 97% |
| UAT Template Creation | 16 hours | 30 min | 97% |
| Data Validation Scripts | 4 hours | 25 min | 90% |
| **Grand Total** | **60 hours** | **150 min (2.5 hrs)** | **96%** |

### Key Takeaways

1. 🚀 **96% time savings** on infrastructure, validation, and documentation (60 hours → 2.5 hours)
2. 📋 **Comprehensive audit evidence** including validation framework aligned with CAF Migrate
3. 🧪 **Production-ready validation**: Chaos engineering, load testing, UAT with realistic data
4. 🎓 **Learning tool**: Copilot teaches Azure best practices and Well-Architected Framework principles
5. ♻️ **Reusable**: Templates, scripts, and experiments work for future migration projects
6. 💡 **Quality**: Consistent, professional documentation with realistic test data
7. 🔍 **Business involvement**: UAT templates show cross-functional testing (18 testers, 8 departments)

### Business Impact

For a partner completing **4 specialization audits per year**:

- **Time saved**: 230 hours/year (57.5 hours per audit × 4 audits)
- **Cost savings**: $34,500/year (at $150/hour blended rate)
- **ROI**: 35x return on Copilot investment ($34,500 saved vs ~$1,000 annual cost)
- **Competitive edge**: Faster specialization achievement enables more customer engagements
- **Quality improvement**: Comprehensive validation framework reduces post-migration issues
- **Reusability**: Validation templates and scripts accelerate future customer projects

---

## 🎯 Next Steps for Participants

1. **Try it yourself**: Clone the repository and run through the agents
2. **Deploy validation**: Test chaos experiments and load testing in your subscription
3. **Customize UAT templates**: Adapt for your customer scenarios and import to Excel
4. **Practice validation**: Run data integrity script against test databases
5. **Customize prompts**: Adapt for your specific customer scenarios and infrastructure
6. **Build muscle memory**: Practice the four-agent workflow regularly
7. **Share**: Show your team and management the time savings and validation framework
8. **Expand**: Use agents for other Azure specializations (Analytics, AI, SAP)

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

**Q: "Do I need to deploy Azure Chaos Studio experiments for every audit?"**  
A: No, the templates and documentation are the audit evidence. Deploy experiments in your demo environment to show live validation if desired.

**Q: "Can I use the UAT templates for real customer projects?"**  
A: Absolutely! The templates are designed for both demos (with dummy data) and actual projects. Copy the CSVs, customize test scenarios for your customer's application, and track real UAT execution.

**Q: "How do I create the Excel reports from CSV files?"**  
A: See `validation/UAT-TEMPLATES-README.md` for three methods: direct Excel open, PowerShell import with formatting, or combine all CSVs into a single workbook with multiple sheets.

**Q: "What if my customer doesn't need all validation types?"**  
A: Pick what's relevant. Small migrations may skip chaos engineering. Large enterprise migrations benefit from the full framework. The modular structure lets you mix and match.

---

## 📚 Resources

### Specialization & Architecture

- [Azure Specializations](https://partner.microsoft.com/partnership/specialization)
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
- [Azure Verified Modules](https://aka.ms/avm)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [GitHub Copilot for Azure](https://learn.microsoft.com/azure/developer/github/github-copilot-azure)

### Validation & Testing

- [Cloud Adoption Framework - Migrate Methodology](https://learn.microsoft.com/azure/cloud-adoption-framework/migrate/)
- [Azure Chaos Studio Documentation](https://learn.microsoft.com/azure/chaos-studio/)
- [Azure Load Testing](https://learn.microsoft.com/azure/load-testing/)
- [Well-Architected Framework RE:08 - Chaos Engineering](https://learn.microsoft.com/azure/well-architected/reliability/testing-strategy)
- [Azure Monitor Synthetic Monitoring](https://learn.microsoft.com/azure/azure-monitor/app/availability-standard-tests)

---

**Demo prepared by**: Azure Specialist Team  
**Last updated**: November 2025  
**Version**: 2.0 (includes comprehensive validation framework)
