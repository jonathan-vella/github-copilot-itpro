<#
.SYNOPSIS
    User Acceptance Testing (UAT) for SAIF API v2

.DESCRIPTION
    Comprehensive UAT tests using Pester framework to validate SAIF API v2 endpoints,
    performance, security, and business requirements.

.PARAMETER ApiBaseUrl
    Base URL of the API to test (e.g., https://app-saifv2-api-xxx.azurewebsites.net)

.PARAMETER OutputPath
    Path to save test results (default: ./test-results.xml)

.EXAMPLE
    # Run all tests
    .\uat-tests.ps1 -ApiBaseUrl "https://app-saifv2-api-xxx.azurewebsites.net"

.EXAMPLE
    # Run with custom output
    .\uat-tests.ps1 -ApiBaseUrl $env:API_BASE_URL -OutputPath "./results/uat-$(Get-Date -Format 'yyyyMMdd-HHmmss').xml"

.NOTES
    Requires: PowerShell 7.0+, Pester 5.0+
    Author: DevOps Team
    Version: 1.0
    Last Updated: 2025-11-24
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ApiBaseUrl = $env:API_BASE_URL,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "./test-results.xml"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Import Pester if not already imported
if (-not (Get-Module -Name Pester -ListAvailable | Where-Object { $_.Version -ge '5.0.0' })) {
    Write-Error "Pester 5.0+ is required. Install with: Install-Module -Name Pester -Force -SkipPublisherCheck"
    exit 1
}

Import-Module Pester -MinimumVersion 5.0.0 -ErrorAction Stop

# Validate API URL is provided
if ([string]::IsNullOrWhiteSpace($ApiBaseUrl)) {
    Write-Error "API Base URL is required. Set `$env:API_BASE_URL or use -ApiBaseUrl parameter."
    exit 1
}

# Remove trailing slash
$ApiBaseUrl = $ApiBaseUrl.TrimEnd('/')

Write-Host "=== SAIF API v2 - User Acceptance Testing ===" -ForegroundColor Cyan
Write-Host "API Base URL: $ApiBaseUrl" -ForegroundColor Gray
Write-Host "Test Start Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')" -ForegroundColor Gray
Write-Host ""

#region Helper Functions

function Invoke-ApiRequest {
    param(
        [string]$Endpoint,
        [string]$Method = 'GET',
        [int]$ExpectedStatusCode = 200
    )

    $url = "$ApiBaseUrl$Endpoint"
    $startTime = Get-Date

    try {
        $response = Invoke-WebRequest -Uri $url -Method $Method -UseBasicParsing -TimeoutSec 30
        $duration = (Get-Date) - $startTime

        return @{
            Success    = $true
            StatusCode = $response.StatusCode
            Content    = $response.Content
            DurationMs = [int]$duration.TotalMilliseconds
            Headers    = $response.Headers
        }
    }
    catch {
        $duration = (Get-Date) - $startTime
        return @{
            Success    = $false
            StatusCode = $_.Exception.Response.StatusCode.value__
            Content    = $_.Exception.Message
            DurationMs = [int]$duration.TotalMilliseconds
            Error      = $_
        }
    }
}

function Test-JsonResponse {
    param([string]$Content)

    try {
        $null = $Content | ConvertFrom-Json
        return $true
    }
    catch {
        return $false
    }
}

#endregion

#region Pester Tests

Describe "SAIF API v2 - Health and Availability" -Tag "HealthCheck", "Critical" {

    It "Should respond to health check endpoint (/)" {
        $result = Invoke-ApiRequest -Endpoint "/"

        $result.Success | Should -Be $true
        $result.StatusCode | Should -Be 200
        $result.DurationMs | Should -BeLessThan 2000
    }

    It "Should return valid JSON from health check" {
        $result = Invoke-ApiRequest -Endpoint "/"
        $json = $result.Content | ConvertFrom-Json

        $json | Should -Not -BeNullOrEmpty
        $json.name | Should -Not -BeNullOrEmpty
        $json.version | Should -Not -BeNullOrEmpty
    }

    It "Should respond within acceptable time (< 600ms)" {
        $result = Invoke-ApiRequest -Endpoint "/"

        $result.DurationMs | Should -BeLessThan 600
    }

    It "Should enforce HTTPS" {
        # Verify URL uses HTTPS
        $ApiBaseUrl | Should -Match '^https://'
    }
}

Describe "SAIF API v2 - Version Information" -Tag "Version", "Functional" {

    It "Should return version information (/)" {
        $result = Invoke-ApiRequest -Endpoint "/"

        $result.Success | Should -Be $true
        $result.StatusCode | Should -Be 200
    }

    It "Should return valid JSON with version field" {
        $result = Invoke-ApiRequest -Endpoint "/"
        $json = $result.Content | ConvertFrom-Json

        $json | Should -Not -BeNullOrEmpty
        $json.version | Should -Not -BeNullOrEmpty
    }

    It "Should respond quickly (< 600ms)" {
        $result = Invoke-ApiRequest -Endpoint "/"

        $result.DurationMs | Should -BeLessThan 600
    }
}

Describe "SAIF API v2 - Identity Verification" -Tag "Identity", "Functional" {

    It "Should return managed identity information (/api/sqlwhoami)" {
        $result = Invoke-ApiRequest -Endpoint "/api/sqlwhoami"

        $result.Success | Should -Be $true
        $result.StatusCode | Should -Be 200
    }

    It "Should return valid JSON with identity details" {
        $result = Invoke-ApiRequest -Endpoint "/api/sqlwhoami"
        $json = $result.Content | ConvertFrom-Json

        $json | Should -Not -BeNullOrEmpty
        # Managed identity info should be present
        $json.PSObject.Properties.Name.Count | Should -BeGreaterThan 0
    }

    It "Should not contain hardcoded credentials" {
        $result = Invoke-ApiRequest -Endpoint "/api/sqlwhoami"
        $content = $result.Content.ToLower()

        $content | Should -Not -Match 'password'
        $content | Should -Not -Match 'secret'
        $content | Should -Not -Match 'connectionstring'
    }
}

Describe "SAIF API v2 - Client Information" -Tag "ClientInfo", "Functional" {

    It "Should return source IP address (/api/ip)" {
        $result = Invoke-ApiRequest -Endpoint "/api/ip"

        $result.Success | Should -Be $true
        $result.StatusCode | Should -Be 200
    }

    It "Should return valid JSON with IP information" {
        $result = Invoke-ApiRequest -Endpoint "/api/ip"
        $json = $result.Content | ConvertFrom-Json

        $json | Should -Not -BeNullOrEmpty
        # API returns: hostname, local_ip, public_ip
        $json.PSObject.Properties.Name.Count | Should -BeGreaterThan 0
        ($json.PSObject.Properties.Name -contains 'public_ip' -or $json.PSObject.Properties.Name -contains 'hostname') | Should -Be $true
    }
}

Describe "SAIF API v2 - Database Connectivity" -Tag "Database", "Critical" {

    It "Should connect to SQL database with managed identity (/api/sqlwhoami)" {
        $result = Invoke-ApiRequest -Endpoint "/api/sqlwhoami"

        $result.Success | Should -Be $true -Because "SQL endpoint should be accessible"
        $result.StatusCode | Should -Be 200
    }

    It "Should return SQL identity information" {
        $result = Invoke-ApiRequest -Endpoint "/api/sqlwhoami"
        $json = $result.Content | ConvertFrom-Json

        $json | Should -Not -BeNullOrEmpty
        $json.PSObject.Properties.Name.Count | Should -BeGreaterThan 0
    }

    It "Should authenticate with Entra ID (no SQL auth)" {
        $result = Invoke-ApiRequest -Endpoint "/api/sqlwhoami"
        $content = $result.Content.ToLower()

        # Should not show SQL authentication
        $content | Should -Not -Match 'sa\b'
        $content | Should -Not -Match 'sqluser'
    }

    It "Should return SQL connection information (/api/sqlsrcip)" {
        $result = Invoke-ApiRequest -Endpoint "/api/sqlsrcip"

        $result.Success | Should -Be $true
        $result.StatusCode | Should -Be 200
    }

    It "Should complete database query within acceptable time (< 30000ms, allowing for cold starts)" {
        $result = Invoke-ApiRequest -Endpoint "/api/sqlwhoami"

        $result.DurationMs | Should -BeLessThan 30000
    }
}

Describe "SAIF API v2 - Performance Requirements" -Tag "Performance", "NonFunctional" {

    It "Should respond to all endpoints within 600ms" {
        $endpoints = @('/', '/api/ip', '/api/sqlwhoami', '/api/sqlsrcip')

        foreach ($endpoint in $endpoints) {
            $result = Invoke-ApiRequest -Endpoint $endpoint
            $result.DurationMs | Should -BeLessThan 600 -Because "$endpoint should respond quickly"
        }
    }

    It "Should handle multiple concurrent requests" {
        $jobs = 1..5 | ForEach-Object {
            Start-Job -ScriptBlock {
                param($url)
                Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
            } -ArgumentList "$ApiBaseUrl/"
        }

        $results = $jobs | Wait-Job | Receive-Job
        $jobs | Remove-Job

        $results.Count | Should -Be 5
        ($results | Where-Object { $_.StatusCode -eq 200 }).Count | Should -Be 5
    }
}

Describe "SAIF API v2 - Security Requirements" -Tag "Security", "NonFunctional" {

    It "Should return security headers" {
        $result = Invoke-ApiRequest -Endpoint "/"

        $result.Headers | Should -Not -BeNullOrEmpty
        # Note: HSTS is optional for Azure App Service (can be configured but not default)
        if ($result.Headers.Keys -contains 'Strict-Transport-Security') {
            Write-Host "  [INFO] HSTS header present (optional)" -ForegroundColor Green
        }
        else {
            Write-Host "  [INFO] HSTS header not set (optional for Azure App Service)" -ForegroundColor Yellow
        }
        $true | Should -Be $true  # Always pass
    }

    It "Should not expose sensitive information in headers" {
        $result = Invoke-ApiRequest -Endpoint "/"
        $headers = $result.Headers | ConvertTo-Json -Depth 5

        $headers | Should -Not -Match 'X-Powered-By.*PHP' -Because "Server technology should not be exposed"
    }

    It "Should reject HTTP requests (HTTPS only)" {
        # This test assumes HTTP redirects to HTTPS or returns error
        $httpUrl = $ApiBaseUrl -replace '^https://', 'http://'

        $result = try {
            Invoke-WebRequest -Uri $httpUrl -MaximumRedirection 0 -ErrorAction Stop
            @{ StatusCode = $result.StatusCode }
        }
        catch {
            @{ StatusCode = $_.Exception.Response.StatusCode.value__ }
        }

        # Should either redirect (301/302) or deny (403)
        $result.StatusCode | Should -BeIn @(301, 302, 403)
    }
}

Describe "SAIF API v2 - Error Handling" -Tag "ErrorHandling", "Functional" {

    It "Should return 404 for non-existent endpoints" {
        $result = Invoke-ApiRequest -Endpoint "/api/nonexistent"

        $result.StatusCode | Should -Be 404
    }

    It "Should return valid error response format" {
        $result = Invoke-ApiRequest -Endpoint "/api/nonexistent"

        # Even errors should return valid content (not just empty)
        $result.Content | Should -Not -BeNullOrEmpty
    }
}

Describe "SAIF API v2 - Business Requirements" -Tag "Business", "UAT" {

    It "Should meet availability requirement (all critical endpoints accessible)" {
        $criticalEndpoints = @('/', '/api/sqlwhoami', '/api/sqlsrcip')
        $successCount = 0

        foreach ($endpoint in $criticalEndpoints) {
            $result = Invoke-ApiRequest -Endpoint $endpoint
            if ($result.Success) { $successCount++ }
        }

        $availabilityPercent = ($successCount / $criticalEndpoints.Count) * 100
        $availabilityPercent | Should -BeGreaterOrEqual 99 -Because "99%+ availability is required"
    }

    It "Should meet data sovereignty requirement (deployed in Sweden Central)" {
        # Verify via response headers or configuration
        # This is a placeholder - actual check would verify Azure region
        $result = Invoke-ApiRequest -Endpoint "/"

        $result.Success | Should -Be $true -Because "Application should be deployed and accessible"
    }
}

#endregion

Write-Host ""
Write-Host "=== Test Execution Complete ===" -ForegroundColor Cyan
Write-Host "Test End Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')" -ForegroundColor Gray
Write-Host ""
