# Service Validation and Testing Guide

## Overview

This guide provides comprehensive validation and testing procedures for Azure Infrastructure and Database Migration Specialization audits, based on Microsoft Cloud Adoption Framework (CAF) Migrate methodology and Azure Well-Architected Framework reliability principles.

## Table of Contents

1. [Pre-Migration Testing](#pre-migration-testing)
2. [Migration Validation](#migration-validation)
3. [Post-Migration Testing](#post-migration-testing)
4. [Chaos Engineering & Fault Injection](#chaos-engineering--fault-injection)
5. [Performance & Load Testing](#performance--load-testing)
6. [User Acceptance Testing (UAT)](#user-acceptance-testing-uat)
7. [Continuous Validation](#continuous-validation)

---

## Pre-Migration Testing

### Compatibility Assessment

**Objective**: Validate workload compatibility with Azure before migration

```powershell
# Run compatibility assessment
.\scripts\pre-migration-assessment.ps1 -ResourceGroupName "rg-taskmanager-prod"
```

**Validation Checklist**:

- ✅ Operating system versions supported in Azure
- ✅ Framework compatibility (.NET versions, SDKs)
- ✅ Database compatibility (SQL Server versions, features)
- ✅ Network connectivity requirements
- ✅ ISV software compatibility with Azure
- ✅ Licensing requirements (Azure Hybrid Benefit)

### Baseline Performance Metrics

**Objective**: Establish performance baseline before migration

**Key Metrics to Capture**:

| Metric Category | Measurement | Tool |
|----------------|-------------|------|
| **Application** | Response time, throughput, error rate | Application Insights |
| **Database** | DTU consumption, query performance, connections | SQL Insights |
| **Compute** | CPU%, memory%, disk I/O | Azure Monitor |
| **Network** | Latency, bandwidth, packet loss | Network Watcher |

```kusto
// Application Insights - Baseline Query
requests
| where timestamp > ago(7d)
| summarize 
    AvgDuration = avg(duration),
    P95Duration = percentile(duration, 95),
    P99Duration = percentile(duration, 99),
    SuccessRate = countif(success == true) * 100.0 / count()
    by bin(timestamp, 1h)
| render timechart
```

### Network Connectivity Testing

**Objective**: Validate network paths before migration

```powershell
# Test connectivity using Azure Network Watcher
$testParams = @{
    Name = "ConnectivityTest"
    ResourceGroupName = "rg-taskmanager-prod"
    SourceResourceId = "/subscriptions/.../virtualMachines/TASKWEB01"
    DestinationResourceId = "/subscriptions/.../sqlServers/sql-taskmanager-prod"
    ProtocolConfiguration = @{
        Protocol = "TCP"
        Port = 1433
    }
}
Test-AzNetworkWatcherConnectivity @testParams
```

---

## Migration Validation

### Data Integrity Validation

**Objective**: Ensure data accuracy during migration

#### Database Migration Validation

```sql
-- Source Database: Row Count Validation
SELECT 
    t.name AS TableName,
    SUM(p.rows) AS RowCount,
    CHECKSUM_AGG(BINARY_CHECKSUM(*)) AS DataChecksum
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY t.name;

-- Target Database: Compare Row Counts
-- Run same query on Azure SQL Database
-- Compare results using PowerShell or Excel
```

**Checksum Validation Script**:

```powershell
# Compare source and target databases
.\scripts\validate-data-integrity.ps1 `
    -SourceServer "on-prem-sql.contoso.com" `
    -TargetServer "sql-taskmanager-prod.database.windows.net" `
    -DatabaseName "TaskManagerDB" `
    -OutputReport "data-integrity-report.html"
```

#### File Migration Validation

```powershell
# Validate file migrations using AzCopy
azcopy sync validate `
    --source "C:\SourceData" `
    --destination "https://sttaskmanagerprod.blob.core.windows.net/data" `
    --compare-hash MD5 `
    --output-level debug
```

### Infrastructure Validation

**Objective**: Confirm all Azure resources deployed correctly

```powershell
# Run infrastructure validation
.\scripts\validate.ps1 -ResourceGroupName "rg-taskmanager-prod"

# Expected Results:
# ✅ 25/25 tests passed (100% success rate)
```

**Key Infrastructure Tests**:

1. **Resource Existence**: All planned resources created
2. **Configuration Compliance**: Resources match architecture specifications
3. **Security Controls**: NSGs, firewalls, TLS settings configured
4. **Monitoring**: Diagnostics, alerts, Log Analytics enabled
5. **Networking**: VNet peering, DNS resolution, routing tables
6. **Identity**: RBAC roles, managed identities, service principals

---

## Post-Migration Testing

### Functional Testing

**Objective**: Validate all application functionality works in Azure

#### End-to-End Testing Scenarios

| Test Scenario | Description | Expected Result | Priority |
|--------------|-------------|-----------------|----------|
| **User Authentication** | Sign in with test accounts | Successful login | P0 |
| **CRUD Operations** | Create, Read, Update, Delete tasks | All operations successful | P0 |
| **Database Connectivity** | Application connects to Azure SQL | Connection established | P0 |
| **Load Balancing** | Traffic distributed across VMs | Even distribution | P1 |
| **Monitoring Data** | Telemetry flowing to Log Analytics | Metrics visible | P1 |
| **Error Handling** | Application handles failures gracefully | User-friendly errors | P2 |
| **Reporting** | Generate usage reports | Reports accurate | P2 |

**Automated Functional Test Suite**:

```powershell
# Run automated functional tests
.\scripts\run-functional-tests.ps1 `
    -ApplicationUrl "http://taskmanager-prod.eastus.cloudapp.azure.com" `
    -TestSuite "All" `
    -OutputFormat "NUnit"
```

### Authentication Flow Validation

**Objective**: Ensure identity and access management works correctly

```powershell
# Test authentication scenarios
.\scripts\test-authentication.ps1 `
    -TenantId "contoso.onmicrosoft.com" `
    -TestUsers @("user1@contoso.com", "user2@contoso.com") `
    -TestScenarios @("Login", "MFA", "PasswordReset", "ServicePrincipal")
```

**Authentication Tests**:

- ✅ User login with Microsoft Entra ID
- ✅ Multi-factor authentication (MFA) flows
- ✅ Service-to-service authentication (managed identities)
- ✅ RBAC permission validation
- ✅ Password reset functionality

### Performance Comparison

**Objective**: Compare Azure performance against baseline

```kusto
// Compare post-migration performance to baseline
let BaselineMetrics = datatable(Metric:string, Baseline:double) [
    "AvgResponseTime", 450,
    "P95ResponseTime", 850,
    "P99ResponseTime", 1200,
    "SuccessRate", 99.9
];
let CurrentMetrics = requests
| where timestamp > ago(24h)
| summarize 
    AvgResponseTime = avg(duration),
    P95ResponseTime = percentile(duration, 95),
    P99ResponseTime = percentile(duration, 99),
    SuccessRate = countif(success == true) * 100.0 / count();
BaselineMetrics
| join kind=inner (CurrentMetrics) on $left.Metric == $right.Metric
| extend Variance = (Current - Baseline) / Baseline * 100
| project Metric, Baseline, Current, Variance_Percent = round(Variance, 2)
```

**Performance Acceptance Criteria**:

- ⚠️ Response time within 10% of baseline
- ⚠️ Throughput meets or exceeds baseline
- ⚠️ Error rate ≤ 0.1%
- ⚠️ Resource utilization < 80% at peak load

---

## Chaos Engineering & Fault Injection

### Overview

Chaos engineering validates workload resilience by intentionally injecting failures to test recovery capabilities. This aligns with Azure Well-Architected Framework reliability principles.

**Reference**: [Azure Well-Architected Framework - Testing Strategy](https://learn.microsoft.com/azure/well-architected/reliability/testing-strategy)

### Chaos Engineering Principles

1. **Start with a hypothesis**: Define expected behavior during failure
2. **Measure baseline behavior**: Capture metrics before fault injection
3. **Inject faults systematically**: Target specific components
4. **Monitor resulting behavior**: Compare with baseline
5. **Document observations**: Record findings for improvement
6. **Remediate and improve**: Address discovered gaps

### Fault Injection Scenarios

#### Scenario 1: VM Failure

**Hypothesis**: Application remains available when one VM fails (load balancer failover)

```powershell
# Using Azure Chaos Studio
$experiment = @{
    Name = "VM-Shutdown-Experiment"
    ResourceGroupName = "rg-taskmanager-prod"
    Location = "eastus"
    Selectors = @{
        Type = "List"
        Targets = @("/subscriptions/.../virtualMachines/TASKWEB01")
    }
    Steps = @{
        Name = "Shutdown VM"
        Branches = @{
            Name = "Shutdown"
            Actions = @{
                Type = "continuous"
                Duration = "PT10M"
                Parameters = @{
                    VirtualMachineAction = "shutdown"
                }
            }
        }
    }
}

New-AzChaosExperiment @experiment
Start-AzChaosExperiment -Name "VM-Shutdown-Experiment" -ResourceGroupName "rg-taskmanager-prod"
```

**Expected Results**:

- ✅ Application remains accessible via load balancer
- ✅ Traffic automatically fails over to healthy VM
- ✅ No user-visible errors
- ✅ Alerts triggered for VM failure
- ✅ Auto-healing restarts failed VM within 5 minutes

**Monitoring During Experiment**:

```kusto
// Monitor application availability during chaos experiment
requests
| where timestamp between(datetime("2025-11-18T10:00:00Z") .. datetime("2025-11-18T10:30:00Z"))
| summarize 
    TotalRequests = count(),
    FailedRequests = countif(success == false),
    AvailabilityPercent = countif(success == true) * 100.0 / count(),
    AvgDuration = avg(duration)
    by bin(timestamp, 1m)
| render timechart
```

#### Scenario 2: Database Connection Failure

**Hypothesis**: Application implements retry logic and graceful degradation during database issues

```json
{
  "experimentName": "SQL-Connection-Failure",
  "description": "Simulate database connection failures using network isolation",
  "steps": [
    {
      "name": "Block SQL Traffic",
      "duration": "PT5M",
      "action": "Block Network Traffic",
      "parameters": {
        "sourceType": "VirtualMachine",
        "destinationType": "SqlDatabase",
        "port": 1433,
        "blockPercentage": 100
      }
    }
  ],
  "successCriteria": {
    "errorRate": "< 5%",
    "gracefulDegradation": true,
    "userExperienceImpact": "Minimal"
  }
}
```

**Expected Results**:

- ✅ Application displays user-friendly error messages
- ✅ Retry logic attempts reconnection (exponential backoff)
- ✅ Cached data served when available
- ✅ Errors logged to Application Insights
- ✅ Alerts triggered for database connectivity issues

#### Scenario 3: High CPU Stress Test

**Hypothesis**: Auto-scaling triggers when CPU exceeds 80% for 5 minutes

```powershell
# CPU stress test using Chaos Studio
$cpuStress = @{
    Name = "CPU-Stress-Test"
    ResourceGroupName = "rg-taskmanager-prod"
    FaultType = "CPUPressure"
    Parameters = @{
        PressureLevel = 95
        Duration = "PT15M"
    }
    Targets = @(
        "/subscriptions/.../virtualMachines/TASKWEB01",
        "/subscriptions/.../virtualMachines/TASKWEB02"
    )
}

Start-AzChaosFaultInjection @cpuStress
```

**Expected Results**:

- ✅ Auto-scaling rules trigger within 5 minutes
- ✅ Additional VM instances provisioned
- ✅ Load balancer distributes traffic to new instances
- ✅ Performance degrades gracefully (< 20% increase in response time)
- ✅ System returns to normal after stress removed

#### Scenario 4: Network Latency Injection

**Hypothesis**: Application remains functional with elevated network latency

```bash
# Network latency injection (200ms delay)
az chaos experiment create \
  --name "Network-Latency-Test" \
  --resource-group "rg-taskmanager-prod" \
  --steps '[
    {
      "name": "Add Network Latency",
      "action": "urn:csci:microsoft:network:networkLatency/1.0",
      "duration": "PT10M",
      "parameters": {
        "latencyInMs": 200,
        "jitterInMs": 50,
        "virtualNetworkResourceId": "/subscriptions/.../virtualNetworks/vnet-prod-eastus"
      }
    }
  ]'

az chaos experiment start \
  --name "Network-Latency-Test" \
  --resource-group "rg-taskmanager-prod"
```

**Expected Results**:

- ✅ Application response time increases proportionally
- ✅ Timeouts configured appropriately (no premature failures)
- ✅ User experience remains acceptable (< 3s response time)
- ✅ No cascading failures to dependent services

### Chaos Testing with Azure Chaos Studio

**Setup Azure Chaos Studio**:

```powershell
# Enable Chaos Studio on resources
$targets = @(
    "/subscriptions/.../virtualMachines/TASKWEB01",
    "/subscriptions/.../virtualMachines/TASKWEB02",
    "/subscriptions/.../sqlServers/sql-taskmanager-prod"
)

foreach ($target in $targets) {
    New-AzChaosTarget -ResourceId $target -TargetType "Microsoft-VirtualMachine"
}

# Create capability for VM shutdown
New-AzChaosCapability `
    -ResourceId $targets[0] `
    -CapabilityName "Shutdown-1.0"
```

**Chaos Experiment Template**:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2021-09-15-preview/chaosExperiment.json",
  "type": "Microsoft.Chaos/experiments",
  "apiVersion": "2023-11-01",
  "name": "HighAvailability-Validation",
  "location": "eastus",
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "selectors": [
      {
        "type": "List",
        "id": "WebTierVMs",
        "targets": [
          {
            "type": "ChaosTarget",
            "id": "/subscriptions/.../virtualMachines/TASKWEB01/providers/Microsoft.Chaos/targets/Microsoft-VirtualMachine"
          }
        ]
      }
    ],
    "steps": [
      {
        "name": "Step 1: VM Failure",
        "branches": [
          {
            "name": "Branch 1",
            "actions": [
              {
                "type": "continuous",
                "name": "urn:csci:microsoft:virtualMachine:shutdown/1.0",
                "duration": "PT10M",
                "parameters": [
                  {
                    "key": "abruptShutdown",
                    "value": "true"
                  }
                ],
                "selectorId": "WebTierVMs"
              }
            ]
          }
        ]
      }
    ]
  }
}
```

### Integration with Load Testing

**Objective**: Validate performance under failure conditions

```yaml
# Load test configuration with chaos
version: v0.1
testName: Chaos-LoadTest
testPlan: loadtest.jmx
engineInstances: 3
testDuration: 600
chaosExperiments:
  - name: VM-Shutdown-Experiment
    startDelay: 180
    duration: 300
  - name: CPU-Stress-Test
    startDelay: 360
    duration: 180
failureCriteria:
  - avg(response_time_ms) > 3000
  - percentage(error) > 5
passPercentage: 95
```

**Run Combined Test**:

```powershell
# Start load test with chaos experiments
.\scripts\run-chaos-loadtest.ps1 `
    -LoadTestFile "chaos-loadtest.yaml" `
    -ResourceGroupName "rg-taskmanager-prod" `
    -Duration 600 `
    -ConcurrentUsers 100
```

---

## Performance & Load Testing

### Azure Load Testing Setup

**Objective**: Validate performance under realistic load conditions

#### Load Test Configuration

```yaml
# loadtest-config.yaml
version: v0.1
testName: TaskManager-LoadTest
testPlan: taskmanager.jmx
engineInstances: 2
properties:
  userPropertyFile: users.csv
secrets:
  - name: SQL_PASSWORD
    value: https://kv-taskmanager-prod.vault.azure.net/secrets/SqlPassword
configurationFiles:
  - config.json
failureCriteria:
  - avg(response_time_ms) > 2000
  - percentage(error) > 0.1
passPercentage: 95
autoStop:
  errorPercentage: 5
  timeWindow: 120
```

#### JMeter Test Plan

```xml
<!-- taskmanager.jmx - Sample HTTP Requests -->
<jmeterTestPlan version="1.2">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="Task Manager Load Test">
      <stringProp name="TestPlan.comments">Load test for Task Manager application</stringProp>
      <boolProp name="TestPlan.functional_mode">false</boolProp>
      <boolProp name="TestPlan.serialize_threadgroups">false</boolProp>
      <elementProp name="TestPlan.user_defined_variables" elementType="Arguments">
        <collectionProp name="Arguments.arguments">
          <elementProp name="BASE_URL" elementType="Argument">
            <stringProp name="Argument.name">BASE_URL</stringProp>
            <stringProp name="Argument.value">${__P(base_url,http://taskmanager-prod.eastus.cloudapp.azure.com)}</stringProp>
          </elementProp>
        </collectionProp>
      </elementProp>
    </TestPlan>
    
    <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="User Threads">
      <stringProp name="ThreadGroup.num_threads">100</stringProp>
      <stringProp name="ThreadGroup.ramp_time">60</stringProp>
      <stringProp name="ThreadGroup.duration">600</stringProp>
      <boolProp name="ThreadGroup.scheduler">true</boolProp>
    </ThreadGroup>
    
    <!-- HTTP Samplers for CRUD operations -->
    <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="GET Tasks">
      <stringProp name="HTTPSampler.domain">${BASE_URL}</stringProp>
      <stringProp name="HTTPSampler.path">/api/tasks</stringProp>
      <stringProp name="HTTPSampler.method">GET</stringProp>
    </HTTPSamplerProxy>
  </hashTree>
</jmeterTestPlan>
```

### Performance Test Scenarios

#### Scenario 1: Baseline Performance Test

**Objective**: Establish performance baseline under normal load

```powershell
# Run baseline performance test
az load test create `
    --name "TaskManager-Baseline" `
    --resource-group "rg-taskmanager-prod" `
    --test-plan "taskmanager.jmx" `
    --engine-instances 2 `
    --description "Baseline performance test - 100 concurrent users"

az load test run `
    --name "TaskManager-Baseline" `
    --resource-group "rg-taskmanager-prod"
```

**Expected Results**:

- Average response time: < 500ms
- P95 response time: < 1000ms
- P99 response time: < 1500ms
- Error rate: < 0.1%
- Throughput: ≥ 100 requests/second

#### Scenario 2: Peak Load Test

**Objective**: Validate performance at maximum expected capacity

```yaml
# peak-loadtest.yaml
version: v0.1
testName: TaskManager-PeakLoad
testPlan: taskmanager.jmx
engineInstances: 5
properties:
  threads: 500
  rampup: 300
  duration: 1800
failureCriteria:
  - avg(response_time_ms) > 2000
  - p99(response_time_ms) > 5000
  - percentage(error) > 1
```

**Run Peak Load Test**:

```bash
az load test run \
  --name "TaskManager-PeakLoad" \
  --resource-group "rg-taskmanager-prod" \
  --parameters threads=500 duration=1800
```

#### Scenario 3: Stress Test

**Objective**: Determine breaking point and failure modes

```powershell
# Gradually increase load until failure
.\scripts\run-stress-test.ps1 `
    -StartUsers 100 `
    -IncrementUsers 50 `
    -IncrementInterval 300 `
    -MaxUsers 1000 `
    -FailureThreshold "error_rate > 5%"
```

**Stress Test Phases**:

| Phase | Users | Duration | Expected Behavior |
|-------|-------|----------|-------------------|
| 1 | 100 | 5 min | Normal performance |
| 2 | 200 | 5 min | Slight degradation (< 10%) |
| 3 | 300 | 5 min | Moderate degradation (10-20%) |
| 4 | 400 | 5 min | Auto-scaling triggers |
| 5 | 500+ | 5 min | Monitor for breaking point |

#### Scenario 4: Endurance Test

**Objective**: Validate system stability over extended period

```yaml
# endurance-test.yaml
version: v0.1
testName: TaskManager-Endurance
testPlan: taskmanager.jmx
engineInstances: 3
properties:
  threads: 200
  rampup: 600
  duration: 28800  # 8 hours
monitoring:
  - resourceId: /subscriptions/.../virtualMachines/TASKWEB01
    metrics: ["Percentage CPU", "Available Memory Bytes", "Network In Total"]
  - resourceId: /subscriptions/.../sqlDatabases/TaskManagerDB
    metrics: ["DTU percentage", "Storage percent", "Deadlocks"]
```

**Endurance Test Monitoring**:

```kusto
// Monitor for memory leaks during endurance test
PerformanceCounters
| where TimeGenerated > ago(8h)
| where CounterName == "Available MBytes"
| summarize 
    AvgMemory = avg(CounterValue),
    MinMemory = min(CounterValue),
    MemoryTrend = regression_predict(TimeGenerated, CounterValue)
    by Computer
| where MemoryTrend < -10  // Alert if memory decreasing by 10MB per hour
```

### Performance Baselines & Test Criteria

**Define Test Pass/Fail Criteria**:

```json
{
  "testCriteria": {
    "baseline": {
      "avgResponseTime": 500,
      "p95ResponseTime": 1000,
      "p99ResponseTime": 1500,
      "errorRate": 0.1,
      "throughput": 100
    },
    "peakLoad": {
      "avgResponseTime": 2000,
      "p95ResponseTime": 3000,
      "p99ResponseTime": 5000,
      "errorRate": 1.0,
      "throughput": 500
    },
    "resourceUtilization": {
      "maxCPU": 80,
      "maxMemory": 85,
      "maxDTU": 75,
      "maxStorage": 90
    }
  }
}
```

### Continuous Performance Monitoring

**Objective**: Track performance trends over time

```kusto
// Performance trend analysis
let baseline = datatable(Metric:string, Target:double) [
    "AvgResponseTime", 500,
    "P95ResponseTime", 1000,
    "ErrorRate", 0.1
];
requests
| where timestamp > ago(30d)
| summarize 
    AvgResponseTime = avg(duration),
    P95ResponseTime = percentile(duration, 95),
    ErrorRate = countif(success == false) * 100.0 / count()
    by bin(timestamp, 1d)
| join kind=inner baseline on $left.Metric == $right.Metric
| extend Compliance = case(
    Metric == "ErrorRate" and Current <= Target, "✅ Pass",
    Metric != "ErrorRate" and Current <= Target, "✅ Pass",
    "❌ Fail"
)
| project Date=timestamp, Metric, Current, Target, Compliance
```

---

## User Acceptance Testing (UAT)

### UAT Planning

**Objective**: Validate application meets business requirements with real users

#### UAT Test Plan Template

```markdown
# User Acceptance Test Plan: Task Manager Application

## Test Scope
- Core functionality (CRUD operations)
- User workflows (login, task management, reporting)
- Integration with external systems
- User experience and accessibility

## Test Environment
- URL: http://taskmanager-uat.eastus.cloudapp.azure.com
- Test Users: See test-users.csv
- Test Data: Pre-loaded with 1000 sample tasks
- Duration: 2 weeks (Nov 18 - Dec 1, 2025)

## Test Team
- Business Owner: Jane Smith (jane.smith@contoso.com)
- UAT Lead: John Doe (john.doe@contoso.com)
- Test Users: Manufacturing floor supervisors (10 users)
- Technical Support: IT Operations team

## Success Criteria
- All P0 scenarios pass with 100% success
- All P1 scenarios pass with ≥ 95% success
- User satisfaction score ≥ 4.0/5.0
- No P0 defects remaining at end of UAT
```

### UAT Test Scenarios

#### Critical Business Scenarios (P0)

| Scenario ID | Test Scenario | Steps | Expected Result | Status |
|-------------|--------------|-------|-----------------|--------|
| UAT-001 | User Login | 1. Navigate to app<br>2. Enter credentials<br>3. Click Sign In | User authenticated and redirected to dashboard | ⏳ Pending |
| UAT-002 | Create Task | 1. Click "New Task"<br>2. Enter title, description, due date<br>3. Click Save | Task created and visible in task list | ⏳ Pending |
| UAT-003 | Update Task Status | 1. Find existing task<br>2. Change status to "Completed"<br>3. Click Save | Status updated, timestamp recorded | ⏳ Pending |
| UAT-004 | Delete Task | 1. Select task<br>2. Click Delete<br>3. Confirm deletion | Task removed from list | ⏳ Pending |
| UAT-005 | Load Balanced Access | 1. Multiple users access app simultaneously<br>2. Perform CRUD operations | All users can access without performance degradation | ⏳ Pending |

#### Important Scenarios (P1)

| Scenario ID | Test Scenario | Steps | Expected Result | Status |
|-------------|--------------|-------|-----------------|--------|
| UAT-101 | Filter Tasks | 1. Use filter controls<br>2. Apply date range filter | Only tasks matching criteria displayed | ⏳ Pending |
| UAT-102 | Search Tasks | 1. Enter search term<br>2. Click Search | Relevant tasks returned in < 2 seconds | ⏳ Pending |
| UAT-103 | Export Report | 1. Navigate to Reports<br>2. Select date range<br>3. Click Export | Report downloaded successfully | ⏳ Pending |
| UAT-104 | Error Handling | 1. Simulate database disconnection<br>2. Attempt to save task | User-friendly error message displayed, retry option available | ⏳ Pending |

### UAT Defect Tracking

**Defect Template**:

```markdown
## Defect: UAT-DEF-001

**Title**: Task creation fails when title exceeds 255 characters

**Severity**: P1 (High)
**Status**: Open
**Reported By**: John Doe (john.doe@contoso.com)
**Date**: 2025-11-18
**Environment**: UAT (http://taskmanager-uat.eastus.cloudapp.azure.com)

**Steps to Reproduce**:
1. Click "New Task"
2. Enter title with 300 characters
3. Click Save

**Expected Result**: Error message "Title must be 255 characters or less"
**Actual Result**: Application throws unhandled exception

**Screenshots**: [Attach screenshot]

**Workaround**: Limit title to 255 characters
**Fix Required**: Add client-side and server-side validation

**Assigned To**: Development Team
**Target Fix Date**: 2025-11-20
```

### UAT Sign-Off Checklist

**Final Acceptance Criteria**:

- ✅ All P0 test scenarios passed (100%)
- ✅ ≥ 95% of P1 test scenarios passed
- ✅ No P0 defects remaining
- ✅ All P1 defects have documented workarounds
- ✅ User satisfaction survey completed (avg ≥ 4.0/5.0)
- ✅ Performance meets acceptance criteria
- ✅ Documentation reviewed and approved
- ✅ Training materials validated
- ✅ Support team trained on new system
- ✅ Rollback plan documented and tested

**UAT Sign-Off Form**:

```markdown
# User Acceptance Testing Sign-Off

**Application**: Task Manager
**Version**: 1.0.0
**UAT Period**: November 18 - December 1, 2025
**Environment**: Azure Production (eastus)

## Test Summary
- Total Test Scenarios: 25
- Passed: 24 (96%)
- Failed: 1 (4%)
- Deferred: 0

## Defect Summary
- P0 Defects: 0
- P1 Defects: 3 (all have workarounds)
- P2 Defects: 7 (to be addressed in v1.1)

## Business Owner Approval
I approve the deployment of Task Manager application to production.

**Name**: Jane Smith
**Title**: Manufacturing Operations Manager
**Signature**: ________________________
**Date**: December 1, 2025

## IT Operations Approval
I confirm the application is ready for production deployment.

**Name**: IT Operations Lead
**Title**: Infrastructure Manager
**Signature**: ________________________
**Date**: December 1, 2025
```

---

## Continuous Validation

### Automated Monitoring & Alerting

**Objective**: Continuously validate service health post-migration

#### Synthetic Monitoring

```powershell
# Create availability tests (Application Insights)
$availabilityTest = @{
    Name = "TaskManager-Homepage"
    ResourceGroupName = "rg-taskmanager-prod"
    Location = "eastus"
    TestFrequency = 300  # Every 5 minutes
    TestLocations = @("us-east-azure", "us-west-azure", "europe-north-azure")
    TestUrl = "http://taskmanager-prod.eastus.cloudapp.azure.com"
    ExpectedStatusCode = 200
    Timeout = 30
}

New-AzApplicationInsightsWebTest @availabilityTest
```

**Synthetic Transaction Monitoring**:

```javascript
// Application Insights Availability Test (Multi-Step)
const { test, expect } = require('@playwright/test');

test('Task Manager - Create Task E2E', async ({ page }) => {
  // Navigate to application
  await page.goto('http://taskmanager-prod.eastus.cloudapp.azure.com');
  
  // Login
  await page.fill('#username', 'testuser@contoso.com');
  await page.fill('#password', process.env.TEST_PASSWORD);
  await page.click('#btnLogin');
  
  // Wait for dashboard
  await page.waitForSelector('#dashboard');
  
  // Create new task
  await page.click('#btnNewTask');
  await page.fill('#taskTitle', 'Synthetic Monitor Test');
  await page.fill('#taskDescription', 'Automated test task');
  await page.click('#btnSave');
  
  // Verify task created
  await expect(page.locator('#taskList')).toContainText('Synthetic Monitor Test');
  
  // Measure total duration
  console.log(`Transaction completed in ${Date.now() - startTime}ms`);
});
```

#### Alert Rules Configuration

```bicep
// Alert rules for continuous validation
resource cpuAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-cpu-high'
  location: 'global'
  properties: {
    description: 'Alert when CPU exceeds 80% for 5 minutes'
    severity: 2
    enabled: true
    scopes: [
      vm1.id
      vm2.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'CPU Percentage'
          metricName: 'Percentage CPU'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

resource availabilityAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-availability-low'
  location: 'global'
  properties: {
    description: 'Alert when availability drops below 99%'
    severity: 0  // Critical
    enabled: true
    scopes: [
      appInsights.id
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'Availability'
          metricName: 'availabilityResults/availabilityPercentage'
          operator: 'LessThan'
          threshold: 99
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}
```

### Azure Monitor Workbooks

**Custom Workbook for Validation Dashboard**:

```json
{
  "version": "Notebook/1.0",
  "items": [
    {
      "type": 1,
      "content": {
        "json": "## Service Validation Dashboard\n\nContinuous monitoring of migrated workload health"
      }
    },
    {
      "type": 10,
      "content": {
        "chartId": "availability-chart",
        "version": "KqlItem/1.0",
        "query": "availabilityResults\n| where timestamp > ago(24h)\n| summarize Availability = avg(availabilityPercentage) by bin(timestamp, 5m)\n| render timechart",
        "size": 0,
        "title": "Application Availability (24h)",
        "timeContext": {
          "durationMs": 86400000
        },
        "queryType": 0,
        "resourceType": "microsoft.insights/components"
      }
    },
    {
      "type": 10,
      "content": {
        "chartId": "performance-chart",
        "version": "KqlItem/1.0",
        "query": "requests\n| where timestamp > ago(24h)\n| summarize \n    AvgDuration = avg(duration),\n    P95Duration = percentile(duration, 95),\n    P99Duration = percentile(duration, 99)\n    by bin(timestamp, 5m)\n| render timechart",
        "size": 0,
        "title": "Response Time Trends (24h)"
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "requests\n| where timestamp > ago(1h)\n| summarize \n    TotalRequests = count(),\n    FailedRequests = countif(success == false),\n    AvgDuration = avg(duration)\n| extend \n    SuccessRate = (TotalRequests - FailedRequests) * 100.0 / TotalRequests,\n    Status = case(\n        SuccessRate >= 99.9, '✅ Healthy',\n        SuccessRate >= 99.0, '⚠️ Warning',\n        '❌ Unhealthy'\n    )\n| project Status, SuccessRate, TotalRequests, FailedRequests, AvgDuration",
        "size": 3,
        "title": "Current Health Status",
        "queryType": 0
      }
    }
  ]
}
```

### Post-Migration Validation Report

**Automated Report Generation**:

```powershell
# Generate post-migration validation report
.\scripts\generate-validation-report.ps1 `
    -ResourceGroupName "rg-taskmanager-prod" `
    -ReportPeriod "24h" `
    -OutputFormat "HTML" `
    -EmailTo "stakeholders@contoso.com"
```

**Report Contents**:

1. **Executive Summary**: Overall health status, key metrics
2. **Availability**: Uptime percentage, downtime incidents
3. **Performance**: Response times, throughput, resource utilization
4. **Errors**: Error rates, top errors, failed requests
5. **Security**: Authentication failures, suspicious activity
6. **Capacity**: Current vs. expected load, scaling events
7. **Compliance**: Test pass/fail rates, SLA adherence
8. **Action Items**: Recommendations, open issues

---

## Summary

This comprehensive validation and testing guide covers:

✅ **Pre-Migration Testing**: Compatibility assessment, baseline metrics, network validation  
✅ **Migration Validation**: Data integrity, infrastructure verification  
✅ **Post-Migration Testing**: Functional testing, authentication flows, performance comparison  
✅ **Chaos Engineering**: Fault injection, resilience validation, Azure Chaos Studio  
✅ **Performance Testing**: Load testing, stress testing, endurance testing, Azure Load Testing  
✅ **User Acceptance Testing**: Business validation, defect tracking, sign-off process  
✅ **Continuous Validation**: Synthetic monitoring, automated alerts, validation dashboards  

**Next Steps**:

1. Review validation scripts in `scripts/` folder
2. Customize test scenarios for your workload
3. Run pre-migration compatibility assessment
4. Execute migration with validation checkpoints
5. Conduct post-migration testing (functional, performance, UAT)
6. Implement chaos engineering experiments
7. Enable continuous validation monitoring
8. Generate validation reports for audit evidence

**References**:

- [CAF Migrate Methodology](https://learn.microsoft.com/azure/cloud-adoption-framework/migrate/)
- [Azure Well-Architected Reliability](https://learn.microsoft.com/azure/well-architected/reliability/)
- [Azure Chaos Studio Documentation](https://learn.microsoft.com/azure/chaos-studio/)
- [Azure Load Testing Documentation](https://learn.microsoft.com/azure/load-testing/)
- [Azure Monitor Documentation](https://learn.microsoft.com/azure/azure-monitor/)
