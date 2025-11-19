#!/bin/bash
set -e

echo "🚀 Running post-create setup for GitHub Copilot IT Pro environment..."

# Log output to file for debugging
exec 1> >(tee -a ~/.devcontainer-install.log)
exec 2>&1

# Update package lists
echo "📦 Updating package lists..."
sudo apt-get update -qq

# Install security scanning tools for Terraform
echo "🔒 Installing Terraform security scanners..."

# Install tfsec
echo "  → Installing tfsec..."
if ! command -v tfsec &> /dev/null; then
    curl -sSL https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
    sudo mv tfsec /usr/local/bin/ 2>/dev/null || true
fi

# Install Checkov
echo "  → Installing Checkov..."
if ! command -v checkov &> /dev/null; then
    pip3 install --quiet --no-cache-dir checkov || echo "Warning: Checkov installation had issues, continuing..."
fi

# Install Azure PowerShell modules
echo "🔧 Installing Azure PowerShell modules..."
pwsh -NoProfile -Command "
    try {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
        if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
            Write-Host '  Installing Az.Accounts...'
            Install-Module -Name Az.Accounts -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        }
        if (-not (Get-Module -ListAvailable -Name Az.Resources)) {
            Write-Host '  Installing Az.Resources...'
            Install-Module -Name Az.Resources -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        }
        if (-not (Get-Module -ListAvailable -Name Az.Storage)) {
            Write-Host '  Installing Az.Storage...'
            Install-Module -Name Az.Storage -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        }
        if (-not (Get-Module -ListAvailable -Name Az.Network)) {
            Write-Host '  Installing Az.Network...'
            Install-Module -Name Az.Network -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        }
        Write-Host '  PowerShell modules installed successfully'
    } catch {
        Write-Warning \"PowerShell module installation had issues: \$_\"
    }
" || echo "Warning: PowerShell module installation incomplete, continuing..."

# Install Terratest dependencies
echo "🧪 Installing Terratest dependencies..."
go install github.com/gruntwork-io/terratest/modules/terraform@latest 2>/dev/null || echo "Warning: Terratest installation had issues, continuing..."

# Create Terraform plugin cache directory
echo "📂 Creating Terraform plugin cache directory..."
mkdir -p "/home/vscode/.terraform-cache"
chmod 755 "/home/vscode/.terraform-cache"

# Install additional utilities
echo "🛠️  Installing additional utilities..."
sudo apt-get install -y -qq \
    jq \
    tree \
    vim \
    curl \
    wget \
    unzip \
    graphviz

# Configure Git safe directory (for mounted volumes)
echo "🔐 Configuring Git safe directory..."
git config --global --add safe.directory "${PWD}"

# Set up Azure CLI defaults
echo "☁️  Configuring Azure CLI defaults..."
az config set defaults.location=swedencentral --only-show-errors 2>/dev/null || true

# Verify installations
echo ""
echo "✅ Verifying tool installations..."
echo "  Terraform: $(terraform version | head -n1)"
echo "  Azure CLI: $(az version --query '"azure-cli"' -o tsv)"
echo "  Bicep: $(az bicep version)"
echo "  PowerShell: $(pwsh --version)"
echo "  Python: $(python3 --version)"
echo "  Go: $(go version)"
echo "  Node.js: $(node --version)"
echo "  tfsec: $(tfsec --version 2>&1 | head -n1)"
echo "  Checkov: $(checkov --version)"

echo ""
echo "🎉 Post-create setup completed successfully!"
echo ""
echo "📝 Next steps:"
echo "  1. Authenticate with Azure: az login"
echo "  2. Set your Azure subscription: az account set --subscription <subscription-id>"
echo "  3. Start exploring demos in the demos/ folder"
echo ""
