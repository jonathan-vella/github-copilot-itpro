# S05 Service Validation - Effective Prompts

## Service Validation Overview

This scenario focuses on **testing and validating** deployed Azure applications using two specialized agents:

1. **UAT Assistant** (`@uat-assistant`) - User Acceptance Testing with interactive workflow
2. **Load Test Assistant** (`@loadtest-assistant`) - Performance validation under load

These agents guide you through comprehensive testing with step-by-step prompts, automated test execution, and report generation.

---

## Using the UAT Assistant

### Starting a UAT Session

```
@uat-assistant I need to test my API
```

The agent will guide you through:

1. **Discovery Phase** - What service, endpoints, acceptance criteria
2. **Test Planning** - Generate checklist of tests to run
3. **Test Execution** - Run tests one-by-one with validation
4. **Results Analysis** - Parse results, identify issues
5. **Documentation** - Auto-populate test report template

### Example UAT Workflow

```
User: @uat-assistant I need to run UAT tests

Agent: What service are you testing?
User: https://app-saifv2-api-ss4xs2.azurewebsites.net

Agent: What are your key acceptance criteria?
User: All endpoints return 200, response time < 600ms, database connectivity works

Agent: Perfect. Here's your test plan:

# UAT Test Plan
- [ ] Health check (< 600ms)
- [ ] Version endpoint (< 600ms)  
- [ ] Identity endpoint (managed identity validation)
- [ ] Database connectivity
- [ ] Security (HTTPS, no sensitive data)
- [ ] Error handling

Ready to run tests? (yes/no)
User: yes

Agent: [Executes tests one by one, showing results]
Agent: All tests complete! Should I populate the report template?
```

### UAT Test Scripts Available

**Bash:**
```bash
cd validation/uat
export API_BASE_URL="https://your-api-url"
./uat-tests.sh
```

**PowerShell:**
```powershell
cd validation/uat
$env:API_BASE_URL = "https://your-api-url"
./uat-tests.ps1
```

### UAT Test Coverage

The assistant validates:
- ✅ Health & availability (endpoint responses, response times)
- ✅ Version information (API version, metadata)
- ✅ Identity verification (managed identity, no secrets exposed)
- ✅ Client information (IP address, connection details)
- ✅ Database connectivity (SQL queries, connection pooling)
- ✅ Security (HTTPS enforcement, headers)
- ✅ Error handling (404s, proper error responses)
- ✅ Performance (response times meet SLA)

---

## Using the Load Test Assistant

### Starting a Load Test Session

```
@loadtest-assistant I need to load test my API
```

The agent will guide you through:

1. **Discovery Phase** - Service URL, endpoints, performance goals, load pattern
2. **Test Planning** - Pre-test checklist, monitoring setup
3. **Script Generation** - k6 or Azure Load Testing script
4. **Test Execution** - Run test with progress monitoring
5. **Results Analysis** - Parse metrics, identify bottlenecks
6. **Report Generation** - Comprehensive performance report with recommendations

### Example Load Test Workflow

```
User: @loadtest-assistant I need to load test my service

Agent: What service/API are you load testing?
User: https://app-saifv2-api-ss4xs2.azurewebsites.net

Agent: What endpoints should we test?
User: /, /api/sqlwhoami, /api/ip

Agent: What are your performance goals?
User: 500 RPS with p95 response time under 500ms

Agent: What load pattern do you want?
  - Ramp-up (gradual increase)
  - Spike (sudden burst)
  - Sustained (constant load)
  - Step (incremental)
User: Ramp-up

Agent: How long and how many virtual users?
User: 5 minutes, 50 VUs ramping to 200 VUs

Agent: [Generates test configuration]
Agent: [Creates k6 script]
Agent: Ready to execute test?
User: yes

Agent: [Runs load test with progress updates]
Agent: Test complete! Results:
- RPS: 485 (Target: 500) ⚠️  
- p95: 445ms (Target: 500ms) ✅
- Error Rate: 0.2% ✅
- CPU: 78% (Target: < 80%) ✅

Agent: Should I generate the detailed report with recommendations?
```

### Load Test Tools Supported

**k6 (Recommended):**
```bash
cd validation/load-testing
k6 run --out json=results.json load-test.js
```

**Azure Load Testing:**
```bash
az load test create \
  --name my-load-test \
  --resource-group rg-saif-demo \
  --load-test-config-file load-test.yaml
```

### Load Test Metrics

