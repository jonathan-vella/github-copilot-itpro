# Development Container for GitHub Copilot IT Pro Field Guide

This devcontainer provides a **complete, pre-configured development environment** for working with all demos
and scenarios in this repository. It includes all required tools, extensions, and configurations out of the box.

**Base Image:** `mcr.microsoft.com/devcontainers/universal:latest` (Ubuntu 24.04 Noble)

## 🎯 What's Included

### Infrastructure as Code Tools

- **Terraform CLI** (latest) with tfsec pre-installed
- **Azure CLI** (latest) with Bicep CLI
- **Checkov** - Infrastructure security scanner
- **Bicep** for Azure infrastructure

### Scripting & Automation

- **PowerShell 7+** (via devcontainer feature) with Az modules (Accounts, Resources, Storage, Network, KeyVault, Websites)
- **Python 3.12** with pip
- **Node.js v22** with npm
- **Bash** with common utilities

### Development Tools

- **Go** (latest) for Terratest infrastructure testing
- **Git** with Git LFS
- **GitHub CLI** (gh)
- **jq**, **tree**, **graphviz**, **dos2unix**

### VS Code Extensions (28 Pre-installed)

- ✅ **GitHub Copilot** + Copilot Chat
- ✅ **Azure Bicep** language support
- ✅ **HashiCorp Terraform** language support
- ✅ **PowerShell** language support
- ✅ **Azure Tools** (Resource Groups, Container Apps, Static Web Apps)
- ✅ **Markdown** (Mermaid diagrams, preview, linting, Prettier formatting)
- ✅ **Kubernetes & Docker** tools
- ✅ **AI Foundry** + AI Toolkit extensions

## 🚀 Quick Start

### Prerequisites

- **Docker Desktop** installed and running
- **VS Code** with **Dev Containers** extension (`ms-vscode-remote.remote-containers`)
- **4GB RAM** minimum allocated to Docker
- **10GB disk space** for container image and tools

### Opening the Devcontainer

**Option 1: Command Palette** (Recommended)

1. Open VS Code in this repository folder
2. Press `F1` or `Ctrl+Shift+P`
3. Type and select: `Dev Containers: Reopen in Container`
4. Wait 5-8 minutes for initial build (subsequent opens are ~30 seconds)

**Option 2: Notification Prompt**

1. Open VS Code in this repository folder
2. Click "Reopen in Container" when prompted

### First-Time Setup (Inside Container)

```bash
# 1. Authenticate with Azure
az login

# 2. Set your default subscription
az account set --subscription "<your-subscription-id>"

# 3. Verify tools are installed (auto-displayed after setup)
terraform version && az bicep version && pwsh --version

# 4. Explore scenarios
cd scenarios/ && tree -L 2
```

## 📁 Environment Configuration

### Pre-configured Environment Variables

| Variable                  | Value                              | Purpose                                        |
| ------------------------- | ---------------------------------- | ---------------------------------------------- |
| `TF_PLUGIN_CACHE_DIR`     | `/home/codespace/.terraform-cache` | Speeds up Terraform provider downloads         |
| `AZURE_DEFAULTS_LOCATION` | `swedencentral`                    | Default Azure region (matches repo guidelines) |

### Azure Credentials Mount

Your host machine's `~/.azure` credentials are automatically mounted into the container,
so you only need to `az login` once on your host machine.

### PowerShell Modules (Auto-installed)

- Az.Accounts, Az.Resources, Az.Storage
- Az.Network, Az.KeyVault, Az.Websites

## 🧪 Testing the Environment

```bash
# Test Bicep compilation
bicep build infra/bicep/contoso-patient-portal/main.bicep

# Test Terraform validation
cd scenarios/S02-terraform-baseline/solution/
terraform init && terraform validate

# Test security scanners
tfsec --version && checkov --version

# Test PowerShell modules
pwsh -Command "Get-Module -ListAvailable Az.*"
```

## 🔄 Updating Tools

### Update All Tools

```bash
bash .devcontainer/update-tools.sh
```

This updates: Azure CLI, Bicep, PowerShell Az modules, Checkov, diagrams, markdownlint, Terratest

### Update Specific Tools

```bash
az upgrade                                    # Azure CLI
az bicep upgrade                              # Bicep
pip3 install --upgrade checkov diagrams       # Python packages
sudo npm update -g markdownlint-cli           # markdownlint
```

## 🐛 Troubleshooting

### Quick Fixes

| Issue                 | Solution                                                 |
| --------------------- | -------------------------------------------------------- |
| Container won't start | Check Docker running, increase memory to 4GB+            |
| Tool not found        | Run `bash .devcontainer/post-create.sh`                  |
| Azure auth fails      | Use `az login --use-device-code`                         |
| Rebuild needed        | `F1` → `Dev Containers: Rebuild Container Without Cache` |

📖 **Full troubleshooting guide:** [docs/troubleshooting.md](../docs/troubleshooting.md)

## 📊 Resource Usage

| Metric                 | Value   |
| ---------------------- | ------- |
| **Container Image**    | ~2.5 GB |
| **Memory (idle)**      | ~1.5 GB |
| **Memory (active)**    | ~3-4 GB |
| **Disk (with caches)** | ~5-8 GB |

## 🔒 Security Notes

- Azure credentials persist in `~/.azure/` (mounted volume)
- Never commit `.azure/` to Git (already in `.gitignore`)
- Use Azure Key Vault for production secrets
- Use service principals for CI/CD environments

## 📚 Related Documentation

- [Prerequisites Guide](../docs/getting-started/prerequisites.md)
- [Model Selection Guide](../docs/getting-started/model-selection.md)
- [S01: Bicep Baseline](../scenarios/S01-bicep-baseline/README.md)
- [Copilot Instructions](../.github/copilot-instructions.md)

---

**Ready?** Press `F1` → `Dev Containers: Reopen in Container` 🚀
