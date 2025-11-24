#!/bin/bash
# Quick Load Test for S05 Validation
set -euo pipefail

CONCURRENT=${1:-10}
REQUESTS=${2:-10}
API_URL=${3:-"https://app-saifv2-api-ss4xs2.azurewebsites.net"}

echo "================================================"
echo "  S05 Load Test Validation"
echo "================================================"
echo "API URL: $API_URL"
echo "Concurrent Users: $CONCURRENT"
echo "Requests per User: $REQUESTS"
echo "Total Requests: $((CONCURRENT * REQUESTS))"
echo ""

# Test endpoints
endpoints=(
    "/"
    "/api/healthcheck"
    "/api/sqlversion"
    "/api/sqlwhoami"
    "/api/ip"
)

echo "🚀 Running load test..."
start_time=$(date +%s)

# Use GNU parallel if available, otherwise simple loop
if command -v parallel &> /dev/null; then
    echo "Using GNU parallel for concurrent requests"
    seq 1 $((CONCURRENT * REQUESTS)) | parallel -j "$CONCURRENT" "
        endpoint=\${endpoints[\$((RANDOM % ${#endpoints[@]}))]}
        curl -s -o /dev/null -w '%{http_code},%{time_total}\n' '$API_URL\$endpoint'
    " > /tmp/load_test_results.txt
else
    echo "Running sequential test (install 'parallel' for better performance)"
    > /tmp/load_test_results.txt
    for i in $(seq 1 $((CONCURRENT * REQUESTS))); do
        endpoint=${endpoints[$((RANDOM % ${#endpoints[@]}))]}
        curl -s -o /dev/null -w "%{http_code},%{time_total}\n" "$API_URL$endpoint" >> /tmp/load_test_results.txt &
        
        # Limit concurrent processes
        if [ $((i % CONCURRENT)) -eq 0 ]; then
            wait
        fi
    done
    wait
fi

end_time=$(date +%s)
duration=$((end_time - start_time))

echo "✓ Completed in ${duration} seconds"
echo ""

# Analyze results
total=$(wc -l < /tmp/load_test_results.txt)
success=$(grep -c "^200," /tmp/load_test_results.txt || true)
failed=$((total - success))
success_pct=$((success * 100 / total))

# Calculate average response time
avg_time=$(awk -F',' '{sum+=$2; count++} END {if(count>0) printf "%.3f", sum/count; else print "0"}' /tmp/load_test_results.txt)

echo "📊 Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total Requests:    $total"
echo "Successful (200):  $success ($success_pct%)"
echo "Failed:            $failed"
echo "Avg Response Time: ${avg_time}s"
echo "Throughput:        $((total / duration)) req/s"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Validate
if [ "$success_pct" -ge 95 ]; then
    echo "✅ LOAD TEST PASSED"
    echo "   Success rate: ${success_pct}% (≥95% required)"
    rm -f /tmp/load_test_results.txt
    exit 0
else
    echo "❌ LOAD TEST FAILED"
    echo "   Success rate: ${success_pct}% (≥95% required)"
    rm -f /tmp/load_test_results.txt
    exit 1
fi
