# S05 Service Validation - Effective Prompts

## Service Validation Overview

This scenario focuses on **testing and validating** deployed Azure applications, not infrastructure deployment. The key areas are:

1. **Load Testing** - Performance validation under load
2. **API Testing** - Endpoint functionality and response validation  
3. **Performance Monitoring** - Response times, error rates, throughput
4. **Resilience Testing** - Recovery from failures
5. **User Acceptance Testing** - Functional validation

## Quick Load Testing with Bash

### 1. Simple HTTP Load Test Script

```
Create a bash script (quick-load-test.sh) that:
- Accepts duration (seconds) and concurrent requests parameters
- Uses curl in background processes to simulate load
- Tests multiple API endpoints (/, /api/version, /api/whoami, /api/sourceip)
- Collects response times and status codes
- Calculates success rate, average response time, requests per second
- Displays color-coded results (green for pass, red for fail)
- Exits with code 0 for pass, 1 for fail
```

### 2. Load Test Execution

```
Run a 30-second load test with 20 concurrent requests:
./quick-load-test.sh 30 20

Expected output:
- Total requests made
- Success rate (%)
- Average response time (ms)
- Requests per second
- Pass/fail status against thresholds
```

### 3. Performance Thresholds

```
Define validation criteria for load tests:
- Success rate: > 99%
- Average response time: < 500ms
- Requests per second: > 10
- Error 4xx/5xx: < 1%
```

## API Endpoint Testing Prompts

### 4. Test API Health Endpoint

```bash
# Write a curl command to test the root health endpoint
curl -s -w "\nStatus: %{http_code}\nTime: %{time_total}s\n" \
  https://app-saifv2-api-ss4xs2.azurewebsites.net/

# Expected response:
# - HTTP 200
# - JSON with "name", "version", "description" fields
# - Response time < 1 second
```

### 5. Test All API Endpoints

```bash
# Create a bash loop to test all SAIF API endpoints
for endpoint in "/" "/api/version" "/api/whoami" "/api/sourceip" "/api/sqlwhoami" "/api/sqlsrcip"; do
  echo "Testing: $endpoint"
  curl -s -w "Status: %{http_code}\n" "$API_URL$endpoint" | head -3
done

# Verify each returns:
# - HTTP 200 status
# - Valid JSON response
# - No error messages
```

### 6. Parallel Load Test

```bash
# Simulate 50 concurrent users for 10 seconds
for i in {1..50}; do
  curl -s "$API_URL/api/version" &
done
wait

# Measure:
# - Total time to complete all requests
# - Any failed requests
# - API server responsiveness
```

## Performance Analysis Prompts

### 7. Response Time Analysis

```bash
# Parse load test results to calculate percentiles
# Display as a formatted table:
echo "Metric       | Value"
echo "-------------|-------"
echo "Min          | 45ms"
echo "Avg          | 123ms"
echo "Median       | 110ms"
echo "P95          | 245ms"
echo "P99          | 389ms"
echo "Max          | 567ms"
```

### 8. Error Rate Calculation

```bash
# Analyze HTTP status codes from load test
total_requests=1000
success_2xx=995
client_errors_4xx=3
server_errors_5xx=2

success_rate=$(echo "scale=1; $success_2xx * 100 / $total_requests" | bc)

echo "Total Requests:    $total_requests"
echo "Success (2xx):     $success_2xx (${success_rate}%)"
echo "Client Errors:     $client_errors_4xx"
echo "Server Errors:     $server_errors_5xx"
```

### 9. Throughput Measurement

```bash
# Calculate requests per second (RPS)
total_requests=1000
test_duration=30
rps=$(echo "scale=2; $total_requests / $test_duration" | bc)
echo "Requests/Second: $rps"

# Verify against targets:
# - Development: > 10 RPS
# - Staging: > 50 RPS
# - Production: > 100 RPS
```

## Validation Script Prompts

### 10. Automated Endpoint Validation

```bash
# Create a bash script to validate all API endpoints
#!/bin/bash
API_URL="https://app-saifv2-api-ss4xs2.azurewebsites.net"
FAILED=0

test_endpoint() {
  endpoint=$1
  status=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL$endpoint")
  if [ $status -eq 200 ]; then
    echo "✓ $endpoint - PASS"
  else
    echo "✗ $endpoint - FAIL (HTTP $status)"
    FAILED=1
  fi
}

test_endpoint "/"
test_endpoint "/api/version"
test_endpoint "/api/whoami"
test_endpoint "/api/sourceip"

exit $FAILED
```

### 11. SQL Connectivity Validation

```bash
# Test SQL database connectivity through API
curl -s "$API_URL/api/sqlwhoami" | jq

# Expected response:
# {
#   "status": "OK",
#   "managed_identity": "app-saifv2-api-ss4xs2",
#   "sql_user": "<managed_identity_guid>"
# }

# Verify:
# - HTTP 200 status
# - Managed identity authentication works
# - No SQL errors in response
```

### 12. Performance Baseline Test

```bash
# Establish performance baseline
# 1. Run quick-load-test.sh with 10 concurrent users for 60 seconds
./quick-load-test.sh 60 10

# 2. Record average response time and RPS
# 3. Store results as baseline in baseline-results.txt
echo "Baseline Performance ($(date +%Y-%m-%d))" > baseline-results.txt
echo "- Avg Response Time: 125ms" >> baseline-results.txt
echo "- RPS: 45" >> baseline-results.txt
echo "- Success Rate: 99.8%" >> baseline-results.txt

# 4. Compare future tests against this baseline
# 5. Alert if performance degrades by > 20%
```

