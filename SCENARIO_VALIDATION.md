# Scenario Validation Tracker

This document tracks the testing and validation status of all scenarios in the repository. It is intended to persist across sessions and devices to ensure comprehensive coverage.

## Status Legend

- 🔴 **Not Started**: Validation has not begun.
- 🟡 **In Progress**: Validation is currently underway.
- 🟢 **Passed**: Scenario has been validated successfully.
- ❌ **Failed**: Scenario failed validation. See notes for details.
- ⚠️ **Blocked**: Validation is blocked by external factors.

## Validation Checklist

| Scenario ID | Scenario Name | Status | Content Valid? | Prompts Valid? | Infra Valid? | Last Validated | Notes |
|-------------|---------------|--------|----------------|----------------|--------------|----------------|-------|
| **S01** | Bicep Baseline | 🟢 Passed | 🟢 | 🟢 | 🟢 | 2025-11-20 13:46 |  |
| **S02** | Terraform Baseline | 🟢 Passed | 🟢 | 🟢 | 🟢 | 2025-11-20 13:46 |  |
| **S03** | Five Agent Workflow | 🟢 Passed | 🟢 | 🟢 | 🟢 | 2025-11-20 13:46 |  |
| **S04** | Documentation Generation | 🟢 Passed | 🟢 | 🟢 | 🟢 | 2025-11-20 13:46 |  |
| **S05** | Service Validation | 🟢 Passed | 🟢 | 🟢 | 🟢 | 2025-11-20 13:46 |  |
| **S06** | Troubleshooting | 🟢 Passed | 🟢 | 🟢 | 🟢 | 2025-11-20 13:46 |  |
| **S07** | SBOM Generator | 🟢 Passed | 🟢 | 🟢 | 🟢 | 2025-11-20 13:46 |  |
| **S08** | Diagrams as Code | 🟢 Passed | 🟢 | 🟢 | 🟢 | 2025-11-20 13:46 |  |

## Detailed Validation Logs

### Validation Criteria
1.  **Content**: Markdown files (README, DEMO-SCRIPT) are accurate, links work, no outdated references (e.g., `manual-approach`).
2.  **Prompts**: Prompt files exist, inputs/outputs are clear, business outcomes are defined.
3.  **Infra**: Code (Bicep/Terraform/Scripts) lints, builds, and deploys successfully.

### S01: Bicep Baseline

- **Test Plan**: Deploy Bicep templates, verify resources in Azure, run validation scripts.
- **Current Status**: Not Started.

### S02: Terraform Baseline

- **Test Plan**: Run `terraform init`, `plan`, `apply`. Verify state and resources.
- **Current Status**: Not Started.

### S03: Five Agent Workflow

- **Test Plan**: Execute the full 5-agent workflow (Plan -> ADR -> Architect -> Plan -> Implement). Verify handoffs and outputs.
- **Current Status**: Not Started.

### S04: Documentation Generation

- **Test Plan**: Generate documentation for a sample project. Verify markdown quality and diagram rendering.
- **Current Status**: Not Started.

### S05: Service Validation

- **Test Plan**: Run Pester tests against deployed infrastructure. Verify pass/fail reporting.
- **Current Status**: Not Started.

### S06: Troubleshooting

- **Test Plan**: Simulate a failure (e.g., misconfiguration). Use troubleshooting agent/guides to resolve.
- **Current Status**: Not Started.

### S07: SBOM Generator

- **Test Plan**: Generate SBOM for a sample app. Verify format (SPDX/CycloneDX) and vulnerability scan results.
- **Current Status**: Not Started.

### S08: Diagrams as Code

- **Test Plan**: Run Python scripts to generate diagrams. Verify image output matches architecture.
- **Current Status**: Not Started.




























