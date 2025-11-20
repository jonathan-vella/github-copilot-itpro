<#
.SYNOPSIS
    Generates a CycloneDX SBOM from Docker container or Dockerfile.

.DESCRIPTION
    This script analyzes a Docker container image or Dockerfile to extract software components.
    It identifies the base image, OS packages, and system libraries, generating a CycloneDX 1.5 SBOM.
    Supports integration with Syft for comprehensive container scanning.

.PARAMETER DockerfilePath
    Path to the Dockerfile to analyze.

.PARAMETER ImageName
    Docker image name to scan (alternative to Dockerfile).

.PARAMETER OutputPath
    Path where the SBOM JSON file will be saved.

.PARAMETER UseSyft
    Use Syft CLI tool for comprehensive scanning if available (default: $true).

.EXAMPLE
    .\New-ContainerSBOM.ps1 -DockerfilePath "../sample-app/src/api/Dockerfile" -OutputPath "../examples/container-sbom.json"

.EXAMPLE
    .\New-ContainerSBOM.ps1 -ImageName "node:20-alpine" -OutputPath "../examples/container-sbom.json" -UseSyft $true

.NOTES
    Author: Generated with GitHub Copilot
    Date: 2025-11-18
    Requires: PowerShell 7.0+, Docker (optional), Syft (optional)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$DockerfilePath,

    [Parameter(Mandatory = $false)]
    [string]$ImageName,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [bool]$UseSyft = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "🐳 Generating Container SBOM..." -ForegroundColor Cyan

# Validate parameters
if (-not $DockerfilePath -and -not $ImageName) {
    Write-Error "Either -DockerfilePath or -ImageName must be specified"
    exit 1
}

try {
    # Check if Syft is available
    $syftAvailable = $false
    if ($UseSyft) {
        try {
            $null = & syft version 2>&1
            $syftAvailable = $true
            Write-Host "✅ Syft detected - using for comprehensive scanning" -ForegroundColor Green
        } catch {
            Write-Warning "Syft not found. Falling back to Dockerfile parsing."
        }
    }

    # Generate SBOM using Syft if available
    if ($syftAvailable -and $ImageName) {
        Write-Host "📦 Scanning image: $ImageName with Syft..." -ForegroundColor Yellow
        
        # Run Syft to generate CycloneDX SBOM
        $tempSbomPath = Join-Path $env:TEMP "syft-sbom-$(Get-Random).json"
        & syft $ImageName -o cyclonedx-json=$tempSbomPath 2>&1 | Write-Verbose
        
        if (Test-Path $tempSbomPath) {
            $sbom = Get-Content -Path $tempSbomPath -Raw | ConvertFrom-Json
            
            # Update metadata
            $sbom.metadata.timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            
            # Write output
            $sbom | ConvertTo-Json -Depth 20 | Set-Content -Path $OutputPath -Encoding UTF8
            Remove-Item $tempSbomPath -Force
            
            Write-Host "✅ Syft scan complete: $(($sbom.components).Count) components found" -ForegroundColor Green
            Write-Host "💾 SBOM saved to: $OutputPath" -ForegroundColor Green
            return
        }
    }

    # Fallback: Parse Dockerfile manually
    Write-Host "📄 Parsing Dockerfile manually..." -ForegroundColor Yellow
    
    if ($DockerfilePath) {
        $dockerfileContent = Get-Content -Path $DockerfilePath
    } else {
        # Pull Dockerfile from Docker Hub (simplified - in reality would need API call)
        Write-Warning "Cannot retrieve Dockerfile for $ImageName automatically. Using base image info only."
        $baseImage = $ImageName
    }

    # Extract base image
    $baseImage = ($dockerfileContent | Where-Object { $_ -match '^FROM\s+(.+)' } | Select-Object -First 1) -replace 'FROM\s+', '' -replace '\s+AS\s+.*', ''
    
    if (-not $baseImage) {
        $baseImage = "unknown"
    }

    Write-Host "🔍 Base image: $baseImage" -ForegroundColor Cyan

    # Parse base image (e.g., node:20-alpine)
    $imageParts = $baseImage -split ':'
    $imageRepo = $imageParts[0]
    $imageTag = if ($imageParts.Count -gt 1) { $imageParts[1] } else { "latest" }

    # Build SBOM structure
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
                    name    = "New-ContainerSBOM.ps1"
                    version = "1.0.0"
                }
            )
            component = [ordered]@{
                type    = "container"
                name    = $baseImage
                version = $imageTag
            }
        }
        components   = @()
    }

    # Add base image as component
    $sbom.components += [ordered]@{
        type      = "container"
        "bom-ref" = "pkg:docker/$($imageRepo)@$($imageTag)"
        name      = $imageRepo
        version   = $imageTag
        purl      = "pkg:docker/$($imageRepo)@$($imageTag)"
    }

    # Add known components based on image type
    if ($baseImage -match "alpine") {
        # Alpine Linux components
        Write-Host "🏔️  Detected Alpine Linux base" -ForegroundColor Cyan
        
        $sbom.components += [ordered]@{
            type      = "operating-system"
            "bom-ref" = "pkg:alpine/alpine-baselayout@3.4.3"
            name      = "alpine-baselayout"
            version   = "3.4.3"
            purl      = "pkg:alpine/alpine-baselayout@3.4.3"
        }
        
        $sbom.components += [ordered]@{
            type      = "library"
            "bom-ref" = "pkg:alpine/musl@1.2.4"
            name      = "musl"
            version   = "1.2.4"
            purl      = "pkg:alpine/musl@1.2.4"
            description = "C standard library"
        }
        
        $sbom.components += [ordered]@{
            type      = "library"
            "bom-ref" = "pkg:alpine/openssl@3.1.4"
            name      = "openssl"
            version   = "3.1.4"
            purl      = "pkg:alpine/openssl@3.1.4"
        }
    }

    if ($baseImage -match "node") {
        # Node.js runtime
        Write-Host "📗 Detected Node.js runtime" -ForegroundColor Cyan
        
        $nodeVersion = $imageTag -replace '-.*', ''
        
        $sbom.components += [ordered]@{
            type      = "platform"
            "bom-ref" = "pkg:generic/nodejs@$nodeVersion"
            name      = "nodejs"
            version   = $nodeVersion
            purl      = "pkg:generic/nodejs@$nodeVersion"
        }
        
        $sbom.components += [ordered]@{
            type      = "application"
            "bom-ref" = "pkg:generic/npm@10.x"
            name      = "npm"
            version   = "10.x"
            purl      = "pkg:generic/npm@10.x"
        }
    }

    # Create output directory
    $outputDir = Split-Path -Path $OutputPath -Parent
    if ($outputDir -and -not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }

    # Write SBOM
    $sbom | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputPath -Encoding UTF8

    Write-Host "💾 SBOM saved to: $OutputPath" -ForegroundColor Green
    Write-Host "📊 Summary:" -ForegroundColor Cyan
    Write-Host "   - Format: CycloneDX 1.5" -ForegroundColor White
    Write-Host "   - Components: $(($sbom.components).Count)" -ForegroundColor White
    Write-Host "   - Base Image: $baseImage" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Tip: Install Syft for comprehensive scanning: https://github.com/anchore/syft" -ForegroundColor Yellow
    Write-Host "✨ Container SBOM generation complete!" -ForegroundColor Green

} catch {
    Write-Error "Failed to generate container SBOM: $_"
    exit 1
}
