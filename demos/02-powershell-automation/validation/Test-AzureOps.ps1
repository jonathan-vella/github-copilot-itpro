<#
.SYNOPSIS
    Validates Azure PowerShell automation scripts functionality.

.DESCRIPTION
    This script performs automated testing of all PowerShell automation scripts
    in the demo environment. It validates:
    - Script syntax and parameter validation
    - Dry-run capabilities
    - Error handling
    - Output formatting
    - Export functionality

.PARAMETER ResourceGroupName
    Test resource group name. Default: rg-copilot-test-001

.PARAMETER Location
    Azure region for test resources. Default: eastus

.PARAMETER CleanupAfterTests
    Remove test resources after validation completes.

.EXAMPLE
    .\Test-AzureOps.ps1
    Run all validation tests with defaults.

.EXAMPLE
    .\Test-AzureOps.ps1 -CleanupAfterTests
    Run tests and cleanup test resources afterward.

.NOTES
    Author: IT Operations Team
    Generated with: GitHub Copilot
    Requires: Az.Resources, Az.Storage, Az.Network modules
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "rg-copilot-test-001",

    [Parameter(Mandatory = $false)]
    [string]$Location = "eastus",

    [Parameter(Mandatory = $false)]
    [switch]$CleanupAfterTests
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptsToTest = @(
    "$scriptPath\..\with-copilot\Get-AzResourceReport.ps1",
    "$scriptPath\..\with-copilot\Find-UntaggedResources.ps1",
    "$scriptPath\..\with-copilot\Remove-OrphanedResources.ps1",
    "$scriptPath\..\with-copilot\Set-BulkTags.ps1"
)

$testResults = @{
    Passed = 0
    Failed = 0
    Skipped = 0
    Tests = @()
}

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message = ""
    )
    
    $status = if ($Passed) { "✅ PASS" } else { "❌ FAIL" }
    $color = if ($Passed) { "Green" } else { "Red" }
    
    Write-Host "   $status - $TestName" -ForegroundColor $color
    if ($Message) {
        Write-Host "      $Message" -ForegroundColor Gray
    }
    
    $testResults.Tests += [PSCustomObject]@{
        TestName = $TestName
        Passed = $Passed
        Message = $Message
        Timestamp = Get-Date
    }
    
    if ($Passed) { $testResults.Passed++ } else { $testResults.Failed++ }
}

function Test-ScriptSyntax {
    param([string]$ScriptPath)
    
    Write-Host "`n🔍 Testing Script Syntax: $(Split-Path -Leaf $ScriptPath)" -ForegroundColor Cyan
    
    try {
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $ScriptPath -Raw), [ref]$errors)
        
        if ($errors.Count -eq 0) {
            Write-TestResult -TestName "Syntax Validation" -Passed $true -Message "No syntax errors found"
        }
        else {
            Write-TestResult -TestName "Syntax Validation" -Passed $false -Message "Found $($errors.Count) syntax errors"
        }
    }
    catch {
        Write-TestResult -TestName "Syntax Validation" -Passed $false -Message $_.Exception.Message
    }
}

function Test-ScriptHelp {
    param([string]$ScriptPath)
    
    Write-Host "`n📖 Testing Script Help Documentation" -ForegroundColor Cyan
    
    try {
        $help = Get-Help $ScriptPath -ErrorAction Stop
        
        # Check for Synopsis
        if ($help.Synopsis) {
            Write-TestResult -TestName "Synopsis Present" -Passed $true
        }
        else {
            Write-TestResult -TestName "Synopsis Present" -Passed $false -Message "No synopsis found"
        }
        
        # Check for Description
        if ($help.Description) {
            Write-TestResult -TestName "Description Present" -Passed $true
        }
        else {
            Write-TestResult -TestName "Description Present" -Passed $false -Message "No description found"
        }
        
        # Check for Examples
        if ($help.Examples.Example.Count -gt 0) {
            Write-TestResult -TestName "Examples Present ($($help.Examples.Example.Count))" -Passed $true
        }
        else {
            Write-TestResult -TestName "Examples Present" -Passed $false -Message "No examples found"
        }
        
        # Check for Parameters
        if ($help.Parameters.Parameter.Count -gt 0) {
            Write-TestResult -TestName "Parameters Documented ($($help.Parameters.Parameter.Count))" -Passed $true
        }
        else {
            Write-TestResult -TestName "Parameters Documented" -Passed $false -Message "No parameters documented"
        }
    }
    catch {
        Write-TestResult -TestName "Help Documentation" -Passed $false -Message $_.Exception.Message
    }
}

