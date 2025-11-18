# Agent Testing Procedures

**Version:** 1.0  
**Last Updated:** 2025-11-18  
**Purpose:** Step-by-step procedures for testing GitHub Copilot custom agents

---

## Table of Contents

1. [Pre-Test Setup](#pre-test-setup)
2. [Manual Testing Workflow](#manual-testing-workflow)
3. [Automated Testing Workflow](#automated-testing-workflow)
4. [Baseline Testing](#baseline-testing)
5. [Regression Testing](#regression-testing)
6. [Performance Testing](#performance-testing)
7. [Recording Results](#recording-results)

---

## Pre-Test Setup

### Prerequisites

Ensure the following are installed and configured:

```powershell
# 1. VS Code with GitHub Copilot
code --version
# Should be 1.85.0 or newer

# 2. PowerShell 7+
$PSVersionTable.PSVersion
# Should be 7.0.0 or newer

# 3. Bicep CLI (for implementation tests)
bicep --version
# Should be 0.20.0 or newer

# 4. Azure CLI (for deployment validation)
az --version
# Should be 2.50.0 or newer
```

### Environment Setup

```powershell
# Navigate to repository root
cd c:\Repos\github-copilot-itpro

# Verify agent files exist
Get-ChildItem .github\agents\*.agent.md | Select-Object Name

# Expected output:
# adr-generator.agent.md
# azure-principal-architect.agent.md
# bicep-plan.agent.md
# bicep-implement.agent.md

# Create test output directories
New-Item -ItemType Directory -Path "demos\agent-testing\actual-outputs\{agent-name}" -Force

# Reload VS Code to load latest agent definitions
# Ctrl+Shift+P > "Developer: Reload Window"
```

---

## Manual Testing Workflow

### Step 1: Select Test Scenario

```powershell
# Review available test scenarios
Get-Content demos\agent-testing\test-cases\azure-architect-tests.md

# Choose a test (e.g., Test 1: Basic WAF Assessment)
```

### Step 2: Prepare Test Environment

```powershell
# Create output file for this test
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outputFile = "demos\agent-testing\actual-outputs\azure-architect\test-01-basic-waf-$timestamp.md"

# Open a new file in VS Code to capture output
code $outputFile
```

### Step 3: Execute Test

1. **Open Copilot Chat** (`Ctrl+Shift+I` or `Ctrl+I`)
2. **Select Agent** (`Ctrl+Shift+A`)
   - Choose the agent you're testing (e.g., `azure-principal-architect`)
3. **Enter Test Prompt**
   - Copy prompt from test case file
   - Paste into chat
4. **Submit and Wait**
   - Agent processes request
   - Output appears in chat

### Step 4: Capture Output

```powershell
# Method 1: Copy from chat
# 1. Select all output from agent response
# 2. Copy (Ctrl+C)
# 3. Paste into output file
# 4. Save (Ctrl+S)

# Method 2: Use chat history
# 1. Right-click agent response
# 2. Select "Copy Response"
# 3. Paste into output file
```

### Step 5: Validate Output

```powershell
# Run validation script
.\demos\agent-testing\Validate-AgentOutput.ps1 `
    -Agent "azure-architect" `
    -TestName "test-01-basic-waf" `
    -OutputFile $outputFile

# Manual validation checklist (from test case):
# [ ] All 5 WAF pillars assessed
# [ ] Scores provided (X/10 format)
# [ ] Cost estimates included
# [ ] Documentation links present
# [ ] Trade-offs discussed
```

### Step 6: Compare with Expected Output

```powershell
# If expected output exists, compare
$expectedFile = "demos\agent-testing\expected-outputs\azure-architect\test-01-basic-waf.md"

if (Test-Path $expectedFile) {
    # Open diff view in VS Code
    code --diff $expectedFile $outputFile
}
```

### Step 7: Record Results

```powershell
# Update test results file
$result = @{
    TestName = "Azure Architect - Test 1: Basic WAF Assessment"
    Timestamp = Get-Date
    Status = "Pass" # or "Fail"
    Issues = @()
    Notes = "All validation criteria met"
}

# Append to results file
$result | ConvertTo-Json | 
    Add-Content "demos\agent-testing\test-results-$timestamp.json"
```

---

## Automated Testing Workflow

### Running the Test Suite

```powershell
# Run all tests
.\demos\agent-testing\Run-AgentTests.ps1 -Agent all -Verbose

# Run specific agent tests
.\demos\agent-testing\Run-AgentTests.ps1 -Agent azure-architect

# Run specific scenario
.\demos\agent-testing\Run-AgentTests.ps1 `
    -Agent bicep-plan `
    -Scenario "hub-spoke-network"

# Run specific test type
.\demos\agent-testing\Run-AgentTests.ps1 -TestType regression
```

### Interpreting Results

```powershell
# Results saved to:
# demos\agent-testing\test-results\test-results-YYYYMMDD-HHMMSS.json

# View summary
Get-Content "demos\agent-testing\test-results\test-results-*.json" | 
    ConvertFrom-Json | 
    Select-Object TotalTests, PassedTests, FailedTests, SkippedTests
```

### Generating Reports

```powershell
# Generate HTML report
.\demos\agent-testing\Generate-TestReport.ps1 `
    -OutputPath "demos\agent-testing\test-results\report-$timestamp.html"

# Open report in browser
Start-Process "demos\agent-testing\test-results\report-$timestamp.html"
```

---

## Baseline Testing

**Purpose:** Establish baseline performance before implementing improvements

### Procedure

```powershell
# 1. Create baseline directory
$baselineDir = "demos\agent-testing\baseline\run-$(Get-Date -Format 'yyyyMMdd')"
New-Item -ItemType Directory -Path $baselineDir -Force

# 2. Run simplified test suite (core functionality only)
.\demos\agent-testing\Run-AgentTests.ps1 `
    -Agent all `
    -Baseline

# 3. Save outputs to baseline directory
# Outputs will be in: demos\agent-testing\actual-outputs\
# Move to baseline for preservation
Move-Item -Path "demos\agent-testing\actual-outputs\*" -Destination $baselineDir

# 4. Document baseline metrics
@{
    Date = Get-Date
    AgentVersions = @{
        ADRGenerator = "1.0.0"
        AzureArchitect = "1.0.0"
        BicepPlan = "1.0.0"
        BicepImplement = "1.0.0"
    }
    Metrics = @{
        AverageWorkflowTime = "60 minutes"
        ClarificationQuestions = "8-10"
        TestPassRate = "N/A"
    }
} | ConvertTo-Json | Out-File "$baselineDir\baseline-metrics.json"
```

---

## Regression Testing

**Purpose:** Ensure improvements don't break existing functionality

### Procedure

```powershell
# 1. Load baseline test cases
$baselineTests = Get-ChildItem "demos\agent-testing\baseline\run-*\*.md"

# 2. Re-run same prompts with current agent versions
foreach ($baselineTest in $baselineTests) {
    Write-Host "Testing: $($baselineTest.Name)"
    
    # Extract prompt from baseline file
    # Run with current agent
    # Compare output format and key features
}

# 3. Compare results
# - Output format should be consistent
# - Core functionality preserved
# - New features added (not replaced)

# 4. Document any breaking changes
```

### Regression Test Checklist

- [ ] All baseline tests still produce valid output
- [ ] Output format is consistent with baseline
- [ ] No errors introduced in previously working scenarios
- [ ] New features enhance (not replace) existing functionality
- [ ] Performance hasn't degraded by >20%

---

## Performance Testing

### Measuring Response Time

```powershell
# Time agent response
$startTime = Get-Date

# [Execute agent prompt here]
# Wait for complete response

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

Write-Host "Agent response time: $duration seconds"

# Record in performance log
@{
    Agent = "azure-architect"
    Test = "basic-waf-assessment"
    ResponseTime = $duration
    Timestamp = Get-Date
} | ConvertTo-Json | Add-Content "demos\agent-testing\performance-log.json"
```

### Performance Benchmarks

| Agent | Test Scenario | Target Time | Acceptable Range |
|-------|---------------|-------------|-------------------|
| ADR Generator | Basic ADR | < 30 sec | 20-45 sec |
| Azure Architect | WAF Assessment | < 30 sec | 25-45 sec |
| Bicep Planning | Simple infra | < 45 sec | 30-60 sec |
| Bicep Implementation | Single module | < 30 sec | 20-45 sec |

### Measuring Accuracy

```powershell
# Cost Estimation Accuracy
# 1. Get agent cost estimate
$agentEstimate = 472 # Example: $472/month

# 2. Calculate actual using Azure Pricing Calculator
$actualCost = 495 # Example: $495/month

# 3. Calculate accuracy
$accuracy = 1 - [Math]::Abs($agentEstimate - $actualCost) / $actualCost
$accuracyPercent = $accuracy * 100

Write-Host "Cost accuracy: $accuracyPercent%" # Target: ±20% (80-120%)
```

---

## Recording Results

### Test Result Format

```json
{
  "testName": "Azure Architect - Test 1: Basic WAF Assessment",
  "agent": "azure-principal-architect",
  "version": "1.1.0",
  "timestamp": "2025-11-18T10:30:00Z",
  "status": "Pass",
  "duration": 28.5,
  "validations": [
    {
      "check": "All WAF pillars assessed",
      "result": true,
      "details": "Found 5/5 pillars"
    },
    {
      "check": "Scoring included",
      "result": true,
      "details": "Scores in X/10 format found"
    },
    {
      "check": "Cost estimates",
      "result": true,
      "details": "Cost table with ranges provided"
    }
  ],
  "issues": [],
  "notes": "All validation criteria met. Output quality excellent."
}
```

### Updating Test Results Document

```powershell
# Append to TESTING-RESULTS.md
$results = @"

### Run #X - $(Get-Date -Format "yyyy-MM-dd")
**Objective:** $objective

**Test Scenarios:**
- [x] ADR Generator: Basic decision documentation
- [x] Azure Architect: Simple WAF assessment
- [ ] Bicep Planning: Single-region infrastructure
- [ ] Bicep Implementation: VNet with subnets

**Results:**
- Total Tests: 15
- Passed: 12
- Failed: 1
- Skipped: 2
- Pass Rate: 92.3%

**Issues Found:**
1. Cost estimates off by >30% in Test 4 (investigating)
2. Mermaid diagram syntax error in Test 7 (fixed)

**Next Steps:**
- Fix identified issues
- Re-run failed tests
- Update expected outputs

"@

Add-Content "docs\agent-improvements\TESTING-RESULTS.md" -Value $results
```

---

## Best Practices

### Testing Best Practices

1. **Test in Clean Environment**
   - Close other workspaces
   - Clear chat history
   - Reload window before test run

2. **Use Consistent Prompts**
   - Copy exact prompt from test case
   - Don't paraphrase or modify
   - Maintain consistency across runs

3. **Document Everything**
   - Save all outputs
   - Record timestamps
   - Note any deviations

4. **Test Incrementally**
   - Don't run all tests at once
   - Test one agent at a time
   - Validate results before proceeding

5. **Compare with Baseline**
   - Always compare with baseline results
   - Note improvements and regressions
   - Update expected outputs when appropriate

### When to Re-test

- After any agent definition changes
- Before releasing new version
- Weekly during active development
- Monthly for maintenance
- After VS Code or Copilot updates

---

## Troubleshooting Test Failures

### Test Failure Checklist

1. [ ] Verify agent file hasn't been corrupted
2. [ ] Check VS Code window was reloaded
3. [ ] Confirm correct agent was selected
4. [ ] Verify prompt was copied correctly
5. [ ] Check network connectivity
6. [ ] Review agent response for error messages
7. [ ] Compare with previous successful run
8. [ ] Check for known issues in troubleshooting guide

### Common Test Failures

**Failure:** Agent produces no output
**Solution:** Reload VS Code, verify agent file syntax

**Failure:** Output missing expected sections
**Solution:** Check if prompt was complete, increase specificity

**Failure:** Validation criteria not met
**Solution:** Update agent definition or expected output

---

## Appendix: Quick Reference

### Common Commands

```powershell
# Reload VS Code
# Ctrl+Shift+P > "Developer: Reload Window"

# Open agent selector
# Ctrl+Shift+A

# Run all tests
.\demos\agent-testing\Run-AgentTests.ps1 -Agent all

# Validate specific output
.\demos\agent-testing\Validate-AgentOutput.ps1 `
    -Agent "azure-architect" `
    -OutputFile "path\to\output.md"

# Generate report
.\demos\agent-testing\Generate-TestReport.ps1
```

### File Locations

- **Test Cases:** `demos/agent-testing/test-cases/`
- **Expected Outputs:** `demos/agent-testing/expected-outputs/`
- **Actual Outputs:** `demos/agent-testing/actual-outputs/`
- **Test Results:** `demos/agent-testing/test-results/`
- **Baseline:** `demos/agent-testing/baseline/`

---

**Maintained By:** GitHub Copilot IT Pro Team  
**Last Updated:** 2025-11-18  
**Version:** 1.0