## Continuous Validation Prompts

### 13. Automated Test Suite

```bash
# Create a master validation script that runs all tests
#!/bin/bash
echo "=== S05 Service Validation Report ==="
echo "Date: $(date)"
echo "API URL: https://app-saifv2-api-ss4xs2.azurewebsites.net"
echo ""

# 1. Endpoint health checks
./validate-endpoints.sh && echo "[✓] Endpoint Health: PASS" || echo "[✗] Endpoint Health: FAIL"

# 2. Quick load test
./quick-load-test.sh 30 10 && echo "[✓] Load Test: PASS" || echo "[✗] Load Test: FAIL"

# 3. SQL connectivity test
curl -s "$API_URL/api/sqlwhoami" | grep -q "OK" && echo "[✓] SQL Connectivity: PASS" || echo "[✗] SQL Connectivity: FAIL"

echo ""
echo "Overall Status: ✓ ALL TESTS PASSED"
```

### 14. CI/CD Integration

```yaml
# Integrate quick-load-test.sh into Azure DevOps pipeline
- task: Bash@3
  displayName: 'Run Load Test'
  inputs:
    targetType: 'filePath'
    filePath: '$(System.DefaultWorkingDirectory)/validation/load-testing/quick-load-test.sh'
    arguments: '30 20'
  continueOnError: false

# Pipeline fails if:
# - Load test exits with code 1
# - Success rate < 99%
# - Average response time > 500ms
```

### 15. Scheduled Validation

```bash
# Create a cron job for nightly validation
0 2 * * * cd /workspaces/S05-service-validation && ./validation/load-testing/quick-load-test.sh 60 20 >> /var/log/s05-validation.log 2>&1

# Benefits:
# - Detect performance degradation early
# - Validate service availability overnight
# - Build historical performance data
# - Alert on failures via email/Slack
```

## Reporting & Documentation Prompts

### 16. Load Test Results Report

```markdown
# Generate markdown report from quick-load-test.sh results
# Load Test Results - 2025-11-24

## Test Configuration
- **API URL**: https://app-saifv2-api-ss4xs2.azurewebsites.net
- **Duration**: 30 seconds
- **Concurrent Requests**: 20
- **Endpoints Tested**: /, /api/version, /api/whoami, /api/sourceip

## Results
| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Total Requests | 1,245 | - | - |
| Success Rate | 99.6% | > 99% | ✓ PASS |
| Avg Response Time | 145ms | < 500ms | ✓ PASS |
| Requests/Second | 41.5 | > 10 | ✓ PASS |

## Conclusion
✅ All validation criteria met. Service performing within acceptable parameters.
```

### 17. Test Execution Log

```bash
# Create a structured log format for test runs
[2025-11-24 12:30:15] START - Load Test (30s, 20 concurrent)
[2025-11-24 12:30:16] INFO - Testing endpoint: /
[2025-11-24 12:30:16] INFO - Testing endpoint: /api/version
[2025-11-24 12:30:17] INFO - Testing endpoint: /api/whoami
[2025-11-24 12:30:17] INFO - Testing endpoint: /api/sourceip
[2025-11-24 12:30:45] RESULT - Total: 1245 requests
[2025-11-24 12:30:45] RESULT - Success: 1240 (99.6%)
[2025-11-24 12:30:45] RESULT - Avg Time: 145ms
[2025-11-24 12:30:45] RESULT - RPS: 41.5
[2025-11-24 12:30:45] PASS - All criteria met
[2025-11-24 12:30:45] END - Exit code: 0
```

### 18. Validation Checklist

```markdown
# Create a service validation checklist
## S05 Service Validation Checklist

### Pre-Validation
- [ ] Infrastructure deployed successfully
- [ ] All containers running (API + Web)
- [ ] SQL database accessible
- [ ] Managed identities configured

### Endpoint Testing
- [ ] Root endpoint (/) returns 200
- [ ] /api/version returns version info
- [ ] /api/whoami returns identity info
- [ ] /api/sourceip returns client IP
- [ ] /api/sqlwhoami returns SQL identity

### Performance Testing
- [ ] Load test passes (quick-load-test.sh)
- [ ] Success rate > 99%
- [ ] Response time < 500ms average
- [ ] RPS > 10 requests/second

### Sign-off
- [ ] All tests passed
- [ ] Results documented
- [ ] Ready for production
```

## Tips for Service Validation Prompts

1. **Focus on Testing**: Emphasize validation, not deployment
2. **Be Measurable**: Include specific thresholds (99% success, 500ms response)
3. **Simple Tools First**: Bash/curl before complex frameworks
4. **Automate Everything**: Scripts should be CI/CD ready
5. **Clear Pass/Fail**: Exit codes 0 (pass) or 1 (fail)
6. **Document Results**: Generate markdown reports from test output
7. **Compare Baselines**: Track performance over time
8. **Test Realistic Scenarios**: Use actual API endpoints, not mocks

## Example Complete Workflow

```bash
# 1. Deploy infrastructure (already done)
cd solution/scripts && ./deploy.ps1

# 2. Wait for services to be ready
sleep 60

# 3. Run validation tests
cd ../../validation/load-testing
./quick-load-test.sh 30 20

# 4. Check exit code
if [ $? -eq 0 ]; then
  echo "✅ Service validation PASSED"
  # Proceed to production
else
  echo "❌ Service validation FAILED"
  # Alert team, block deployment
  exit 1
fi
```
