#!/bin/bash

# Terraform Infrastructure - Deployment Script
# Validates and deploys Terraform infrastructure to Azure

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="${1:-dev}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$PROJECT_ROOT/solution/environments/$ENVIRONMENT"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Terraform Infrastructure - Deployment Script           ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Validate environment parameter
if [[ ! " dev staging prod " =~ " ${ENVIRONMENT} " ]]; then
    echo -e "${RED}ERROR: Invalid environment '${ENVIRONMENT}'${NC}"
    echo "Usage: ./deploy.sh [dev|staging|prod]"
    exit 1
fi

echo -e "${GREEN}Environment: ${ENVIRONMENT}${NC}"
echo -e "${GREEN}Terraform Directory: ${TF_DIR}${NC}"
echo ""

# Check prerequisites
echo -e "${CYAN}Checking prerequisites...${NC}"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}ERROR: Terraform is not installed${NC}"
    echo "Install from: https://www.terraform.io/downloads"
    exit 1
fi

TERRAFORM_VERSION=$(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)
echo -e "${GREEN}✓ Terraform installed (version ${TERRAFORM_VERSION})${NC}"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}ERROR: Azure CLI is not installed${NC}"
    echo "Install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

echo -e "${GREEN}✓ Azure CLI installed${NC}"

# Check Azure login
AZURE_ACCOUNT=$(az account show --query name -o tsv 2>/dev/null)
if [ -z "$AZURE_ACCOUNT" ]; then
    echo -e "${YELLOW}Not logged in to Azure. Running 'az login'...${NC}"
    az login
    AZURE_ACCOUNT=$(az account show --query name -o tsv)
fi

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo -e "${GREEN}✓ Azure authenticated${NC}"
echo -e "  Account: ${AZURE_ACCOUNT}"
echo -e "  Subscription: ${SUBSCRIPTION_ID}"
echo ""

# Check if Terraform directory exists
if [ ! -d "$TF_DIR" ]; then
    echo -e "${RED}ERROR: Terraform directory not found: ${TF_DIR}${NC}"
    echo "Please create the environment configuration first"
    exit 1
fi

cd "$TF_DIR"

# Terraform validation
echo -e "${CYAN}Validating Terraform configuration...${NC}"

# Check formatting
echo -n "Checking code formatting... "
if terraform fmt -check -recursive > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠ Code not formatted${NC}"
    echo "Running 'terraform fmt -recursive'..."
    terraform fmt -recursive
fi

# Initialize Terraform
echo -n "Initializing Terraform... "
if terraform init > /tmp/tf-init.log 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    cat /tmp/tf-init.log
    exit 1
fi

# Validate configuration
echo -n "Validating configuration... "
if terraform validate > /tmp/tf-validate.log 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    cat /tmp/tf-validate.log
    exit 1
fi

# Optional: Run tfsec if installed
if command -v tfsec &> /dev/null; then
    echo -n "Running security scan (tfsec)... "
    if tfsec . --soft-fail > /tmp/tfsec.log 2>&1; then
        echo -e "${GREEN}✓ No critical issues${NC}"
    else
        echo -e "${YELLOW}⚠ Warnings found (see /tmp/tfsec.log)${NC}"
    fi
fi

# Optional: Run checkov if installed
if command -v checkov &> /dev/null; then
    echo -n "Running policy scan (checkov)... "
    if checkov -d . --quiet --compact > /tmp/checkov.log 2>&1; then
        echo -e "${GREEN}✓ Policy compliant${NC}"
    else
        echo -e "${YELLOW}⚠ Warnings found (see /tmp/checkov.log)${NC}"
    fi
fi

echo ""

# Generate plan
echo -e "${CYAN}Generating execution plan...${NC}"
terraform plan -out=tfplan

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    DEPLOYMENT CONFIRMATION                 ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}You are about to deploy to: ${ENVIRONMENT}${NC}"
echo -e "${YELLOW}Subscription: ${AZURE_ACCOUNT} (${SUBSCRIPTION_ID})${NC}"
echo ""
echo -e "Review the plan above carefully."
echo ""
read -p "Do you want to proceed with deployment? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Deployment cancelled by user${NC}"
    rm -f tfplan
    exit 0
fi

echo ""
echo -e "${CYAN}Applying Terraform configuration...${NC}"
START_TIME=$(date +%s)

if terraform apply tfplan; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                  DEPLOYMENT SUCCESSFUL                     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Environment: ${ENVIRONMENT}${NC}"
    echo -e "${GREEN}Duration: ${DURATION} seconds${NC}"
    echo ""
    echo -e "${CYAN}Outputs:${NC}"
    terraform output
    echo ""
    echo -e "${CYAN}Next Steps:${NC}"
    echo -e "  1. Verify resources in Azure Portal"
    echo -e "  2. Test application connectivity"
    echo -e "  3. Review monitoring dashboards"
    echo -e "  4. Run validation tests: ./test.sh ${ENVIRONMENT}"
    echo ""
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                    DEPLOYMENT FAILED                       ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Check the error messages above for details${NC}"
    echo -e "${YELLOW}Common issues:${NC}"
    echo -e "  • Insufficient Azure permissions"
    echo -e "  • Resource naming conflicts (try unique suffix)"
    echo -e "  • Quota limits exceeded"
    echo -e "  • Network connectivity issues"
    exit 1
fi

# Cleanup
rm -f tfplan
