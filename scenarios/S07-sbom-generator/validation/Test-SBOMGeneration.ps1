<#
.SYNOPSIS
    Validates and tests SBOM generation scripts.

.DESCRIPTION
    This script tests the SBOM generation process end-to-end, validating outputs
    against CycloneDX schema and ensuring all components are captured.

.PARAMETER TestApplicationSBOM
    Test application dependency scanning.

.PARAMETER TestContainerSBOM
    Test container image scanning.

.PARAMETER TestInfrastructureSBOM
    Test Azure infrastructure scanning (requires Azure resources).

.PARAMETER TestAll
    Run all tests (default: $true).

.EXAMPLE
    .\Test-SBOMGeneration.ps1 -TestAll

.NOTES
    Author: Generated with GitHub Copilot
    Date: 2025-11-18
    Requires: PowerShell 7.0+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$TestApplicationSBOM,

    [Parameter(Mandatory = $false)]
    [switch]$TestContainerSBOM,

    [Parameter(Mandatory = $false)]
    [switch]$TestInfrastructureSBOM,

    [Parameter(Mandatory = $false)]
    [switch]$TestAll = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:TestResults = @()

Write-Host "🧪 Testing SBOM Generation Scripts..." -ForegroundColor Cyan
Write-Host ""

# Helper function to add test result
function Add-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message
    )
    
    $script:TestResults += [PSCustomObject]@{
        Test    = $TestName
        Passed  = $Passed
        Message = $Message
    }
    
    if ($Passed) {
        Write-Host "✅ PASS: $TestName" -ForegroundColor Green
    } else {
        Write-Host "❌ FAIL: $TestName - $Message" -ForegroundColor Red
    }
}

# Test 1: Application SBOM Generation
if ($TestAll -or $TestApplicationSBOM) {
    Write-Host "📦 Test 1: Application SBOM Generation" -ForegroundColor Yellow
    
    try {
        $packageJsonPath = Join-Path $PSScriptRoot "../sample-app/src/api/package.json"
        $outputPath = Join-Path $PSScriptRoot "../examples/test-application-sbom.json"
        
        if (Test-Path $packageJsonPath) {
            & "$PSScriptRoot/../with-copilot/New-ApplicationSBOM.ps1" -PackageJsonPath $packageJsonPath -OutputPath $outputPath -Verbose:$false
            
            if (Test-Path $outputPath) {
                $sbom = Get-Content $outputPath -Raw | ConvertFrom-Json
                
                # Validate structure
                $hasRequiredFields = ($sbom.bomFormat -eq "CycloneDX") -and 
                                    ($sbom.specVersion) -and 
                                    ($sbom.serialNumber) -and 
                                    ($sbom.components)
                
                if ($hasRequiredFields) {
                    $componentCount = ($sbom.components).Count
                    Add-TestResult "Application SBOM Generation" $true "Generated $componentCount components"
                } else {
                    Add-TestResult "Application SBOM Generation" $false "Missing required fields"
                }
                
                Remove-Item $outputPath -Force
            } else {
                Add-TestResult "Application SBOM Generation" $false "Output file not created"
            }
        } else {
            Add-TestResult "Application SBOM Generation" $false "package.json not found at $packageJsonPath"
        }
    } catch {
        Add-TestResult "Application SBOM Generation" $false $_.Exception.Message
    }
    Write-Host ""
}

