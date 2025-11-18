# Quick Start Guide: Awesome Copilot for IT Pros

**Time Investment: 15 minutes | Outcome: Enhanced Copilot for Azure Infrastructure**

## ⚡ 5-Minute Setup (Essential)

### Step 1: Add Project-Wide Bicep Standards

```bash
cd /path/to/github-copilot-itpro

# Add Bicep best practices
cat resources/copilot-customizations/instructions/bicep-code-best-practices.instructions.md >> .github/copilot-instructions.md

# Add DevOps principles
cat resources/copilot-customizations/instructions/devops-core-principles.instructions.md >> .github/copilot-instructions.md
```

**What you get**: Copilot now knows Bicep naming conventions and DevOps best practices across all files.

### Step 2: Test It

Open `demos/01-bicep-quickstart/scenario/requirements.md` in VS Code and ask Copilot:

```
Create a Bicep template for a virtual network with 3 subnets
```

**Expected improvement**:

- ✅ Uses lowerCamelCase naming
- ✅ Includes @description decorators
- ✅ Adds proper outputs
- ✅ Uses latest API versions

---

## 📦 10-Minute Setup (Recommended)

### Step 3: Install Bicep Chat Mode

1. Open VS Code
2. Install GitHub Copilot Chat extension (if not already installed)
3. Copy the content from: `resources/copilot-customizations/chatmodes/bicep-implement.chatmode.md`
4. In Copilot Chat, create a new chat mode or use the file directly

**Alternative**: Use the install badge in the chatmode file (requires VS Code Insiders)

### Step 4: Try the Chat Mode

In Copilot Chat, switch to the Bicep Implementation chat mode and try:

```
Create a storage account with:
- Premium tier
- HTTPS only
- No public access
- Geo-redundant storage
```

**What you get**:

- Validates against Azure Verified Modules
- Runs bicep build/lint automatically
- Ensures security best practices
- No secrets or hardcoded values

---

## 🚀 15-Minute Setup (Complete)

### Step 5: Add PowerShell Testing Support

```bash
# Add Pester v5 testing standards
cat resources/copilot-customizations/instructions/powershell-pester-5.instructions.md >> .github/copilot-instructions.md
```

### Step 6: Install Azure Architect Chat Mode

Copy content from: `resources/copilot-customizations/chatmodes/azure-principal-architect.chatmode.md`

Use for architecture reviews:

```
Review this hub-spoke network design:
- 1 hub VNet with Azure Firewall
- 3 spoke VNets for apps
- VNet peering between all
- NSGs on every subnet

Check against Well-Architected Framework
```

### Step 7: Bookmark Documentation Prompt

Open: `resources/copilot-customizations/prompts/documentation-writer.prompt.md`

Use when you need to generate:

- README files
- Runbooks
- How-to guides
- Architecture documentation

---

## 🎯 Common Use Cases

### Use Case 1: Generate Bicep Template

**Situation**: Need to create infrastructure for a demo

**Steps**:

1. Ensure bicep instructions are in `.github/copilot-instructions.md`
2. Open a new `.bicep` file
3. Type a comment describing what you need:

```bicep
// Create a 3-tier network with:
// - Hub VNet (10.0.0.0/16)
// - App subnet (10.0.1.0/24)
// - Data subnet (10.0.2.0/24)
// - Management subnet (10.0.3.0/24)
// - NSGs on all subnets
```

4. Let Copilot generate the template
5. Review and accept

**Time saved**: 45 min → 10 min (78% faster)

### Use Case 2: Write PowerShell Tests

**Situation**: Need to test a PowerShell automation script

**Steps**:

1. Ensure Pester instructions are in `.github/copilot-instructions.md`
2. Create a new file: `Get-AzureResources.Tests.ps1`
3. Ask Copilot:

```
Create Pester tests for Get-AzureResources function that:
- Mocks Get-AzResource
- Tests successful retrieval
- Tests error handling
- Tests filtering by resource type
```

4. Review generated test structure

**Time saved**: 30 min → 5 min (83% faster)

### Use Case 3: Review Architecture

**Situation**: Need to validate design against Azure best practices

**Steps**:

1. Switch to Azure Principal Architect chat mode
2. Describe your architecture
3. Ask for review against specific pillars:

```
Review for:
1. Security (Network isolation, RBAC, encryption)
2. Cost optimization
3. Reliability (HA, DR)
```

4. Get structured feedback with recommendations

