# Copilot Customizations Index

Quick reference for all customizations in this directory.

## 📋 By Use Case

### "I'm writing Bicep templates"
- **Instructions**: [bicep-code-best-practices.instructions.md](instructions/bicep-code-best-practices.instructions.md)
- **Chat Mode**: [bicep-implement.chatmode.md](chatmodes/bicep-implement.chatmode.md)
- **Time Saved**: 78% (45 min → 10 min)

### "I'm writing PowerShell automation"
- **Instructions**: [powershell-pester-5.instructions.md](instructions/powershell-pester-5.instructions.md)
- **Time Saved**: 75% (60 min → 15 min)

### "I'm working with Terraform on Azure"
- **Instructions**: [terraform-azure.instructions.md](instructions/terraform-azure.instructions.md)
- **Chat Mode**: [terraform-azure-implement.chatmode.md](chatmodes/terraform-azure-implement.chatmode.md)
- **Time Saved**: 70%+

### "I need to review architecture"
- **Chat Mode**: [azure-principal-architect.chatmode.md](chatmodes/azure-principal-architect.chatmode.md)
- **Framework**: Well-Architected Framework principles

### "I need to write documentation"
- **Prompt**: [documentation-writer.prompt.md](prompts/documentation-writer.prompt.md)
- **Framework**: Diátaxis (tutorials, how-tos, reference, explanation)
- **Time Saved**: 83% (90 min → 20 min)

### "I'm troubleshooting Azure resources"
- **Prompt**: [azure-resource-health-diagnose.prompt.md](prompts/azure-resource-health-diagnose.prompt.md)
- **Time Saved**: 73% (30 min → 8 min)

### "I want to understand DevOps best practices"
- **Instructions**: [devops-core-principles.instructions.md](instructions/devops-core-principles.instructions.md)
- **Frameworks**: CALMS, DORA metrics

### "I need a complete Azure development setup"
- **Collection**: [azure-cloud-development.md](collections/azure-cloud-development.md)
- **Contains**: 18 curated resources

---

## 📋 By File Type

### Instructions (Project/File-Wide Standards)
Apply to entire project or specific file patterns.

| File | AppliesTo | Purpose | Install Location |
|------|-----------|---------|------------------|
| [bicep-code-best-practices.instructions.md](instructions/bicep-code-best-practices.instructions.md) | `**/*.bicep` | Naming, structure, security | `.github/copilot-instructions.md` |
| [powershell-pester-5.instructions.md](instructions/powershell-pester-5.instructions.md) | `**/*.Tests.ps1` | Pester v5 testing patterns | `.github/copilot-instructions.md` |
| [terraform-azure.instructions.md](instructions/terraform-azure.instructions.md) | `**/*.tf` | Terraform Azure conventions | `.github/copilot-instructions.md` |
| [devops-core-principles.instructions.md](instructions/devops-core-principles.instructions.md) | `*` | CALMS, DORA, automation | `.github/copilot-instructions.md` |

### Chat Modes (Specialized AI Personas)
Invoke for specific tasks in Copilot Chat.

| File | Persona | Best For | Key Features |
|------|---------|----------|--------------|
| [bicep-implement.chatmode.md](chatmodes/bicep-implement.chatmode.md) | Bicep IaC Specialist | Creating Bicep templates | Validates AVM, runs build/lint |
| [azure-principal-architect.chatmode.md](chatmodes/azure-principal-architect.chatmode.md) | Azure Principal Architect | Architecture reviews | Well-Architected Framework |
| [terraform-azure-implement.chatmode.md](chatmodes/terraform-azure-implement.chatmode.md) | Terraform Azure Specialist | Terraform on Azure | Idempotency, modules |

### Prompts (Task Templates)
Copy-paste for specific tasks.

| File | Task Type | Output | Typical Use |
|------|-----------|--------|-------------|
| [documentation-writer.prompt.md](prompts/documentation-writer.prompt.md) | Documentation | Tutorials, guides, reference | "Document deployment process" |
| [azure-resource-health-diagnose.prompt.md](prompts/azure-resource-health-diagnose.prompt.md) | Troubleshooting | Diagnostic plan, remediation | "VM performance degraded" |

### Collections (Bundled Workflows)
Complete toolkits for specific domains.

| File | Domain | Items | Purpose |
|------|--------|-------|---------|
| [azure-cloud-development.md](collections/azure-cloud-development.md) | Azure & Cloud | 18 resources | Complete Azure dev toolkit |

---

## 📋 By Demo Module

Recommended customizations for each demo:

### Demo 01: Bicep Quickstart
- ✅ [bicep-code-best-practices.instructions.md](instructions/bicep-code-best-practices.instructions.md)
- ✅ [bicep-implement.chatmode.md](chatmodes/bicep-implement.chatmode.md)
- 📊 Impact: Generate production-ready templates 78% faster

### Demo 02: PowerShell Automation
- ✅ [powershell-pester-5.instructions.md](instructions/powershell-pester-5.instructions.md)
- ✅ [devops-core-principles.instructions.md](instructions/devops-core-principles.instructions.md)
- 📊 Impact: Automated testing patterns built-in

