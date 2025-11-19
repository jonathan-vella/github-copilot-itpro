#!/bin/bash
set -e

echo "🔄 Updating development tools..."

# Update Azure CLI
echo "📦 Updating Azure CLI..."
az upgrade --yes --only-show-errors 2>/dev/null || true

# Update Bicep
echo "📦 Updating Bicep..."
az bicep upgrade --only-show-errors 2>/dev/null || true

# Update Terraform
echo "📦 Checking for Terraform updates..."
CURRENT_VERSION=$(terraform version -json | jq -r '.terraform_version')
echo "  Current Terraform version: $CURRENT_VERSION"

# Update PowerShell modules
echo "📦 Updating PowerShell modules..."
pwsh -NoProfile -Command "
    Update-Module -Name Az.Accounts -Force -ErrorAction SilentlyContinue
    Update-Module -Name Az.Resources -Force -ErrorAction SilentlyContinue
    Update-Module -Name Az.Storage -Force -ErrorAction SilentlyContinue
    Update-Module -Name Az.Network -Force -ErrorAction SilentlyContinue
"

# Update Python packages
echo "📦 Updating Python packages..."
pip3 install --upgrade --quiet checkov

# Update Go modules
echo "📦 Updating Go modules..."
go get -u github.com/gruntwork-io/terratest/modules/terraform

echo "✅ Tool updates completed!"