The assistant analyzes:
- 📊 **Throughput** - Requests per second (RPS)
- ⏱️ **Response Times** - p50, p95, p99 percentiles
- ❌ **Error Rate** - HTTP errors, timeouts, connection failures
- 💻 **Resource Utilization** - CPU, memory, network on App Service
- 🗄️ **Database Performance** - Query times, DTU usage, connection pool
- 📈 **Scaling Recommendations** - When to scale up/out

---

## API Endpoint Testing Prompts

### Quick Manual Testing (Without Agents)

If you prefer manual testing without the agents:

#### Test API Health

```bash
curl -s -w "\nStatus: %{http_code}\nTime: %{time_total}s\n" \
  https://app-saifv2-api-ss4xs2.azurewebsites.net/
```

#### Test All Endpoints

```bash
API_URL="https://app-saifv2-api-ss4xs2.azurewebsites.net"
for endpoint in "/" "/api/ip" "/api/sqlwhoami" "/api/sqlsrcip"; do
  echo "Testing: $endpoint"
  curl -s -w "Status: %{http_code}\n" "$API_URL$endpoint" | head -3
done
```

#### SQL Connectivity

```bash
curl -s "$API_URL/api/sqlwhoami" | jq
```

---

## Agent-Generated Reports

Both assistants auto-populate comprehensive templates:

### UAT Report Template
Location: `validation/uat/uat-report-template.md`

Includes:
- Executive summary with pass/fail metrics
- Test results by category (8 test suites)
- Issues and defects tracking
- Acceptance criteria assessment
- Three-level sign-off (QA, Tech Lead, Business)

### Load Test Report Template
Location: `validation/load-testing/load-test-report-template.md`

Includes:
- Executive summary with performance grade
- Detailed metrics (RPS, response times, error rates)
- Per-endpoint breakdown
- Resource utilization (CPU, memory, database)
- Bottleneck analysis
- Scaling recommendations with cost impact
- Three-level sign-off (Performance Engineer, Tech Lead, DevOps/SRE)

---

## CI/CD Integration

### UAT in Pipeline

```yaml
# Azure DevOps Pipeline
- task: Bash@3
  displayName: 'Run UAT Tests'
  inputs:
    targetType: 'filePath'
    filePath: '$(System.DefaultWorkingDirectory)/validation/uat/uat-tests.sh'
  env:
    API_BASE_URL: $(API_URL)
  continueOnError: false
```

### Load Testing in Pipeline

```yaml
# Azure DevOps Pipeline
- task: Bash@3
  displayName: 'Run Load Test'
  inputs:
    targetType: 'inline'
    script: |
      cd validation/load-testing
      k6 run --out json=results.json load-test.js
  continueOnError: false
```

---

## Tips for Using the Agents

### UAT Assistant Best Practices

1. **Be Specific**: Clearly state your acceptance criteria upfront
2. **Review Checklists**: Confirm the test plan before execution
3. **One by One**: Let the agent guide you through tests sequentially
4. **Document Issues**: Report any failures immediately for tracking
5. **Get Sign-off**: Use the generated template for formal approval

### Load Test Assistant Best Practices

1. **Define Goals**: Know your target RPS and response time SLA
2. **Choose Pattern**: Select the right load pattern for your scenario:
   - **Ramp-up**: Capacity planning and gradual scale testing
   - **Spike**: Resilience and auto-scaling validation
   - **Sustained**: Stability and memory leak detection
   - **Step**: Finding breaking points and limits
3. **Monitor Resources**: Watch CPU/memory during tests
4. **Compare Baselines**: Track performance trends over time
5. **Act on Recommendations**: Implement scaling suggestions

---

## Example End-to-End Workflow

### Complete UAT + Load Test Workflow

```bash
# Step 1: Run UAT tests first
@uat-assistant I need to validate my SAIF API at https://app-saifv2-api-ss4xs2.azurewebsites.net
# [Follow agent prompts]
# Result: ✅ All 24 tests passed, report generated

# Step 2: Run load tests after UAT passes
@loadtest-assistant Load test the same API
# [Follow agent prompts]
# Configuration: 5 min, ramp 50→200 VUs, target 500 RPS
# Result: ✅ 485 RPS, p95=445ms, 0.2% errors

# Step 3: Review reports
code validation/uat/uat-report-[timestamp].md
code validation/load-testing/load-test-report-[timestamp].md

# Step 4: Get approvals
# Send reports to stakeholders for sign-off

# Step 5: Deploy to production (if approved)
```