**Time saved**: 60 min → 15 min (75% faster)

### Use Case 4: Troubleshoot Azure Resources

**Situation**: VM is showing degraded performance

**Steps**:

1. Open: `resources/copilot-customizations/prompts/azure-resource-health-diagnose.prompt.md`
2. Copy the prompt structure
3. Fill in your resource details
4. Get diagnostic steps and remediation plan

**Time saved**: 30 min → 8 min (73% faster)

### Use Case 5: Generate Documentation

**Situation**: Need a runbook for deployment process

**Steps**:

1. Open: `resources/copilot-customizations/prompts/documentation-writer.prompt.md`
2. Request a how-to guide:

```
Create a how-to guide for:
Audience: IT Pros new to Bicep
Goal: Deploy demo 01 infrastructure
Include: Prerequisites, steps, validation, troubleshooting
```

3. Review proposed structure
4. Generate full documentation

**Time saved**: 90 min → 20 min (78% faster)

---

## 🔍 Verification

### Check Instructions Are Active

1. Open any `.bicep` file
2. Start typing a parameter:

```bicep
param storage
```

3. Copilot should suggest using `@description` decorator
4. Variable suggestions should use lowerCamelCase

### Check Chat Mode Is Active

1. Open Copilot Chat
2. Look for your installed chat modes
3. Switch to "Bicep Implementation Specialist"
4. Chat interface should reflect the specialized role

### Check Prompts Are Accessible

1. Open prompt files in VS Code
2. Keep them in a browser tab or VS Code for quick access
3. Copy-paste prompt templates as needed

---

## 📊 Expected Results

After this setup, you should see:

### Code Quality Improvements

- ✅ Consistent naming conventions
- ✅ Proper security settings by default
- ✅ Best practices applied automatically
- ✅ Complete parameter documentation

### Speed Improvements

- ✅ 60-75% time reduction on infrastructure code
- ✅ 80%+ time reduction on documentation
- ✅ Faster troubleshooting with structured prompts
- ✅ Less time looking up syntax and API versions

### Learning Benefits

- ✅ See best practices in action
- ✅ Understand "why" through Copilot's explanations
- ✅ Learn by reviewing generated code
- ✅ Build confidence in modern IaC

---

## 🆘 Troubleshooting

### Copilot Isn't Using Instructions

**Problem**: Generated code doesn't follow the conventions

**Solution**:

1. Check `.github/copilot-instructions.md` exists and has content
2. Restart VS Code
3. Check file extensions match (e.g., `.bicep` for Bicep instructions)
4. Clear Copilot cache: Cmd/Ctrl + Shift + P → "Copilot: Clear Cache"

### Chat Mode Not Appearing

**Problem**: Can't find installed chat mode

**Solution**:

1. Ensure GitHub Copilot Chat extension is installed
2. Update to latest VS Code version
3. Try using the content directly in chat instead of installing
4. Check VS Code Insiders for latest features

### Instructions Conflict

**Problem**: Multiple instruction files giving different advice

**Solution**:

1. Review `.github/copilot-instructions.md` for conflicts
2. Prioritize: Project-specific > Language-specific > General
3. Remove or comment out conflicting sections
4. Use `applyTo` frontmatter to scope instructions

### Generated Code Has Errors

**Problem**: Bicep or Terraform code doesn't validate

**Solution**:

1. Run validation: `bicep build file.bicep` or `terraform validate`
2. Share error with Copilot and ask for fix
3. Check that instructions file is up to date
4. Verify you're using the correct chat mode for the task

---

## 🎓 Next Steps

After completing this quick start:

1. **Practice**: Work through demo 01 (Bicep Quickstart) with these customizations active
2. **Experiment**: Try variations of prompts to see what works best
3. **Customize**: Adapt the instructions to your organization's standards
4. **Share**: Show colleagues the time savings and quality improvements
5. **Contribute**: Submit improvements back to this repository

---

## 📚 Additional Resources

- **Full Documentation**: [README.md](README.md) - Complete guide to all customizations
- **Demo Modules**: [../../demos/](../../demos/) - Hands-on examples
- **Awesome Copilot**: https://github.com/github/awesome-copilot - Source repository
- **Copilot Docs**: https://docs.github.com/copilot - Official documentation

---

**Time to Value: 5-15 minutes**  
**ROI: 60-90% time savings on infrastructure tasks**  
**Learning Curve: Gentle - learn by doing**

Happy coding! 🚀
