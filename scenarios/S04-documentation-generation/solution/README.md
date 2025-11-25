# Documentation Generation Scripts

This folder contains PowerShell scripts that generate context-rich prompts for Copilot
to create professional Azure documentation.

## Understanding the Approach

These scripts **do not generate final documentation directly**. Instead, they:

1. Query Azure Resource Graph for accurate resource data
2. Structure the data for documentation purposes
3. Generate a **prompt file** with data + template
4. You paste the prompt into Copilot Chat to generate final docs
5. You review and refine the output

**Why this approach?**

| Benefit | Explanation |
|---------|-------------|
| **Accuracy** | Data comes directly from Azure, not AI guessing |
| **Control** | You can customize the prompt before generation |
| **Learning** | You see how prompts are structured |
| **Quality** | Human-in-the-loop catches AI errors |
| **Flexibility** | Easy to regenerate with different parameters |

## Scripts Overview

| Script | Purpose | Output |
|--------|---------|--------|
| `ArchitectureDoc.ps1` | Architecture documentation | Resource inventory, diagrams, security analysis |
| `Day2OperationsGuide.ps1` | Day 2 operations | Daily/weekly/monthly procedures, monitoring queries |
| `TroubleshootingGuide.ps1` | Troubleshooting playbooks | Issue patterns, diagnostic steps, resolution procedures |
| `APIDocumentation.ps1` | API documentation | Endpoint inventory, authentication, examples |

## Quick Start

```powershell
# 1. Connect to Azure
Connect-AzAccount
Set-AzContext -Subscription "Your-Subscription"

# 2. Run a documentation script
./ArchitectureDoc.ps1 -ResourceGroupName "rg-prod" -OutputPath "./output"

# 3. Open the generated prompt
code ./output/architecture-prompt.txt

# 4. Copy contents to Copilot Chat

# 5. Review and save generated documentation
```

## Script Details

### ArchitectureDoc.ps1

Generates architecture documentation prompt including:
- Executive summary with resource statistics
- Complete resource inventory table
- Mermaid architecture diagram syntax
- Network topology (VNets, subnets, NSGs)
- Security controls analysis
- Cost estimates (when possible)

**Parameters:**

```powershell
./ArchitectureDoc.ps1 `
    -ResourceGroupName "rg-prod" `      # Required: Resource group to document
    -OutputPath "./output" `            # Optional: Output directory (default: ./output)
    -IncludeDiagrams `                  # Optional: Generate Mermaid diagram data
    -IncludeNetworkTopology `           # Optional: Include network details
    -IncludeCostAnalysis                # Optional: Include cost estimates
```

### Day2OperationsGuide.ps1

Generates operations guide prompt including:
- Daily operations (health checks, log review, backup verification)
- Weekly operations (performance review, cost analysis, security scan)
- Monthly operations (capacity planning, DR testing, patch review)
- Scaling procedures (manual and auto-scale)
- Resource-specific monitoring queries (KQL)

**Parameters:**

```powershell
./Day2OperationsGuide.ps1 `
    -ResourceGroupName "rg-prod" `      # Required: Resource group to document
    -OutputPath "./output" `            # Optional: Output directory
    -IncludeKQLQueries `                # Optional: Include monitoring queries
    -IncludeScalingProcedures           # Optional: Include scaling documentation
```

### TroubleshootingGuide.ps1

Generates troubleshooting guide prompt including:
- Resource-specific failure patterns
- Diagnostic procedures with commands
- KQL queries for Application Insights
- Decision tree structure for triage
- Escalation criteria

**Parameters:**

```powershell
./TroubleshootingGuide.ps1 `
    -ResourceGroupName "rg-prod" `      # Required: Resource group to document
    -OutputPath "./output" `            # Optional: Output directory
    -IncludeDiagnostics `               # Optional: Include diagnostic commands
    -IncludeRunbooks                    # Optional: Include remediation runbooks
