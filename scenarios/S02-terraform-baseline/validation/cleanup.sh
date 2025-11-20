#!/bin/bash

# Terraform Infrastructure - Cleanup Script
# Safely destroys all Terraform-managed resources

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ENVIRONMENT="${1:-dev}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$PROJECT_ROOT/solution/environments/$ENVIRONMENT"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Terraform Infrastructure - Cleanup Script              ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Validate environment
if [[ ! " dev staging prod " =~ " ${ENVIRONMENT} " ]]; then
    echo -e "${RED}ERROR: Invalid environment '${ENVIRONMENT}'${NC}"
    echo "Usage: ./cleanup.sh [dev|staging|prod]"
    exit 1
fi

echo -e "${RED}⚠️  WARNING: This will destroy all resources in ${ENVIRONMENT}${NC}"
echo ""

# Check if directory exists
if [ ! -d "$TF_DIR" ]; then
    echo -e "${RED}ERROR: Terraform directory not found: ${TF_DIR}${NC}"
    exit 1
fi

cd "$TF_DIR"

# Check if state exists
if [ ! -f ".terraform/terraform.tfstate" ] && [ ! -f "terraform.tfstate" ]; then
    echo -e "${YELLOW}No Terraform state found. Nothing to destroy.${NC}"
    exit 0
fi

# Show current resources
echo -e "${CYAN}Current resources:${NC}"
terraform show -no-color | head -n 50
echo ""

# Confirmation
echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║                    DESTRUCTION CONFIRMATION                ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${RED}You are about to DESTROY all resources in: ${ENVIRONMENT}${NC}"
echo -e "${RED}This action CANNOT be undone!${NC}"
echo ""
echo -e "Type the environment name to confirm: "
read -p "> " CONFIRM_ENV

if [ "$CONFIRM_ENV" != "$ENVIRONMENT" ]; then
    echo -e "${YELLOW}Cleanup cancelled (environment name mismatch)${NC}"
    exit 0
fi

echo ""
echo -e "${CYAN}Destroying resources...${NC}"
START_TIME=$(date +%s)

if terraform destroy -auto-approve; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                   CLEANUP SUCCESSFUL                       ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}All resources destroyed in ${DURATION} seconds${NC}"
    echo ""
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                     CLEANUP FAILED                         ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Some resources may still exist. Check Azure Portal.${NC}"
    echo -e "${YELLOW}You may need to manually delete resources or run destroy again.${NC}"
    exit 1
fi
