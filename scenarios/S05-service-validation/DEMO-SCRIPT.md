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

5. **Configure SQL access**
   ```powershell
   .\Configure-SqlAccess.ps1 -location swedencentral
   ```

6. **Run load tests**
   - Open `validation/load-testing/load-test-config.yaml`
   - Show Azure Load Testing configuration
   ```powershell
   .\validation\load-testing\Run-LoadTest.ps1
   ```

7. **Execute chaos experiments**
   - Open `validation/chaos-testing/chaos-experiments.json`
   - Demonstrate CPU spike, memory pressure, network latency
   ```powershell
   .\validation\chaos-testing\Run-ChaosExperiment.ps1 -ExperimentName cpu-spike
   ```

8. **User acceptance tests**
   ```powershell
   .\validation\uat\Run-UAT.ps1
   ```

### Phase 3: GitHub Copilot Integration (10 min)

9. **Show Copilot-assisted testing**
   - Ask: "Generate a load test that simulates 100 concurrent users"
   - Ask: "Create a chaos experiment for database connection failures"
   - Ask: "Write UAT scenarios for SQL connectivity"

10. **Demonstrate debugging**
    - Introduce an error (e.g., wrong connection string)
    - Use Copilot to diagnose and fix

### Phase 4: Cleanup & Q&A (5 min)

11. **Show resource cleanup**
    ```powershell
    .\scripts\Cleanup.ps1
    ```

12. **Q&A and discussion**

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
