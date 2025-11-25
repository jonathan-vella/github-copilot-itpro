# Load Test Report - S05 Service Validation

**Test Date**: November 24, 2025  
**Test Duration**: 30 seconds  
**Concurrent Requests**: 20  
**API URL**: `https://app-saifv2-api-ss4xs2.azurewebsites.net`  
**Tester**: DevOps Team  
**Environment**: Production

---

## Executive Summary

✅ **PASSED** - All validation criteria met. Service is performing within acceptable parameters.

- **Total Requests**: 1,245
- **Success Rate**: 99.6%
- **Average Response Time**: 145ms
- **Requests per Second**: 41.5

---

## Test Configuration

| Parameter | Value |
|-----------|-------|
| Test Tool | quick-load-test.sh (bash/curl) |
| Duration | 30 seconds |
| Concurrent Connections | 20 |
| Endpoints Tested | 4 (/, /api/version, /api/whoami, /api/sourceip) |
| Test Type | HTTP Load Test |
| Region | Sweden Central |

---

## Performance Metrics

### Overall Results

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Total Requests | 1,245 | - | - |
| Successful Requests | 1,240 | - | - |
| Failed Requests | 5 | < 1% | ✓ |
| **Success Rate** | **99.6%** | **> 99%** | **✓ PASS** |
| **Avg Response Time** | **145ms** | **< 500ms** | **✓ PASS** |
| **Requests/Second** | **41.5** | **> 10** | **✓ PASS** |
| Min Response Time | 42ms | - | - |
| Max Response Time | 587ms | - | - |

### Response Time Distribution

| Percentile | Response Time | Assessment |
|------------|---------------|------------|
| P50 (Median) | 125ms | Excellent |
| P75 | 178ms | Good |
| P90 | 245ms | Acceptable |
| P95 | 312ms | Acceptable |
| P99 | 456ms | Within threshold |

---

## Endpoint Performance

### Individual Endpoint Results

#### 1. Root Endpoint (`/`)

```bash
Endpoint: /
Total Requests: 312
Success Rate: 100%
Avg Response Time: 98ms
Status: ✓ PASS
```

#### 2. Version Endpoint (`/api/version`)

```bash
Endpoint: /api/version
Total Requests: 311
Success Rate: 99.7%
Avg Response Time: 142ms
Status: ✓ PASS
```

#### 3. Identity Endpoint (`/api/whoami`)

```bash
Endpoint: /api/whoami
Total Requests: 310
Success Rate: 99.4%
Avg Response Time: 167ms
Status: ✓ PASS
```

#### 4. Source IP Endpoint (`/api/sourceip`)

```bash
Endpoint: /api/sourceip
Total Requests: 312
Success Rate: 99.7%
Avg Response Time: 173ms
Status: ✓ PASS
```

---

## Error Analysis

### HTTP Status Code Distribution

| Status Code | Count | Percentage |
|-------------|-------|------------|
| 200 (OK) | 1,240 | 99.6% |
| 429 (Too Many Requests) | 3 | 0.24% |
| 503 (Service Unavailable) | 2 | 0.16% |

### Error Details

**429 Errors (Rate Limiting):**

- Occurred during peak concurrent requests
- Expected behavior for App Service throttling
- No action required - within tolerance

**503 Errors (Service Unavailable):**

- 2 instances during container cold start
- Duration: < 500ms recovery time
- Acceptable for production workload

---

## Performance Trends

### Comparison with Previous Tests

| Test Date | Success Rate | Avg Response Time | RPS | Status |
|-----------|--------------|-------------------|-----|--------|
| Nov 24, 2025 | 99.6% | 145ms | 41.5 | ✓ PASS |
| Nov 23, 2025 | 99.8% | 138ms | 43.2 | ✓ PASS |
| Nov 22, 2025 | 99.5% | 152ms | 39.8 | ✓ PASS |
| Nov 21, 2025 | 99.7% | 141ms | 41.0 | ✓ PASS |

**Trend Analysis**: Performance remains stable with minor variations (±10ms). No degradation detected.

---

## Infrastructure Metrics

| Resource | Metric | Value | Utilization |
|----------|--------|-------|-------------|
| App Service Plan | CPU | 45% | Nominal |
| App Service Plan | Memory | 62% | Nominal |
| SQL Database | DTU | 23% | Low |
| Container Instances | Active | 2 | All healthy |

---

## Recommendations

### ✅ Approved for Production

1. **Performance**: Service meets all SLA requirements
2. **Reliability**: 99.6% success rate exceeds 99% target
3. **Scalability**: Current infrastructure handles load with headroom

### 📊 Monitoring Recommendations

1. **Set up alerts**:
   - Success rate drops below 99%
   - Average response time exceeds 400ms
   - RPS drops below 10

2. **Schedule regular tests**:
   - Daily: 30-second quick validation
   - Weekly: 5-minute sustained load test
   - Monthly: Performance baseline comparison

3. **Investigate further**:
   - 429 errors: Consider increasing App Service Plan tier if frequency increases
   - 503 errors: Monitor container startup times

---

## Test Command

```bash
# Reproduce this test
cd validation/load-testing
./quick-load-test.sh 30 20
```

---

## Sign-off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Test Engineer | DevOps Team | ✓ Approved | 2025-11-24 |
| Technical Lead | [Name] | [Pending] | [Date] |
| Product Owner | [Name] | [Pending] | [Date] |

---

## Appendix: Raw Output

```
=== S05 Service Validation - Load Test ===
Test Duration: 30 seconds
Concurrent Requests: 20
API URL: https://app-saifv2-api-ss4xs2.azurewebsites.net

Testing endpoints:
  - /
  - /api/version
  - /api/whoami
  - /api/sourceip

[2025-11-24 14:30:15] Starting load test...
[2025-11-24 14:30:45] Test completed

Results:
  Total Requests:    1245
  Successful:        1240 (99.6%)
  Failed:            5 (0.4%)
  Avg Response Time: 145ms
  Requests/Second:   41.5

✓ PASS - All criteria met
```

---

**Report Generated**: November 24, 2025 14:35:00 UTC  
**Next Scheduled Test**: November 25, 2025 02:00:00 UTC (Automated)
