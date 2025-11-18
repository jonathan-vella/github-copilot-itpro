<#
.SYNOPSIS
    Automated test runner for GitHub Copilot Custom Agents
.DESCRIPTION
    Runs test scenarios against custom agents and validates outputs.
    Compares actual outputs with expected outputs and generates test reports.
.PARAMETER Agent
    Which agent to test: adr-generator, azure-architect, bicep-plan, bicep-implement, or all
.PARAMETER Scenario
    Specific test scenario to run (optional)
.PARAMETER TestType
    Type of test to run: functional, quality, integration, regression, or all
.PARAMETER OutputPath
    Path to save test results (default: .\test-results\)
.PARAMETER Baseline
    Run in baseline mode (saves outputs as expected results)
.EXAMPLE
    .\Run-AgentTests.ps1 -Agent all -Verbose
.EXAMPLE
    .\Run-AgentTests.ps1 -Agent azure-architect -Scenario "basic-waf"
.EXAMPLE
    .\Run-AgentTests.ps1 -TestType regression
.NOTES
    Version: 1.0
    Author: GitHub Copilot IT Pro Team
    Last Updated: 2025-11-18
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('adr-generator', 'azure-architect', 'bicep-plan', 'bicep-implement', 'all')]
    [string]$Agent = 'all',
    
    [Parameter(Mandatory = $false)]
    [string]$Scenario,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('functional', 'quality', 'integration', 'regression', 'all')]
    [string]$TestType = 'all',
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = '.\test-results',
    
    [Parameter(Mandatory = $false)]
    [switch]$Baseline
)

#Requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ============================================================================
# Configuration
# ============================================================================

$script:TestRoot = $PSScriptRoot
$script:TestCasesPath = Join-Path $TestRoot 'test-cases'
$script:ExpectedOutputsPath = Join-Path $TestRoot 'expected-outputs'
$script:ActualOutputsPath = Join-Path $TestRoot 'actual-outputs'
$script:TestScenariosPath = Join-Path $TestRoot 'test-scenarios'

# Test results
$script:TestResults = @{
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
    SkippedTests = 0
    StartTime = Get-Date
    EndTime = $null
    Tests = @()
}

# ============================================================================
# Helper Functions
# ============================================================================

function Write-TestHeader {
    param([string]$Message)
    
    Write-Host ""
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host ""
}

function Write-TestResult {
    param(
        [string]$TestName,
        [ValidateSet('Pass', 'Fail', 'Skip')]
        [string]$Result,
        [string]$Message
    )
    
    $color = switch ($Result) {
        'Pass' { 'Green' }
        'Fail' { 'Red' }
        'Skip' { 'Yellow' }
    }
    
    $icon = switch ($Result) {
        'Pass' { '✓' }
        'Fail' { '✗' }
        'Skip' { '○' }
    }
    
    Write-Host "  $icon " -ForegroundColor $color -NoNewline
    Write-Host "$TestName " -NoNewline
    if ($Message) {
        Write-Host "- $Message" -ForegroundColor Gray
    } else {
        Write-Host ""
    }
}

function Initialize-TestEnvironment {
    [CmdletBinding()]
    param()
    
    Write-Verbose "Initializing test environment..."
    
    # Create directories if they don't exist
    $directories = @(
        $script:TestCasesPath,
        $script:ExpectedOutputsPath,
        $script:ActualOutputsPath,
        $script:TestScenariosPath,
        $OutputPath
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            Write-Verbose "Creating directory: $dir"
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
        }
    }
    
    # Create agent-specific output directories
    $agents = @('adr-generator', 'azure-architect', 'bicep-plan', 'bicep-implement')
    foreach ($agent in $agents) {
        $expectedDir = Join-Path $script:ExpectedOutputsPath $agent
        $actualDir = Join-Path $script:ActualOutputsPath $agent
        
        if (-not (Test-Path $expectedDir)) {
            New-Item -Path $expectedDir -ItemType Directory -Force | Out-Null
        }
        if (-not (Test-Path $actualDir)) {
            New-Item -Path $actualDir -ItemType Directory -Force | Out-Null
        }
    }
}

