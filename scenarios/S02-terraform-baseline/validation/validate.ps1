$ErrorActionPreference = 'Stop'

$result = @{
    Status = "Passed"
    Content = "Passed"
    Prompts = "Passed"
    Infra = "Passed"
    Notes = @()
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

# 3. Infra Validation (Terraform Validate)
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    $tfFiles = Get-ChildItem "$PSScriptRoot/../solution" -Recurse -Filter "*.tf"
    if ($tfFiles.Count -eq 0) {
        $result.Infra = "Failed"
        $result.Status = "Failed"
        $result.Notes += "No Terraform files found in solution/"
    } else {
        # Initialize and validate in the solution directory (or environments/dev if structured that way)
        # Assuming solution/environments/dev exists based on README
        $devEnvPath = "$PSScriptRoot/../solution/environments/dev"
        if (Test-Path $devEnvPath) {
            Push-Location $devEnvPath
            try {
                terraform init -backend=false -no-color 2>&1 | Out-Null
                $validateOutput = terraform validate -no-color 2>&1
                if ($LASTEXITCODE -ne 0) {
                    $result.Infra = "Failed"
                    $result.Status = "Failed"
                    $result.Notes += "Terraform validation failed"
                }
            } catch {
                $result.Infra = "Failed"
                $result.Status = "Failed"
                $result.Notes += "Terraform error: $_"
            } finally {
                Pop-Location
            }
        } else {
            # Fallback to solution root if env structure missing
             $result.Infra = "Warning"
             $result.Notes += "environments/dev not found, skipping deep validation"
        }
    }
} else {
    $result.Infra = "Warning"
    $result.Notes += "Terraform CLI not installed, skipping validation"
}

# Return JSON
$result | ConvertTo-Json -Compress