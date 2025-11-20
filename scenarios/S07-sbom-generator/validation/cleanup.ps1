<#
.SYNOPSIS
    Cleanup script for SBOM demo resources.

.DESCRIPTION
    Removes generated SBOM files and test outputs from the demo directory.
    Use this to reset the demo to a clean state.

.PARAMETER RemoveExamples
    Remove example SBOM files (default: $false to preserve for demos).

.PARAMETER RemoveTests
    Remove test output files (default: $true).

.PARAMETER WhatIf
    Show what would be deleted without actually deleting.

.EXAMPLE
    .\cleanup.ps1

.EXAMPLE
    .\cleanup.ps1 -RemoveExamples -RemoveTests

.NOTES
    Author: Generated with GitHub Copilot
    Date: 2025-11-18
    Requires: PowerShell 7.0+
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [switch]$RemoveExamples = $false,

    [Parameter(Mandatory = $false)]
    [switch]$RemoveTests = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "🧹 Cleaning up SBOM demo resources..." -ForegroundColor Cyan
Write-Host ""

$filesDeleted = 0

# Remove test output files
if ($RemoveTests) {
    Write-Host "📁 Removing test output files..." -ForegroundColor Yellow
    
    $testFiles = @(
        "../examples/test-*.json",
        "../examples/test-*.html",
        "../examples/test-*.csv",
        "../examples/test-*.md"
    )
    
    foreach ($pattern in $testFiles) {
        $files = Get-ChildItem -Path (Join-Path $PSScriptRoot $pattern) -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            if ($PSCmdlet.ShouldProcess($file.FullName, "Delete")) {
                Remove-Item $file.FullName -Force
                Write-Host "   ✅ Deleted: $($file.Name)" -ForegroundColor Green
                $filesDeleted++
            }
        }
    }
}

# Remove example SBOM files (optional)
if ($RemoveExamples) {
    Write-Host "📁 Removing example SBOM files..." -ForegroundColor Yellow
    Write-Warning "This will remove pre-generated examples used for demos!"
    
    $confirm = Read-Host "Are you sure? (yes/no)"
    
    if ($confirm -eq "yes") {
        $exampleFiles = Get-ChildItem -Path (Join-Path $PSScriptRoot "../examples") -Filter "*.json" -ErrorAction SilentlyContinue
        
        foreach ($file in $exampleFiles) {
            if ($PSCmdlet.ShouldProcess($file.FullName, "Delete")) {
                Remove-Item $file.FullName -Force
                Write-Host "   ✅ Deleted: $($file.Name)" -ForegroundColor Green
                $filesDeleted++
            }
        }
        
        $reportFiles = Get-ChildItem -Path (Join-Path $PSScriptRoot "../examples") -Include "*.html", "*.csv", "*.md" -Recurse -ErrorAction SilentlyContinue
        
        foreach ($file in $reportFiles) {
            if ($PSCmdlet.ShouldProcess($file.FullName, "Delete")) {
                Remove-Item $file.FullName -Force
                Write-Host "   ✅ Deleted: $($file.Name)" -ForegroundColor Green
                $filesDeleted++
            }
        }
    } else {
        Write-Host "   ⏭️  Skipped example file deletion" -ForegroundColor Yellow
    }
}

# Summary
Write-Host ""
if ($filesDeleted -gt 0) {
    Write-Host "✨ Cleanup complete! Deleted $filesDeleted file(s)" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No files to clean up" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "💡 Tip: To regenerate examples, run the PowerShell scripts in with-copilot/" -ForegroundColor Yellow