function Get-TestCases {
    [CmdletBinding()]
    param(
        [string]$AgentName
    )
    
    $testFile = Join-Path $script:TestCasesPath "$AgentName-tests.md"
    
    if (-not (Test-Path $testFile)) {
        Write-Warning "Test file not found: $testFile"
        return @()
    }
    
    Write-Verbose "Loading test cases from: $testFile"
    
    # Parse test file (simplified - would need full markdown parser for production)
    $content = Get-Content $testFile -Raw
    
    # Extract test sections (this is a simplified parser)
    $tests = @()
    $pattern = '## (Test \d+): (.+?)(?=## Test \d+:|## Regression Tests|$)'
    $matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    foreach ($match in $matches) {
        $testName = $match.Groups[1].Value.Trim()
        $testContent = $match.Groups[2].Value.Trim()
        
        $tests += @{
            Name = $testName
            Content = $testContent
            Agent = $AgentName
        }
    }
    
    return $tests
}

function Test-AgentOutput {
    [CmdletBinding()]
    param(
        [hashtable]$TestCase,
        [string]$ActualOutput
    )
    
    Write-Verbose "Validating output for: $($TestCase.Name)"
    
    $validations = @()
    
    # Basic validation: output is not empty
    if ([string]::IsNullOrWhiteSpace($ActualOutput)) {
        $validations += @{
            Check = "Output not empty"
            Result = $false
            Message = "Agent produced no output"
        }
        return $validations
    }
    
    $validations += @{
        Check = "Output not empty"
        Result = $true
        Message = "Output received ($(($ActualOutput -split "`n").Count) lines)"
    }
    
    # Agent-specific validations
    switch ($TestCase.Agent) {
        'azure-architect' {
            # Check for WAF pillar mentions
            $pillars = @('Security', 'Reliability', 'Performance', 'Cost', 'Operational')
            $foundPillars = 0
            foreach ($pillar in $pillars) {
                if ($ActualOutput -match $pillar) {
                    $foundPillars++
                }
            }
            
            $validations += @{
                Check = "WAF pillars mentioned"
                Result = ($foundPillars -ge 4)
                Message = "Found $foundPillars/5 WAF pillars"
            }
            
            # Check for scoring pattern (X/10)
            $hasScoring = $ActualOutput -match '\d+/10'
            $validations += @{
                Check = "Scoring included"
                Result = $hasScoring
                Message = if ($hasScoring) { "Scoring pattern found" } else { "No scoring pattern" }
            }
            
            # Check for cost estimation
            $hasCost = $ActualOutput -match '\$\d+' -or $ActualOutput -match 'cost|Cost|COST'
            $validations += @{
                Check = "Cost information"
                Result = $hasCost
                Message = if ($hasCost) { "Cost information found" } else { "No cost information" }
            }
        }
        
        'bicep-plan' {
            # Check for Mermaid diagram
            $hasMermaid = $ActualOutput -match '```mermaid'
            $validations += @{
                Check = "Mermaid diagram present"
                Result = $hasMermaid
                Message = if ($hasMermaid) { "Mermaid diagram found" } else { "No Mermaid diagram" }
            }
            
            # Check for cost table
            $hasCostTable = $ActualOutput -match 'Monthly Cost|Est\. Cost|Estimated Cost'
            $validations += @{
                Check = "Cost estimation table"
                Result = $hasCostTable
                Message = if ($hasCostTable) { "Cost table found" } else { "No cost table" }
            }
            
            # Check for testing strategy
            $hasTestStrategy = $ActualOutput -match 'Test|Validation|Rollback'
            $validations += @{
                Check = "Testing strategy"
                Result = $hasTestStrategy
                Message = if ($hasTestStrategy) { "Testing content found" } else { "No testing strategy" }
            }
        }
        
        'bicep-implement' {
            # Check for Bicep code
            $hasBicepCode = $ActualOutput -match 'param |resource |module |output '
            $validations += @{
                Check = "Bicep code present"
                Result = $hasBicepCode
                Message = if ($hasBicepCode) { "Bicep syntax found" } else { "No Bicep code" }
            }
            
            # Check for tags
            $hasTags = $ActualOutput -match 'tags:'
            $validations += @{
                Check = "Resource tagging"
                Result = $hasTags
                Message = if ($hasTags) { "Tags found" } else { "No tags" }
            }
        }
        
        'adr-generator' {
            # Check for ADR sections
            $sections = @('Context', 'Decision', 'Consequences', 'Alternatives')
            $foundSections = 0
            foreach ($section in $sections) {
                if ($ActualOutput -match $section) {
                    $foundSections++
                }
            }
            
            $validations += @{
                Check = "ADR sections present"
                Result = ($foundSections -ge 3)
                Message = "Found $foundSections/4 required sections"
            }
        }
    }
    
    return $validations
}

