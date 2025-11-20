# Development Container for GitHub Copilot IT Pro Field Guide

This devcontainer provides a **complete, pre-configured development environment** for working with all demos and examples in this repository. It includes all required tools, extensions, and configurations out of the box.

## 🎯 What's Included

### Infrastructure as Code Tools
- **Terraform CLI** v1.5.0+ with tflint
- **Azure CLI** (latest) with Bicep CLI
- **Bicep** for Azure infrastructure
- **tfsec** - Terraform security scanner
- **Checkov** - Infrastructure security scanner

### Scripting & Automation
- **PowerShell 7+** with Az modules (Accounts, Resources, Storage, Network)
- **Python 3.11** with pip
- **Node.js 20** with npm
- **Bash** with common utilities

### Development Tools
- **Go 1.22** (for Terratest infrastructure testing)
- **Git** with Git LFS
- **GitHub CLI** (gh)
- **jq**, **tree**, **vim**, **graphviz**

### VS Code Extensions (Pre-installed)
- ✅ **GitHub Copilot** + Copilot Chat (required)
- ✅ **Azure Bicep** language support
- ✅ **HashiCorp Terraform** language support
- ✅ **PowerShell** language support
- ✅ **Azure Tools** (Resource Groups, Functions, Static Web Apps)
- ✅ **Markdown All in One** + Mermaid support
- ✅ **GitLens** for Git visualization
- ✅ And 20+ more productivity extensions

## 🚀 Quick Start

### Prerequisites
- **Docker Desktop** installed and running
- **VS Code** with **Dev Containers** extension (`ms-vscode-remote.remote-containers`)
- **4GB RAM** minimum allocated to Docker
- **20GB disk space** for container image and tools

### Opening the Devcontainer

**Option 1: Command Palette** (Recommended)
1. Open VS Code in this repository folder
2. Press `F1` or `Ctrl+Shift+P`
3. Type and select: `Dev Containers: Reopen in Container`
4. Wait 3-5 minutes for initial build (subsequent opens are faster)

**Option 2: Notification Prompt**
1. Open VS Code in this repository folder
2. Click "Reopen in Container" when prompted

**Option 3: Remote Explorer**
1. Click the Remote Explorer icon in the sidebar
2. Select "Dev Containers"
3. Click the folder icon next to this repository

### First-Time Setup (Inside Container)

Once the container is running:

```bash
# 1. Authenticate with Azure
az login

# 2. Set your default subscription
az account set --subscription "<your-subscription-id>"

# 3. Verify tools are installed
terraform version
az version
bicep --version
pwsh --version
tfsec --version
checkov --version

# 4. Explore demos
cd scenarios/
tree -L 2
```

## 📁 What Gets Configured Automatically

### Environment Variables
- `AZURE_DEFAULTS_LOCATION=swedencentral` (matches repository default)
- `TF_PLUGIN_CACHE_DIR=.terraform-cache` (speeds up Terraform downloads)

### PowerShell Modules (Auto-installed)
- Az.Accounts
- Az.Resources
- Az.Storage
- Az.Network

### Azure CLI Configuration
- Default location set to `swedencentral`
- Bicep CLI installed and upgraded

### Git Configuration
- Safe directory configured for mounted volumes
- Git LFS initialized

### Terminal Configuration
- Default shell: **PowerShell 7** (matches repository guidelines)
- Alternative shell: **Bash** (available via dropdown)

## 🧪 Testing the Environment

Run these commands to validate your setup:

```bash
# Test Bicep compilation (Demo 01)
cd scenarios/01-bicep-quickstart/with-copilot/example-code/
bicep build main.bicep

# Test Terraform validation (Demo 03)
cd scenarios/03-terraform-infrastructure/manual-approach/example-code/
terraform init
terraform validate

# Test PowerShell cmdlets (Demo 02)
pwsh -Command "Get-Module -ListAvailable Az.*"

# Test security scanners
tfsec --version
checkov --version
```

## 🔧 Customization

### Adding VS Code Extensions
Edit `.devcontainer/devcontainer.json` and add to the `extensions` array:

```json
"customizations": {
  "vscode": {
    "extensions": [
      "your-publisher.extension-name"
    ]
  }
}
```

Then rebuild the container:
1. Press `F1`
2. Select `Dev Containers: Rebuild Container`

### Installing Additional Tools
Edit `.devcontainer/post-create.sh` and add your installation commands:

```bash
# Install custom tool
echo "Installing my-custom-tool..."
sudo apt-get install -y my-custom-tool
```

### Modifying Environment Variables
Edit `.devcontainer/devcontainer.json` under `remoteEnv`:

```json
"remoteEnv": {
  "MY_VARIABLE": "value"
}
```

## 🐛 Troubleshooting

