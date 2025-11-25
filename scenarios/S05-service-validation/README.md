# S05: Service Validation and Testing

## 🎯 Scenario Overview

This scenario demonstrates **AI-assisted service validation** using GitHub Copilot agents to automate testing workflows for deployed Azure applications.

**Application**: SAIF (Secure AI Framework) api-v2 - A Python FastAPI application with Azure SQL Database backend (managed identity authentication)

**Testing Approach**:

- 🤖 **UAT Assistant Agent** - Interactive user acceptance testing with automated report generation
- 🤖 **Load Test Assistant Agent** - Performance validation with bottleneck analysis and scaling recommendations
- ✅ Comprehensive test suites (Bash + PowerShell)
- ✅ Professional audit-ready reports
- ✅ CI/CD integration examples

---

## 📂 Repository Structure

```
S05-service-validation/
├── agents/                       # 🤖 GitHub Copilot custom agents
│   ├── uat-assistant.agent.md    # UAT testing workflow agent
│   └── loadtest-assistant.agent.md # Load testing workflow agent
├── solution/                     # SAIF v2 deployment package
│   ├── app/                      # FastAPI application code
│   ├── web/                      # Web frontend application
│   ├── infra/                    # Bicep infrastructure templates
│   │   ├── main.bicep            # Main orchestration
│   │   ├── main.parameters.json  # Parameters file
│   │   └── modules/              # Modular Bicep files (AVM patterns)
│   ├── scripts/                  # Deployment automation
│   │   ├── Deploy-SAIF.ps1       # Version chooser (v1/v2)
│   │   ├── Deploy-SAIF-v2.ps1    # Direct v2 deployment
│   │   └── Configure-SAIF-SqlAccess.ps1
│   ├── SAIF-README.md            # Application documentation
│   └── SAIF-DEPLOY.md            # Deployment guide
├── validation/                   # Testing suites and tools
│   ├── uat/                      # User Acceptance Testing
│   │   ├── uat-tests.sh          # Bash test suite (24 tests)
│   │   ├── uat-tests.ps1         # PowerShell test suite (26 tests)
│   │   ├── uat-report-template.md # Auto-populated report
│   │   └── README.md             # UAT documentation
│   └── load-testing/             # Performance Testing
│       ├── load-test-report-template.md # Auto-populated report
│       └── README.md             # Load test documentation
├── templates/                    # Sign-off and audit templates
│   ├── deployment-sign-off.md
│   ├── test-results-sign-off.md
│   └── audit-evidence-package.md
├── scenario/                     # Business requirements & architecture
│   ├── requirements.md           # Customer scenario
│   └── architecture.md           # Technical architecture (15 Mermaid diagrams)
├── prompts/                      # Copilot prompt examples
│   └── effective-prompts.md      # Prompt patterns for agents
├── examples/                     # Sample outputs and reports
├── DEMO-SCRIPT.md                # 30-45 min demo walkthrough
└── README.md                     # This file
```

---

## 🚀 Quick Start

### Prerequisites

- Azure subscription with Contributor access
- Azure CLI installed and authenticated
- VS Code with GitHub Copilot Chat
- PowerShell 7+ or Bash (for running test scripts)
- Docker Desktop (for container builds)

### Step 1: Deploy SAIF Application (One-Time Setup)

```powershell
# Navigate to solution scripts folder
cd solution/scripts

# Deploy to default region (swedencentral)
./deploy.ps1

# Or specify custom region/resource group
./deploy.ps1 -location germanywestcentral -resourceGroupName "rg-my-validation-test"
```

**Deployment time**: ~15-20 minutes (fully automated)

See `solution/scripts/DEPLOYMENT-NOTES.md` for detailed deployment options and troubleshooting.

### Step 2: Run UAT Tests with Agent

Open GitHub Copilot Chat and start the UAT workflow:

```
@uat-assistant I need to run UAT tests for my SAIF API
```

The agent will:

1. Ask about your service and acceptance criteria
2. Generate a comprehensive test plan
3. Guide you to run automated tests (24 test cases)
4. Auto-populate a professional report with results

**Manual test execution** (if preferred):

```bash
cd validation/uat
export API_BASE_URL="https://your-api-url"
./uat-tests.sh  # Bash version
# or
./uat-tests.ps1  # PowerShell version
```

### Step 3: Run Load Tests with Agent

Continue with the Load Test Assistant:

```
@loadtest-assistant I need to load test my API
```

The agent will:

