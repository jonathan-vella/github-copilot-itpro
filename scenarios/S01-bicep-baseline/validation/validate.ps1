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
if (-not (Test-Path "$PSScriptRoot/../prompts/effective-prompts.md")) {
    $result.Prompts = "Failed"
    $result.Status = "Failed"
    $result.Notes += "Missing prompts/effective-prompts.md"
}

# 3. Infra Validation (Bicep Lint)
if (Get-Command bicep -ErrorAction SilentlyContinue) {
    $bicepFiles = Get-ChildItem "$PSScriptRoot/../solution/*.bicep"
    if ($bicepFiles.Count -eq 0) {
        $result.Infra = "Failed"
        $result.Status = "Failed"
        $result.Notes += "No Bicep files found in solution/"
    }
    else {
        foreach ($file in $bicepFiles) {
            # Capture stderr as well
            $lintOutput = $null
            try {
                $lintOutput = bicep lint $file.FullName 2>&1
            }
            catch {
                $lintOutput = $_.Exception.Message
            }
            
            if ($lintOutput -match "Error") {
                $result.Infra = "Failed"
                $result.Status = "Failed"
                $result.Notes += "Bicep lint errors in $($file.Name)"
            }
        }
    }
}
else {
    $result.Infra = "Warning"
    $result.Notes += "Bicep CLI not installed, skipping lint"
}

# Return JSON
$result | ConvertTo-Json -Compress