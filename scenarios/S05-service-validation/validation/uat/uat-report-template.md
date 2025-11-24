# User Acceptance Testing (UAT) Report

**Test Session ID:** `UAT-[YYYY-MM-DD]-[HHmm]`  
**Date:** `[Date]`  
**Tester:** `[Name]`  
**Service Under Test:** `[Service Name]`  
**Environment:** `[Dev/Staging/Production]`

---

## Executive Summary

**Overall Test Status:** `[PASS/FAIL/PARTIAL]`  
**Total Tests Executed:** `[Number]`  
**Tests Passed:** `[Number]` (`[Percentage]%`)  
**Tests Failed:** `[Number]` (`[Percentage]%`)  
**Tests Skipped:** `[Number]`

**Key Findings:**

- `[Summary finding 1]`
- `[Summary finding 2]`
- `[Summary finding 3]`

**Recommendation:** `[Proceed to Production / Address Issues / Retest Required]`

---

## Test Configuration

| Parameter | Value |
|-----------|-------|
| Service URL | `[URL]` |
| API Version | `[Version]` |
| Test Framework | Bash/PowerShell/Pester |
| Test Duration | `[Duration]` |
| Max Response Time | `[XXX]ms` |
| Max DB Response Time | `[XXXX]ms` |

---

## Test Results by Category

### 1. Health and Availability Tests

**Status:** `[PASS/FAIL]`

| Test Case | Endpoint | Expected | Actual | Status | Duration |
|-----------|----------|----------|--------|--------|----------|
| Health check returns 200 | `/` | 200 OK | `[Actual]` | ✅/❌ | `[XXX]ms` |
| Health check responds quickly | `/` | < 600ms | `[XXX]ms` | ✅/❌ | `[XXX]ms` |
| Health check returns valid JSON | `/` | Valid JSON | `[Result]` | ✅/❌ | `[XXX]ms` |

**Notes:**

- `[Any observations]`

---

### 2. Version Information Tests

**Status:** `[PASS/FAIL]`

| Test Case | Endpoint | Expected | Actual | Status | Duration |
|-----------|----------|----------|--------|--------|----------|
| Version endpoint accessible | `/` | 200 OK | `[Actual]` | ✅/❌ | `[XXX]ms` |
| Version field present | `/` | Contains 'version' | `[Result]` | ✅/❌ | `[XXX]ms` |
| Response time acceptable | `/` | < 600ms | `[XXX]ms` | ✅/❌ | `[XXX]ms` |

**Notes:**

- `[Any observations]`

---

### 3. Identity Verification Tests

**Status:** `[PASS/FAIL]`

| Test Case | Endpoint | Expected | Actual | Status | Duration |
|-----------|----------|----------|--------|--------|----------|
| Identity endpoint accessible | `/api/sqlwhoami` | 200 OK | `[Actual]` | ✅/❌ | `[XXX]ms` |
| Valid JSON response | `/api/sqlwhoami` | Valid JSON | `[Result]` | ✅/❌ | `[XXX]ms` |
| No password in response | `/api/sqlwhoami` | Not contains 'password' | `[Result]` | ✅/❌ | `[XXX]ms` |
| No secrets in response | `/api/sqlwhoami` | Not contains 'secret' | `[Result]` | ✅/❌ | `[XXX]ms` |

**Notes:**

- `[Any observations]`

---

### 4. Client Information Tests

**Status:** `[PASS/FAIL]`

| Test Case | Endpoint | Expected | Actual | Status | Duration |
|-----------|----------|----------|--------|--------|----------|
| IP endpoint accessible | `/api/ip` | 200 OK | `[Actual]` | ✅/❌ | `[XXX]ms` |
| Valid JSON response | `/api/ip` | Valid JSON | `[Result]` | ✅/❌ | `[XXX]ms` |
| Response time acceptable | `/api/ip` | < 600ms | `[XXX]ms` | ✅/❌ | `[XXX]ms` |

**Notes:**

- `[Any observations]`

---

### 5. Database Connectivity Tests

**Status:** `[PASS/FAIL]`

| Test Case | Endpoint | Expected | Actual | Status | Duration |
|-----------|----------|----------|--------|--------|----------|
| SQL identity query | `/api/sqlwhoami` | 200 OK | `[Actual]` | ✅/❌ | `[XXX]ms` |
| SQL identity response time | `/api/sqlwhoami` | < 30000ms | `[XXX]ms` | ✅/❌ | `[XXX]ms` |
| SQL connection query | `/api/sqlsrcip` | 200 OK | `[Actual]` | ✅/❌ | `[XXX]ms` |
| SQL connection response time | `/api/sqlsrcip` | < 30000ms | `[XXX]ms` | ✅/❌ | `[XXX]ms` |

