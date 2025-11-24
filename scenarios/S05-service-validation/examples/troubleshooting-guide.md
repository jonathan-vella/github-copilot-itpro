# Troubleshooting Guide - S05 Service Validation

This guide provides solutions to common issues encountered during service validation and testing.

---

## Table of Contents

1. [Load Test Failures](#load-test-failures)
2. [API Endpoint Errors](#api-endpoint-errors)
3. [Performance Issues](#performance-issues)
4. [Database Connectivity](#database-connectivity)
5. [Container Issues](#container-issues)
6. [CI/CD Pipeline Failures](#cicd-pipeline-failures)
7. [Diagnostic Commands](#diagnostic-commands)

---

## Load Test Failures

### Issue: Load Test Returns 100% Failure Rate

**Symptoms:**

```bash
$ ./quick-load-test.sh 30 20
Results:
  Total Requests:    0
  Successful:        0 (0%)
  Failed:            All
❌ FAIL
```

**Possible Causes:**

1. **App Service Not Running**

   ```bash
   # Check app service status
   az webapp show --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01 \
     --query "state" -o tsv
   ```

   **Solution:** Start the app service

   ```bash
   az webapp start --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01
   ```

2. **Wrong API URL**
   - Verify URL in script or environment variable

   ```bash
   curl -I https://app-saifv2-api-ss4xs2.azurewebsites.net/
   ```

3. **Firewall/NSG Blocking Access**
   - Check if your IP is allowed

   ```bash
   # Get your public IP
   curl -s https://api.ipify.org
   
   # Check firewall rules
   az webapp config access-restriction show \
     --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01
   ```

---

### Issue: High Failure Rate (50-90%)

**Symptoms:**

```bash
Results:
  Successful:        523 (52%)
  Failed:            477 (48%)
  Avg Response Time: 2,345ms
❌ FAIL
```

**Possible Causes:**

1. **Resource Exhaustion**

   ```bash
   # Check CPU and Memory
   az monitor metrics list \
     --resource /subscriptions/.../app-saifv2-api-ss4xs2 \
     --metric "CpuPercentage,MemoryPercentage" \
     --start-time 2025-11-24T14:00:00Z
   ```

   **Solution:** Scale up App Service Plan

   ```bash
   az appservice plan update \
     --name asp-saif-ss4xs2 \
     --resource-group rg-s05-validation-swc01 \
     --sku P2v3
   ```

2. **Database Throttling**
   - Check SQL Database DTU usage

   ```bash
   az sql db show \
     --name sqldb-saif \
     --server sql-saif-ss4xs2 \
     --resource-group rg-s05-validation-swc01 \
     --query "currentServiceObjectiveName"
   ```

3. **Container Cold Start**
   - Wait longer after deployment

   ```bash
   # Wait 90 seconds instead of 60
   sleep 90
   ```

---

### Issue: "curl: command not found"

**Symptoms:**

```bash
$ ./quick-load-test.sh 30 20
./quick-load-test.sh: line 15: curl: command not found
```

**Solution:**

**Ubuntu/Debian:**

```bash
sudo apt-get update && sudo apt-get install -y curl bc
```

**macOS:**

```bash
brew install curl
```

**Windows (WSL2):**

```bash
sudo apt update && sudo apt install curl bc
```

**Alpine Linux:**

```bash
apk add --no-cache curl bc
```

---

## API Endpoint Errors

### Issue: HTTP 403 Forbidden

**Symptoms:**

```bash
$ curl -I https://app-saifv2-api-ss4xs2.azurewebsites.net/
HTTP/2 403
```

**Possible Causes:**

1. **Access Restrictions Enabled**

   ```bash
   # Check access restrictions
   az webapp config access-restriction show \
     --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01
   ```

   **Solution:** Add your IP to allow list

   ```bash
   az webapp config access-restriction add \
     --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01 \
     --rule-name "DevOps-Team" \
     --action Allow \
     --ip-address YOUR.IP.ADDRESS/32 \
     --priority 100
   ```

2. **Authentication Required**
   - Check if API requires authentication

   ```bash
   # Test with authentication header
   curl -H "Authorization: Bearer $TOKEN" \
     https://app-saifv2-api-ss4xs2.azurewebsites.net/
   ```

---

### Issue: HTTP 404 Not Found

**Symptoms:**

```bash
$ curl -I https://app-saifv2-api-ss4xs2.azurewebsites.net/api/version
HTTP/2 404
```

**Possible Causes:**

1. **Wrong Endpoint Path**
   - List available endpoints

   ```bash
   curl -s https://app-saifv2-api-ss4xs2.azurewebsites.net/ | jq
   ```

2. **Container Not Running**

   ```bash
   # Check container logs
   az webapp log tail \
     --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01
   ```

3. **Application Not Deployed**

   ```bash
   # Check deployment status
   az webapp deployment list \
     --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01
   ```

---

### Issue: HTTP 429 Too Many Requests

**Symptoms:**

```bash
HTTP/2 429
{
  "error": "Rate limit exceeded"
}
```

**This is EXPECTED** during load testing. App Service has built-in rate limiting.

**If excessive (> 5%):**

- Reduce concurrent requests: `./quick-load-test.sh 30 10`
- Increase App Service Plan tier
- Implement request throttling in application

---

### Issue: HTTP 500 Internal Server Error

**Symptoms:**

```bash
$ curl https://app-saifv2-api-ss4xs2.azurewebsites.net/
HTTP/2 500
{
  "error": "Internal server error"
}
```

**Diagnostic Steps:**

1. **Check Application Logs**

   ```bash
   az webapp log tail \
     --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01
   ```

2. **Check Application Insights**

   ```bash
   az monitor app-insights query \
     --app app-saifv2-api-insights \
     --analytics-query "exceptions | where timestamp > ago(1h)"
   ```

3. **Test Database Connection**

   ```bash
   curl https://app-saifv2-api-ss4xs2.azurewebsites.net/api/sqlwhoami
   ```

**Common Solutions:**

- Database connection string incorrect
- Managed identity not granted SQL permissions
- Application code error (check logs)

---

### Issue: HTTP 503 Service Unavailable

**Symptoms:**

```bash
HTTP/2 503
```

**Possible Causes:**

1. **Container Starting (Cold Start)**
   - **Expected** - Wait 30-60 seconds

   ```bash
   sleep 60
   curl https://app-saifv2-api-ss4xs2.azurewebsites.net/
   ```

2. **App Service Crashed**

   ```bash
   # Restart app service
   az webapp restart \
     --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01
   ```

3. **Health Check Failing**

   ```bash
   # Check health check configuration
   az webapp config show \
     --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01 \
     --query "healthCheckPath"
   ```

---

## Performance Issues

### Issue: Slow Response Times (> 1 second)

**Symptoms:**

```bash
Results:
  Avg Response Time: 1,245ms
⚠️ WARNING - Performance degraded
```

**Diagnostic Steps:**

1. **Check Application Insights**

   ```kusto
   requests
   | where timestamp > ago(1h)
   | summarize avg(duration), percentiles(duration, 50, 95, 99)
   ```

2. **Identify Slow Endpoints**

   ```bash
   for endpoint in "/" "/api/version" "/api/whoami" "/api/sourceip"; do
     echo "Testing: $endpoint"
     curl -s -w "Time: %{time_total}s\n" \
       -o /dev/null \
       "https://app-saifv2-api-ss4xs2.azurewebsites.net$endpoint"
   done
   ```

3. **Check Database Performance**

   ```bash
   # Check SQL Database DTU
   az sql db show-usage \
     --name sqldb-saif \
     --server sql-saif-ss4xs2 \
     --resource-group rg-s05-validation-swc01
   ```

**Solutions:**

1. **Enable Always On**

   ```bash
   az webapp config set \
     --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01 \
     --always-on true
   ```

2. **Scale Up App Service Plan**

   ```bash
   az appservice plan update \
     --name asp-saif-ss4xs2 \
     --resource-group rg-s05-validation-swc01 \
     --sku P2v3
   ```

3. **Enable Caching**
   - Add response caching in application code

---

### Issue: Response Time Spikes

**Symptoms:**

- P95: 200ms
- P99: 1,500ms
- Max: 5,000ms

**Possible Causes:**

1. **Garbage Collection**
   - Monitor memory usage
   - Increase container memory

2. **Database Query Timeouts**

   ```kusto
   // Query slow SQL requests
   dependencies
   | where type == "SQL"
   | where duration > 1000
   | summarize count() by target
   ```

3. **Network Latency**
   - Test from different regions

   ```bash
   # Test from Azure VM in different region
   curl -s -w "Time: %{time_total}s\n" \
     -o /dev/null \
     https://app-saifv2-api-ss4xs2.azurewebsites.net/
   ```

---

## Database Connectivity

### Issue: "Login failed for user"

**Symptoms:**

```bash
$ curl https://app-saifv2-api-ss4xs2.azurewebsites.net/api/sqlwhoami
{
  "error": "Login failed for user '<token-identified principal>'"
}
```

**Solution Steps:**

1. **Verify Managed Identity Exists**

   ```bash
   az webapp identity show \
     --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01
   ```

2. **Grant SQL Permissions**

   ```sql
   -- Run this in SQL Database via Azure Portal Query Editor
   CREATE USER [app-saifv2-api-ss4xs2] FROM EXTERNAL PROVIDER;
   ALTER ROLE db_datareader ADD MEMBER [app-saifv2-api-ss4xs2];
   ALTER ROLE db_datawriter ADD MEMBER [app-saifv2-api-ss4xs2];
   ```

3. **Verify Firewall Rules**

   ```bash
   az sql server firewall-rule list \
     --server sql-saif-ss4xs2 \
     --resource-group rg-s05-validation-swc01
   ```

4. **Enable "Allow Azure Services"**

   ```bash
   az sql server firewall-rule create \
     --server sql-saif-ss4xs2 \
     --resource-group rg-s05-validation-swc01 \
     --name AllowAllAzureIps \
     --start-ip-address 0.0.0.0 \
     --end-ip-address 0.0.0.0
   ```

---

### Issue: Database Connection Timeout

**Symptoms:**

```bash
{
  "error": "Timeout expired. The timeout period elapsed prior to obtaining a connection."
}
```

**Solutions:**

1. **Check Connection String**

   ```bash
   az webapp config connection-string list \
     --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01
   ```

2. **Verify SQL Server is Running**

   ```bash
   az sql server show \
     --name sql-saif-ss4xs2 \
     --resource-group rg-s05-validation-swc01 \
     --query "state"
   ```

3. **Test SQL Connectivity**

   ```bash
   # From within App Service
   az webapp ssh --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01
   
   # Inside container
   nc -zv sql-saif-ss4xs2.database.windows.net 1433
   ```

---

## Container Issues

### Issue: "ImagePullBackOff"

**Symptoms:**

```bash
az webapp log tail shows:
Failed to pull image "acrsaifss4xs2.azurecr.io/saifv2/api:latest": 
Error: ImagePullBackOff
```

**Solution Steps:**

1. **Verify Image Exists**

   ```bash
   az acr repository show \
     --name acrsaifss4xs2 \
     --repository saifv2/api
   ```

2. **Check Managed Identity AcrPull Role**

   ```bash
   az role assignment list \
     --assignee $(az webapp identity show \
       --name app-saifv2-api-ss4xs2 \
       --resource-group rg-s05-validation-swc01 \
       --query principalId -o tsv) \
     --scope /subscriptions/.../acrsaifss4xs2
   ```

3. **Grant AcrPull Permission**

   ```bash
   az role assignment create \
     --assignee $(az webapp identity show \
       --name app-saifv2-api-ss4xs2 \
       --resource-group rg-s05-validation-swc01 \
       --query principalId -o tsv) \
     --role AcrPull \
     --scope /subscriptions/.../acrsaifss4xs2
   ```

4. **Rebuild and Push Image**

   ```bash
   cd app/
   az acr build --registry acrsaifss4xs2 \
     --image saifv2/api:latest .
   ```

---

### Issue: Container Keeps Restarting

**Symptoms:**

```bash
Container crashes every few seconds
```

**Diagnostic Steps:**

1. **Check Container Logs**

   ```bash
   az webapp log tail \
     --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01
   ```

2. **Check Startup Command**

   ```bash
   az webapp config show \
     --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01 \
     --query "appCommandLine"
   ```

3. **Verify Environment Variables**

   ```bash
   az webapp config appsettings list \
     --name app-saifv2-api-ss4xs2 \
     --resource-group rg-s05-validation-swc01
   ```

---

## CI/CD Pipeline Failures

### Issue: "Script not executable"

**Symptoms:**

```bash
bash: ./quick-load-test.sh: Permission denied
```

**Solution:**

```bash
chmod +x validation/load-testing/quick-load-test.sh
# Then run the script
./quick-load-test.sh 30 20
```

---

### Issue: Pipeline Timeout

**Symptoms:**

```
Task 'Run Load Test' exceeded timeout of 5 minutes
```

**Solutions:**

1. **Increase Timeout**

   ```yaml
   # Azure DevOps
   - task: Bash@3
     timeoutInMinutes: 10  # Increase from 5 to 10
   ```

2. **Reduce Test Duration**

   ```bash
   # Use shorter test for CI/CD
   ./quick-load-test.sh 15 10  # Instead of 30 20
   ```

---

### Issue: "az: command not found"

**Symptoms:**

```bash
./deploy.ps1: az: command not found
```

**Solution:**

Use an image with Azure CLI pre-installed:

```yaml
# GitHub Actions
- uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}

# Azure DevOps
- task: AzureCLI@2
  inputs:
    azureSubscription: 'Azure-Connection'
```

---

## Diagnostic Commands

### Quick Health Check

```bash
#!/bin/bash
# health-check.sh

API_URL="https://app-saifv2-api-ss4xs2.azurewebsites.net"
RG="rg-s05-validation-swc01"

echo "=== S05 Service Health Check ==="
echo ""

# 1. Check App Service State
echo "1. App Service Status:"
az webapp show --name app-saifv2-api-ss4xs2 --resource-group $RG \
  --query "{name:name, state:state, hostNames:hostNames}" -o table

# 2. Check API Endpoint
echo ""
echo "2. API Endpoint Test:"
curl -s -w "\nHTTP Status: %{http_code}\nResponse Time: %{time_total}s\n" \
  -o /dev/null "$API_URL/"

# 3. Check Database Connectivity
echo ""
echo "3. Database Connectivity:"
curl -s "$API_URL/api/sqlwhoami" | jq -r '.status // "FAIL"'

# 4. Check Container Status
echo ""
echo "4. Container Logs (last 10 lines):"
az webapp log tail --name app-saifv2-api-ss4xs2 --resource-group $RG \
  --provider application | tail -10

echo ""
echo "=== Health Check Complete ==="
```

### Performance Analysis

```bash
#!/bin/bash
# performance-check.sh

API_URL="https://app-saifv2-api-ss4xs2.azurewebsites.net"

echo "=== Performance Analysis ==="

for endpoint in "/" "/api/version" "/api/whoami" "/api/sourceip"; do
  echo ""
  echo "Endpoint: $endpoint"
  
  # Test 10 times
  times=()
  for i in {1..10}; do
    time=$(curl -s -w "%{time_total}" -o /dev/null "$API_URL$endpoint")
    times+=($time)
  done
  
  # Calculate average
  total=0
  for t in "${times[@]}"; do
    total=$(echo "$total + $t" | bc)
  done
  avg=$(echo "scale=3; $total / 10" | bc)
  
  echo "Average Response Time: ${avg}s"
done
```

---

## Getting Help

### Support Channels

1. **GitHub Issues**: [repo]/issues
2. **Slack**: #devops-support
3. **Email**: devops-team@example.com

### Useful Resources

- [Azure App Service Troubleshooting](https://learn.microsoft.com/azure/app-service/troubleshoot)
- [Azure SQL Database Troubleshooting](https://learn.microsoft.com/azure/sql-database/troubleshoot-common-errors)
- [Container Registry Troubleshooting](https://learn.microsoft.com/azure/container-registry/container-registry-troubleshoot)

---

**Last Updated**: November 24, 2025  
**Version**: 1.0  
**Maintainer**: DevOps Team
