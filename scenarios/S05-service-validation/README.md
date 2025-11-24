# S05: Service Validation and Testing

## 🎯 Scenario Overview

This scenario demonstrates **Module B Control 4.1** from the Azure Infrastructure and Database Migration Specialization audit - **Service Validation and Testing**.

**Application**: SAIF (Secure AI Framework) api-v2 - A Python FastAPI application with Azure SQL Database backend

**Testing Focus**:
- ✅ HTTP Load Testing (Bash/curl-based)
- ✅ API Endpoint Validation
- ✅ Performance Baseline Measurement
- 🔜 Chaos Engineering (planned)
- 🔜 User Acceptance Testing (planned)

---

## 📂 Repository Structure

```
S05-service-validation/
├── app/                          # SAIF api-v2 application
│   ├── app.py                    # Main FastAPI application
│   ├── db_*_worker.py            # Database worker scripts
│   ├── Dockerfile                # Container image definition
│   ├── requirements.txt          # Python dependencies
│   └── init-db.sql               # Database initialization
├── infra/                        # Bicep infrastructure templates
│   ├── main.bicep                # Main orchestration
│   ├── main.parameters.json      # Parameters file
│   └── modules/                  # Modular Bicep files
├── validation/                   # Service validation and testing
│   ├── load-testing/             # HTTP load testing (quick-load-test.sh)
│   ├── chaos-testing/            # Resilience testing (future)
│   ├── uat/                      # User acceptance tests (future)
│   └── README.md                 # Validation documentation
├── monitoring/                   # Monitoring queries and dashboards
├── scripts/                      # Helper automation scripts
├── validation/                   # Validation report templates
└── TODO.md                       # Implementation checklist
```

---

## 🚀 Quick Start

### Prerequisites

- Azure subscription with Contributor access
- Azure CLI installed (authentication pre-configured)
- PowerShell 7+
- VS Code with GitHub Copilot
- Docker Desktop (for container builds)

### Step 1: Review SAIF Application

The SAIF api-v2 application provides these endpoints:
- `/` - Health check
- `/api/whoami` - Identity information
- `/api/version` - Application version
- `/api/sourceip` - Client IP address

See `SAIF-README.md` for full application documentation.

### Step 2: Deploy Infrastructure

```powershell
# Deploy infrastructure and application
cd scripts
./deploy.ps1

# Or specify custom options
./deploy.ps1 -location swedencentral -resourceGroupName "rg-my-validation-test"
```

### Step 3: Run Service Validation Tests

```bash
# Navigate to validation directory
cd validation/load-testing

# Run quick HTTP load test (30 seconds, 20 concurrent requests)
./quick-load-test.sh 30 20

# Expected output: Success rate > 99%, Avg response time < 500ms
```

---

## 📊 Current Status

✅ **Phase 1.1**: Infrastructure templates copied from SAIF  
✅ **Phase 1.2**: Application code copied (api-v2)  
🔄 **Phase 1.3**: CI/CD pipeline - Not Started  
🔄 **Phase 2**: Service validation scripts - Not Started  
🔄 **Phase 3**: Monitoring setup - Not Started  
🔄 **Phase 4**: Documentation - In Progress  

See `TODO.md` for detailed task list.

---

## 🎓 Learning Objectives

By completing this scenario, you will learn how to:

1. **Deploy** a production-ready application with Bicep IaC
2. **Validate** application performance under load
3. **Test resilience** through chaos engineering
4. **Execute** structured UAT with automated scripts
5. **Generate** audit-ready validation reports
6. **Demonstrate** Module B Control 4.1 compliance

---

## 📈 Time Savings

| Task | Manual | With Copilot | Savings |
|------|--------|--------------|---------|
| Infrastructure Setup | 6 hrs | 1 hr | 83% |
| Simple Load Test Script | 4 hrs | 20 min | 92% |
| API Endpoint Validation | 3 hrs | 15 min | 92% |
| Performance Baseline | 2 hrs | 30 min | 75% |
| Validation Report | 8 hrs | 2 hrs | 75% |
| Monitoring Setup | 4 hrs | 1 hr | 75% |
| Documentation | 4 hrs | 1.5 hrs | 62% |
| **TOTAL** | **40 hrs** | **10 hrs** | **75%** |

---

## 🔗 Related Resources

- [SAIF Repository](https://github.com/jonathan-vella/SAIF)
- [Azure Load Testing](https://learn.microsoft.com/azure/load-testing/)
- [Azure Chaos Studio](https://learn.microsoft.com/azure/chaos-studio/)
- [Azure Specialization Audit Checklist](../../docs/azure-specialization-audit-checklist.md)
- [Module B Control 4.1](../../docs/azure-specialization-audit-checklist.md#41-service-validation-and-testing)

---

## 📝 Next Steps

1. ✅ Review `TODO.md` for complete task list
2. 🔄 Review `SAIF-DEPLOY.md` for deployment guidance
3. 🔄 Customize Bicep templates for your environment
4. 🔄 Create deployment script with validation
5. 🔄 Build load testing scripts
6. 🔄 Design chaos experiments

---

**Status**: 🟡 In Progress  
**Last Updated**: 2025-11-24  
**Completion**: ~15% (Phase 1 infrastructure copied)
