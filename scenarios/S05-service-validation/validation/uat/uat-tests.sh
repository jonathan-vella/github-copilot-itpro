#!/bin/bash

##############################################################################
# SAIF API v2 - User Acceptance Testing (UAT)
#
# Description: Bash-based UAT tests for validating SAIF API v2 endpoints,
#              performance, security, and business requirements.
#
# Usage:
#   ./uat-tests.sh [options]
#
# Options:
#   --verbose         Enable verbose output
#   --endpoint NAME   Test specific endpoint only
#   --help            Show this help message
#
# Environment Variables:
#   API_BASE_URL      Base URL of the API (required)
#
# Examples:
#   ./uat-tests.sh
#   ./uat-tests.sh --verbose
#   ./uat-tests.sh --endpoint health
#   API_BASE_URL="https://app-saifv2-api-xxx.azurewebsites.net" ./uat-tests.sh
#
# Requirements: curl, jq
#
# Author: DevOps Team
# Version: 1.0
# Last Updated: 2025-11-24
##############################################################################

set -uo pipefail
# Note: Not using set -e to allow tests to continue after failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Configuration
VERBOSE=false
SPECIFIC_ENDPOINT=""
MAX_RESPONSE_TIME_MS=600
MAX_DB_RESPONSE_TIME_MS=30000  # 30 seconds for database cold starts

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --endpoint)
            SPECIFIC_ENDPOINT="$2"
            shift 2
            ;;
        --help)
            grep '^#' "$0" | sed 's/^# \?//'
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Validate API_BASE_URL is set
if [[ -z "${API_BASE_URL:-}" ]]; then
    echo -e "${RED}Error: API_BASE_URL environment variable is required${NC}"
    echo "Example: export API_BASE_URL='https://app-saifv2-api-xxx.azurewebsites.net'"
    exit 1
fi

# Remove trailing slash
API_BASE_URL="${API_BASE_URL%/}"

# Check dependencies
command -v curl >/dev/null 2>&1 || { echo -e "${RED}Error: curl is required but not installed${NC}"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo -e "${RED}Error: jq is required but not installed${NC}"; exit 1; }

echo -e "${CYAN}=== SAIF API v2 - User Acceptance Testing ===${NC}"
echo -e "${BLUE}API Base URL: ${API_BASE_URL}${NC}"
echo -e "${BLUE}Test Start Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')${NC}"
echo ""

##############################################################################
# Helper Functions
##############################################################################

# Make API request and measure response time
api_request() {
    local endpoint="$1"
    local expected_status="${2:-200}"
    local url="${API_BASE_URL}${endpoint}"

    # Make request with timing
    local start_time=$(date +%s%N)
    local http_code
    local response_body
    local response_time_ms

    response=$(curl -s -w "\n%{http_code}\n%{time_total}" -X GET "$url" 2>/dev/null || echo -e "\n000\n0")
    
    # Parse response
    response_body=$(echo "$response" | head -n -2)
    http_code=$(echo "$response" | tail -n 2 | head -n 1)
    response_time=$(echo "$response" | tail -n 1)
    # Convert to milliseconds using awk (more portable than bc)
    response_time_ms=$(echo "$response_time" | awk '{printf "%.0f", $1 * 1000}')

    # Return results via global variables (bash limitation workaround)
    LAST_HTTP_CODE=$http_code
    LAST_RESPONSE_BODY=$response_body
    LAST_RESPONSE_TIME_MS=$response_time_ms
    
    [[ $VERBOSE == true ]] && echo -e "${BLUE}  Response: $http_code in ${response_time_ms}ms${NC}"
}

# Test assertion
assert_equals() {
    local actual="$1"
    local expected="$2"
    local test_name="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [[ "$actual" == "$expected" ]]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "${GREEN}✓${NC} $test_name"
        return 0
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${RED}✗${NC} $test_name"
        echo -e "  ${RED}Expected: $expected, Got: $actual${NC}"
        return 1
    fi
}

