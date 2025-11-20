<#
.SYNOPSIS
    Runs validation tests for scenarios and updates SCENARIO_VALIDATION.md.

.DESCRIPTION
    This script iterates through the specified scenarios, looks for a validation script,
    executes it, and updates the status in the SCENARIO_VALIDATION.md file.
    
    It expects a standard validation script at: scenarios/<ScenarioFolder>/validation/validate.ps1
    
    The validate.ps1 script should return a custom object or JSON with:
    {
        Status: "Passed"|"Failed"
        Content: "Passed"|"Failed"
        Prompts: "Passed"|"Failed"
        Infra: "Passed"|"Failed"
        Notes: "..."
    }

.PARAMETER Scenarios
    List of Scenario IDs to validate (e.g., "S01", "S08"). Default is all.

.EXAMPLE
    ./scripts/validate-scenarios.ps1 -Scenarios "S01"
#>

param (
    [string[]]$Scenarios = @("S01", "S02", "S03", "S04", "S05", "S06", "S07", "S08")
)

$RepoRoot = Resolve-Path "$PSScriptRoot/.."
$ValidationFile = Join-Path $RepoRoot "SCENARIO_VALIDATION.md"

function Get-StatusIcon {
    param ([string]$Status)
    switch ($Status) {
        "Not Started" { return "🔴" }
        "In Progress" { return "🟡" }
        "Passed" { return "🟢" }
        "Failed" { return "❌" }
        "Blocked" { return "⚠️" }
        Default { return "🔴" }
    }
}

function Update-ScenarioStatus {
    param (
        [string]$Id,
        [string]$Status,
        [string]$ContentStatus,
        [string]$PromptsStatus,
        [string]$InfraStatus,
        [string]$Notes
    )

    $Date = Get-Date -Format "yyyy-MM-dd HH:mm"
    $FileContent = Get-Content $ValidationFile -Raw

    # Regex to match the new table row format:
    # | **ID** | Name | Status | Content | Prompts | Infra | Last Validated | Notes |
    # We use a more flexible regex to handle varying whitespace
    $Pattern = "\|\s*\*\*$Id\*\*\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|"
    
    if ($FileContent -match $Pattern) {
        $Name = $matches[1].Trim()
        $CurrentStatus = $matches[2].Trim()
        $CurrentContent = $matches[3].Trim()
        $CurrentPrompts = $matches[4].Trim()
        $CurrentInfra = $matches[5].Trim()
        $CurrentNotes = $matches[7].Trim()

        # Use provided values or fall back to existing
        $NewStatusStr = if ($Status) { "$(Get-StatusIcon $Status) $Status" } else { $CurrentStatus }
        $NewContentStr = if ($ContentStatus) { "$(Get-StatusIcon $ContentStatus)" } else { $CurrentContent }
        $NewPromptsStr = if ($PromptsStatus) { "$(Get-StatusIcon $PromptsStatus)" } else { $CurrentPrompts }
        $NewInfraStr = if ($InfraStatus) { "$(Get-StatusIcon $InfraStatus)" } else { $CurrentInfra }
        
        if ($PSBoundParameters.ContainsKey('Notes')) {
            $NewNotes = $Notes
        }
        else {
            $NewNotes = $CurrentNotes
        }

        $NewRow = "| **$Id** | $Name | $NewStatusStr | $NewContentStr | $NewPromptsStr | $NewInfraStr | $Date | $NewNotes |"
        
        $FileContent = $FileContent -replace $Pattern, $NewRow
        Set-Content -Path $ValidationFile -Value $FileContent -Encoding UTF8
        Write-Host "Updated $Id status in SCENARIO_VALIDATION.md" -ForegroundColor Cyan
    }
    else {
        Write-Warning "Could not find entry for $Id in SCENARIO_VALIDATION.md"
    }
}

# Main Loop
foreach ($Id in $Scenarios) {
    Write-Host "Processing $Id..." -ForegroundColor Green
    
    # Find the scenario folder
    $ScenarioFolder = Get-ChildItem -Path "$RepoRoot/scenarios" -Directory | Where-Object { $_.Name -like "$Id-*" } | Select-Object -First 1
    
    if (-not $ScenarioFolder) {
        Write-Warning "Folder for $Id not found."
        Update-ScenarioStatus -Id $Id -Status "Blocked" -Notes "Folder not found"
        continue
    }

    Update-ScenarioStatus -Id $Id -Status "In Progress"

    $ValidationPath = Join-Path $ScenarioFolder.FullName "validation"
    $ValidateScript = Join-Path $ValidationPath "validate.ps1"
    
    if (Test-Path $ValidateScript) {
        Write-Host "Running validation for $Id..."
        try {
            # Execute validation script and capture output
            $RawResult = & $ValidateScript -ErrorAction Stop
            
            # Try to parse as JSON if it's a string
            if ($RawResult -is [string]) {
                try {
                    $Result = $RawResult | ConvertFrom-Json
                }
                catch {
                    $Result = $RawResult # Keep as string if not JSON
                }
            }
            else {
                $Result = $RawResult
            }
            
            if ($Result -is [System.Collections.IDictionary] -or $Result -is [PSCustomObject]) {
                Update-ScenarioStatus -Id $Id `
                    -Status $Result.Status `
                    -ContentStatus $Result.Content `
                    -PromptsStatus $Result.Prompts `
                    -InfraStatus $Result.Infra `
                    -Notes ($Result.Notes -join "; ")
            }
            else {
                # Fallback if script doesn't return structured data
                $Status = if ($LASTEXITCODE -eq 0) { "Passed" } else { "Failed" }
                Update-ScenarioStatus -Id $Id -Status $Status -Notes "Script executed (legacy mode)"
            }
        }
        catch {
            Update-ScenarioStatus -Id $Id -Status "Failed" -Notes "Script error: $($_.Exception.Message)"
        }
    }
    else {
        Update-ScenarioStatus -Id $Id -Status "Blocked" -Notes "No validate.ps1 found"
    }
}