function Invoke-TestRun {
    [CmdletBinding()]
    param(
        [string[]]$AgentsToTest
    )
    
    Write-TestHeader "Starting Test Run"
    Write-Host "Agents to test: $($AgentsToTest -join ', ')" -ForegroundColor White
    Write-Host "Test type: $TestType" -ForegroundColor White
    Write-Host "Output path: $OutputPath" -ForegroundColor White
    Write-Host ""
    
    foreach ($agentName in $AgentsToTest) {
        Write-TestHeader "Testing Agent: $agentName"
        
        $testCases = Get-TestCases -AgentName $agentName
        
        if ($testCases.Count -eq 0) {
            Write-Warning "No test cases found for $agentName"
            continue
        }
        
        Write-Host "Found $($testCases.Count) test cases" -ForegroundColor White
        Write-Host ""
        
        foreach ($testCase in $testCases) {
            $script:TestResults.TotalTests++
            
            $testName = "$agentName - $($testCase.Name)"
            
            # In baseline mode, this would be manual
            # For automated testing, we'd need integration with Copilot API
            Write-Host "Test: $($testCase.Name)" -ForegroundColor White
            Write-Host "Status: Manual execution required" -ForegroundColor Yellow
            Write-Host "Instructions:" -ForegroundColor Gray
            Write-Host "  1. Press Ctrl+Shift+A and select '$agentName'" -ForegroundColor Gray
            Write-Host "  2. Use prompt from test case" -ForegroundColor Gray
            Write-Host "  3. Save output to: $script:ActualOutputsPath\$agentName\$($testCase.Name).md" -ForegroundColor Gray
            Write-Host ""
            
            $script:TestResults.SkippedTests++
            $script:TestResults.Tests += @{
                Name = $testName
                Result = 'Skip'
                Message = 'Manual execution required'
                Timestamp = Get-Date
            }
        }
    }
}

function Export-TestReport {
    [CmdletBinding()]
    param()
    
    $script:TestResults.EndTime = Get-Date
    $duration = $script:TestResults.EndTime - $script:TestResults.StartTime
    
    Write-TestHeader "Test Run Summary"
    
    Write-Host "Total Tests:   $($script:TestResults.TotalTests)" -ForegroundColor White
    Write-Host "Passed:        " -NoNewline
    Write-Host "$($script:TestResults.PassedTests)" -ForegroundColor Green
    Write-Host "Failed:        " -NoNewline
    Write-Host "$($script:TestResults.FailedTests)" -ForegroundColor Red
    Write-Host "Skipped:       " -NoNewline
    Write-Host "$($script:TestResults.SkippedTests)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Duration:      $($duration.ToString('mm\:ss'))" -ForegroundColor White
    Write-Host ""
    
    # Calculate pass rate
    $totalExecuted = $script:TestResults.PassedTests + $script:TestResults.FailedTests
    if ($totalExecuted -gt 0) {
        $passRate = [math]::Round(($script:TestResults.PassedTests / $totalExecuted) * 100, 1)
        Write-Host "Pass Rate:     $passRate%" -ForegroundColor $(if ($passRate -ge 90) { 'Green' } elseif ($passRate -ge 70) { 'Yellow' } else { 'Red' })
    }
    
    # Save JSON report
    $reportPath = Join-Path $OutputPath "test-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $script:TestResults | ConvertTo-Json -Depth 10 | Out-File $reportPath -Encoding utf8
    
    Write-Host ""
    Write-Host "Report saved to: $reportPath" -ForegroundColor Cyan
}

# ============================================================================
# Main Execution
# ============================================================================

try {
    Write-TestHeader "GitHub Copilot Custom Agent Test Runner"
    
    # Initialize environment
    Initialize-TestEnvironment
    
    # Determine which agents to test
    $agentsToTest = if ($Agent -eq 'all') {
        @('adr-generator', 'azure-architect', 'bicep-plan', 'bicep-implement')
    } else {
        @($Agent)
    }
    
    # Run tests
    Invoke-TestRun -AgentsToTest $agentsToTest
    
    # Export report
    Export-TestReport
    
    Write-Host ""
    Write-Host "NOTE: " -ForegroundColor Yellow -NoNewline
    Write-Host "This script currently requires manual test execution." -ForegroundColor White
    Write-Host "Future versions will integrate with GitHub Copilot API for automation." -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Error "Test run failed: $_"
    Write-Error $_.ScriptStackTrace
    exit 1
}
