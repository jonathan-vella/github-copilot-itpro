$ErrorActionPreference = 'Stop'

$result = @{
    Status  = "Passed"
    Content = "Passed"
    Prompts = "Passed"
    Infra   = "Passed"
    Notes   = @()
}

# 1. Content Validation
$requiredFiles = @("README.md", "DEMO-SCRIPT.md")
foreach ($file in $requiredFiles) {
    if (-not (Test-Path "$PSScriptRoot/../$file")) {
        $result.Content = "Failed"
        $result.Status = "Failed"
        $result.Notes += "Missing file: $file"
    }
}

# 2. Prompts Validation
if (-not (Test-Path "$PSScriptRoot/../prompts/workflow-prompts.md")) {
    $result.Prompts = "Failed"
    $result.Status = "Failed"
    $result.Notes += "Missing prompts/workflow-prompts.md"
}

# 3. Infra Validation (Bicep Lint on the shared infra folder)
$infraPath = Resolve-Path "$PSScriptRoot/../../../infra/bicep/contoso-patient-portal"
if (-not (Test-Path $infraPath)) {
    $result.Infra = "Failed"
    $result.Status = "Failed"
    $result.Notes += "Infra folder not found at $infraPath"
}
else {
    if (Get-Command bicep -ErrorAction SilentlyContinue) {
        $mainBicep = Join-Path $infraPath "main.bicep"
        if (Test-Path $mainBicep) {
            # Capture stderr as well
            $lintOutput = $null
            try {
                $lintOutput = bicep lint $mainBicep 2>&1
            }
            catch {
                $lintOutput = $_.Exception.Message
            }
            
            if ($lintOutput -match "Error") {
                $result.Infra = "Failed"
                $result.Status = "Failed"
                $result.Notes += "Bicep lint errors in main.bicep"
            }
        }
        else {
            $result.Infra = "Failed"
            $result.Status = "Failed"
            $result.Notes += "main.bicep not found in infra folder"
        }
    }
    else {
        $result.Infra = "Warning"
        $result.Notes += "Bicep CLI not installed, skipping lint"
    }
}

# Return JSON
$result | ConvertTo-Json -Compress