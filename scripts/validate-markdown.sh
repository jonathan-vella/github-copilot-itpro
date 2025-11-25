#!/bin/bash
# ============================================================================
# Markdown Validation Script
# ============================================================================
# Purpose: Validate all markdown files against style guide and fix common issues
# Usage:
#   ./scripts/validate-markdown.sh          # Validate only
#   ./scripts/validate-markdown.sh --fix    # Validate and auto-fix
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if markdownlint is installed
if ! command -v markdownlint &> /dev/null; then
    echo -e "${RED}Error: markdownlint-cli is not installed${NC}"
    echo ""
    echo "Install it with:"
    echo "  npm install -g markdownlint-cli"
    echo ""
    echo "Or use npx to run without installing:"
    echo "  npx markdownlint-cli '**/*.md' --ignore node_modules --config .markdownlint.json"
    exit 1
fi

# Parse arguments
FIX_MODE=false
if [ "$1" == "--fix" ]; then
    FIX_MODE=true
fi

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Markdown Validation Script${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Count markdown files
MD_COUNT=$(find . -name "*.md" -not -path "./node_modules/*" -not -path "./.git/*" | wc -l)
echo -e "${BLUE}Found ${MD_COUNT} markdown file(s)${NC}"
echo ""

# Run validation
echo -e "${BLUE}Step 1: Running markdownlint validation...${NC}"
if [ "$FIX_MODE" = true ]; then
    echo -e "${YELLOW}(Auto-fix mode enabled)${NC}"
    if markdownlint '**/*.md' --ignore node_modules --config .markdownlint.json --fix; then
        echo -e "${GREEN}✓ Validation passed (with auto-fixes applied)${NC}"
        VALIDATION_PASSED=true
    else
        echo -e "${RED}✗ Validation failed (some issues could not be auto-fixed)${NC}"
        VALIDATION_PASSED=false
    fi
else
    if markdownlint '**/*.md' --ignore node_modules --config .markdownlint.json; then
        echo -e "${GREEN}✓ Validation passed${NC}"
        VALIDATION_PASSED=true
    else
        echo -e "${RED}✗ Validation failed${NC}"
        VALIDATION_PASSED=false
    fi
fi
echo ""

# Check line endings
echo -e "${BLUE}Step 2: Checking line endings...${NC}"
if git ls-files --eol | grep 'w/crlf' > /dev/null; then
    echo -e "${YELLOW}⚠ Found files with CRLF line endings${NC}"
    echo ""
    echo "Files with CRLF:"
    git ls-files --eol | grep 'w/crlf'
    echo ""
    echo "To fix, run:"
    echo "  git add --renormalize ."
    LINE_ENDINGS_OK=false
else
    echo -e "${GREEN}✓ All files use LF line endings${NC}"
    LINE_ENDINGS_OK=true
fi
echo ""

# Summary
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}======================================${NC}"

if [ "$VALIDATION_PASSED" = true ] && [ "$LINE_ENDINGS_OK" = true ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some checks failed${NC}"
    echo ""
    if [ "$VALIDATION_PASSED" = false ]; then
        echo "Markdown validation: FAILED"
        if [ "$FIX_MODE" = false ]; then
            echo "  Tip: Run with --fix to auto-fix common issues"
        fi
    fi
    if [ "$LINE_ENDINGS_OK" = false ]; then
        echo "Line endings check: FAILED"
        echo "  Tip: Run 'git add --renormalize .' to fix"
    fi
    exit 1
fi