```

### APIDocumentation.ps1

Generates API documentation prompt including:
- API-capable resource inventory (App Services, Functions, APIM)
- Authentication patterns
- Endpoint documentation structure
- Code example templates (PowerShell, Python, C#)
- Error handling patterns

**Parameters:**

```powershell
./APIDocumentation.ps1 `
    -ResourceGroupName "rg-prod" `      # Required: Resource group to document
    -OutputPath "./output" `            # Optional: Output directory
    -IncludeAuthentication `            # Optional: Include auth documentation
    -IncludeExamples `                  # Optional: Include code examples
    -IncludeSDKs                        # Optional: Include SDK generation guidance
```

## The Workflow

```
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 1: Run Script                                                      │
│                                                                         │
│   ./ArchitectureDoc.ps1 -ResourceGroupName "rg-prod"                   │
│                                                                         │
│   Script queries Azure → Structures data → Generates prompt file        │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 2: Review Prompt                                                   │
│                                                                         │
│   code ./output/architecture-prompt.txt                                │
│                                                                         │
│   - Verify data looks correct                                          │
│   - Add organization-specific requirements                              │
│   - Customize template sections if needed                               │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 3: Generate with Copilot                                          │
│                                                                         │
│   - Copy prompt contents                                               │
│   - Paste into GitHub Copilot Chat                                     │
│   - Wait for generation (30-60 seconds typically)                      │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ STEP 4: Review & Refine                                                │
│                                                                         │
│   - Verify accuracy against Azure Portal                               │
│   - Check diagrams render correctly                                    │
│   - Add organization-specific context                                  │
│   - Save as final documentation                                        │
└─────────────────────────────────────────────────────────────────────────┘
```

## Output Directory Structure

After running scripts, the `output/` directory contains:

```
output/
├── architecture-prompt.txt       # Architecture documentation prompt
├── day2-operations-prompt.txt    # Operations guide prompt
├── troubleshooting-prompt.txt    # Troubleshooting guide prompt
├── api-documentation-prompt.txt  # API documentation prompt
└── raw-data/                     # (Optional) Raw query results for debugging
    ├── resources.json
    ├── network.json
    └── security.json
```

## Customization

### Adding Organization Standards

Edit the prompt template sections in each script to include your standards:

```powershell
# In ArchitectureDoc.ps1, find the prompt template section:
$customRequirements = @"
## Organization Standards
- Use ACME Corp document template
- Include "Confidential" footer
- Reference internal wiki for procedures
- Follow ISO 27001 documentation requirements
"@
```

### Adding New Documentation Types

Copy an existing script and modify:

1. Update the Resource Graph queries for your data needs
2. Modify the prompt template structure
3. Adjust the output formatting

### Changing Diagram Styles

The scripts generate Mermaid syntax. Customize diagram appearance:

```powershell
# Change from top-bottom to left-right layout
$diagramDirection = "LR"  # Instead of "TB"

# Add custom styling
$mermaidStyle = @"
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#0078D4'}}}%%
"@
```

## Troubleshooting

### Script Errors

**"Not connected to Azure"**
```powershell
Connect-AzAccount
Set-AzContext -Subscription "Your-Subscription"
```

**"Resource group not found"**
```powershell
# Verify resource group exists
Get-AzResourceGroup -Name "rg-prod"
```

**"No resources returned"**
```powershell
# Check resources exist in the group
Get-AzResource -ResourceGroupName "rg-prod" | Select Name, Type
```

### Prompt Issues

**Generated documentation is too generic:**
- Add more specific requirements to the prompt
- Include actual resource names in the template
- Ask Copilot to "be specific about {resource name}"

**Diagrams don't render:**
- Check Mermaid syntax in the prompt
- Validate at [mermaid.live](https://mermaid.live/)
- Ensure proper code block markers (\`\`\`mermaid)

**Missing sections:**
- Verify data was collected (check `output/raw-data/`)
- Add explicit section requirements to prompt
- Regenerate with additional flags

## Related Files

- `examples/copilot-documentation-conversation.md` - Full learning conversation
- `prompts/effective-prompts.md` - Prompt patterns and best practices
- `scenario/requirements.md` - TechCorp scenario details

---

**Remember:** These scripts generate PROMPTS, not final documentation. The workflow is:
Script → Prompt → Copilot → Review → Final Docs
