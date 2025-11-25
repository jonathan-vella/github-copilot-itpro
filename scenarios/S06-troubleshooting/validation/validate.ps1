$result = @{
    Status = "Failed"
    Content = "Failed"
    Prompts = "Failed"
    Infra = "Failed"
    Notes = ""
}

$scenarioRoot = Resolve-Path "$PSScriptRoot/.."
$solutionPath = Join-Path $scenarioRoot "solution"
$readmePath = Join-Path $scenarioRoot "README.md"
$demoScriptPath = Join-Path $scenarioRoot "DEMO-SCRIPT.md"

# Check Content
if ((Test-Path $readmePath) -and (Test-Path $demoScriptPath)) {
    $result.Content = "Passed"
} else {
    $result.Notes += "Missing README.md or DEMO-SCRIPT.md. "
}

# Check Prompts
$promptsPath = Join-Path $scenarioRoot "prompts"
if ((Test-Path $promptsPath) -and (Get-ChildItem $promptsPath *.md).Count -ge 1) {
    $result.Prompts = "Passed"
} else {
    $result.Notes += "Missing prompts or prompt files. "
}

# Check Solution Scripts
$scripts = @(
    "Get-AzureHealthSnapshot.ps1",
    "Invoke-DiagnosticQuery.ps1"
)

$missingScripts = @()
foreach ($script in $scripts) {
    if (-not (Test-Path (Join-Path $solutionPath $script))) {
        $missingScripts += $script
    }
}

if ($missingScripts.Count -eq 0) {
    $result.Infra = "Passed"
} else {
    $result.Infra = "Failed"
    $result.Notes += "Missing scripts: $($missingScripts -join ', '). "
}

# Final Status
if ($result.Content -eq "Passed" -and $result.Infra -eq "Passed" -and $result.Prompts -eq "Passed") {
    $result.Status = "Passed"
}

$result | ConvertTo-Json -Compress