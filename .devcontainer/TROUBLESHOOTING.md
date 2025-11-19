# Devcontainer Quick Start & Troubleshooting

## Quick Start (3 Steps)

1. **Ensure Docker Desktop is running**
   - Windows: Check system tray for Docker icon
   - macOS: Check menu bar for Docker icon

2. **Open in Container**
   - Press `F1` in VS Code
   - Type: `Dev Containers: Reopen in Container`
   - Wait 3-5 minutes for first build

3. **Authenticate with Azure**
   ```bash
   az login
   az account set --subscription "<your-subscription-id>"
   ```

## Common Errors & Fixes

### Error: "Command failed" with Exit code 1

**Likely Causes:**
- Docker not running
- Docker resource limits too low
- Network/firewall blocking image download

**Fixes:**
```powershell
# 1. Verify Docker is running
docker version

# 2. Increase Docker memory (Docker Desktop → Settings → Resources → Memory: 4GB+)

# 3. Clear Docker cache and retry
docker system prune -a --volumes
# Then: F1 → Dev Containers: Rebuild Container
```

### Error: Post-create script fails

**Symptoms:**
- Container starts but tools missing
- Installation errors in logs

**Fixes:**
```bash
# Check installation log
cat ~/.devcontainer-install.log

# Manually run post-create script
bash .devcontainer/post-create.sh

# Or rebuild from scratch
# F1 → Dev Containers: Rebuild Container Without Cache
```

### Error: Cannot pull base image

**Symptoms:**
- "Error: Failed to pull image"
- Network timeout errors

**Fixes:**
```powershell
# 1. Test network connectivity
docker pull mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# 2. Configure Docker proxy (if behind corporate firewall)
# Docker Desktop → Settings → Resources → Proxies

# 3. Use alternative base image (edit .devcontainer/devcontainer.json)
"image": "mcr.microsoft.com/devcontainers/base:ubuntu"  # Use Ubuntu 22.04 instead
```

### Error: Extension not loading

**Symptoms:**
- Extension shows "disabled" or "not installed"
- Features don't work

**Fixes:**
```bash
# 1. Reload VS Code window
# F1 → Developer: Reload Window

# 2. Check if extension supports remote containers
# Some extensions only work on host, not in containers

# 3. Manually install extension in container
# Open Extensions panel → Search → Install in Container
```

## Minimal Configuration (Fallback)

If full configuration fails, use this minimal setup:

**`.devcontainer/devcontainer.json`**:
```json
{
  "name": "GitHub Copilot IT Pro (Minimal)",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  
  "features": {
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "ghcr.io/devcontainers/features/terraform:1": {},
    "ghcr.io/devcontainers/features/powershell:1": {}
  },
  
  "customizations": {
    "vscode": {
      "extensions": [
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "ms-azuretools.vscode-bicep",
        "HashiCorp.terraform",
        "ms-vscode.powershell"
      ]
    }
  },
  
  "remoteUser": "vscode"
}
```

Then manually install additional tools:
```bash
# Install Bicep
az bicep install

# Install security scanners
pip3 install checkov
curl -sSL https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
```

## Verify Installation

Run these commands to verify tools are working:

```bash
# Check versions
terraform version
az version
bicep --version
pwsh --version
python3 --version
go version
node --version

# Test Terraform
cd demos/03-terraform-infrastructure/manual-approach/example-code/
terraform init

# Test Bicep
cd demos/01-bicep-quickstart/
bicep build main.bicep

# Test Azure CLI
az account show
```

## Performance Tips

**Slow builds?**
- Close unnecessary applications
- Increase Docker Desktop memory allocation
- Disable Windows Defender real-time scanning for Docker folders (at your own risk)
- Use SSD for Docker virtual disk

**Container taking too much space?**
```powershell
# Check Docker disk usage
docker system df

# Clean up unused images/containers
docker system prune -a

# Reset Docker Desktop to factory defaults (last resort)
```

## Getting Help

1. **Check logs**: `cat ~/.devcontainer-install.log`
2. **Rebuild**: `F1` → `Dev Containers: Rebuild Container`
3. **Report issue**: Include OS, Docker version, error message

## Alternative: Use Host Machine

If devcontainer doesn't work, install tools directly on your machine:

**Windows (PowerShell Admin)**:
```powershell
# Install Chocolatey (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install tools
choco install terraform azure-cli bicep powershell-core git -y

# Install security scanners
pip3 install checkov
# Download tfsec from: https://github.com/aquasecurity/tfsec/releases
```

**macOS (Homebrew)**:
```bash
# Install tools
brew install terraform azure-cli bicep powershell git go node python

# Install security scanners
pip3 install checkov
brew install tfsec
```

**Linux (Ubuntu/Debian)**:
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Install PowerShell
wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update && sudo apt install powershell

# Install Bicep
az bicep install

# Install security scanners
pip3 install checkov
curl -sSL https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
```

---

**Still having issues?** Open an issue in the repository with:
- Operating system and version
- Docker Desktop version (`docker version`)
- Full error message
- Contents of `~/.devcontainer-install.log`
