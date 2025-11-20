<#
.SYNOPSIS
    Merges multiple CycloneDX SBOM documents into a single unified SBOM.

.DESCRIPTION
    This script reads multiple CycloneDX SBOM JSON files from a directory, merges all components
    into a single unified SBOM, deduplicates components by name and version, and generates
    a new SBOM document with combined metadata.

.PARAMETER InputPath
    Directory containing SBOM JSON files to merge, or array of file paths.

.PARAMETER OutputFile
    Path where the merged SBOM will be saved.

.PARAMETER DeduplicateComponents
    Remove duplicate components (same name and version) (default: $true).

.EXAMPLE
    .\Merge-SBOMDocuments.ps1 -InputPath "../examples" -OutputFile "../examples/merged-sbom.json"

.EXAMPLE
    .\Merge-SBOMDocuments.ps1 -InputPath @("app-sbom.json", "container-sbom.json") -OutputFile "merged.json"

.NOTES
    Author: Generated with GitHub Copilot
    Date: 2025-11-18
    Requires: PowerShell 7.0+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputFile,

    [Parameter(Mandatory = $false)]
    [bool]$DeduplicateComponents = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "🔀 Merging SBOM documents..." -ForegroundColor Cyan

try {
    # Collect SBOM files
    $sbomFiles = @()
    
    if (Test-Path $InputPath -PathType Container) {
        # Directory provided - find all JSON files containing "sbom"
        $sbomFiles = Get-ChildItem -Path $InputPath -Filter "*sbom*.json" | Where-Object { $_.Name -ne (Split-Path $OutputFile -Leaf) }
        Write-Host "📁 Found $($sbomFiles.Count) SBOM files in: $InputPath" -ForegroundColor Cyan
    } elseif (Test-Path $InputPath -PathType Leaf) {
        # Single file provided
        $sbomFiles = @(Get-Item $InputPath)
        Write-Host "📄 Processing single SBOM file" -ForegroundColor Cyan
    } else {
        Write-Error "Input path not found: $InputPath"
        exit 1
    }

    if ($sbomFiles.Count -eq 0) {
        Write-Warning "No SBOM files found to merge"
        exit 0
    }

    # Initialize merged SBOM structure
    $mergedSbom = [ordered]@{
        bomFormat    = "CycloneDX"
        specVersion  = "1.5"
        serialNumber = "urn:uuid:$([guid]::NewGuid().ToString())"
        version      = 1
        metadata     = [ordered]@{
            timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            tools     = @(
                [ordered]@{
                    vendor  = "GitHub Copilot"
                    name    = "Merge-SBOMDocuments.ps1"
                    version = "1.0.0"
                }
            )
            component = [ordered]@{
                type        = "application"
                name        = "Merged SBOM"
                description = "Unified SBOM from multiple sources"
            }
        }
        components   = @()
    }

    # Track components for deduplication
    $componentMap = @{}
    $totalComponentsProcessed = 0

    # Process each SBOM file
    foreach ($file in $sbomFiles) {
        Write-Host "📖 Reading: $($file.Name)..." -ForegroundColor Yellow
        
        try {
            $sbom = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
            
            # Validate it's a CycloneDX SBOM
            if ($sbom.bomFormat -ne "CycloneDX") {
                Write-Warning "Skipping $($file.Name) - not a CycloneDX SBOM"
                continue
            }

            # Merge components
            if ($sbom.components) {
                foreach ($component in $sbom.components) {
                    $totalComponentsProcessed++
                    
                    # Create unique key for deduplication
                    $componentKey = "$($component.name):$($component.version)"
                    
                    if ($DeduplicateComponents) {
                        if (-not $componentMap.ContainsKey($componentKey)) {
                            $componentMap[$componentKey] = $component
                            Write-Verbose "Added component: $componentKey"
                        } else {
                            Write-Verbose "Skipped duplicate: $componentKey"
                        }
                    } else {
                        # Add all components without deduplication
                        $mergedSbom.components += $component
                    }
                }
                
                Write-Host "   ✅ Processed $(($sbom.components).Count) components" -ForegroundColor Green
            }
        } catch {
            Write-Warning "Failed to parse $($file.Name): $_"
            continue
        }
    }

    # Add deduplicated components to merged SBOM
    if ($DeduplicateComponents) {
        $mergedSbom.components = @($componentMap.Values)
    }

    # Create output directory
    $outputDir = Split-Path -Path $OutputFile -Parent
    if ($outputDir -and -not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }

    # Write merged SBOM
    $mergedSbom | ConvertTo-Json -Depth 20 | Set-Content -Path $OutputFile -Encoding UTF8

    Write-Host ""
    Write-Host "💾 Merged SBOM saved to: $OutputFile" -ForegroundColor Green
    Write-Host "📊 Merge Summary:" -ForegroundColor Cyan
    Write-Host "   - Input files: $($sbomFiles.Count)" -ForegroundColor White
    Write-Host "   - Total components processed: $totalComponentsProcessed" -ForegroundColor White
    Write-Host "   - Unique components in merged SBOM: $(($mergedSbom.components).Count)" -ForegroundColor White
    
    if ($DeduplicateComponents) {
        $duplicatesRemoved = $totalComponentsProcessed - ($mergedSbom.components).Count
        Write-Host "   - Duplicates removed: $duplicatesRemoved" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "✨ SBOM merge complete!" -ForegroundColor Green

} catch {
    Write-Error "Failed to merge SBOM documents: $_"
    exit 1
}