### Container Won't Start
**Symptom**: Build fails or container exits immediately

**Solutions**:
1. Check Docker Desktop is running
2. Increase Docker memory allocation (Settings → Resources → Memory → 4GB+)
3. Clear Docker cache: `docker system prune -a --volumes`
4. Rebuild from scratch: `F1` → `Dev Containers: Rebuild Container Without Cache`

### Tool Not Found
**Symptom**: Command like `tfsec` or `checkov` not available

**Solutions**:
1. Check if post-create script ran: `cat ~/.devcontainer-install.log`
2. Manually run post-create: `bash .devcontainer/post-create.sh`
3. Rebuild container: `F1` → `Dev Containers: Rebuild Container`

### Azure CLI Authentication Issues
**Symptom**: `az login` fails or times out

**Solutions**:
1. Use device code flow: `az login --use-device-code`
2. Check firewall/proxy settings in Docker Desktop
3. Try service principal auth: `az login --service-principal --username <app-id> --password <password> --tenant <tenant-id>`

### Terraform Plugin Download Slow
**Symptom**: `terraform init` takes very long

**Solutions**:
1. Plugin cache is configured at `.terraform-cache/`
2. First download is slow; subsequent runs are cached
3. Pre-download providers: `terraform providers mirror .terraform-cache/`

### VS Code Extension Not Loading
**Symptom**: Extension appears installed but doesn't work

**Solutions**:
1. Reload window: `F1` → `Developer: Reload Window`
2. Check extension logs: `F1` → `Developer: Show Logs` → Select extension
3. Disable/re-enable extension in Extensions panel
4. Rebuild container: `F1` → `Dev Containers: Rebuild Container`

## 🔄 Updating Tools

### Update All Tools
Run the update script:

```bash
bash .devcontainer/update-tools.sh
```

This updates:
- Azure CLI
- Bicep CLI
- PowerShell Az modules
- Checkov
- Go modules

### Update Specific Tool

**Azure CLI**:
```bash
az upgrade
```

**Bicep**:
```bash
az bicep upgrade
```

**PowerShell Modules**:
```powershell
Update-Module -Name Az.* -Force
```

**Python Packages**:
```bash
pip3 install --upgrade checkov
```

## 📊 Resource Usage

**Container Image Size**: ~3.5 GB  
**Memory Usage**: ~1.5-2 GB (idle), ~3-4 GB (active development)  
**CPU Usage**: Minimal (spikes during Terraform/Bicep operations)  
**Disk Usage**: ~5-10 GB (with plugin caches and workspaces)

## 🔒 Security Considerations

### Credentials
- Azure credentials are stored in `~/.azure/` inside the container
- Credentials persist across container rebuilds (mounted volume)
- **Do NOT commit** `.azure/` directory to Git (already in `.gitignore`)

### Service Principals
For CI/CD or shared environments, use service principal authentication:

```bash
# Login with service principal
az login --service-principal \
  --username $AZURE_CLIENT_ID \
  --password $AZURE_CLIENT_SECRET \
  --tenant $AZURE_TENANT_ID

# Or use environment variables (configure in devcontainer.json remoteEnv)
az login --service-principal
```

### Secrets Management
- Use Azure Key Vault for production secrets
- Use `.env` files for local development (add to `.gitignore`)
- Never hard-code credentials in scripts or templates

## 📚 Related Documentation

- [Demo 01: Bicep Quickstart](../scenarios/01-bicep-quickstart/README.md)
- [Demo 02: PowerShell Automation](../scenarios/02-powershell-automation/README.md)
- [Demo 03: Terraform Infrastructure](../scenarios/03-terraform-infrastructure/README.md)
- [Copilot Instructions](.github/copilot-instructions.md)
- [VS Code Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)

## 🆘 Getting Help

If you encounter issues:

1. **Check logs**: Look in `~/.devcontainer-install.log` for post-create errors
2. **Rebuild container**: Often fixes transient issues
3. **Search issues**: Check repository GitHub Issues for similar problems
4. **File an issue**: Create a new issue with:
   - OS version (Windows/macOS/Linux)
   - Docker Desktop version
   - Error messages or logs
   - Steps to reproduce

## 🎯 Benefits of Using Devcontainers

✅ **Consistent Environment**: Everyone uses the same tool versions  
✅ **Fast Onboarding**: New contributors productive in minutes  
✅ **Pre-configured**: All extensions and settings ready to use  
✅ **Isolated**: Doesn't affect your host machine setup  
✅ **Portable**: Works on Windows, macOS, and Linux  
✅ **Reproducible**: Same environment in CI/CD pipelines  

---

**Ready to start?** Press `F1` → `Dev Containers: Reopen in Container` and begin building Azure infrastructure with GitHub Copilot! 🚀