# Test assertion for less than
assert_less_than() {
    local actual="$1"
    local max="$2"
    local test_name="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [[ $actual -lt $max ]]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "${GREEN}✓${NC} $test_name (${actual}ms < ${max}ms)"
        return 0
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${RED}✗${NC} $test_name"
        echo -e "  ${RED}Expected: < $max, Got: $actual${NC}"
        return 1
    fi
}

# Test assertion for JSON validity
assert_valid_json() {
    local json="$1"
    local test_name="$2"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if echo "$json" | jq empty 2>/dev/null; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "${GREEN}✓${NC} $test_name"
        return 0
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${RED}✗${NC} $test_name"
        echo -e "  ${RED}Invalid JSON response${NC}"
        return 1
    fi
}

# Test assertion for string contains
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [[ "$haystack" == *"$needle"* ]]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "${GREEN}✓${NC} $test_name"
        return 0
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${RED}✗${NC} $test_name"
        echo -e "  ${RED}Expected to find: $needle${NC}"
        return 1
    fi
}

# Test assertion for NOT contains
assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [[ "$haystack" != *"$needle"* ]]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "${GREEN}✓${NC} $test_name"
        return 0
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "${RED}✗${NC} $test_name"
        echo -e "  ${RED}Should not contain: $needle${NC}"
        return 1
    fi
}

##############################################################################
# Test Suites
##############################################################################

test_health_check() {
    echo -e "\n${CYAN}[Health Check Tests]${NC}"

    api_request "/"
    assert_equals "$LAST_HTTP_CODE" "200" "Health check endpoint returns 200 OK"
    assert_less_than "$LAST_RESPONSE_TIME_MS" "$MAX_RESPONSE_TIME_MS" "Health check responds within ${MAX_RESPONSE_TIME_MS}ms"
    assert_valid_json "$LAST_RESPONSE_BODY" "Health check returns valid JSON"
}

test_version_info() {
    echo -e "\n${CYAN}[Version Information Tests]${NC}"

    api_request "/"
    assert_equals "$LAST_HTTP_CODE" "200" "Version endpoint returns 200 OK"
    assert_less_than "$LAST_RESPONSE_TIME_MS" "$MAX_RESPONSE_TIME_MS" "Version endpoint responds within ${MAX_RESPONSE_TIME_MS}ms"
    assert_valid_json "$LAST_RESPONSE_BODY" "Version endpoint returns valid JSON"
    assert_contains "$LAST_RESPONSE_BODY" "version" "Version response contains version field"
}

test_identity() {
    echo -e "\n${CYAN}[Identity Verification Tests]${NC}"

    api_request "/api/sqlwhoami"
    assert_equals "$LAST_HTTP_CODE" "200" "Identity endpoint returns 200 OK"
    assert_less_than "$LAST_RESPONSE_TIME_MS" "$MAX_RESPONSE_TIME_MS" "Identity endpoint responds within ${MAX_RESPONSE_TIME_MS}ms"
    assert_valid_json "$LAST_RESPONSE_BODY" "Identity endpoint returns valid JSON"
    
    # Security check
    local lower_response=$(echo "$LAST_RESPONSE_BODY" | tr '[:upper:]' '[:lower:]')
    assert_not_contains "$lower_response" "password" "Response does not contain 'password'"
    assert_not_contains "$lower_response" "secret" "Response does not contain 'secret'"
}

test_client_info() {
    echo -e "\n${CYAN}[Client Information Tests]${NC}"

    api_request "/api/ip"
    assert_equals "$LAST_HTTP_CODE" "200" "Source IP endpoint returns 200 OK"
    assert_less_than "$LAST_RESPONSE_TIME_MS" "$MAX_RESPONSE_TIME_MS" "Source IP endpoint responds within ${MAX_RESPONSE_TIME_MS}ms"
    assert_valid_json "$LAST_RESPONSE_BODY" "Source IP endpoint returns valid JSON"
}

