/**
 * SAIF - Secure AI Foundations
 * Custom JavaScript Functions
 * Version: 1.0.0
 * Last Updated: 2025-06-18
 */

// Global variables
let lastEndpoint = null;
let lastParams = null;
let isRequestPending = false;
let checksRun = 0;
let lastResponseTime = 0;

// Initialize tooltips and popovers from Bootstrap
document.addEventListener('DOMContentLoaded', function() {
    // Initialize Bootstrap tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));

    // Initialize Bootstrap popovers
    const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
    popoverTriggerList.map(popoverTriggerEl => new bootstrap.Popover(popoverTriggerEl));
    
    // Initialize dashboard metrics
    initializeDashboard();
});

/**
 * Initialize dashboard metrics with initial values
 */
function initializeDashboard() {
    // Start checking API status
    checkApiStatus();
    
    // Start checking DB status
    checkDbStatus();
    
    // Set up periodic refresh every 60 seconds
    setInterval(() => {
        checkApiStatus();
        checkDbStatus();
    }, 60000);
}

/**
 * Check API health status for dashboard
 */
async function checkApiStatus() {
    try {
        const startTime = performance.now();
        const response = await fetchFromApi('healthcheck', {}, false);
        const endTime = performance.now();
        
        // Calculate response time in milliseconds
        const responseTime = Math.round(endTime - startTime);
        
        // Update metrics
        document.getElementById('metric-api-status').textContent = response.status || 'Online';
        document.getElementById('metric-api-status').className = response.status === 'OK' ? 'text-success' : 'text-warning';
        
        document.getElementById('metric-latency').textContent = responseTime + 'ms';
        
        // Store for later use
        lastResponseTime = responseTime;
    } catch (error) {
        document.getElementById('metric-api-status').textContent = 'Offline';
        document.getElementById('metric-api-status').className = 'text-danger';
        document.getElementById('metric-latency').textContent = '--';
    }
}

/**
 * Check database status for dashboard
 */
async function checkDbStatus() {
    try {
        const response = await fetchFromApi('sqlversion', {}, false);
        document.getElementById('metric-db-status').textContent = 'Connected';
        document.getElementById('metric-db-status').className = 'text-success';
    } catch (error) {
        document.getElementById('metric-db-status').textContent = 'Error';
        document.getElementById('metric-db-status').className = 'text-danger';
    }
}

/**
 * Fetch data from the API via our PHP proxy but avoid updating dashboard
 * @param {string} endpoint - API endpoint path
 * @param {Object} params - Query parameters or path parameters
 * @param {boolean} updateDash - Whether to update dashboard metrics
 * @returns {Promise<Object>} API response as JSON
 */
async function fetchFromApi(endpoint, params = {}, updateDash = true) {
    // Create the URL using our api-proxy.php script
    const url = new URL('/api-proxy.php', window.location.origin);
    
    // Get endpoint name without the /api/ prefix if present
    const endpointName = endpoint.startsWith('/api/') ? 
        endpoint.substring(5) : endpoint;
    
    // Set the endpoint parameter
    url.searchParams.append('endpoint', endpointName);
    
    // Add additional query parameters if any
    Object.keys(params).forEach(key => {
        url.searchParams.append(key, params[key]);
    });

    try {
        // Set global tracking variables
        lastEndpoint = endpoint;
        lastParams = params;
        isRequestPending = true;
        
        // Start loading state
        updateLoadingState(true);
        
        const response = await fetch(url);
        
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        
        const data = await response.json();
        
        // End loading state
        updateLoadingState(false);
        isRequestPending = false;
        
        return data;
    } catch (error) {
        // End loading state even on error
        updateLoadingState(false);
        isRequestPending = false;
        
        return { error: error.message };
    }
}

/**
 * Update UI to show loading state
 * @param {boolean} isLoading - Whether request is loading
 */
function updateLoadingState(isLoading) {
    const resultElement = document.getElementById('result');
    const loadingIndicator = document.getElementById('loading-indicator');
    const resultTabs = document.getElementById('resultTabs');
    const executionInfo = document.getElementById('execution-info');
    const copyButton = document.getElementById('copyResultBtn');
    
    if (isLoading) {
        resultElement.classList.add('text-muted');
        if (loadingIndicator) {
            loadingIndicator.classList.remove('d-none');
        }
        if (executionInfo) {
            executionInfo.classList.add('d-none');
        }
    } else {
        resultElement.classList.remove('text-muted');
        if (loadingIndicator) {
            loadingIndicator.classList.add('d-none');
        }
        if (resultTabs && resultElement.textContent.trim() !== 'Run a diagnostic to see results...') {
            resultTabs.classList.remove('d-none');
            copyButton.disabled = false;
        }
        checksRun++;
        document.getElementById('metric-checks-run').textContent = checksRun;
    }
}

