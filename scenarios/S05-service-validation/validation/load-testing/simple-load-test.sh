#!/bin/bash

# Simple Load Test Validation Script
# Tests S05 API with concurrent requests to validate deployment

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
CONCURRENT_USERS=${1:-10}
REQUESTS_PER_USER=${2:-5}
API_URL=${3:-"https://app-saifv2-api-ss4xs2.azurewebsites.net"}

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}  S05 Load Test Validation${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""
echo -e "Target API:       ${API_URL}"
echo -e "Concurrent Users: ${CONCURRENT_USERS}"
echo -e "Requests/User:    ${REQUESTS_PER_USER}"
echo -e "Total Requests:   $((CONCURRENT_USERS * REQUESTS_PER_USER))"
echo ""

# Create temp directory for results
TEMP_DIR=$(mktemp -d)
trap "rm -rf ${TEMP_DIR}" EXIT

# Function to test endpoint
test_endpoint() {
    local endpoint=$1
    local user_id=$2
    local request_num=$3
    
    local start_time=$(date +%s%N)
    local response=$(curl -s -w "\n%{http_code}\n%{time_total}" "${API_URL}${endpoint}" -o "${TEMP_DIR}/response_${user_id}_${request_num}.json" 2>&1)
    local end_time=$(date +%s%N)
    
    local http_code=$(echo "$response" | tail -n 2 | head -n 1)
    local time_total=$(echo "$response" | tail -n 1)
    local duration=$(( (end_time - start_time) / 1000000 ))
    
    echo "${endpoint}|${http_code}|${duration}" >> "${TEMP_DIR}/results_${user_id}.txt"
}

# Function to simulate user
simulate_user() {
    local user_id=$1
    
    for i in $(seq 1 ${REQUESTS_PER_USER}); do
        # Test different endpoints
        case $((i % 5)) in
            0) test_endpoint "/" ${user_id} ${i} ;;
            1) test_endpoint "/api/healthcheck" ${user_id} ${i} ;;
            2) test_endpoint "/api/sqlversion" ${user_id} ${i} ;;
            3) test_endpoint "/api/sqlwhoami" ${user_id} ${i} ;;
            4) test_endpoint "/api/ip" ${user_id} ${i} ;;
        esac
        
        # Small delay between requests
        sleep 0.1
    done
}

echo -e "${YELLOW}🚀 Starting load test...${NC}"
echo ""

# Start concurrent users
for user in $(seq 1 ${CONCURRENT_USERS}); do
    simulate_user ${user} &
done

# Wait for all background jobs to complete
wait

echo -e "${GREEN}✓ All requests completed${NC}"
echo ""

# Analyze results
echo -e "${CYAN}📊 Results Analysis${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

total_requests=0
successful_requests=0
failed_requests=0
total_time=0

for result_file in ${TEMP_DIR}/results_*.txt; do
    if [ -f "$result_file" ]; then
        while IFS='|' read -r endpoint http_code duration; do
            ((total_requests++))
            total_time=$((total_time + duration))
            
            if [ "${http_code}" == "200" ]; then
                ((successful_requests++))
            else
                ((failed_requests++))
            fi
        done < "$result_file"
    fi
done

# Calculate metrics
if [ ${total_requests} -gt 0 ]; then
    avg_response_time=$((total_time / total_requests))
    success_rate=$((successful_requests * 100 / total_requests))
    error_rate=$((100 - success_rate))
else
    avg_response_time=0
    success_rate=0
    error_rate=100
fi

echo -e "Total Requests:      ${total_requests}"
echo -e "Successful:          ${successful_requests} (${success_rate}%)"
echo -e "Failed:              ${failed_requests} (${error_rate}%)"
echo -e "Avg Response Time:   ${avg_response_time} ms"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Validate results
if [ ${success_rate} -ge 95 ] && [ ${avg_response_time} -lt 2000 ]; then
    echo -e "${GREEN}✅ LOAD TEST PASSED${NC}"
    echo -e "   Success rate: ${success_rate}% (≥95% required)"
    echo -e "   Avg response: ${avg_response_time}ms (<2000ms required)"
    exit 0
else
    echo -e "${RED}❌ LOAD TEST FAILED${NC}"
    if [ ${success_rate} -lt 95 ]; then
        echo -e "   ${RED}Success rate too low: ${success_rate}% (≥95% required)${NC}"
    fi
    if [ ${avg_response_time} -ge 2000 ]; then
        echo -e "   ${RED}Response time too high: ${avg_response_time}ms (<2000ms required)${NC}"
    fi
    exit 1
fi
