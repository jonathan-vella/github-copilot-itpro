# GitHub Copilot Custom Agents - Troubleshooting Guide

**Version:** 1.0  
**Last Updated:** 2025-11-18

---

## Table of Contents

1. [Common Issues](#common-issues)
2. [Agent-Specific Troubleshooting](#agent-specific-troubleshooting)
3. [Performance Issues](#performance-issues)
4. [Output Quality Issues](#output-quality-issues)
5. [Integration Issues](#integration-issues)
6. [Advanced Troubleshooting](#advanced-troubleshooting)
7. [Getting Help](#getting-help)

---

## Common Issues

### Issue 1: Agent Not Responding

**Symptoms:**

- No output after selecting agent
- VS Code appears frozen
- Agent dropdown doesn't show custom agents

**Common Causes:**

1. Agent definition file has syntax errors
2. VS Code hasn't loaded custom agents
3. GitHub Copilot extension not activated
4. Agent file not in correct location

**Solutions:**

```powershell
# 1. Verify agent files exist
Get-ChildItem .github\agents\*.agent.md

# Expected output: 4 agent files
# - adr-generator.agent.md
# - azure-principal-architect.agent.md
# - bicep-plan.agent.md
# - bicep-implement.agent.md
```

**Fix 1: Reload VS Code Window**

1. Press `Ctrl+Shift+P`
2. Type "Reload Window"
3. Select "Developer: Reload Window"
4. Wait 10-15 seconds for agents to load
5. Try again with `Ctrl+Shift+A`

**Fix 2: Check Agent File Syntax**

```powershell
# Validate YAML front matter
$agentFile = ".github\agents\azure-principal-architect.agent.md"
$content = Get-Content $agentFile -Raw

# Check for YAML front matter
if ($content -match '^```chatagent\s+---(.+?)---') {
    Write-Host "✓ Front matter found" -ForegroundColor Green
} else {
    Write-Host "✗ Front matter missing or malformed" -ForegroundColor Red
}
```

**Fix 3: Verify GitHub Copilot Extension**

1. Open Extensions view (`Ctrl+Shift+X`)
2. Search for "GitHub Copilot"
3. Ensure extension is enabled and up to date
4. Check for "GitHub Copilot Chat" extension as well

---

### Issue 2: Agent Produces Incomplete Output

**Symptoms:**

- Output cuts off mid-sentence
- Missing expected sections
- Partial responses

**Common Causes:**

1. Token limit reached
2. Prompt too complex
3. Context overflow
4. Agent interrupted

**Solutions:**

**Fix 1: Simplify Prompt**

```markdown
❌ Too Complex:
Design a complete enterprise architecture with multi-region HA, 
DR, security, compliance, cost optimization, monitoring, and 
provide detailed implementation plan with all Bicep code.

✅ Simplified (use agent handoffs):
Design a multi-region HA architecture for a web application.
[Get architecture recommendations, then hand off to planning agent]
```

**Fix 2: Break Into Multiple Prompts**

```markdown
# Step 1: Get architecture
Agent: azure-principal-architect
Prompt: Design multi-region HA web app architecture

# Step 2: Get plan
Agent: bicep-plan
Prompt: Create implementation plan for the architecture above

# Step 3: Implement
Agent: bicep-implement
Prompt: Implement Phase 1 from the plan
```

**Fix 3: Use Agent Handoffs**

- Instead of asking one agent to do everything
- Use handoff buttons to pass context to next agent
- Each agent focuses on its specialty

---

### Issue 3: Cost Estimates Missing or Inaccurate

**Symptoms:**

- No cost information in architect recommendations
- Cost estimates significantly off from Azure pricing
- Cost table not formatted correctly

**Common Causes:**

1. Agent definition not updated with cost estimation feature
2. Microsoft Docs MCP server not accessible
3. Prompt doesn't explicitly request cost info

**Solutions:**

**Fix 1: Verify Agent Version**

```powershell
# Check if agent has cost estimation feature
$agentFile = ".github\agents\azure-principal-architect.agent.md"
$content = Get-Content $agentFile -Raw

if ($content -match 'Cost Estimation|cost estimate') {
    Write-Host "✓ Cost estimation feature present" -ForegroundColor Green
} else {
    Write-Host "✗ Cost estimation feature missing" -ForegroundColor Red
    Write-Host "Update agent to version 1.1.0+" -ForegroundColor Yellow
}
```

**Fix 2: Explicitly Request Cost Info**

```markdown
❌ Vague:
Design an architecture for my web app

✅ Explicit:
Design an architecture for my web app and provide detailed cost estimates
```

**Fix 3: Validate Against Azure Pricing Calculator**

- Use [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
- Compare agent estimates with calculator
- Report discrepancies if > 30% difference

---

### Issue 4: Dependency Diagrams Not Rendering

**Symptoms:**

- Mermaid code appears but doesn't render
- Diagram shows as plain text
- Syntax errors in Mermaid code

**Common Causes:**

1. Mermaid extension not installed
2. Markdown preview not showing diagrams
3. Syntax errors in Mermaid code

**Solutions:**

**Fix 1: Install Mermaid Extension**

1. Press `Ctrl+Shift+X`
2. Search for "Markdown Preview Mermaid Support"
3. Install extension by Matt Bierner
4. Reload window

**Fix 2: Use Markdown Preview**

1. Open .md file with diagram
2. Press `Ctrl+Shift+V` for preview
3. Diagram should render automatically

**Fix 3: Validate Mermaid Syntax**

```powershell
# Copy Mermaid code and validate at:
# https://mermaid.live/

# Common syntax errors:
# - Missing 'graph TD' or 'graph LR' declaration
# - Invalid node names (spaces, special chars)
# - Incorrect arrow syntax (should be '-->' not '->')
```

---

### Issue 5: Progressive Implementation Not Used

**Symptoms:**

- Implementation agent generates all code at once
- No phase-based deployment
- Complex infrastructure not broken down

**Common Causes:**

1. Prompt doesn't indicate complexity
2. Agent determines infrastructure is simple enough
3. Implementation plan doesn't have phases

**Solutions:**

**Fix 1: Explicitly Request Progressive Implementation**

```markdown
Implement the infrastructure using progressive implementation pattern.
Deploy in phases with validation between each phase.
```

**Fix 2: Ensure Plan Has Phases**

```markdown
# When using bicep-plan agent:
Create a plan with at least 3 phases:
1. Foundation resources
2. Security and networking
3. Compute and data resources
```

**Fix 3: Verify Complexity Threshold**

- Progressive implementation recommended for:
  - 10+ resources
  - 3+ modules
  - Complex dependencies
  - Multi-tier applications

---

## Agent-Specific Troubleshooting

### ADR Generator Agent

#### Issue: ADR Number Conflict

**Symptoms:**

- Agent creates ADR with number that already exists
- File overwrite warning

**Solution:**

```powershell
# List existing ADRs
Get-ChildItem docs\adr\adr-*.md | Sort-Object Name

# Manually specify next number
# Prompt: "Create ADR-0005 for [decision]"
```

#### Issue: Missing Alternatives Section

**Symptoms:**

- Generated ADR has no alternatives
- Only one option documented

**Solution:**

```markdown
# Explicitly provide alternatives in prompt:
Document the decision to use Azure Bastion.

Alternatives considered:
1. Jump Box VM with NSG rules
2. Just-in-Time (JIT) VM access
3. Azure Bastion (chosen)

Provide analysis of why each alternative was accepted or rejected.
```

---

### Azure Principal Architect Agent

#### Issue: WAF Scores Too High/Low

**Symptoms:**

- All pillars scored 9-10 (unrealistic)
- All pillars scored 1-3 (overly critical)

**Solution:**

```markdown
# Provide context for realistic assessment:
Assess this architecture:
- App Service Standard S1 (no private endpoints)
- SQL Database with public access
- Single region deployment
- Basic monitoring configured

Provide realistic WAF scores based on production readiness standards.
```

#### Issue: No Microsoft Documentation Links

**Symptoms:**

- Recommendations without reference links
- Generic advice not backed by official docs

**Solution:**

1. Verify Microsoft Docs MCP server is active
2. Check agent has Microsoft Docs tools enabled
3. Explicitly request documentation:

```markdown
Provide architecture recommendations with links to Microsoft Learn 
documentation and Azure Architecture Center patterns.
```

---

### Bicep Planning Specialist Agent

#### Issue: Plan Too High-Level

**Symptoms:**

- Vague resource descriptions
- Missing parameter details
- No specific SKUs or configurations

**Solution:**

```markdown
# Request detailed plan:
Create a detailed implementation plan with:
- Specific Azure resource types and API versions
- Exact SKU configurations (S1, P1v3, etc.)
- Complete parameter definitions with examples
- Detailed dependency mapping
```

#### Issue: Cost Table Has No Values

**Symptoms:**

- Cost table present but shows $TBD or $X
- No actual cost estimates

**Solution:**

```markdown
# Provide usage context:
Create a plan with detailed cost estimates.

Context for costing:
- Region: West Europe
- Environment: Production
- Expected load: 10,000 users/day
- Data storage: 500GB
```

---

### Bicep Implementation Specialist Agent

#### Issue: Bicep Build Fails

**Symptoms:**

- `bicep build` command returns errors
- Syntax errors in generated code

**Solution:**

```powershell
# 1. Check Bicep CLI version
bicep --version
# Should be 0.20.0 or newer

# 2. Run build with detailed output
bicep build main.bicep --stdout --no-restore

# 3. Common errors:
# - Missing parameter decorators
# - Invalid resource property names
# - Incorrect API versions
# - Circular dependencies

# 4. Fix and rebuild
bicep format main.bicep
bicep build main.bicep
```

#### Issue: Missing Required Tags

**Symptoms:**

- Resources deployed without tags
- Tagging validation fails

**Solution:**

```markdown
# Explicitly request tagging:
Generate Bicep code with these required tags on all resources:
- Environment: dev
- ManagedBy: Bicep
- Project: MyProject
- Owner: TeamName
```

---

## Performance Issues

### Issue: Agent Takes Too Long to Respond

**Symptoms:**

- Wait times > 60 seconds
- VS Code appears to hang

**Causes:**

1. Complex prompt requiring deep analysis
2. Multiple documentation lookups
3. Network latency to API

**Solutions:**

**Fix 1: Simplify Complexity**

- Break complex requests into smaller prompts
- Use agent handoffs for multi-step workflows
- Avoid "do everything" prompts

**Fix 2: Check Network Connection**

```powershell
# Test connectivity to GitHub
Test-NetConnection -ComputerName github.com -Port 443

# Test VS Code extensions loading
# If slow, check proxy/firewall settings
```

**Fix 3: Use Caching**

- Reuse previous agent outputs as context
- Reference existing ADRs, plans, or code
- Avoid re-requesting same information

---

## Output Quality Issues

### Issue: Generic Recommendations

**Symptoms:**

- Vague advice ("use best practices")
- No specific Azure services mentioned
- No actionable guidance

**Solutions:**

**Fix 1: Provide Specific Context**

```markdown
❌ Generic:
Design a secure web application

✅ Specific:
Design a secure web application for:
- 50,000 monthly active users
- PCI-DSS Level 1 compliance required
- Budget: Limited budget for demo environment
- Team has limited Azure experience
- Must support EU and US users
```

**Fix 2: Request Specificity**

```markdown
Provide specific Azure service recommendations with:
- Exact SKUs and configurations
- Step-by-step implementation guidance
- Links to Microsoft documentation
- Cost estimates
```

---

### Issue: Outdated Information

**Symptoms:**

- References to deprecated services
- Old API versions
- Pricing from previous years

**Solutions:**

**Fix 1: Verify Agent Uses Latest Tools**

```markdown
# Check agent definition has Microsoft Docs tools:
tools: ['Microsoft Docs/*', 'Azure MCP/*', 'Bicep (EXPERIMENTAL)/*']
```

**Fix 2: Explicitly Request Current Info**

```markdown
Provide recommendations using the latest Azure services and pricing 
as of November 2025. Use latest stable API versions (2023-05-01 or newer).
```

**Fix 3: Validate Against Microsoft Learn**

- Cross-check recommendations with [Microsoft Learn](https://learn.microsoft.com/)
- Verify service availability and pricing
- Report inaccuracies

---

## Integration Issues

### Issue: Handoff Context Lost

**Symptoms:**

- Next agent doesn't know about previous agent's output
- Need to re-explain requirements
- Disconnected workflow

**Solutions:**

**Fix 1: Use Handoff Buttons**

- Don't manually switch agents mid-conversation
- Use the handoff buttons in agent interface
- Context automatically preserved

**Fix 2: Reference Previous Outputs**

```markdown
# When manually switching agents:
Implement the plan from .bicep-planning-files/INFRA.web-app.md
Use the architecture assessment from the previous conversation.
```

**Fix 3: Save Intermediate Outputs**

- ADRs saved to `/docs/adr/`
- Plans saved to `.bicep-planning-files/`
- Reference these files in subsequent prompts

---

## Advanced Troubleshooting

### Debugging Agent Behavior

**Enable Verbose Logging:**

```powershell
# VS Code Developer Tools
# Help > Toggle Developer Tools
# Console tab shows extension logging
```

**Check Agent Configuration:**

```powershell
# Validate agent YAML syntax
$agentPath = ".github\agents\azure-principal-architect.agent.md"
$content = Get-Content $agentPath -Raw

# Extract and validate front matter
if ($content -match '```chatagent\s+---\s+(.+?)\s+---') {
    $yaml = $matches[1]
    # Check for required fields: name, description, tools
    Write-Host "Agent YAML:" -ForegroundColor Cyan
    Write-Host $yaml
}
```

**Test Agent in Isolation:**

1. Create minimal test prompt
2. Test without workspace context
3. Compare with expected behavior
4. Identify where deviation occurs

---

### Reporting Issues

**Before Reporting:**

1. Check this troubleshooting guide
2. Verify agent version is current
3. Try with a simplified prompt
4. Test with different agent

**What to Include in Issue Report:**

1. **Agent Name:** Which agent had the issue
2. **Agent Version:** Check front matter or CHANGELOG.md
3. **Prompt Used:** Exact prompt that caused issue
4. **Expected Behavior:** What you expected to happen
5. **Actual Behavior:** What actually happened
6. **Screenshots:** If applicable
7. **Environment:** VS Code version, OS, Copilot version

**Where to Report:**

- GitHub Issues: [Repository Issues](https://github.com/jonathan-vella/github-copilot-itpro/issues)
- Use label: `agent-issue`

---

## Getting Help

### Documentation Resources

- [Five-Mode Workflow Guide](../resources/copilot-customizations/FIVE-MODE-WORKFLOW.md)
- [Agent Version History (Archive)](../../docs/agent-improvements-archive/CHANGELOG.md)
- [Test Cases](./test-cases/)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)

### Community Support

- GitHub Discussions: Repository discussions
- Azure Community: [Azure Forums](https://learn.microsoft.com/answers/tags/133/azure)
- Partner Slack: SI partner channels

### Escalation Path

1. **Self-Service:** This troubleshooting guide
2. **Community:** GitHub discussions
3. **Issue Report:** GitHub issues with full details
4. **Partner Support:** For SI partners with support agreements

---

## Quick Reference: Common Commands

```powershell
# Reload VS Code to refresh agents
# Ctrl+Shift+P > "Developer: Reload Window"

# Open agent selection
# Ctrl+Shift+A

# List agent files
Get-ChildItem .github\agents\*.agent.md

# Validate Bicep
bicep build main.bicep
bicep lint main.bicep

# Check agent version
Select-String -Path ".github\agents\*.agent.md" -Pattern "Version:|version:"

# Run agent tests
.\demos\agent-testing\Run-AgentTests.ps1 -Agent all

# Generate test report
.\demos\agent-testing\Generate-TestReport.ps1
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-18 | Initial troubleshooting guide |

---

**Maintained By:** GitHub Copilot IT Pro Team  
**Last Updated:** 2025-11-18  
**Feedback:** Open an issue with label `documentation`