/**
 * Run a basic diagnostic endpoint
 * @param {string} endpoint - API endpoint to call
 */
async function runDiagnostic(endpoint) {
    document.getElementById('result').innerText = 'Loading...';
    
    // Reset result display
    resetResultDisplay();
    
    // Show the results section if it's not visible
    showResultsSection();
    
    // Update endpoint badge
    const endpointBadge = document.getElementById('endpoint-badge');
    if (endpointBadge) {
        endpointBadge.textContent = endpoint;
        endpointBadge.classList.remove('d-none');
    }
    
    // Update result title
    document.getElementById('result-title').textContent = 'Results: ' + endpoint.split('/').pop();
    
    const data = await fetchFromApi(endpoint);
    formatAndDisplayResults(data);
}

/**
 * Run DNS lookup
 */
async function runDnsLookup() {
    const hostname = document.getElementById('hostname').value;
    if (!hostname) {
        alert('Please enter a hostname');
        return;
    }
    
    document.getElementById('result').innerText = 'Loading...';
    showResultsSection();
    
    const data = await fetchFromApi('/api/dns', { pathParam: hostname });
    formatAndDisplayResults(data);
}

/**
 * Run reverse DNS lookup
 */
async function runReverseDnsLookup() {
    const ip = document.getElementById('ip').value;
    if (!ip) {
        alert('Please enter an IP address');
        return;
    }
    
    document.getElementById('result').innerText = 'Loading...';
    showResultsSection();
    
    const data = await fetchFromApi('/api/reversedns', { pathParam: ip });
    formatAndDisplayResults(data);
}

/**
 * Run URL fetch tool
 */
async function runUrlFetch() {
    const url = document.getElementById('url').value;
    if (!url) {
        alert('Please enter a URL');
        return;
    }
    
    document.getElementById('result').innerText = 'Loading...';
    showResultsSection();
    
    const data = await fetchFromApi('/api/curl', { url: url });
    formatAndDisplayResults(data);
}

/**
 * Calculate PI to specified digits
 */
async function calculatePi() {
    const digits = document.getElementById('digits').value;
    if (!digits || isNaN(parseInt(digits))) {
        alert('Please enter a valid number of digits');
        return;
    }
    
    document.getElementById('result').innerText = 'Calculating PI...';
    showResultsSection();
    
    const data = await fetchFromApi('/api/pi', { digits: digits });
    formatAndDisplayResults(data);
}

/**
 * Format and display results in a nicely formatted way
 * @param {Object} data - Results data from API
 */
function formatAndDisplayResults(data) {
    const resultElement = document.getElementById('result');
    resultElement.innerHTML = '';
    
    // Check if data has error property
    if (data && data.error) {
        resultElement.innerHTML = `<div class="alert alert-danger">Error: ${data.error}</div>`;
        document.getElementById('status-badge').textContent = 'Error';
        document.getElementById('status-badge').className = 'badge bg-danger';
        return;
    }
    
    // For nicely formatted JSON
    const formattedJson = JSON.stringify(data, null, 2);
    resultElement.innerHTML = `<pre class="language-json"><code>${formattedJson}</code></pre>`;
    
    // Initialize code highlighting if Prism.js is available
    if (typeof Prism !== 'undefined') {
        Prism.highlightAll();
    }
    
    // Update the enhanced result display
    updateResultAnalysis(data, lastEndpoint, lastResponseTime);
    
    // Show result tabs and execution info
    document.getElementById('resultTabs').classList.remove('d-none');
    document.getElementById('execution-info').classList.remove('d-none');
    document.getElementById('copyResultBtn').disabled = false;
}

/**
 * Make sure the results section is visible
 */
