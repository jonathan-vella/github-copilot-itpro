# S05: Service Validation Demo Script

**Duration**: 45-60 minutes  
**Audience**: DevOps engineers, SREs, Azure architects  
**Difficulty**: Advanced

## Overview

This demo showcases a comprehensive approach to validating Azure application deployments through:

- Infrastructure-as-Code deployment with Bicep
- Managed Identity authentication to Azure SQL
- Load testing with Azure Load Testing
- Chaos engineering experiments
- User acceptance testing automation

## Prerequisites

- Azure subscription with Contributor access
- Azure CLI installed and authenticated
- PowerShell 7+
- GitHub Copilot enabled in VS Code

## Demo Flow

### Phase 1: Infrastructure Deployment (15 min)

1. **Show the scenario**
   - Open `scenario/requirements.md`
   - Highlight: Entra-only SQL auth, managed identity, zone redundancy

2. **Review Bicep templates**
   - `solution/infra/main.bicep` - orchestration
   - `solution/infra/modules/` - modular design with AVM patterns

3. **Deploy infrastructure**

   ```powershell
   cd solution/scripts
   .\deploy.ps1 -location swedencentral
   ```

4. **Explain what was deployed**
   - ACR with 2 container images
   - SQL Server with Entra ID-only auth
   - 2 App Services (API + Web)
   - Observability (Log Analytics + App Insights)

### Phase 2: Validation Testing (20 min)

1. **Configure SQL access**

   ```powershell
   .\Configure-SqlAccess.ps1 -location swedencentral
   ```

2. **Run quick load test**
   - Navigate to validation directory
   - Show the simple bash script for HTTP load testing

   ```bash
   cd validation/load-testing
   ./quick-load-test.sh 30 20
   ```

   - Explain what it does:
     - 30-second test with 20 concurrent requests
     - Tests 4 API endpoints in parallel
     - Calculates success rate and average response time
     - Color-coded output (green = pass, red = fail)

3. **Analyze test results**
   - Point out key metrics:
     - Total requests made (should be ~600-1000)
     - Success rate (should be > 99%)
     - Average response time (should be < 500ms)
     - Pass/fail status
   - **Value message**: "Simple bash script provides immediate validation without complex infrastructure"

4. **Verify API endpoints**

   ```bash
   # Test individual endpoints
   curl -s https://app-saifv2-api-ss4xs2.azurewebsites.net/ | jq
   curl -s https://app-saifv2-api-ss4xs2.azurewebsites.net/api/version | jq
   ```

### Phase 3: GitHub Copilot Integration (10 min)

1. **Show Copilot-assisted test creation**
   - Ask: "Create a bash script to validate all API endpoints return 200"
   - Ask: "Generate a curl command to measure API response time"
   - Ask: "Write a script to compare current performance against a baseline"

2. **Demonstrate performance analysis**
    - Ask: "Parse quick-load-test.sh output and calculate percentiles"
    - Ask: "Create a markdown report from test results"
    - Use Copilot to add new test scenarios

### Phase 4: Cleanup & Q&A (5 min)

1. **Show resource cleanup**

    ```powershell
    .\scripts\Cleanup.ps1
    ```

2. **Q&A and discussion**

## Key Talking Points

- **Managed Identity**: No secrets in config - Azure handles authentication
- **Entra-only SQL**: Meets compliance requirements (e.g., Azure Policy)
- **Zone Redundancy**: Premium tier ensures high availability
- **Testing Pyramid**: Load → Chaos → UAT validates all layers
- **GitOps Ready**: Infrastructure and tests version-controlled

## Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| Image not found | Check ACR image name matches Bicep |
| SQL auth fails | Run Configure-SqlAccess.ps1 |
| Load test timeout | Increase duration in config |
| Chaos experiment blocked | Check Azure Chaos Studio permissions |

## Success Metrics

- ✅ Infrastructure deploys in < 10 minutes
- ✅ All endpoints return JSON responses
- ✅ Load test achieves < 500ms p95 latency
- ✅ Application recovers from chaos experiments
- ✅ UAT tests pass 100%

## Follow-up Resources

- [Azure Load Testing Docs](https://learn.microsoft.com/azure/load-testing/)
- [Azure Chaos Studio Docs](https://learn.microsoft.com/azure/chaos-studio/)
- [Managed Identity Best Practices](https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview)