test_database_connectivity() {
    echo -e "\n${CYAN}[Database Connectivity Tests]${NC}"

    # SQL whoami test
    api_request "/api/sqlwhoami"
    assert_equals "$LAST_HTTP_CODE" "200" "SQL identity endpoint returns 200 OK"
    assert_less_than "$LAST_RESPONSE_TIME_MS" "$MAX_DB_RESPONSE_TIME_MS" "SQL identity endpoint responds within ${MAX_DB_RESPONSE_TIME_MS}ms"
    assert_valid_json "$LAST_RESPONSE_BODY" "SQL identity endpoint returns valid JSON"

    # SQL connection test
    api_request "/api/sqlsrcip"
    assert_equals "$LAST_HTTP_CODE" "200" "SQL connection endpoint returns 200 OK"
    assert_less_than "$LAST_RESPONSE_TIME_MS" "$MAX_DB_RESPONSE_TIME_MS" "SQL connection endpoint responds within ${MAX_DB_RESPONSE_TIME_MS}ms"
    assert_valid_json "$LAST_RESPONSE_BODY" "SQL connection endpoint returns valid JSON"
}

test_security() {
    echo -e "\n${CYAN}[Security Tests]${NC}"

    # HTTPS enforcement
    assert_contains "$API_BASE_URL" "https://" "API uses HTTPS"

    # Check for security headers (optional - not all Azure App Services set HSTS by default)
    local headers=$(curl -s -I "$API_BASE_URL/" 2>/dev/null | tr '[:upper:]' '[:lower:]')
    if [[ "$headers" == *"strict-transport-security"* ]]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        echo -e "${GREEN}✓${NC} Strict-Transport-Security header present (optional)"
    else
        echo -e "${YELLOW}ℹ${NC} Strict-Transport-Security header not set (optional for Azure App Service)"
    fi
}

test_error_handling() {
    echo -e "\n${CYAN}[Error Handling Tests]${NC}"

    api_request "/api/nonexistent" "404"
    assert_equals "$LAST_HTTP_CODE" "404" "Non-existent endpoint returns 404"
}

test_performance() {
    echo -e "\n${CYAN}[Performance Tests]${NC}"

    # Test multiple endpoints for consistent performance
    local endpoints=("/" "/api/ip" "/api/sqlwhoami" "/api/sqlsrcip")
    local total_time=0
    local count=0

    for endpoint in "${endpoints[@]}"; do
        api_request "$endpoint"
        total_time=$((total_time + LAST_RESPONSE_TIME_MS))
        count=$((count + 1))
    done

    local avg_time=$((total_time / count))
    assert_less_than "$avg_time" "$MAX_RESPONSE_TIME_MS" "Average response time across all endpoints (${avg_time}ms < ${MAX_RESPONSE_TIME_MS}ms)"
}

##############################################################################
# Main Test Execution
##############################################################################

# Run specific endpoint or all tests
case "$SPECIFIC_ENDPOINT" in
    "health")
        test_health_check
        ;;
    "version")
        test_version_info
        ;;
    "identity")
        test_identity
        ;;
    "client")
        test_client_info
        ;;
    "database")
        test_database_connectivity
        ;;
    "security")
        test_security
        ;;
    "error")
        test_error_handling
        ;;
    "performance")
        test_performance
        ;;
    "")
        # Run all tests
        test_health_check
        test_version_info
        test_identity
        test_client_info
        test_database_connectivity
        test_security
        test_error_handling
        test_performance
        ;;
    *)
        echo -e "${RED}Unknown endpoint: $SPECIFIC_ENDPOINT${NC}"
        exit 1
        ;;
esac

##############################################################################
# Test Summary
##############################################################################

echo ""
echo -e "${CYAN}=== Test Summary ===${NC}"
echo -e "${BLUE}Test End Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')${NC}"
echo ""
echo -e "Total Tests:  $TOTAL_TESTS"
echo -e "${GREEN}Passed:       $PASSED_TESTS${NC}"
if [[ $FAILED_TESTS -gt 0 ]]; then
    echo -e "${RED}Failed:       $FAILED_TESTS${NC}"
else
    echo -e "Failed:       $FAILED_TESTS"
fi
echo ""

# Calculate success rate
if [[ $TOTAL_TESTS -gt 0 ]]; then
    SUCCESS_RATE=$(awk "BEGIN {printf \"%.1f\", $PASSED_TESTS * 100 / $TOTAL_TESTS}")
    echo -e "Success Rate: ${SUCCESS_RATE}%"
    echo ""
fi

# Exit with appropriate code
if [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