function showResultsSection() {
    const resultsSection = document.getElementById('results-section');
    if (resultsSection) {
        resultsSection.classList.remove('d-none');
        
        // Scroll to results
        resultsSection.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
}

/**
 * Retry the last request
 */
function retryLastRequest() {
    if (lastEndpoint) {
        fetchFromApi(lastEndpoint, lastParams)
            .then(data => formatAndDisplayResults(data));
    } else {
        alert('No previous request to retry');
    }
}

/**
 * Toggle dark mode
 */
function toggleDarkMode() {
    document.body.classList.toggle('dark-mode');
    const isDarkMode = document.body.classList.contains('dark-mode');
    localStorage.setItem('darkMode', isDarkMode ? 'enabled' : 'disabled');
    
    // Update button icon
    const darkModeToggle = document.getElementById('darkModeToggle');
    if (darkModeToggle) {
        if (isDarkMode) {
            darkModeToggle.innerHTML = '<i class="bi bi-sun-fill"></i>';
            darkModeToggle.setAttribute('title', 'Switch to Light Mode');
        } else {
            darkModeToggle.innerHTML = '<i class="bi bi-moon-fill"></i>';
            darkModeToggle.setAttribute('title', 'Switch to Dark Mode');
        }
    }
}

/**
 * Reset the result display to its initial state
 */
function resetResultDisplay() {
    const resultTabs = document.getElementById('resultTabs');
    const executionInfo = document.getElementById('execution-info');
    const copyButton = document.getElementById('copyResultBtn');
    
    if (resultTabs) {
        resultTabs.classList.add('d-none');
    }
    
    if (executionInfo) {
        executionInfo.classList.add('d-none');
    }
    
    if (copyButton) {
        copyButton.disabled = true;
    }
    
    // Reset formatted output
    document.getElementById('formatted-output').innerHTML = 'Select a tool to view formatted results';
    document.getElementById('result-analysis').innerHTML = '<p class="text-muted">Run a diagnostic to generate analysis</p>';
}

/**
 * Copy the result to clipboard
 */
function copyResultToClipboard() {
    const resultText = document.getElementById('result').innerText;
    
    navigator.clipboard.writeText(resultText).then(function() {
        // Show success message
        const copyBtn = document.getElementById('copyResultBtn');
        const originalHTML = copyBtn.innerHTML;
        
        copyBtn.innerHTML = '<i class="bi bi-check-lg"></i>';
        copyBtn.classList.remove('btn-outline-secondary');
        copyBtn.classList.add('btn-success');
        
        setTimeout(function() {
            copyBtn.innerHTML = originalHTML;
            copyBtn.classList.remove('btn-success');
            copyBtn.classList.add('btn-outline-secondary');
        }, 2000);
    });
}

/**
 * Update the result display with analyzed data
 * @param {Object} data - The API response data
 * @param {string} endpoint - The API endpoint that was called
 * @param {number} responseTime - The API response time in milliseconds
 */
function updateResultAnalysis(data, endpoint, responseTime) {
    const resultAnalysis = document.getElementById('result-analysis');
    const executionInfo = document.getElementById('execution-info');
    const executionTime = document.getElementById('execution-time');
    const statusBadge = document.getElementById('status-badge');
    
    if (!resultAnalysis || !data) return;
    
    // Update execution time and status
    executionTime.textContent = responseTime;
    executionInfo.classList.remove('d-none');
    
    // Format the data based on endpoint
    let analysisHTML = '';
    let isSuccess = true;
    
    try {
        // Try to determine if the request was successful
        if (typeof data === 'object') {
            if (data.error || data.status === 'error') {
                isSuccess = false;
                statusBadge.textContent = 'Error';
                statusBadge.className = 'badge bg-danger';
            } else {
                statusBadge.textContent = 'Success';
                statusBadge.className = 'badge bg-success';
            }
        }
        
        // Generate endpoint-specific analysis
        if (endpoint.includes('healthcheck')) {
            analysisHTML = generateHealthAnalysis(data);
        } else if (endpoint.includes('ip')) {
            analysisHTML = generateIpAnalysis(data);
        } else if (endpoint.includes('sql')) {
            analysisHTML = generateSqlAnalysis(data, endpoint);
        } else if (endpoint.includes('dns')) {
            analysisHTML = generateDnsAnalysis(data);
        } else if (endpoint.includes('url')) {
            analysisHTML = generateUrlAnalysis(data);
        } else if (endpoint.includes('printenv')) {
            analysisHTML = generateEnvAnalysis(data);
        } else if (endpoint.includes('pi')) {
            analysisHTML = generatePiAnalysis(data);
        } else {
            analysisHTML = '<div class="alert alert-info">Analysis not available for this endpoint.</div>';
        }
        
        // Update the formatted output
        updateFormattedOutput(data);
    } catch (error) {
        analysisHTML = `<div class="alert alert-warning">Error analyzing results: ${error.message}</div>`;
    }
    
    resultAnalysis.innerHTML = analysisHTML;
}

/**
 * Generate analysis for health check endpoint
 * @param {Object} data - Health check response data
 * @returns {string} HTML analysis content
 */
function generateHealthAnalysis(data) {
    let html = '<div class="mb-3">';
    
    if (data.status === 'OK') {
        html += '<div class="alert alert-success"><i class="bi bi-check-circle me-2"></i> API service is healthy and responding properly.</div>';
    } else {
        html += '<div class="alert alert-danger"><i class="bi bi-exclamation-triangle me-2"></i> API service is experiencing issues.</div>';
    }
    
    html += '<h6 class="mt-3">Service Details</h6>';
    html += '<ul class="list-group">';
    
    if (data.version) {
        html += `<li class="list-group-item d-flex justify-content-between align-items-center">
            <span>API Version</span>
            <span class="badge bg-primary rounded-pill">${data.version}</span>
        </li>`;
    }
    
    if (data.hostname) {
        html += `<li class="list-group-item d-flex justify-content-between align-items-center">
            <span>Hostname</span>
            <span class="badge bg-secondary rounded-pill">${data.hostname}</span>
        </li>`;
    }
    
    html += '</ul>';
    html += '</div>';
    
    return html;
}

/**
 * Generate analysis for IP information endpoint
 * @param {Object} data - IP info response data
 * @returns {string} HTML analysis content
 */
function generateIpAnalysis(data) {
    let html = '<div class="mb-3">';
    
    if (data.ipv4 || data.ipv6) {
        html += '<div class="alert alert-success"><i class="bi bi-check-circle me-2"></i> Successfully retrieved IP information.</div>';
        
        html += '<h6 class="mt-3">Network Details</h6>';
        html += '<ul class="list-group">';
        
        if (data.hostname) {
            html += `<li class="list-group-item d-flex justify-content-between align-items-center">
                <span>Hostname</span>
                <span>${data.hostname}</span>
            </li>`;
        }
        
        if (data.ipv4) {
            html += `<li class="list-group-item d-flex justify-content-between align-items-center">
                <span>IPv4 Address</span>
                <span class="badge bg-primary rounded-pill">${data.ipv4}</span>
            </li>`;
        }
        
        if (data.ipv6) {
            html += `<li class="list-group-item d-flex justify-content-between align-items-center">
                <span>IPv6 Address</span>
                <span class="badge bg-secondary">${data.ipv6}</span>
            </li>`;
        }
        
        html += '</ul>';
    } else {
        html += '<div class="alert alert-warning"><i class="bi bi-exclamation-triangle me-2"></i> Unable to retrieve complete IP information.</div>';
    }
    
    html += '</div>';
    return html;
}

/**
 * Generate analysis for SQL-related endpoints
 * @param {Object} data - SQL response data
 * @param {string} endpoint - The specific SQL endpoint
 * @returns {string} HTML analysis content
 */
function generateSqlAnalysis(data, endpoint) {
    let html = '<div class="mb-3">';
    
    if (endpoint.includes('sqlversion')) {
        if (data.version) {
            html += '<div class="alert alert-success"><i class="bi bi-check-circle me-2"></i> Successfully connected to the database.</div>';
            
            html += '<h6 class="mt-3">Database Details</h6>';
            html += '<ul class="list-group">';
            html += `<li class="list-group-item d-flex justify-content-between align-items-center">
                <span>SQL Version</span>
                <span>${data.version}</span>
            </li>`;
            
            if (data.edition) {
                html += `<li class="list-group-item d-flex justify-content-between align-items-center">
                    <span>Edition</span>
                    <span>${data.edition}</span>
                </li>`;
            }
            
            html += '</ul>';
            
            html += '<div class="alert alert-warning mt-3"><i class="bi bi-shield-exclamation me-2"></i> Exposing database version information might help attackers identify known vulnerabilities.</div>';
        } else {
            html += '<div class="alert alert-danger"><i class="bi bi-exclamation-triangle me-2"></i> Unable to retrieve database version information.</div>';
        }
    } else if (endpoint.includes('sqlsrcip')) {
        if (data.client_ip) {
            html += '<div class="alert alert-success"><i class="bi bi-check-circle me-2"></i> Successfully retrieved client IP information.</div>';
            
            html += '<h6 class="mt-3">Connection Details</h6>';
            html += '<ul class="list-group">';
            html += `<li class="list-group-item d-flex justify-content-between align-items-center">
                <span>Client IP</span>
                <span class="badge bg-primary rounded-pill">${data.client_ip}</span>
            </li>`;
            html += '</ul>';
        } else {
            html += '<div class="alert alert-danger"><i class="bi bi-exclamation-triangle me-2"></i> Unable to retrieve client IP information.</div>';
        }
    }
    
    html += '</div>';
    return html;
}

/**
 * Generate placeholder analysis functions for other endpoints
 * These would be implemented with actual logic based on returned data formats
 */
function generateDnsAnalysis(data) {
    // Placeholder - would implement actual analysis based on DNS response format
    return '<div class="alert alert-info">DNS lookup completed. Review the raw results for details.</div>';
}

function generateUrlAnalysis(data) {
    // Placeholder - would implement actual analysis based on URL fetch response format
    return '<div class="alert alert-info">URL fetch completed. Review the raw results for details.</div>';
}

function generateEnvAnalysis(data) {
    return `<div class="alert alert-danger"><i class="bi bi-shield-exclamation me-2"></i> <strong>Security Warning:</strong> Environment variables may contain sensitive information like API keys, credentials, and configuration settings.</div>
            <div class="mt-3">Found approximately ${Object.keys(data).length} environment variables.</div>`;
}

function generatePiAnalysis(data) {
    // Placeholder - would implement actual analysis for PI calculation
    return '<div class="alert alert-info">PI calculation completed. Review the raw results to see the calculated digits.</div>';
}
