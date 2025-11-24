<?php
// Configuration
$apiUrl = getenv('API_URL') ?: 'http://localhost:8000';
$apiKey = getenv('API_KEY') ?: 'insecure_api_key_12345';
$version = "1.0.0";
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SAIF - Secure AI Foundations</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/themes/prism.min.css" rel="stylesheet">
    <link href="assets/css/custom.css" rel="stylesheet">
    <link rel="icon" href="assets/img/saif-logo.svg">
</head>
<body>    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container">
            <!-- Left-aligned toggle button for mobile -->
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <!-- Logo in the center -->
            <div class="navbar-brand-wrapper">
                <a class="navbar-brand" href="#">
                    <div class="d-flex align-items-center justify-content-center">
                        <img src="assets/img/saif-logo.svg" alt="SAIF Logo" class="logo">
                        <span class="brand-text">SAIF</span>
                    </div>
                </a>
            </div>
            
            <!-- Navigation items -->
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link active" href="#">Diagnostics</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#">Documentation</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#">About</a>
                    </li>
                </ul>
                
                <!-- Right-aligned items -->
                <div class="ms-auto d-flex align-items-center">
                    <span class="badge bg-danger me-2 d-flex align-items-center">
                        <i class="bi bi-shield-exclamation me-1"></i> Vulnerable App
                    </span>
                    <button id="darkModeToggle" class="btn btn-outline-light btn-sm ms-2" onclick="toggleDarkMode()" title="Toggle Dark Mode">
                        <i class="bi bi-moon-fill"></i>
                    </button>
                </div>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero-section">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-7">
                    <h1 class="display-4">Secure AI Foundations</h1>
                    <p class="lead">Diagnostic Testing Interface for security analysis and API testing.</p>
                    <p>Use these tools to test various API endpoints and identify potential security vulnerabilities.</p>
                    <div class="mt-4">
                        <span class="badge rounded-pill bg-light text-dark me-2">Version <?php echo htmlspecialchars($version); ?></span>
                        <span class="badge rounded-pill bg-light text-dark me-2">API Available</span>
                        <span class="badge rounded-pill bg-light text-dark me-2">Training Mode</span>                    </div>                    
                    <div class="security-warning mt-4">
                        <i class="bi bi-exclamation-triangle-fill text-warning me-2" style="font-size: 1.2rem;"></i> 
                        <strong class="text-dark">Security Notice:</strong> This application contains intentional vulnerabilities for educational purposes.
                    </div>
                </div>
                <div class="col-lg-5">
                    <img src="assets/img/dashboard-illustration.svg" alt="Dashboard Illustration" class="img-fluid hero-image">
                </div>
            </div>
        </div>    </section>

    <!-- Dashboard Metrics Section -->
    <section class="metrics-dashboard py-4">
        <div class="container">
            <div class="row g-4">
                <div class="col-md-3">
                    <div class="metric-card">
                        <div class="metric-icon">
                            <i class="bi bi-activity"></i>
                        </div>
                        <div class="metric-data">
                            <h3 id="metric-api-status">Online</h3>
                            <p>API Status</p>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-3">
                    <div class="metric-card">
                        <div class="metric-icon">
                            <i class="bi bi-hdd-network"></i>
                        </div>
                        <div class="metric-data">
                            <h3 id="metric-latency">--</h3>
                            <p>API Latency</p>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-3">
                    <div class="metric-card">
                        <div class="metric-icon">
                            <i class="bi bi-database-check"></i>
                        </div>
                        <div class="metric-data">
                            <h3 id="metric-db-status">--</h3>
                            <p>DB Status</p>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-3">
                    <div class="metric-card">
                        <div class="metric-icon">
                            <i class="bi bi-shield-check"></i>
                        </div>
                        <div class="metric-data">
                            <h3 id="metric-checks-run">0</h3>
                            <p>Checks Run</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <div class="container mt-4">        <!-- Tool Categories Navigation -->
        <ul class="nav nav-pills mb-4" id="toolsTab" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="all-tab" data-bs-toggle="pill" data-bs-target="#all-tools" type="button">
                    <i class="bi bi-grid-3x3-gap me-1"></i> All Tools
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="basic-tab" data-bs-toggle="pill" data-bs-target="#basic-tools" type="button">
                    <i class="bi bi-cpu me-1"></i> Basic Diagnostics
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="network-tab" data-bs-toggle="pill" data-bs-target="#network-tools" type="button">
                    <i class="bi bi-globe me-1"></i> Network Tools
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="database-tab" data-bs-toggle="pill" data-bs-target="#database-tools" type="button">
                    <i class="bi bi-database me-1"></i> Database
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="advanced-tab" data-bs-toggle="pill" data-bs-target="#advanced-tools" type="button">
                    <i class="bi bi-gear me-1"></i> Advanced
                </button>
            </li>
        </ul>
        
        <!-- Tool Categories Content -->
        <div class="tab-content" id="toolsTabContent">
            <!-- All Tools Tab -->
            <div class="tab-pane fade show active" id="all-tools" role="tabpanel">
                <div class="row">
                    <!-- Basic Tools -->
                    <div class="col-md-4 col-lg-3 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-health.svg" alt="Health Check" width="24" height="24" class="me-2">
                                Health Check
                            </div>
                            <div class="card-body d-flex flex-column">
                                <p class="card-text text-muted small">Check the API service health status and response time.</p>
                                <div class="mt-auto">
                                    <button class="btn btn-primary w-100" onclick="runDiagnostic('/api/healthcheck')">
                                        <i class="bi bi-activity me-1"></i> Run Health Check
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4 col-lg-3 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-ip.svg" alt="IP Info" width="24" height="24" class="me-2">
                                IP Information
                            </div>
                            <div class="card-body d-flex flex-column">
                                <p class="card-text text-muted small">Get information about the server's IP addresses and hostname.</p>
                                <div class="mt-auto">
                                    <button class="btn btn-primary w-100" onclick="runDiagnostic('/api/ip')">
                                        <i class="bi bi-hdd-network me-1"></i> Get IP Info
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- SQL Tools -->
                    <div class="col-md-4 col-lg-3 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-sql.svg" alt="SQL Info" width="24" height="24" class="me-2">
                                SQL Information
                            </div>
                            <div class="card-body d-flex flex-column">
                                <p class="card-text text-muted small">Check database version and connection information.</p>
                                <div class="mt-auto d-grid gap-2">
                                    <button class="btn btn-primary" onclick="runDiagnostic('/api/sqlversion')">
                                        <i class="bi bi-database-check me-1"></i> SQL Version
                                    </button>
                                    <button class="btn btn-outline-primary" onclick="runDiagnostic('/api/sqlsrcip')">
                                        <i class="bi bi-shuffle me-1"></i> SQL Source IP
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- DNS Tools -->
                    <div class="col-md-4 col-lg-3 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-dns.svg" alt="DNS Tools" width="24" height="24" class="me-2">
                                DNS Tools
                            </div>
                            <div class="card-body d-flex flex-column">
                                <div class="mb-3">
                                    <label for="hostname" class="form-label">Hostname</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-globe2"></i></span>
                                        <input type="text" class="form-control" id="hostname" value="example.com" placeholder="e.g., example.com">
                                    </div>
                                </div>
                                <div class="mt-auto">
                                    <button class="btn btn-primary w-100" onclick="runDnsLookup()">
                                        <i class="bi bi-search me-1"></i> DNS Lookup
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Reverse DNS -->
                    <div class="col-md-4 col-lg-3 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-dns.svg" alt="Reverse DNS" width="24" height="24" class="me-2">
                                Reverse DNS
                            </div>
                            <div class="card-body d-flex flex-column">
                                <div class="mb-3">
                                    <label for="ip" class="form-label">IP Address</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-diagram-3"></i></span>
                                        <input type="text" class="form-control" id="ip" value="8.8.8.8" placeholder="e.g., 8.8.8.8">
                                    </div>
                                </div>
                                <div class="mt-auto">
                                    <button class="btn btn-primary w-100" onclick="runReverseDnsLookup()">
                                        <i class="bi bi-arrow-left-right me-1"></i> Reverse DNS
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- URL Fetch -->
                    <div class="col-md-4 col-lg-3 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-url.svg" alt="URL Fetch" width="24" height="24" class="me-2">
                                URL Fetch
                                <span class="badge badge-security ms-auto" data-bs-toggle="tooltip" title="Contains security vulnerabilities">Vulnerable</span>
                            </div>
                            <div class="card-body d-flex flex-column">
                                <div class="mb-3">
                                    <label for="url" class="form-label">URL</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-link-45deg"></i></span>
                                        <input type="text" class="form-control" id="url" value="https://example.com" placeholder="e.g., https://example.com">
                                    </div>
                                </div>
                                <div class="mt-auto">
                                    <button class="btn btn-primary w-100" onclick="runUrlFetch()">
                                        <i class="bi bi-cloud-download me-1"></i> Fetch URL
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Environment Variables -->
                    <div class="col-md-4 col-lg-3 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-env.svg" alt="Environment Variables" width="24" height="24" class="me-2">
                                Environment Variables
                                <span class="badge badge-security ms-auto" data-bs-toggle="tooltip" title="Contains security vulnerabilities">Vulnerable</span>
                            </div>
                            <div class="card-body d-flex flex-column">
                                <p class="card-text text-muted small">Display all environment variables from the API server.</p>
                                <p class="card-text text-danger small"><i class="bi bi-exclamation-triangle"></i> Warning: May expose sensitive data</p>
                                <div class="mt-auto">
                                    <button class="btn btn-primary w-100" onclick="runDiagnostic('/api/printenv')">
                                        <i class="bi bi-list-check me-1"></i> Show Environment
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- PI Calculator -->
                    <div class="col-md-4 col-lg-3 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-pi.svg" alt="PI Calculator" width="24" height="24" class="me-2">
                                PI Calculator
                            </div>
                            <div class="card-body d-flex flex-column">
                                <div class="mb-3">
                                    <label for="digits" class="form-label">Digits</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-123"></i></span>
                                        <input type="number" class="form-control" id="digits" value="1000" min="1" max="100000">
                                    </div>
                                    <div class="form-text">Max: 100,000 digits</div>
                                </div>
                                <div class="mt-auto">
                                    <button class="btn btn-primary w-100" onclick="calculatePi()">
                                        <i class="bi bi-calculator me-1"></i> Calculate PI
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Basic Diagnostics Tab -->
            <div class="tab-pane fade" id="basic-tools" role="tabpanel">
                <div class="row">
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-health.svg" alt="Health Check" width="24" height="24" class="me-2">
                                Health Check
                            </div>
                            <div class="card-body d-flex flex-column">
                                <p class="card-text text-muted small">Check the API service health status and response time.</p>
                                <div class="mt-auto">
                                    <button class="btn btn-primary w-100" onclick="runDiagnostic('/api/healthcheck')">
                                        <i class="bi bi-activity me-1"></i> Run Health Check
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-ip.svg" alt="IP Info" width="24" height="24" class="me-2">
                                IP Information
                            </div>
                            <div class="card-body d-flex flex-column">
                                <p class="card-text text-muted small">Get information about the server's IP addresses and hostname.</p>
                                <div class="mt-auto">
                                    <button class="btn btn-primary w-100" onclick="runDiagnostic('/api/ip')">
                                        <i class="bi bi-hdd-network me-1"></i> Get IP Info
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Network Tools Tab -->
            <div class="tab-pane fade" id="network-tools" role="tabpanel">
                <div class="row">
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-dns.svg" alt="DNS Tools" width="24" height="24" class="me-2">
                                DNS Tools
                            </div>
                            <div class="card-body d-flex flex-column">
                                <div class="mb-3">
                                    <label for="hostname-network" class="form-label">Hostname</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-globe2"></i></span>
                                        <input type="text" class="form-control" id="hostname-network" value="example.com" placeholder="e.g., example.com">
                                    </div>
                                </div>
                                <div class="mt-auto">
                                    <button class="btn btn-primary w-100" onclick="runDnsLookup('hostname-network')">
                                        <i class="bi bi-search me-1"></i> DNS Lookup
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-dns.svg" alt="Reverse DNS" width="24" height="24" class="me-2">
                                Reverse DNS
                            </div>
                            <div class="card-body d-flex flex-column">
                                <div class="mb-3">
                                    <label for="ip-network" class="form-label">IP Address</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-diagram-3"></i></span>
                                        <input type="text" class="form-control" id="ip-network" value="8.8.8.8" placeholder="e.g., 8.8.8.8">
                                    </div>
                                </div>
                                <div class="mt-auto">
                                    <button class="btn btn-primary w-100" onclick="runReverseDnsLookup('ip-network')">
                                        <i class="bi bi-arrow-left-right me-1"></i> Reverse DNS
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-url.svg" alt="URL Fetch" width="24" height="24" class="me-2">
                                URL Fetch
                                <span class="badge badge-security ms-auto" data-bs-toggle="tooltip" title="Contains security vulnerabilities">Vulnerable</span>
                            </div>
                            <div class="card-body d-flex flex-column">
                                <div class="mb-3">
                                    <label for="url-network" class="form-label">URL</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-link-45deg"></i></span>
                                        <input type="text" class="form-control" id="url-network" value="https://example.com" placeholder="e.g., https://example.com">
                                    </div>
                                </div>
                                <div class="mt-auto">
                                    <button class="btn btn-primary w-100" onclick="runUrlFetch('url-network')">
                                        <i class="bi bi-cloud-download me-1"></i> Fetch URL
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Database Tab -->
            <div class="tab-pane fade" id="database-tools" role="tabpanel">
                <div class="row">
                    <div class="col-md-6 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-sql.svg" alt="SQL Info" width="24" height="24" class="me-2">
                                SQL Information
                            </div>
                            <div class="card-body d-flex flex-column">
                                <p class="card-text text-muted small">Check database version and connection information.</p>
                                <div class="mt-auto d-grid gap-2">
                                    <button class="btn btn-primary" onclick="runDiagnostic('/api/sqlversion')">
                                        <i class="bi bi-database-check me-1"></i> SQL Version
                                    </button>
                                    <button class="btn btn-outline-primary" onclick="runDiagnostic('/api/sqlsrcip')">
                                        <i class="bi bi-shuffle me-1"></i> SQL Source IP
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Advanced Tab -->
            <div class="tab-pane fade" id="advanced-tools" role="tabpanel">
                <div class="row">
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-env.svg" alt="Environment Variables" width="24" height="24" class="me-2">
                                Environment Variables
                                <span class="badge badge-security ms-auto" data-bs-toggle="tooltip" title="Contains security vulnerabilities">Vulnerable</span>
                            </div>
                            <div class="card-body d-flex flex-column">
                                <p class="card-text text-muted small">Display all environment variables from the API server.</p>
                                <p class="card-text text-danger small"><i class="bi bi-exclamation-triangle"></i> Warning: May expose sensitive data</p>
                                <div class="mt-auto">
                                    <button class="btn btn-primary w-100" onclick="runDiagnostic('/api/printenv')">
                                        <i class="bi bi-list-check me-1"></i> Show Environment
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card diagnostic-card h-100">
                            <div class="card-header d-flex align-items-center">
                                <img src="assets/img/icon-pi.svg" alt="PI Calculator" width="24" height="24" class="me-2">
                                PI Calculator
                            </div>
                            <div class="card-body d-flex flex-column">
                                <div class="mb-3">
                                    <label for="digits-advanced" class="form-label">Digits</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-123"></i></span>
                                        <input type="number" class="form-control" id="digits-advanced" value="1000" min="1" max="100000">
                                    </div>
                                    <div class="form-text">Max: 100,000 digits</div>
                                </div>
                                <div class="mt-auto">
                                    <button class="btn btn-primary w-100" onclick="calculatePi('digits-advanced')">
                                        <i class="bi bi-calculator me-1"></i> Calculate PI
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Results Section -->        <div class="row mt-4" id="results-section">
            <div class="col-12">
                <div class="card results-card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">
                            <i class="bi bi-terminal me-2"></i>
                            <span id="result-title">Results</span>
                            <span class="badge bg-secondary ms-2 api-endpoint-badge d-none" id="endpoint-badge"></span>
                        </h5>
                        <div>
                            <button class="btn btn-sm btn-outline-secondary me-2" id="copyResultBtn" onclick="copyResultToClipboard()" title="Copy to Clipboard" disabled>
                                <i class="bi bi-clipboard"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-secondary" onclick="retryLastRequest()" title="Retry Last Request">
                                <i class="bi bi-arrow-repeat"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body result-container position-relative">
                        <!-- Result Tabs -->
                        <ul class="nav nav-tabs mb-3 result-tabs d-none" id="resultTabs">
                            <li class="nav-item">
                                <button class="nav-link active" id="raw-tab" data-bs-toggle="pill" data-bs-target="#raw-result" type="button">Raw Output</button>
                            </li>
                            <li class="nav-item">
                                <button class="nav-link" id="formatted-tab" data-bs-toggle="pill" data-bs-target="#formatted-result" type="button">Formatted</button>
                            </li>
                            <li class="nav-item">
                                <button class="nav-link" id="analysis-tab" data-bs-toggle="pill" data-bs-target="#analysis-result" type="button">Analysis</button>
                            </li>
                        </ul>
                        
                        <div class="tab-content">
                            <div class="tab-pane fade show active" id="raw-result">
                                <div id="loading-indicator" class="d-none text-center py-5">
                                    <div class="loading-spinner mb-3"></div>
                                    <p>Processing request...</p>
                                </div>
                                <pre id="result" class="mb-0">Run a diagnostic to see results...</pre>
                            </div>
                            <div class="tab-pane fade" id="formatted-result">
                                <div id="formatted-output" class="formatted-json">Select a tool to view formatted results</div>
                            </div>
                            <div class="tab-pane fade" id="analysis-result">
                                <div id="result-analysis" class="analysis-panel p-3">
                                    <p class="text-muted">Run a diagnostic to generate analysis</p>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Execution Time & Status -->
                        <div class="text-end mt-3 execution-info d-none" id="execution-info">
                            <small class="text-muted">
                                Execution time: <span id="execution-time">0</span>ms | 
                                Status: <span id="status-badge" class="badge bg-success">Success</span>
                            </small>
                        </div>
                    </div>
                </div>
            </div>
        </div><!-- Features Section -->
        <section class="features-section mt-5 mb-5">
            <div class="container">
                <div class="row">
                    <div class="col-12 text-center mb-4">
                        <div class="section-title-container">
                            <h2 class="section-title">About SAIF</h2>
                            <div class="section-divider"></div>
                            <p class="lead">A security training platform to help identify and mitigate common vulnerabilities.</p>
                        </div>
                    </div>
                </div>
                
                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="feature-card">
                            <div class="feature-icon-wrapper">
                                <div class="feature-icon-bg">
                                    <i class="bi bi-shield-lock"></i>
                                </div>
                            </div>
                            <h5>Security Challenges</h5>
                            <p>Explore and identify intentional vulnerabilities embedded in this application.</p>
                            <ul class="feature-list">
                                <li><i class="bi bi-check-circle-fill"></i> SQL Injection</li>
                                <li><i class="bi bi-check-circle-fill"></i> Server-Side Request Forgery</li>
                                <li><i class="bi bi-check-circle-fill"></i> Information Disclosure</li>
                            </ul>
                        </div>
                    </div>
                    
                    <div class="col-md-4">
                        <div class="feature-card">
                            <div class="feature-icon-wrapper">
                                <div class="feature-icon-bg">
                                    <i class="bi bi-layers"></i>
                                </div>
                            </div>
                            <h5>Three-Tier Architecture</h5>
                            <p>Demonstrates frontend, API, and database components and their security considerations.</p>
                            <ul class="feature-list">
                                <li><i class="bi bi-check-circle-fill"></i> PHP Web Frontend</li>
                                <li><i class="bi bi-check-circle-fill"></i> Python FastAPI Backend</li>
                                <li><i class="bi bi-check-circle-fill"></i> SQL Server Database</li>
                            </ul>
                        </div>
                    </div>
                    
                    <div class="col-md-4">
                        <div class="feature-card">
                            <div class="feature-icon-wrapper">
                                <div class="feature-icon-bg">
                                    <i class="bi bi-cloud"></i>
                                </div>
                            </div>
                            <h5>Cloud Deployment</h5>
                            <p>Configured for deployment to Azure App Services using secure infrastructure as code.</p>
                            <ul class="feature-list">
                                <li><i class="bi bi-check-circle-fill"></i> Azure Infrastructure as Code</li>
                                <li><i class="bi bi-check-circle-fill"></i> Containerized Services</li>
                                <li><i class="bi bi-check-circle-fill"></i> CI/CD Ready</li>
                            </ul>
                        </div>
                    </div>
                </div>
                
                <div class="row mt-5">
                    <div class="col-12 text-center">
                        <div class="cta-card">
                            <div class="cta-content">
                                <h4>Ready to Learn More?</h4>
                                <p>Explore the documentation to learn how to secure similar applications.</p>
                                <a href="#" class="btn btn-primary">View Documentation</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        
        <!-- Footer -->
        <footer class="footer mt-auto py-4">
            <div class="container">
                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="footer-branding">
                            <a href="#" class="footer-logo d-flex align-items-center text-decoration-none">
                                <img src="assets/img/saif-logo.svg" alt="SAIF Logo" width="36" height="36" class="me-2">
                                <span class="h5 mb-0">SAIF</span>
                            </a>
                            <p class="mt-3 text-muted">Secure AI Foundations is an educational platform for security testing and vulnerability identification.</p>
                            <p class="version-badge">
                                <span class="badge rounded-pill bg-light text-dark">Version <?php echo htmlspecialchars($version); ?></span>
                            </p>
                        </div>
                    </div>
                    
                    <div class="col-md-3">
                        <h6 class="footer-heading">Tools</h6>
                        <ul class="footer-links list-unstyled">
                            <li><a href="#" data-bs-toggle="pill" data-bs-target="#basic-tools" class="footer-link">Basic Diagnostics</a></li>
                            <li><a href="#" data-bs-toggle="pill" data-bs-target="#network-tools" class="footer-link">Network Tools</a></li>
                            <li><a href="#" data-bs-toggle="pill" data-bs-target="#database-tools" class="footer-link">Database Tools</a></li>
                            <li><a href="#" data-bs-toggle="pill" data-bs-target="#advanced-tools" class="footer-link">Advanced Tools</a></li>
                        </ul>
                    </div>
                    
                    <div class="col-md-3">
                        <h6 class="footer-heading">Resources</h6>
                        <ul class="footer-links list-unstyled">
                            <li><a href="https://learn.microsoft.com" class="footer-link">Documentation</a></li>
                            <li><a href="https://learn.microsoft.com/en-us/azure/security/fundamentals/best-practices-and-patterns" class="footer-link">Security Guide</a></li>
                            <li><a href="https://github.com/jonathan-vella/SAIF/tree/main/api" class="footer-link">API Reference</a></li>
                            <li><a href="https://github.com/jonathan-vella/SAIF" class="footer-link">GitHub Repository</a></li>
                        </ul>
                    </div>
                    
                    <div class="col-md-2">
                        <h6 class="footer-heading">Connect</h6>
                        <div class="social-links">
                            <a href="https://github.com/jonathan-vella" class="social-link" title="GitHub"><i class="bi bi-github"></i></a>
                            <a href="#" class="social-link" title="Twitter"><i class="bi bi-twitter-x"></i></a>
                            <a href="https://www.linkedin.com/in/jonathanvella/" class="social-link" title="LinkedIn"><i class="bi bi-linkedin"></i></a>
                        </div>
                    </div>
                </div>
                
                <div class="footer-divider mt-4"></div>
                
                <div class="row mt-3">
                    <div class="col-md-6">
                        <p class="mb-0 copyright">&copy; 2025 SAIF Project - For educational purposes only</p>
                    </div>
                    <div class="col-md-6 text-md-end">
                        <p class="mb-0 footer-legal">
                            <a href="#" class="footer-link-sm">Privacy Policy</a> |
                            <a href="#" class="footer-link-sm">Terms of Use</a> |
                            <a href="#" class="footer-link-sm">Security</a>
                        </p>
                    </div>
                </div>
            </div>
        </footer>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/prism.min.js"></script>
    <script src="assets/js/custom.js"></script>
    
    <script>
        // Check if there are duplicate input element IDs and fix them
        document.addEventListener('DOMContentLoaded', function() {
            // Initialize tooltips
            const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
            const tooltips = [...tooltipTriggerList].map(el => new bootstrap.Tooltip(el));
            
            // Set up network tab DNS lookup
            document.getElementById('hostname-network').addEventListener('input', function() {
                document.getElementById('hostname').value = this.value;
            });
            document.getElementById('hostname').addEventListener('input', function() {
                document.getElementById('hostname-network').value = this.value;
            });
            
            // Set up network tab reverse DNS lookup
            document.getElementById('ip-network').addEventListener('input', function() {
                document.getElementById('ip').value = this.value;
            });
            document.getElementById('ip').addEventListener('input', function() {
                document.getElementById('ip-network').value = this.value;
            });
            
            // Set up network tab URL fetch
            document.getElementById('url-network').addEventListener('input', function() {
                document.getElementById('url').value = this.value;
            });
            document.getElementById('url').addEventListener('input', function() {
                document.getElementById('url-network').value = this.value;
            });
            
            // Set up advanced tab PI calculator
            document.getElementById('digits-advanced').addEventListener('input', function() {
                document.getElementById('digits').value = this.value;
            });
            document.getElementById('digits').addEventListener('input', function() {
                document.getElementById('digits-advanced').value = this.value;
            });
        });
        
        // Extended versions of functions to handle alternate IDs
        function runDnsLookup(altId = null) {
            const hostnameInput = altId ? document.getElementById(altId) : document.getElementById('hostname');
            const hostname = hostnameInput.value;
            
            if (!hostname) {
                alert('Please enter a hostname');
                return;
            }
            
            document.getElementById('result').innerText = 'Loading...';
            showResultsSection();
            
            fetchFromApi('/api/dns', { pathParam: hostname })
                .then(data => formatAndDisplayResults(data));
        }
        
        function runReverseDnsLookup(altId = null) {
            const ipInput = altId ? document.getElementById(altId) : document.getElementById('ip');
            const ip = ipInput.value;
            
            if (!ip) {
                alert('Please enter an IP address');
                return;
            }
            
            document.getElementById('result').innerText = 'Loading...';
            showResultsSection();
            
            fetchFromApi('/api/reversedns', { pathParam: ip })
                .then(data => formatAndDisplayResults(data));
        }
        
        function runUrlFetch(altId = null) {
            const urlInput = altId ? document.getElementById(altId) : document.getElementById('url');
            const url = urlInput.value;
            
            if (!url) {
                alert('Please enter a URL');
                return;
            }
            
            document.getElementById('result').innerText = 'Loading...';
            showResultsSection();
            
            fetchFromApi('/api/curl', { url: url })
                .then(data => formatAndDisplayResults(data));
        }
        
        function calculatePi(altId = null) {
            const digitsInput = altId ? document.getElementById(altId) : document.getElementById('digits');
            const digits = digitsInput.value;
            
            if (!digits || isNaN(parseInt(digits))) {
                alert('Please enter a valid number of digits');
                return;
            }
            
            document.getElementById('result').innerText = 'Calculating PI...';
            showResultsSection();
            
            fetchFromApi('/api/pi', { digits: digits })
                .then(data => formatAndDisplayResults(data));
        }
        
        async function fetchFromApi(endpoint, params = {}){
            // Create the URL using our api-proxy.php script
            const url = new URL('/api-proxy.php', window.location.origin);
            
            // Get endpoint name without the /api/ prefix
            const endpointName = endpoint.startsWith('/api/') ? 
                endpoint.substring(5) : endpoint;
            
            // Set the endpoint parameter
            url.searchParams.append('endpoint', endpointName);
            
            // Add additional query parameters if any
            Object.keys(params).forEach(key => {
                url.searchParams.append(key, params[key]);
            });

            try {
                const response = await fetch(url);
                
                if (!response.ok) {
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                
                const data = await response.json();
                return data;
            } catch (error) {
                return { error: error.message };
            }
        }

        async function runDiagnostic(endpoint) {
            document.getElementById('result').innerText = 'Loading...';
            
            const data = await fetchFromApi(endpoint);
            document.getElementById('result').innerText = JSON.stringify(data, null, 2);
        }        async function runDnsLookup() {
            const hostname = document.getElementById('hostname').value;
            document.getElementById('result').innerText = 'Loading...';
            
            const data = await fetchFromApi('/api/dns', { pathParam: hostname });
            document.getElementById('result').innerText = JSON.stringify(data, null, 2);
        }
        
        async function runReverseDnsLookup() {
            const ip = document.getElementById('ip').value;
            document.getElementById('result').innerText = 'Loading...';
            
            const data = await fetchFromApi('/api/reversedns', { pathParam: ip });
            document.getElementById('result').innerText = JSON.stringify(data, null, 2);
        }
        
        async function runUrlFetch() {
            const url = document.getElementById('url').value;
            document.getElementById('result').innerText = 'Loading...';
            
            const data = await fetchFromApi('/api/curl', { url: url });
            document.getElementById('result').innerText = JSON.stringify(data, null, 2);
        }
        
        async function calculatePi() {
            const digits = document.getElementById('digits').value;
            document.getElementById('result').innerText = 'Calculating PI...';
            
            const data = await fetchFromApi('/api/pi', { digits: digits });
            document.getElementById('result').innerText = JSON.stringify(data, null, 2);
        }
    </script>
</body>
</html>