1. Ask about performance goals and load patterns
2. Generate k6 or Azure Load Testing scripts
3. Execute tests and monitor progress
4. Identify bottlenecks and recommend scaling
5. Generate detailed performance report

### Step 4: Review Generated Reports

```bash
# UAT Report (functional validation)
code validation/uat/uat-report-template.md

# Load Test Report (performance validation)
code validation/load-testing/load-test-report-template.md
```

Both reports include:

- Executive summary with pass/fail status
- Detailed test results and metrics
- Issues and recommendations
- Three-level sign-off sections

---

## 📊 Scenario Status

✅ **SAIF v2 Deployment**: Fully automated with managed identity  
✅ **UAT Assistant Agent**: Interactive testing workflow complete  
✅ **Load Test Assistant Agent**: Performance validation with recommendations  
✅ **Test Suites**: Bash + PowerShell (24-26 tests)  
✅ **Report Templates**: Professional audit-ready documentation  
✅ **Demo Script**: 30-45 minute walkthrough  
✅ **Effective Prompts**: Agent usage examples and patterns  

**Status**: 🟢 Production Ready  
**Last Updated**: 2025-01-24

---

## 🎓 Learning Objectives

By completing this scenario, you will learn how to:

1. **Use AI Agents** for guided testing workflows
2. **Automate UAT** with comprehensive test suites (functional validation)
3. **Perform Load Testing** with bottleneck analysis (performance validation)
4. **Generate Reports** automatically with executive summaries
5. **Integrate Testing** into CI/CD pipelines
6. **Reduce Validation Time** by 70-80% while improving quality
7. **Document Compliance** with audit-ready sign-off templates

---

## 📈 Time Savings with AI Agents

| Task | Manual | With Copilot Agents | Savings |
|------|--------|---------------------|---------|
| UAT Test Planning | 2 hrs | 5 min | 96% |
| UAT Test Execution | 3 hrs | 15 min | 92% |
| UAT Report Generation | 4 hrs | 5 min | 98% |
| Load Test Configuration | 3 hrs | 10 min | 94% |
| Load Test Execution | 5 hrs | 15 min | 95% |
| Performance Analysis | 4 hrs | 10 min | 96% |
| Load Test Report | 4 hrs | 5 min | 98% |
| **Total Validation** | **25 hrs** | **65 min** | **96%** |

**Key Benefits:**

- ✅ Comprehensive test coverage (50+ validations)
- ✅ Professional reports with executive summaries
- ✅ Actionable recommendations with cost analysis
- ✅ Repeatable process across all teams
- ✅ Junior engineers get senior-level guidance

---

## 🔗 Related Resources

### Documentation

- [Demo Script](DEMO-SCRIPT.md) - 30-45 minute walkthrough
- [Deployment Guide](solution/scripts/DEPLOYMENT-NOTES.md) - Infrastructure deployment
- [Effective Prompts](prompts/effective-prompts.md) - Agent usage patterns
- [UAT Testing Guide](validation/uat/README.md) - Functional validation
- [Load Testing Guide](validation/load-testing/README.md) - Performance validation

### Agents

- [UAT Assistant](agents/uat-assistant.agent.md) - User acceptance testing workflow
- [Load Test Assistant](agents/loadtest-assistant.agent.md) - Performance testing workflow

### External Links

- [GitHub Copilot](https://github.com/features/copilot)
- [k6 Load Testing](https://k6.io/)
- [Azure Load Testing](https://learn.microsoft.com/azure/load-testing/)
- [Pester Testing Framework](https://pester.dev/)

---

## 📝 Get Started

**For Demo/Training:**

1. Review [DEMO-SCRIPT.md](DEMO-SCRIPT.md) for presentation guidance
2. Deploy SAIF using `solution/scripts/deploy.ps1`
3. Run agents with `@uat-assistant` and `@loadtest-assistant`
4. Review generated reports and customize for your needs

**For Your Own API:**

1. Deploy your service to Azure
2. Open Copilot Chat: `@uat-assistant I need to test [your API]`
3. Follow agent prompts (service URL, endpoints, criteria)
4. Review generated test plan and execute
5. Generate professional reports automatically

**For CI/CD Integration:**

1. Add test scripts to your pipeline (see `validation/uat/README.md`)
2. Configure environment variables (API_BASE_URL)
3. Capture test output for automated reporting
4. Set pass/fail thresholds in pipeline

---

**Status**: 🟢 Production Ready  
**Maintained By**: SAIF Team  
**Last Updated**: 2025-01-24