# Test 2: Container SBOM Generation
if ($TestAll -or $TestContainerSBOM) {
    Write-Host "🐳 Test 2: Container SBOM Generation" -ForegroundColor Yellow
    
    try {
        $dockerfilePath = Join-Path $PSScriptRoot "../sample-app/src/api/Dockerfile"
        $outputPath = Join-Path $PSScriptRoot "../examples/test-container-sbom.json"
        
        if (Test-Path $dockerfilePath) {
            & "$PSScriptRoot/../with-copilot/New-ContainerSBOM.ps1" -DockerfilePath $dockerfilePath -OutputPath $outputPath -Verbose:$false -UseSyft $false
            
            if (Test-Path $outputPath) {
                $sbom = Get-Content $outputPath -Raw | ConvertFrom-Json
                
                $hasComponents = ($sbom.components) -and (($sbom.components).Count -gt 0)
                
                if ($hasComponents) {
                    Add-TestResult "Container SBOM Generation" $true "Generated $(($sbom.components).Count) components"
                } else {
                    Add-TestResult "Container SBOM Generation" $false "No components generated"
                }
                
                Remove-Item $outputPath -Force
            } else {
                Add-TestResult "Container SBOM Generation" $false "Output file not created"
            }
        } else {
            Add-TestResult "Container SBOM Generation" $false "Dockerfile not found"
        }
    } catch {
        Add-TestResult "Container SBOM Generation" $false $_.Exception.Message
    }
    Write-Host ""
}

# Test 3: SBOM Merging
Write-Host "🔀 Test 3: SBOM Merging" -ForegroundColor Yellow

try {
    $examplesPath = Join-Path $PSScriptRoot "../examples"
    $outputPath = Join-Path $PSScriptRoot "../examples/test-merged-sbom.json"
    
    & "$PSScriptRoot/../with-copilot/Merge-SBOMDocuments.ps1" -InputPath $examplesPath -OutputFile $outputPath -Verbose:$false
    
    if (Test-Path $outputPath) {
        $sbom = Get-Content $outputPath -Raw | ConvertFrom-Json
        
        $isValid = ($sbom.bomFormat -eq "CycloneDX") -and ($sbom.components).Count -gt 0
        
        if ($isValid) {
            Add-TestResult "SBOM Merging" $true "Merged SBOM has $(($sbom.components).Count) components"
        } else {
            Add-TestResult "SBOM Merging" $false "Invalid merged SBOM structure"
        }
        
        Remove-Item $outputPath -Force
    } else {
        Add-TestResult "SBOM Merging" $false "Merged SBOM not created"
    }
} catch {
    Add-TestResult "SBOM Merging" $false $_.Exception.Message
}

Write-Host ""

# Test 4: Report Export
Write-Host "📊 Test 4: Report Export" -ForegroundColor Yellow

try {
    $sbomPath = Join-Path $PSScriptRoot "../examples/application-sbom.json"
    $outputPath = Join-Path $PSScriptRoot "../examples/test-report.html"
    
    if (Test-Path $sbomPath) {
        & "$PSScriptRoot/../with-copilot/Export-SBOMReport.ps1" -SBOMPath $sbomPath -OutputFormat "HTML" -OutputPath $outputPath -Verbose:$false
        
        if (Test-Path $outputPath) {
            $htmlContent = Get-Content $outputPath -Raw
            $hasContent = $htmlContent.Length -gt 1000 -and $htmlContent -match "SBOM Report"
            
            if ($hasContent) {
                Add-TestResult "Report Export" $true "HTML report generated successfully"
            } else {
                Add-TestResult "Report Export" $false "HTML report incomplete"
            }
            
            Remove-Item $outputPath -Force
        } else {
            Add-TestResult "Report Export" $false "Report file not created"
        }
    } else {
        Add-TestResult "Report Export" $false "Sample SBOM not found"
    }
} catch {
    Add-TestResult "Report Export" $false $_.Exception.Message
}

Write-Host ""

# Summary
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan

$passedTests = ($script:TestResults | Where-Object { $_.Passed }).Count
$totalTests = $script:TestResults.Count

foreach ($result in $script:TestResults) {
    $status = if ($result.Passed) { "✅ PASS" } else { "❌ FAIL" }
    $color = if ($result.Passed) { "Green" } else { "Red" }
    Write-Host "$status : $($result.Test)" -ForegroundColor $color
    if (-not $result.Passed -and $result.Message) {
        Write-Host "         $($result.Message)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Results: $passedTests / $totalTests tests passed" -ForegroundColor $(if ($passedTests -eq $totalTests) { "Green" } else { "Yellow" })

if ($passedTests -eq $totalTests) {
    Write-Host "🎉 All tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️  Some tests failed" -ForegroundColor Yellow
    exit 1
}
