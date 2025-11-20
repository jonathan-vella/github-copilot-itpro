<#
.SYNOPSIS
    Generates a CycloneDX SBOM from package.json npm dependencies.

.DESCRIPTION
    This script parses a package.json file, extracts all dependencies and devDependencies,
    and generates a CycloneDX 1.5 format SBOM in JSON. The SBOM includes component names,
    versions, types, and package URLs (PURL) for each npm package.

.PARAMETER PackageJsonPath
    Path to the package.json file to analyze.

.PARAMETER OutputPath
    Path where the SBOM JSON file will be saved.

.PARAMETER IncludeDevDependencies
    Include devDependencies in the SBOM (default: $true).

.PARAMETER ProjectName
    Name of the project/application (default: extracted from package.json).

.EXAMPLE
    .\New-ApplicationSBOM.ps1 -PackageJsonPath "../sample-app/src/api/package.json" -OutputPath "../examples/application-sbom.json"

.NOTES
    Author: Generated with GitHub Copilot
    Date: 2025-11-18
    Requires: PowerShell 7.0+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$PackageJsonPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [bool]$IncludeDevDependencies = $true,

    [Parameter(Mandatory = $false)]
    [string]$ProjectName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "🔍 Generating Application SBOM from package.json..." -ForegroundColor Cyan

try {
    # Read and parse package.json
    Write-Verbose "Reading package.json from: $PackageJsonPath"
    $packageJson = Get-Content -Path $PackageJsonPath -Raw | ConvertFrom-Json

    # Extract project information
    if (-not $ProjectName) {
        $ProjectName = $packageJson.name
    }
    $projectVersion = $packageJson.version ?? "1.0.0"

    Write-Host "📦 Project: $ProjectName v$projectVersion" -ForegroundColor Green

    # Generate SBOM metadata
    $sbom = [ordered]@{
        bomFormat    = "CycloneDX"
        specVersion  = "1.5"
        serialNumber = "urn:uuid:$([guid]::NewGuid().ToString())"
        version      = 1
        metadata     = [ordered]@{
            timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            tools     = @(
                [ordered]@{
                    vendor  = "GitHub Copilot"
                    name    = "New-ApplicationSBOM.ps1"
                    version = "1.0.0"
                }
            )
            component = [ordered]@{
                type    = "application"
                name    = $ProjectName
                version = $projectVersion
            }
        }
        components   = @()
    }

    # Process dependencies
    $componentCount = 0
    
    if ($packageJson.dependencies) {
        Write-Host "📚 Processing $(($packageJson.dependencies.PSObject.Properties).Count) production dependencies..." -ForegroundColor Yellow
        
        foreach ($dep in $packageJson.dependencies.PSObject.Properties) {
            $componentCount++
            $component = [ordered]@{
                type    = "library"
                "bom-ref" = "pkg:npm/$($dep.Name)@$($dep.Value -replace '[\^~]', '')"
                name    = $dep.Name
                version = $dep.Value -replace '[\^~]', ''
                purl    = "pkg:npm/$($dep.Name)@$($dep.Value -replace '[\^~]', '')"
                scope   = "required"
            }
            $sbom.components += $component
        }
    }

    # Process devDependencies if requested
    if ($IncludeDevDependencies -and $packageJson.devDependencies) {
        Write-Host "🛠️  Processing $(($packageJson.devDependencies.PSObject.Properties).Count) dev dependencies..." -ForegroundColor Yellow
        
        foreach ($dep in $packageJson.devDependencies.PSObject.Properties) {
            $componentCount++
            $component = [ordered]@{
                type    = "library"
                "bom-ref" = "pkg:npm/$($dep.Name)@$($dep.Value -replace '[\^~]', '')"
                name    = $dep.Name
                version = $dep.Value -replace '[\^~]', ''
                purl    = "pkg:npm/$($dep.Name)@$($dep.Value -replace '[\^~]', '')"
                scope   = "optional"
            }
            $sbom.components += $component
        }
    }

    Write-Host "✅ Found $componentCount total components" -ForegroundColor Green

    # Create output directory if it doesn't exist
    $outputDir = Split-Path -Path $OutputPath -Parent
    if ($outputDir -and -not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }

    # Write SBOM to file
    $sbomJson = $sbom | ConvertTo-Json -Depth 10
    Set-Content -Path $OutputPath -Value $sbomJson -Encoding UTF8

    Write-Host "💾 SBOM saved to: $OutputPath" -ForegroundColor Green
    Write-Host "📊 Summary:" -ForegroundColor Cyan
    Write-Host "   - Format: CycloneDX 1.5" -ForegroundColor White
    Write-Host "   - Components: $componentCount" -ForegroundColor White
    Write-Host "   - Project: $ProjectName v$projectVersion" -ForegroundColor White
    Write-Host ""
    Write-Host "✨ Application SBOM generation complete!" -ForegroundColor Green

} catch {
    Write-Error "Failed to generate SBOM: $_"
    exit 1
}
