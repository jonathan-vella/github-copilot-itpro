# S05 Service Validation - Effective Prompts

## Infrastructure Deployment Prompts

### 1. Bicep Template Generation
```
Create a Bicep template for Azure App Service with:
- Premium P1v3 tier for zone redundancy
- Managed identity enabled
- Container deployment from ACR
- Health check path configured
- Always On enabled
```

### 2. SQL Server with Entra Auth
```
Generate a Bicep module for Azure SQL Server with:
- Entra ID-only authentication (azureADOnlyAuthentication: true)
- No SQL admin username/password
- Administrators block with AAD admin details
- Allow Azure services firewall rule
```

### 3. Managed Identity Configuration
```
Show me how to:
1. Enable managed identity on App Service
2. Grant AcrPull role to the managed identity
3. Configure App Service to pull from ACR using managed identity
```

## Load Testing Prompts

### 4. Load Test Configuration
```
Create an Azure Load Testing config (YAML) for:
- 100 concurrent virtual users
- 5 minute duration
- Ramp-up: 30 seconds
- Target: App Service URL
- Endpoints: /, /api/version, /api/whoami
- Success criteria: p95 < 500ms, error rate < 1%
```

### 5. PowerShell Load Test Wrapper
```
Write a PowerShell script that:
- Accepts test name and config file parameters
- Creates Azure Load Testing resource if not exists
- Uploads test configuration
- Executes the test
- Polls for completion
- Downloads and displays results
- Returns exit code 1 if test fails criteria
```

### 6. Load Test Analysis
```
Parse Azure Load Testing results JSON and generate a markdown report showing:
- Total requests
- Average/p95/p99 response times
- Error rate
- Requests per second
- Pass/fail status with reasons
```

## Chaos Engineering Prompts

### 7. Chaos Experiment Definition
```
Create an Azure Chaos Studio experiment JSON for CPU spike:
- Target: App Service
- Action: CPU stress at 80% for 5 minutes
- Selector: All instances
- Duration: 5 minutes
- Branch: sequential execution
```

### 8. Chaos Experiment Executor
```
Write a PowerShell script that:
- Accepts experiment name parameter
- Loads experiment JSON from file
- Creates or updates Chaos Studio experiment
- Grants necessary permissions
- Starts the experiment
- Monitors execution status
- Collects application metrics during chaos
- Reports recovery time
```

### 9. Multi-Experiment Runner
```
Create a script to run multiple chaos experiments sequentially:
- CPU spike (80% load)
- Memory pressure (90% usage)
- Network latency (+100ms)
- Container restart
- Between each: 10 minute recovery period
- Verify app health before proceeding
- Generate consolidated report
```

## UAT Testing Prompts

### 10. API Health Check Test
```
Write a PowerShell Pester test that:
- Calls the /api/healthcheck endpoint
- Verifies HTTP 200 status
- Validates JSON response contains "status": "healthy"
- Checks response time < 1 second
- Tests from multiple regions if possible
```

### 11. SQL Connectivity Test
```
Create a Pester test for SQL connectivity:
- Call /api/sqlwhoami endpoint
- Verify managed identity name in response
- Confirm no SQL username/password in app settings
- Test database read/write operations
- Validate connection pooling works
```

### 12. Managed Identity Validation
```
Write tests to validate managed identity:
- App Service has system-assigned identity
- Identity has AcrPull role on ACR
- Identity has db_datareader and db_datawriter on SQL DB
- No connection strings with passwords in app config
- Token acquisition works (check /api/token endpoint)
```

## Debugging & Troubleshooting Prompts

### 13. Log Analysis
```
Parse App Service logs to:
- Extract errors in last 1 hour
- Group by error type
- Show top 5 most frequent errors
- Identify slowest API endpoints
- Report on 5xx vs 4xx errors
```

### 14. Container Image Issues
```
I'm getting "ImagePullFailure" errors. Help me:
1. Verify ACR image exists
2. Check managed identity has AcrPull role
3. Validate image name in app settings matches ACR
4. Show how to manually trigger image pull
```

### 15. SQL Authentication Debugging
```
SQL connection is failing with "Login failed for user". Help diagnose:
- Is Entra auth enabled on SQL Server?
- Does managed identity exist in SQL database as user?
- Are required roles granted?
- Is firewall allowing Azure services?
- Show commands to verify each step
```

## Documentation Prompts

### 16. Architecture Diagram
```
Generate Mermaid diagram showing:
- Azure resources (ACR, App Service, SQL)
- Data flow from user → web app → API → SQL
- Managed identity authentication paths
- Observability (App Insights, Log Analytics)
```

### 17. Runbook Generation
```
Create an operational runbook for this deployment covering:
- Pre-deployment checklist
- Deployment steps with verification
- Post-deployment validation
- Rollback procedures
- Monitoring and alerting setup
- Common issues and resolutions
```

### 18. Test Report Template
```
Generate markdown template for test execution report:
- Executive summary (pass/fail)
- Infrastructure deployment results
- Load test results (tables and charts)
- Chaos experiment outcomes
- UAT test results
- Recommendations
- Next steps
```

## Tips for Better Prompts

1. **Be Specific**: Include exact parameter names, regions, SKUs
2. **Provide Context**: Mention Azure Policy requirements, compliance needs
3. **Request Validation**: Ask for error handling and verification steps
4. **Iterative Refinement**: Start broad, then add specific requirements
5. **Ask for Examples**: Request sample outputs or test data
6. **Security First**: Always mention managed identity, no hardcoded secrets