**Notes:**

- `[Any observations about database performance, cold starts, etc.]`

---

### 6. Security Tests

**Status:** `[PASS/FAIL]`

| Test Case | Expected | Actual | Status | Notes |
|-----------|----------|--------|--------|-------|
| API uses HTTPS | https:// URL | `[Result]` | ✅/❌ | `[Notes]` |
| HSTS header present | Header set | `[Result]` | ℹ️ | Optional for Azure App Service |
| No sensitive data exposure | No leaks | `[Result]` | ✅/❌ | `[Notes]` |

**Notes:**

- `[Any security observations]`

---

### 7. Error Handling Tests

**Status:** `[PASS/FAIL]`

| Test Case | Endpoint | Expected | Actual | Status |
|-----------|----------|----------|--------|--------|
| Non-existent endpoint | `/api/nonexistent` | 404 | `[Actual]` | ✅/❌ |

**Notes:**

- `[Any observations about error handling]`

---

### 8. Performance Tests

**Status:** `[PASS/FAIL]`

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Average response time | < 600ms | `[XXX]ms` | ✅/❌ |
| Max response time | < 1000ms | `[XXX]ms` | ✅/❌ |
| Min response time | N/A | `[XXX]ms` | ℹ️ |

**Response Time Distribution:**

- `/` (root): `[XXX]ms`
- `/api/ip`: `[XXX]ms`
- `/api/sqlwhoami`: `[XXX]ms`
- `/api/sqlsrcip`: `[XXX]ms`

**Notes:**

- `[Any performance observations or bottlenecks]`

---

## Issues and Defects

### Critical Issues

| ID | Test Case | Description | Impact | Status |
|----|-----------|-------------|--------|--------|
| `[ID]` | `[Test]` | `[Description]` | High/Medium/Low | Open/Fixed |

### Non-Critical Issues

| ID | Test Case | Description | Impact | Status |
|----|-----------|-------------|--------|--------|
| `[ID]` | `[Test]` | `[Description]` | High/Medium/Low | Open/Fixed |

---

## Acceptance Criteria Assessment

| Criterion | Target | Actual | Met? |
|-----------|--------|--------|------|
| All endpoints accessible | 100% | `[XX]%` | ✅/❌ |
| Response time < 600ms | All tests | `[XX]%` | ✅/❌ |
| Database connectivity | Working | `[Status]` | ✅/❌ |
| Security requirements | HTTPS, no leaks | `[Status]` | ✅/❌ |
| Error handling | 404 on invalid | `[Status]` | ✅/❌ |

---

## Recommendations

### Immediate Actions Required

1. `[Action item 1]`
2. `[Action item 2]`
3. `[Action item 3]`

### Future Improvements

1. `[Improvement 1]`
2. `[Improvement 2]`
3. `[Improvement 3]`

---

## Test Artifacts

- **Test Script:** `validation/uat/uat-tests.sh` or `validation/uat/uat-tests.ps1`
- **Test Output:** `[Link or attachment]`
- **Screenshots:** `[If applicable]`
- **Logs:** `[Link or attachment]`

---

## Sign-Off

### QA Engineer

**Name:** `[Name]`  
**Date:** `[Date]`  
**Signature:** `[Signature]`

**Comments:**

```
[QA comments and observations]
```

**Approval:** ✅ Approved / ❌ Rejected / ⚠️ Conditional

---

### Technical Lead

**Name:** `[Name]`  
**Date:** `[Date]`  
**Signature:** `[Signature]`

**Comments:**

```
[Technical lead comments]
```

**Approval:** ✅ Approved / ❌ Rejected / ⚠️ Conditional

---

### Business Stakeholder

**Name:** `[Name]`  
**Date:** `[Date]`  
**Signature:** `[Signature]`

**Comments:**

```
[Business stakeholder comments]
```

**Approval:** ✅ Approved / ❌ Rejected / ⚠️ Conditional

---

## Appendix

### Test Environment Details

```
OS: [Operating System]
Shell: [bash/PowerShell version]
Tools: [curl, jq, etc.]
Network: [Network conditions]
```

### Raw Test Output

```
[Paste complete test output here for reference]
```

---

**Report Generated:** `[Timestamp]`  
**Generated By:** UAT Assistant Agent  
**Version:** 1.0
