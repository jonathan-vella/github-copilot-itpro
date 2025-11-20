#!/bin/bash
set -e

echo "🚀 Running post-create setup for GitHub Copilot IT Pro environment..."

# Log output to file for debugging
exec 1> >(tee -a ~/.devcontainer-install.log)
exec 2>&1

# Update package lists
echo "📦 Updating package lists..."
sudo apt-get update -qq

# Install Python pip (required for Checkov)
echo "🐍 Installing Python pip..."
sudo apt-get install -y -qq python3-pip

# Install security scanning tools for Terraform
echo "🔒 Installing Terraform security scanners..."

# Install tfsec
echo "  → Installing tfsec..."
if ! command -v tfsec &> /dev/null; then
    curl -sSL https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
    sudo mv tfsec /usr/local/bin/ 2>/dev/null || true
fi

# Install Checkov (use --break-system-packages for Ubuntu 24.04)
echo "  → Installing Checkov..."
if ! command -v checkov &> /dev/null; then
    pip3 install --quiet --no-cache-dir --break-system-packages checkov || echo "Warning: Checkov installation had issues, continuing..."
fi

# Install Diagrams library for S08
echo "📊 Installing Diagrams library..."
pip3 install --quiet --no-cache-dir --break-system-packages diagrams || echo "Warning: Diagrams installation had issues, continuing..."

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

# Install Terratest dependencies (skip if Go not available)
echo "🧪 Installing Terratest dependencies..."
if command -v go &> /dev/null; then
    go install github.com/gruntwork-io/terratest/modules/terraform@latest 2>/dev/null || echo "Warning: Terratest installation had issues, continuing..."
else
    echo "  → Skipping Terratest (Go not installed)"
fi

# Create Terraform plugin cache directory
echo "📂 Creating Terraform plugin cache directory..."
mkdir -p "/home/vscode/.terraform-cache"
chmod 755 "/home/vscode/.terraform-cache"

# Install Node.js and npm (for markdown validation)
echo "📦 Installing Node.js LTS..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y -qq nodejs
fi

# Install markdownlint-cli globally
echo "📝 Installing markdownlint-cli..."
if ! command -v markdownlint &> /dev/null; then
    sudo npm install -g markdownlint-cli --silent
fi

# Install additional utilities
echo "🛠️  Installing additional utilities..."
sudo apt-get install -y -qq \
    jq \
    tree \
    vim \
    curl \
    wget \
    unzip \
    graphviz \
    dos2unix

# Configure Git safe directory (for mounted volumes)
echo "🔐 Configuring Git safe directory..."
git config --global --add safe.directory "${PWD}"

# Install Bicep CLI
echo "🔧 Installing Bicep CLI..."
if ! az bicep version &> /dev/null; then
    rm -rf ~/.azure/bin/bicep
    az bicep install && chmod +x ~/.azure/bin/bicep || echo "Warning: Bicep installation had issues, continuing..."
fi

# Add Bicep to PATH if not already present
if [[ ":$PATH:" != *":$HOME/.azure/bin:"* ]]; then
    echo 'export PATH=$PATH:$HOME/.azure/bin' >> ~/.bashrc
    echo "  → Added Bicep to PATH in .bashrc"
fi

# Set up Azure CLI defaults
echo "☁️  Configuring Azure CLI defaults..."
az config set defaults.location=swedencentral --only-show-errors 2>/dev/null || true

# Verify installations
echo ""
echo "✅ Verifying tool installations..."
echo "  Terraform: $(terraform version 2>/dev/null | head -n1 || echo 'not installed')"
echo "  Azure CLI: $(az version --query '"azure-cli"' -o tsv 2>/dev/null || echo 'not installed')"
echo "  Bicep: $(az bicep version 2>/dev/null || echo 'not installed')"
echo "  PowerShell: $(pwsh --version 2>/dev/null || echo 'not installed')"
echo "  Python: $(python3 --version 2>/dev/null || echo 'not installed')"
echo "  pip: $(pip3 --version 2>/dev/null | awk '{print $2}' || echo 'not installed')"
echo "  Go: $(go version 2>/dev/null || echo 'not installed')"
echo "  Node.js: $(node --version 2>/dev/null || echo 'not installed')"
echo "  npm: $(npm --version 2>/dev/null || echo 'not installed')"
echo "  markdownlint: $(markdownlint --version 2>/dev/null || echo 'not installed')"
echo "  tfsec: $(tfsec --version 2>/dev/null || echo 'not installed')"
echo "  Checkov: $(checkov --version 2>/dev/null || echo 'not installed')"

echo ""
echo "🎉 Post-create setup completed successfully!"
echo ""
echo "📝 Next steps:"
echo "  1. Authenticate with Azure: az login"
echo "  2. Set your Azure subscription: az account set --subscription <subscription-id>"
echo "  3. Start exploring demos in the scenarios/ folder"
echo ""
