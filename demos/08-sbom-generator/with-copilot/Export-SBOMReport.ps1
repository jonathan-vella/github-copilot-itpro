<#
.SYNOPSIS
    Exports a CycloneDX SBOM to various human-readable formats.

.DESCRIPTION
    This script reads a CycloneDX SBOM JSON file and exports it to multiple formats
    including HTML dashboard, CSV for spreadsheet analysis, and Markdown documentation.

.PARAMETER SBOMPath
    Path to the CycloneDX SBOM JSON file.

.PARAMETER OutputFormat
    Output format: HTML, CSV, Markdown, or All (default: HTML).

.PARAMETER OutputPath
    Directory or file path for the output.

.EXAMPLE
    .\Export-SBOMReport.ps1 -SBOMPath "../examples/merged-sbom.json" -OutputFormat "HTML" -OutputPath "../examples/sbom-report.html"

.EXAMPLE
    .\Export-SBOMReport.ps1 -SBOMPath "merged-sbom.json" -OutputFormat "All" -OutputPath "../reports"

.NOTES
    Author: Generated with GitHub Copilot
    Date: 2025-11-18
    Requires: PowerShell 7.0+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$SBOMPath,

    [Parameter(Mandatory = $false)]
    [ValidateSet("HTML", "CSV", "Markdown", "All")]
    [string]$OutputFormat = "HTML",

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "📊 Exporting SBOM report..." -ForegroundColor Cyan

try {
    # Read SBOM
    Write-Verbose "Reading SBOM from: $SBOMPath"
    $sbom = Get-Content -Path $SBOMPath -Raw | ConvertFrom-Json

    if ($sbom.bomFormat -ne "CycloneDX") {
        Write-Error "Not a valid CycloneDX SBOM"
        exit 1
    }

    $componentCount = ($sbom.components).Count
    Write-Host "✅ Loaded SBOM with $componentCount components" -ForegroundColor Green

    # Determine output paths
    if (Test-Path $OutputPath -PathType Container) {
        $baseFileName = [System.IO.Path]::GetFileNameWithoutExtension($SBOMPath)
        $htmlPath = Join-Path $OutputPath "$baseFileName-report.html"
        $csvPath = Join-Path $OutputPath "$baseFileName-report.csv"
        $mdPath = Join-Path $OutputPath "$baseFileName-report.md"
    } else {
        $htmlPath = $OutputPath
        $csvPath = $OutputPath -replace '\.html$', '.csv'
        $mdPath = $OutputPath -replace '\.html$', '.md'
    }

    # Export based on format
    $formats = if ($OutputFormat -eq "All") { @("HTML", "CSV", "Markdown") } else { @($OutputFormat) }

    foreach ($format in $formats) {
        switch ($format) {
            "HTML" {
                Write-Host "🌐 Generating HTML report..." -ForegroundColor Yellow
                $html = Generate-HTMLReport -SBOM $sbom
                Set-Content -Path $htmlPath -Value $html -Encoding UTF8
                Write-Host "   ✅ HTML saved to: $htmlPath" -ForegroundColor Green
            }
            "CSV" {
                Write-Host "📄 Generating CSV report..." -ForegroundColor Yellow
                $csv = Generate-CSVReport -SBOM $sbom
                $csv | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
                Write-Host "   ✅ CSV saved to: $csvPath" -ForegroundColor Green
            }
            "Markdown" {
                Write-Host "📝 Generating Markdown report..." -ForegroundColor Yellow
                $md = Generate-MarkdownReport -SBOM $sbom
                Set-Content -Path $mdPath -Value $md -Encoding UTF8
                Write-Host "   ✅ Markdown saved to: $mdPath" -ForegroundColor Green
            }
        }
    }

    Write-Host ""
    Write-Host "✨ SBOM export complete!" -ForegroundColor Green

} catch {
    Write-Error "Failed to export SBOM report: $_"
    exit 1
}