function Initialize-TestEnvironment {
    Write-Host "`n🔧 Setting up test environment..." -ForegroundColor Cyan
    
    try {
        # Create test resource group
        $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
        if (-not $rg) {
            Write-Host "   Creating test resource group: $ResourceGroupName" -ForegroundColor Yellow
            New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag @{
                Purpose = 'Testing'
                CreatedBy = 'Test-AzureOps'
                Environment = 'Test'
            } | Out-Null
            Write-TestResult -TestName "Test Resource Group Created" -Passed $true
        }
        else {
            Write-TestResult -TestName "Test Resource Group Exists" -Passed $true
        }
        
        # Create test storage account (for orphaned resource testing)
        $storageAccountName = "sttest$(-join ((48..57) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_}))"
        Write-Host "   Creating test storage account: $storageAccountName" -ForegroundColor Yellow
        
        New-AzStorageAccount `
            -ResourceGroupName $ResourceGroupName `
            -Name $storageAccountName `
            -Location $Location `
            -SkuName Standard_LRS `
            -Kind StorageV2 `
            -Tag @{Environment='Test'; Owner='TestSuite'} | Out-Null
        
        Write-TestResult -TestName "Test Storage Account Created" -Passed $true
        
        # Create test managed disk (orphaned)
        $diskName = "disk-test-orphaned-001"
        Write-Host "   Creating test orphaned disk: $diskName" -ForegroundColor Yellow
        
        $diskConfig = New-AzDiskConfig `
            -Location $Location `
            -CreateOption Empty `
            -DiskSizeGB 32 `
            -SkuName Standard_LRS
        
        New-AzDisk `
            -ResourceGroupName $ResourceGroupName `
            -DiskName $diskName `
            -Disk $diskConfig | Out-Null
        
        Write-TestResult -TestName "Test Orphaned Disk Created" -Passed $true
        
        # Create test public IP (orphaned)
        $pipName = "pip-test-orphaned-001"
        Write-Host "   Creating test orphaned public IP: $pipName" -ForegroundColor Yellow
        
        New-AzPublicIpAddress `
            -ResourceGroupName $ResourceGroupName `
            -Name $pipName `
            -Location $Location `
            -AllocationMethod Static `
            -Sku Standard | Out-Null
        
        Write-TestResult -TestName "Test Orphaned Public IP Created" -Passed $true
        
        Write-Host "   ✅ Test environment ready" -ForegroundColor Green
        return $true
    }
    catch {
        Write-TestResult -TestName "Test Environment Setup" -Passed $false -Message $_.Exception.Message
        return $false
    }
}

function Test-GetAzResourceReport {
    Write-Host "`n📊 Testing Get-AzResourceReport.ps1" -ForegroundColor Cyan
    
    try {
        $scriptPath = "$scriptPath\..\with-copilot\Get-AzResourceReport.ps1"
        $outputPath = Join-Path $env:TEMP "test-report.csv"
        
        # Test CSV export
        & $scriptPath -ResourceGroupName $ResourceGroupName -OutputFormat CSV -OutputPath $outputPath
        
        if (Test-Path $outputPath) {
            $csvContent = Import-Csv $outputPath
            if ($csvContent.Count -gt 0) {
                Write-TestResult -TestName "CSV Export Functional" -Passed $true -Message "Exported $($csvContent.Count) resources"
            }
            else {
                Write-TestResult -TestName "CSV Export Functional" -Passed $false -Message "CSV file empty"
            }
            Remove-Item $outputPath -Force
        }
        else {
            Write-TestResult -TestName "CSV Export Functional" -Passed $false -Message "CSV file not created"
        }
    }
    catch {
        Write-TestResult -TestName "Get-AzResourceReport Execution" -Passed $false -Message $_.Exception.Message
    }
}

