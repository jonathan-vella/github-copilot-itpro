#!/bin/bash
set -e

echo "🚀 Running post-create setup for GitHub Copilot IT Pro environment..."

# Update package lists
echo "📦 Updating package lists..."
sudo apt-get update -qq

# Install security scanning tools for Terraform
echo "🔒 Installing Terraform security scanners..."

# Install tfsec
echo "  → Installing tfsec..."
if ! command -v tfsec &> /dev/null; then
    curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
    sudo mv tfsec /usr/local/bin/
fi

# Install Checkov
echo "  → Installing Checkov..."
if ! command -v checkov &> /dev/null; then
    pip3 install --quiet --no-cache-dir checkov
fi

# Install Azure PowerShell modules
echo "🔧 Installing Azure PowerShell modules..."
pwsh -NoProfile -Command "
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        Install-Module -Name Az.Accounts -Scope CurrentUser -Force -AllowClobber
    }
    if (-not (Get-Module -ListAvailable -Name Az.Resources)) {
        Install-Module -Name Az.Resources -Scope CurrentUser -Force -AllowClobber
    }
    if (-not (Get-Module -ListAvailable -Name Az.Storage)) {
        Install-Module -Name Az.Storage -Scope CurrentUser -Force -AllowClobber
    }
    if (-not (Get-Module -ListAvailable -Name Az.Network)) {
        Install-Module -Name Az.Network -Scope CurrentUser -Force -AllowClobber
    }
"

# Install Terratest dependencies
echo "🧪 Installing Terratest dependencies..."
go install github.com/gruntwork-io/terratest/modules/terraform@latest

# Create Terraform plugin cache directory
echo "📂 Creating Terraform plugin cache directory..."
mkdir -p "${PWD}/.terraform-cache"
chmod 755 "${PWD}/.terraform-cache"

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
