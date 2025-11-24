<#
.SYNOPSIS
    Executes Azure Load Testing for S05 Service Validation

.DESCRIPTION
    This script creates/updates an Azure Load Testing resource and executes
    load tests against the deployed SAIF API. Supports baseline, stress,
    and spike test scenarios.

.PARAMETER ResourceGroupName
    Name of the resource group containing the load testing resource

.PARAMETER Location
    Azure region for the load test resource (default: swedencentral)

.PARAMETER TestName
    Name of the test to run (baseline, stress, spike, endurance)

.PARAMETER ApiUrl
    URL of the API to test (if not provided, will auto-detect from deployment)

.PARAMETER ConcurrentUsers
    Number of concurrent users (default: 100)

.PARAMETER Duration
    Test duration in seconds (default: 300)

.PARAMETER WhatIf
    Show what would be executed without actually running the test

.EXAMPLE
    .\Run-LoadTest.ps1 -TestName baseline
    Runs baseline load test with default settings

.EXAMPLE
    .\Run-LoadTest.ps1 -TestName stress -ConcurrentUsers 500 -Duration 600
    Runs stress test with 500 users for 10 minutes
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [ValidateSet('swedencentral', 'germanywestcentral', 'westeurope', 'northeurope')]
    [string]$Location = 'swedencentral',

    [Parameter(Mandatory = $false)]
    [ValidateSet('baseline', 'stress', 'spike', 'endurance')]
    [string]$TestName = 'baseline',

    [Parameter(Mandatory = $false)]
    [string]$ApiUrl,

    [Parameter(Mandatory = $false)]
    [int]$ConcurrentUsers = 100,

    [Parameter(Mandatory = $false)]
    [int]$Duration = 300
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

#region Helper Functions

function Write-Banner {
    param([string]$Message)
    Write-Host "`n$('=' * 80)" -ForegroundColor Cyan
    Write-Host " $Message" -ForegroundColor Cyan
    Write-Host "$('=' * 80)`n" -ForegroundColor Cyan
}

function Get-DeploymentInfo {
    Write-Host "🔍 Detecting deployment information..." -ForegroundColor Cyan
    
    # Find resource group with S05 deployment
    $rgPattern = "rg-s05-validation-*"
    $rgs = az group list --query "[?starts_with(name, 'rg-s05-validation-')].name" -o tsv
    
    if (-not $rgs) {
        throw "No S05 deployment found. Please deploy infrastructure first."
    }
    
    $script:ResourceGroupName = $rgs[0]
    Write-Host "✓ Found resource group: $ResourceGroupName" -ForegroundColor Green
    
    # Get API URL from App Service
    $apiAppName = az webapp list --resource-group $ResourceGroupName `
        --query "[?contains(name, 'api')].defaultHostName" -o tsv
    
    if (-not $apiAppName) {
        throw "Could not find API App Service in resource group"
    }
    
    $script:ApiUrl = "https://$apiAppName"
    Write-Host "✓ API URL: $ApiUrl" -ForegroundColor Green
}

function New-LoadTestResource {
    param(
        [string]$ResourceGroup,
        [string]$Location
    )
    
    $testResourceName = "lt-s05-validation"
    
    Write-Host "🔨 Checking for existing Load Testing resource..." -ForegroundColor Cyan
    
    $existing = az load test list --resource-group $ResourceGroup `
        --query "[?name=='$testResourceName'].name" -o tsv 2>$null
    
    if ($existing) {
        Write-Host "✓ Load Testing resource '$testResourceName' already exists" -ForegroundColor Green
        return $testResourceName
    }
    
    Write-Host "📦 Creating Load Testing resource '$testResourceName'..." -ForegroundColor Yellow
    
    if ($PSCmdlet.ShouldProcess($testResourceName, "Create Load Testing resource")) {
        az load test create `
            --name $testResourceName `
            --resource-group $ResourceGroup `
            --location $Location `
            --tags "Project=S05-Service-Validation" "Environment=test" | Out-Null
        
        Write-Host "✓ Load Testing resource created" -ForegroundColor Green
    }
    
    return $testResourceName
}