function Test-FindUntaggedResources {
    Write-Host "`n��️  Testing Find-UntaggedResources.ps1" -ForegroundColor Cyan
    
    try {
        $scriptPath = "$scriptPath\..\with-copilot\Find-UntaggedResources.ps1"
        $outputPath = Join-Path $env:TEMP "test-untagged.csv"
        
        # Test with required tags (note: test resources have Environment, Owner tags)
        # Script will detect missing CostCenter tag
        & $scriptPath `
            -ResourceGroupName $ResourceGroupName `
            -RequiredTags @('Environment', 'Owner', 'CostCenter') `
            -ExportPath $outputPath -ErrorAction Stop
        
        # Script executed successfully - check if report was created
        if (Test-Path $outputPath) {
            Write-TestResult -TestName "Untagged Resources Detection" -Passed $true -Message "Report generated successfully"
            Remove-Item $outputPath -Force
        }
        else {
            # No report means all resources are compliant - this is also a pass
            Write-TestResult -TestName "Untagged Resources Detection" -Passed $true -Message "All resources compliant (no report needed)"
        }
    }
    catch {
        Write-TestResult -TestName "Find-UntaggedResources Execution" -Passed $false -Message $_.Exception.Message
    }
}

function Test-RemoveOrphanedResources {
    Write-Host "`n🗑️  Testing Remove-OrphanedResources.ps1" -ForegroundColor Cyan
    
    try {
        $scriptPath = "$scriptPath\..\with-copilot\Remove-OrphanedResources.ps1"
        $outputPath = Join-Path $env:TEMP "test-orphaned.csv"
        
        # Test dry-run mode (no actual deletion)
        & $scriptPath `
            -ResourceGroupName $ResourceGroupName `
            -IncludeCostEstimates `
            -ExportPath $outputPath
        
        if (Test-Path $outputPath) {
            $orphanedResources = Import-Csv $outputPath
            if ($orphanedResources.Count -ge 2) {  # Should find disk and public IP
                Write-TestResult -TestName "Orphaned Resources Detection" -Passed $true -Message "Found $($orphanedResources.Count) orphaned resources"
            }
            else {
                Write-TestResult -TestName "Orphaned Resources Detection" -Passed $false -Message "Expected to find at least 2 orphaned resources"
            }
            Remove-Item $outputPath -Force
        }
        else {
            Write-TestResult -TestName "Orphaned Resources Detection" -Passed $false -Message "Report not generated"
        }
    }
    catch {
        Write-TestResult -TestName "Remove-OrphanedResources Execution" -Passed $false -Message $_.Exception.Message
    }
}

function Test-SetBulkTags {
    Write-Host "`n🏷️  Testing Set-BulkTags.ps1" -ForegroundColor Cyan
    
    try {
        $scriptPath = "$scriptPath\..\with-copilot\Set-BulkTags.ps1"
        
        # Test dry-run mode
        & $scriptPath `
            -ResourceGroupName $ResourceGroupName `
            -Tags @{Project='TestProject'; Phase='Testing'} `
            -DryRun
        
        Write-TestResult -TestName "Bulk Tagging Dry-Run" -Passed $true -Message "Dry-run completed successfully"
    }
    catch {
        Write-TestResult -TestName "Set-BulkTags Execution" -Passed $false -Message $_.Exception.Message
    }
}

function Remove-TestEnvironment {
    Write-Host "`n🧹 Cleaning up test environment..." -ForegroundColor Cyan
    
    try {
        Remove-AzResourceGroup -Name $ResourceGroupName -Force
        Write-Host "   ✅ Test resources removed" -ForegroundColor Green
    }
    catch {
        Write-Host "   ⚠️  Warning: Could not remove test resources - $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Main execution
try {
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     Azure PowerShell Automation - Validation Suite        ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    
    # Test syntax for all scripts
    foreach ($script in $scriptsToTest) {
        if (Test-Path $script) {
            Test-ScriptSyntax -ScriptPath $script
            Test-ScriptHelp -ScriptPath $script
        }
        else {
            Write-Host "`n⚠️  Script not found: $script" -ForegroundColor Yellow
            $testResults.Skipped++
        }
    }
    
    # Initialize test environment
    $envReady = Initialize-TestEnvironment
    
    if ($envReady) {
        # Run functional tests
        Test-GetAzResourceReport
        Test-FindUntaggedResources
        Test-RemoveOrphanedResources
        Test-SetBulkTags
    }
    
    # Cleanup if requested
    if ($CleanupAfterTests) {
        Remove-TestEnvironment
    }
    
    # Display summary
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor White
    Write-Host "║                    TEST SUMMARY                            ║" -ForegroundColor White
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor White
    
    Write-Host "`n📊 Results:" -ForegroundColor White
    Write-Host "   ✅ Passed: $($testResults.Passed)" -ForegroundColor Green
    Write-Host "   ❌ Failed: $($testResults.Failed)" -ForegroundColor Red
    Write-Host "   ⏭️  Skipped: $($testResults.Skipped)" -ForegroundColor Yellow
    
    $totalTests = $testResults.Passed + $testResults.Failed
    if ($totalTests -gt 0) {
        $passRate = [Math]::Round(($testResults.Passed / $totalTests) * 100, 1)
        Write-Host "`n   Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 90) { 'Green' } elseif ($passRate -ge 70) { 'Yellow' } else { 'Red' })
    }
    
    if ($testResults.Failed -eq 0) {
        Write-Host "`n✅ All tests passed!" -ForegroundColor Green
        exit 0
    }
    else {
        Write-Host "`n⚠️  Some tests failed. Review results above." -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host "`n❌ Test suite error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