### Demo 03: Azure Arc Onboarding
- ✅ [azure-principal-architect.chatmode.md](chatmodes/azure-principal-architect.chatmode.md)
- ✅ [devops-core-principles.instructions.md](instructions/devops-core-principles.instructions.md)
- 📊 Impact: Architecture validation and scale patterns

### Demo 04: Troubleshooting Assistant
- ✅ [azure-resource-health-diagnose.prompt.md](prompts/azure-resource-health-diagnose.prompt.md)
- 📊 Impact: Structured diagnostic approach

### Demo 05: Documentation Generator
- ✅ [documentation-writer.prompt.md](prompts/documentation-writer.prompt.md)
- 📊 Impact: Professional docs 83% faster

---

## 📋 By Skill Level

### Beginner (Just Starting)
**Start here** (5 min setup):
1. [QUICK-START.md](QUICK-START.md) - Read this first
2. [bicep-code-best-practices.instructions.md](instructions/bicep-code-best-practices.instructions.md)
3. [documentation-writer.prompt.md](prompts/documentation-writer.prompt.md)

**Why**: Immediate value with minimal learning curve

### Intermediate (Some IaC Experience)
**Add these** (10 min setup):
1. Everything from Beginner
2. [devops-core-principles.instructions.md](instructions/devops-core-principles.instructions.md)
3. [bicep-implement.chatmode.md](chatmodes/bicep-implement.chatmode.md)
4. [powershell-pester-5.instructions.md](instructions/powershell-pester-5.instructions.md)

**Why**: Comprehensive IaC toolkit with testing

### Advanced (Architecture & Scale)
**Complete setup** (15 min):
1. Everything from Intermediate
2. [azure-principal-architect.chatmode.md](chatmodes/azure-principal-architect.chatmode.md)
3. [terraform-azure.instructions.md](instructions/terraform-azure.instructions.md)
4. [azure-cloud-development.md](collections/azure-cloud-development.md)

**Why**: Full Azure architecture and multi-tool support

---

## 📋 Installation Methods

### Method 1: Project-Wide (Recommended)
```bash
# Bicep standards
cat instructions/bicep-code-best-practices.instructions.md >> ../../.github/copilot-instructions.md

# DevOps principles
cat instructions/devops-core-principles.instructions.md >> ../../.github/copilot-instructions.md
```
**Pros**: Applies to entire project, persistent  
**Cons**: Must be in .github directory

### Method 2: VS Code Chat Modes
1. Copy chatmode file content
2. Install in VS Code Copilot Chat
3. Switch modes as needed

**Pros**: Specialized personas, task-specific  
**Cons**: Must install individually

### Method 3: Direct Prompt Use
1. Open prompt file
2. Copy content
3. Paste into Copilot Chat

**Pros**: No installation, flexible  
**Cons**: Manual copy-paste

### Method 4: Full Collection Install
```bash
# Install entire Azure collection via awesome-copilot
# See collections/azure-cloud-development.md for details
```
**Pros**: Complete toolkit  
**Cons**: More resources than needed

---

## 📋 Quick Commands

### Add All Essential Instructions
```bash
cd resources/copilot-customizations
cat instructions/bicep-code-best-practices.instructions.md \
    instructions/devops-core-principles.instructions.md \
    instructions/powershell-pester-5.instructions.md \
    >> ../../.github/copilot-instructions.md
```

### View What's Installed
```bash
cat ../../.github/copilot-instructions.md
```

### Remove Instructions
```bash
# Edit .github/copilot-instructions.md and delete sections
code ../../.github/copilot-instructions.md
```

---

## 📋 Troubleshooting Index

| Problem | Solution | Reference |
|---------|----------|-----------|
| Instructions not applying | Restart VS Code, check file extension | [QUICK-START.md](QUICK-START.md#troubleshooting) |
| Chat mode not found | Update VS Code, check installation | [QUICK-START.md](QUICK-START.md#troubleshooting) |
| Conflicting advice | Review .github/copilot-instructions.md | [README.md](README.md#best-practices) |
| Code validation errors | Run linter, share with Copilot | [QUICK-START.md](QUICK-START.md#troubleshooting) |

---

## 📋 Metrics & ROI

Based on time-tracking data from demo modules:

| Task | Manual | With Copilot | Savings | Customization |
|------|--------|--------------|---------|---------------|
| Bicep Template | 45 min | 10 min | 78% | bicep-code-best-practices |
| PowerShell Script | 60 min | 15 min | 75% | powershell-pester-5 |
| Architecture Review | 60 min | 15 min | 75% | azure-principal-architect |
| Troubleshooting | 30 min | 8 min | 73% | azure-resource-health-diagnose |
| Documentation | 90 min | 20 min | 78% | documentation-writer |

**Average**: 76% time reduction  
**ROI**: Setup time (5-15 min) recovered on first use

---

## 🔗 Related Files

- [README.md](README.md) - Complete documentation
- [QUICK-START.md](QUICK-START.md) - 5-15 minute setup guide
- [../../README.md](../../README.md) - Main project README
- [../../CONTRIBUTING.md](../../CONTRIBUTING.md) - Contribution guidelines

---

**Last Updated**: November 2024  
**Source**: [github/awesome-copilot](https://github.com/github/awesome-copilot)  
**Curated For**: IT Pros working with Azure infrastructure
