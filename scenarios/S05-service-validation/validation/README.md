# S05 Service Validation - Testing Framework

This folder contains comprehensive testing scripts for validating the S05 SAIF deployment.

## Testing Phases

### 1. Load Testing (`load-testing/`)

Validates application performance under various load conditions:

- **Baseline Test**: 100 users, 5 minutes
- **Stress Test**: 500 users, 10 minutes  
- **Spike Test**: 0→500→0 users, 15 minutes
- **Endurance Test**: 200 users, 30 minutes

**Run load tests:**
```powershell
cd load-testing
.\Run-LoadTest.ps1 -TestName baseline
```

### 2. Chaos Engineering (`chaos-testing/`)

Tests application resilience through controlled failure injection:

- CPU spike (80% load)
- Memory pressure (90% usage)
- Network latency injection (+100ms)
- Database connection failures
- Container restart simulation

**Run chaos experiments:**
```powershell
cd chaos-testing
.\Run-ChaosExperiment.ps1 -ExperimentName cpu-spike
```

### 3. User Acceptance Testing (`uat/`)

Automated functional tests for critical user scenarios:

- API health checks
- SQL connectivity validation
- Managed identity verification
- Response format validation
- Performance threshold checks

**Run UAT tests:**
```powershell
cd uat
.\Run-UAT.ps1
```

## Test Execution Order

1. **Pre-deployment**: Infrastructure validation
2. **Post-deployment**: Load testing (baseline)
3. **Resilience**: Chaos engineering experiments
4. **Acceptance**: UAT functional tests

## Success Criteria

| Test Type | Metric | Target |
|-----------|--------|--------|
| Load Test | P95 Response Time | < 500ms |
| Load Test | Error Rate | < 1% |
| Load Test | RPS | > 100 |
| Chaos | Recovery Time | < 2 minutes |
| UAT | Pass Rate | 100% |

## CI/CD Integration

All tests can be integrated into Azure DevOps or GitHub Actions pipelines:

```yaml
- task: PowerShell@2
  displayName: 'Run Load Tests'
  inputs:
    filePath: 'validation/load-testing/Run-LoadTest.ps1'
    arguments: '-TestName baseline'
```

## Troubleshooting

**Load test fails with "resource not found":**
- Ensure infrastructure is deployed
- Verify resource group name matches pattern `rg-s05-validation-*`

**Chaos experiment permission denied:**
- Check Azure Chaos Studio is enabled
- Verify RBAC permissions on target resources

**UAT tests timeout:**
- Check App Service is running
- Verify firewall allows test traffic
- Review Application Insights for errors
