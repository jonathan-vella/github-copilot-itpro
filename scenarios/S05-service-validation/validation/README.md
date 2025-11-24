# S05 Service Validation - Testing Framework

This folder contains service validation scripts for testing the S05 SAIF deployment.

## Testing Phases

### 1. Load Testing (`load-testing/`)

Simple HTTP load testing using bash and curl to validate API performance:

- **Quick Load Test**: `quick-load-test.sh` - Configurable duration and concurrency
- **Key Features**:
  - Parallel curl requests
  - Response time measurement
  - Success rate calculation
  - Color-coded pass/fail output

**Run load tests:**

```bash
cd load-testing

# 30-second test with 20 concurrent requests
./quick-load-test.sh 30 20

# 60-second test with 10 concurrent requests
./quick-load-test.sh 60 10
```

### 2. Chaos Engineering (`chaos-testing/`)

⚠️ **Coming Soon** - Planned resilience testing:

- Container restart scenarios
- Resource contention simulation
- Network interruption tests

### 3. User Acceptance Testing (`uat/`)

⚠️ **Coming Soon** - Planned functional tests:

- API health checks
- SQL connectivity validation
- Response format validation
- Performance threshold checks

## Test Execution Order

1. **Deploy Infrastructure**: Run `solution/scripts/deploy.ps1`
2. **Wait for Services**: Allow 60-90 seconds for containers to start
3. **Run Load Test**: Execute `quick-load-test.sh` from `validation/load-testing/`
4. **Verify Results**: Check success rate and response times

## Success Criteria

| Test Type | Metric | Target |
|-----------|--------|--------|
| Quick Load Test | Success Rate | > 99% |
| Quick Load Test | Avg Response Time | < 500ms |
| Quick Load Test | RPS | > 10 |
| API Endpoints | HTTP Status | 200 |

## CI/CD Integration

Integrate load testing into Azure DevOps or GitHub Actions pipelines:

```yaml
- task: Bash@3
  displayName: 'Run Service Validation'
  inputs:
    targetType: 'filePath'
    filePath: 'validation/load-testing/quick-load-test.sh'
    arguments: '30 20'
  continueOnError: false
```

**GitHub Actions Example:**

```yaml
- name: Run Load Test
  run: |
    cd validation/load-testing
    chmod +x quick-load-test.sh
    ./quick-load-test.sh 30 20
```

## Troubleshooting

**Load test returns all failures:**

- Ensure infrastructure is deployed: `az group exists -n rg-s05-validation-swc01`
- Verify App Services are running: `az webapp list -g rg-s05-validation-swc01 --query "[].state"`
- Check API is accessible: `curl https://app-saifv2-api-ss4xs2.azurewebsites.net/`

**Slow response times (> 500ms):**

- Check App Service Plan SKU (should be P1v3 for production)
- Review Application Insights for bottlenecks
- Verify SQL database isn't throttled

**"curl: command not found" error:**

- Install curl: `sudo apt-get install curl` (Ubuntu/Debian) or `brew install curl` (macOS)
- For Windows: Use Git Bash or WSL2