function Start-LoadTest {
    param(
        [string]$ResourceGroup,
        [string]$TestResourceName,
        [string]$TestName,
        [string]$ApiUrl,
        [int]$Users,
        [int]$Duration
    )
    
    Write-Banner "Starting Load Test: $TestName"
    
    $scriptPath = $PSScriptRoot
    $testId = "s05-$TestName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $configFile = Join-Path $scriptPath "load-test-config.yaml"
    $jmxFile = Join-Path $scriptPath "load-test.jmx"
    
    # Verify files exist
    if (-not (Test-Path $configFile)) {
        throw "Config file not found: $configFile"
    }
    if (-not (Test-Path $jmxFile)) {
        throw "JMX file not found: $jmxFile"
    }
    
    Write-Host "📁 Test configuration: $configFile" -ForegroundColor Cyan
    Write-Host "📁 JMeter plan: $jmxFile" -ForegroundColor Cyan
    Write-Host "🎯 Target API: $ApiUrl" -ForegroundColor Cyan
    Write-Host "👥 Concurrent users: $Users" -ForegroundColor Cyan
    Write-Host "⏱️  Duration: $Duration seconds" -ForegroundColor Cyan
    
    if (-not $PSCmdlet.ShouldProcess($testId, "Execute load test")) {
        Write-Host "WhatIf: Would execute load test" -ForegroundColor Yellow
        return $null
    }
    
    # Create test
    Write-Host "`n🚀 Creating test..." -ForegroundColor Yellow
    az load test create `
        --test-id $testId `
        --load-test-resource $TestResourceName `
        --resource-group $ResourceGroup `
        --display-name "S05 $TestName Test" `
        --description "$TestName load test with $Users users for $Duration seconds" `
        --test-plan $jmxFile `
        --engine-instances 1 `
        --env "API_URL=$($ApiUrl -replace 'https://','')" `
        --env "CONCURRENT_USERS=$Users" `
        --env "TEST_DURATION=$Duration" `
        --env "RAMP_UP_TIME=30" | Out-Null
    
    # Run test
    Write-Host "▶️  Starting test execution..." -ForegroundColor Yellow
    $runId = "run-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    az load test-run create `
        --test-id $testId `
        --test-run-id $runId `
        --load-test-resource $TestResourceName `
        --resource-group $ResourceGroup `
        --display-name "S05 $TestName - $(Get-Date -Format 'yyyy-MM-dd HH:mm')" | Out-Null
    
    # Poll for completion
    Write-Host "⏳ Waiting for test to complete..." -ForegroundColor Cyan
    
    $maxWaitTime = $Duration + 300  # Test duration + 5 minutes buffer
    $startTime = Get-Date
    $completed = $false
    
    while (-not $completed -and ((Get-Date) - $startTime).TotalSeconds -lt $maxWaitTime) {
        Start-Sleep -Seconds 15
        
        $status = az load test-run show `
            --test-run-id $runId `
            --load-test-resource $TestResourceName `
            --resource-group $ResourceGroup `
            --query "status" -o tsv
        
        Write-Host "  Status: $status" -ForegroundColor Gray
        
        if ($status -in @('DONE', 'FAILED', 'CANCELLED')) {
            $completed = $true
        }
    }
    
    if (-not $completed) {
        Write-Warning "Test did not complete within expected time"
        return $null
    }
    
    return @{
        TestId = $testId
        RunId  = $runId
        Status = $status
    }
}

function Get-TestResults {
    param(
        [string]$ResourceGroup,
        [string]$TestResourceName,
        [string]$RunId
    )
    
    Write-Banner "Test Results"
    
    $results = az load test-run show `
        --test-run-id $RunId `
        --load-test-resource $TestResourceName `
        --resource-group $ResourceGroup `
        --query "{status:status, startTime:startDateTime, endTime:endDateTime, virtualUsers:testRunStatistics.totalRequests, errors:testRunStatistics.errorPct, avgResponseTime:testRunStatistics.averageResponseTimeMs, p95ResponseTime:testRunStatistics.percentile95ResponseTimeMs}" `
        -o json | ConvertFrom-Json
    
    Write-Host "📊 Test Summary" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host "Status:              $($results.status)" -ForegroundColor $(if ($results.status -eq 'DONE') { 'Green' } else { 'Red' })
    Write-Host "Start Time:          $($results.startTime)"
    Write-Host "End Time:            $($results.endTime)"
    Write-Host "Total Requests:      $($results.virtualUsers)"
    Write-Host "Error Rate:          $([math]::Round($results.errors, 2))%"
    Write-Host "Avg Response Time:   $([math]::Round($results.avgResponseTime, 2)) ms"
    Write-Host "P95 Response Time:   $([math]::Round($results.p95ResponseTime, 2)) ms"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Gray
    
    # Check pass/fail criteria
    $passed = $true
    $failures = @()
    
    if ($results.errors -gt 1.0) {
        $passed = $false
        $failures += "Error rate ($([math]::Round($results.errors, 2))%) exceeds threshold (1%)"
    }
    
    if ($results.p95ResponseTime -gt 500) {
        $passed = $false
        $failures += "P95 response time ($([math]::Round($results.p95ResponseTime, 2)) ms) exceeds threshold (500 ms)"
    }
    
    if ($passed) {
        Write-Host "✅ TEST PASSED" -ForegroundColor Green
        return 0
    }
    else {
        Write-Host "❌ TEST FAILED" -ForegroundColor Red
        Write-Host "`nFailure Reasons:" -ForegroundColor Yellow
        $failures | ForEach-Object { Write-Host "  • $_" -ForegroundColor Yellow }
        return 1
    }
}

#endregion

#region Main Execution

try {
    Write-Banner "Azure Load Testing - S05 Service Validation"
    
    # Auto-detect deployment if not provided
    if (-not $ResourceGroupName -or -not $ApiUrl) {
        Get-DeploymentInfo
    }
    
    # Adjust parameters based on test type
    switch ($TestName) {
        'baseline' {
            $ConcurrentUsers = 100
            $Duration = 300  # 5 minutes
        }
        'stress' {
            $ConcurrentUsers = 500
            $Duration = 600  # 10 minutes
        }
        'spike' {
            $ConcurrentUsers = 500
            $Duration = 900  # 15 minutes with spike pattern
        }
        'endurance' {
            $ConcurrentUsers = 200
            $Duration = 1800  # 30 minutes
        }
    }
    
    # Create or get load testing resource
    $testResourceName = New-LoadTestResource -ResourceGroup $ResourceGroupName -Location $Location
    
    # Execute test
    $testRun = Start-LoadTest `
        -ResourceGroup $ResourceGroupName `
        -TestResourceName $testResourceName `
        -TestName $TestName `
        -ApiUrl $ApiUrl `
        -Users $ConcurrentUsers `
        -Duration $Duration
    
    if ($null -eq $testRun) {
        if ($WhatIfPreference) {
            exit 0
        }
        throw "Test execution failed"
    }
    
    # Get and display results
    $exitCode = Get-TestResults `
        -ResourceGroup $ResourceGroupName `
        -TestResourceName $testResourceName `
        -RunId $testRun.RunId
    
    exit $exitCode
    
}
catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}

#endregion