# Helper function to generate HTML report
function Generate-HTMLReport {
    param($SBOM)
    
    $componentRows = ($SBOM.components | ForEach-Object {
        "<tr><td>$($_.name)</td><td>$($_.version)</td><td>$($_.type)</td><td>$($_.purl ?? 'N/A')</td></tr>"
    }) -join "`n"
    
    $typeGroups = $SBOM.components | Group-Object type | Sort-Object Count -Descending
    $typeChart = ($typeGroups | ForEach-Object { "['$($_.Name)', $($_.Count)]" }) -join ", "
    
    @"
<!DOCTYPE html>
<html>
<head>
    <title>SBOM Report</title>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #0078D4; border-bottom: 3px solid #0078D4; padding-bottom: 10px; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 30px 0; }
        .stat-card { background: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #0078D4; }
        .stat-card h3 { margin: 0 0 10px 0; color: #666; font-size: 14px; }
        .stat-card .value { font-size: 32px; font-weight: bold; color: #0078D4; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th { background: #0078D4; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        tr:hover { background: #f8f9fa; }
        .chart { height: 300px; margin: 30px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📦 Software Bill of Materials (SBOM) Report</h1>
        <p><strong>Generated:</strong> $($SBOM.metadata.timestamp)</p>
        <p><strong>Format:</strong> CycloneDX $($SBOM.specVersion)</p>
        
        <div class="stats">
            <div class="stat-card">
                <h3>Total Components</h3>
                <div class="value">$(($SBOM.components).Count)</div>
            </div>
            <div class="stat-card">
                <h3>Component Types</h3>
                <div class="value">$(($SBOM.components | Group-Object type).Count)</div>
            </div>
            <div class="stat-card">
                <h3>Unique Names</h3>
                <div class="value">$(($SBOM.components | Select-Object -Unique name).Count)</div>
            </div>
        </div>

        <h2>📊 Component Types</h2>
        <div id="chart_div" class="chart"></div>

        <h2>📋 Component Inventory</h2>
        <table>
            <thead>
                <tr><th>Name</th><th>Version</th><th>Type</th><th>PURL</th></tr>
            </thead>
            <tbody>
                $componentRows
            </tbody>
        </table>
    </div>

    <script type="text/javascript">
        google.charts.load('current', {'packages':['corechart']});
        google.charts.setOnLoadCallback(drawChart);
        function drawChart() {
            var data = google.visualization.arrayToDataTable([
                ['Type', 'Count'],
                $typeChart
            ]);
            var options = { title: 'Components by Type', is3D: true, colors: ['#0078D4', '#50E6FF', '#00B294', '#FFB900', '#F25022'] };
            var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
            chart.draw(data, options);
        }
    </script>
</body>
</html>
"@
}

# Helper function to generate CSV report
function Generate-CSVReport {
    param($SBOM)
    
    $SBOM.components | Select-Object `
        @{N='Component';E={$_.name}},
        @{N='Version';E={$_.version}},
        @{N='Type';E={$_.type}},
        @{N='PURL';E={$_.purl}},
        @{N='License';E={$_.licenses.license.id -join ', '}}
}

# Helper function to generate Markdown report
function Generate-MarkdownReport {
    param($SBOM)
    
    $componentTable = ($SBOM.components | ForEach-Object {
        "| $($_.name) | $($_.version) | $($_.type) | $($_.purl ?? 'N/A') |"
    }) -join "`n"
    
    @"
# Software Bill of Materials (SBOM) Report

**Generated:** $($SBOM.metadata.timestamp)  
**Format:** CycloneDX $($SBOM.specVersion)  
**Serial Number:** $($SBOM.serialNumber)

## Summary Statistics

- **Total Components:** $(($SBOM.components).Count)
- **Component Types:** $(($SBOM.components | Group-Object type).Count)
- **Unique Names:** $(($SBOM.components | Select-Object -Unique name).Count)

## Component Types Breakdown

$(($SBOM.components | Group-Object type | Sort-Object Count -Descending | ForEach-Object { "- **$($_.Name):** $($_.Count)" }) -join "`n")

## Component Inventory

| Name | Version | Type | PURL |
|------|---------|------|------|
$componentTable

---

*Report generated by GitHub Copilot SBOM Generator*
"@
}
