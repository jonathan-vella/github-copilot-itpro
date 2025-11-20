$result = @{
    Status  = "Failed"
    Content = "Failed"
    Prompts = "Failed"
    Infra   = "Failed"
    Notes   = ""
}

$scenarioRoot = Resolve-Path "$PSScriptRoot/.."
$solutionPath = Join-Path $scenarioRoot "solution"
$readmePath = Join-Path $scenarioRoot "README.md"
$demoScriptPath = Join-Path $scenarioRoot "DEMO-SCRIPT.md"

# Check Content
if ((Test-Path $readmePath) -and (Test-Path $demoScriptPath)) {
    $result.Content = "Passed"
}
else {
    $result.Notes += "Missing README.md or DEMO-SCRIPT.md. "
}

# Check Prompts
$promptsPath = Join-Path $scenarioRoot "prompts"
if ((Test-Path $promptsPath) -and (Get-ChildItem $promptsPath *.md).Count -ge 4) {
    $result.Prompts = "Passed"
}
else {
    $result.Notes += "Missing prompts or not enough prompt files. "
}

# Check Infra (Bicep)
$bicepMain = Join-Path $solutionPath "infrastructure/main.bicep"
if (Test-Path $bicepMain) {
    # Try to build bicep
    try {
        $buildOutput = bicep build $bicepMain --stdout 2>&1
        if ($LASTEXITCODE -eq 0) {
            $result.Infra = "Passed"
        }
        else {
            $result.Infra = "Failed"
            $result.Notes += "Bicep build failed. "
        }
    }
    catch {
        $result.Infra = "Failed"
        $result.Notes += "Bicep build exception. "
    }
}
else {
    $result.Infra = "Failed"
    $result.Notes += "Missing main.bicep. "
}

# Check Application
$appPath = Join-Path $solutionPath "application/TaskManager.Web"
if (-not (Test-Path $appPath)) {
    $result.Infra = "Failed"
    $result.Notes += "Missing application code. "
}

# Final Status
if ($result.Content -eq "Passed" -and $result.Infra -eq "Passed" -and $result.Prompts -eq "Passed") {
    $result.Status = "Passed"
}

$result | ConvertTo-Json -Compress