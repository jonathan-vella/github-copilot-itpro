<#
.SYNOPSIS
    Sets up and tests SAIF (Secure AI Foundations) locally using Docker.
.DESCRIPTION
    This script builds and runs Docker containers for local testing of the SAIF application.
    It creates necessary SQL initialization scripts and helps with local development.
.EXAMPLE
    .\Test-SAIFLocal.ps1
.NOTES
    Author: SAIF Team
    Version: 1.0.0
    Date: 2025-06-18
    Requirements: Docker Desktop must be installed and running.
#>

[CmdletBinding()]
param()

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "SAIF: Secure AI Foundations"
Write-Host "Local Testing Environment"
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script sets up the local development environment for SAIF."
Write-Host ""
Write-Host "Steps:" -ForegroundColor Yellow
Write-Host "1. Checking prerequisites"
Write-Host "2. Building Docker containers"
Write-Host "3. Creating and initializing the database"
Write-Host "4. Starting the application"
Write-Host ""

# Check for Docker
try {
    Write-Host "Checking Docker installation..." -ForegroundColor Cyan
    docker --version | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker command failed"
    }
}
catch {
    Write-Host "Docker is not installed or not running. Please install Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

# Create SQL initialization script
Write-Host "Creating SQL initialization script..." -ForegroundColor Cyan
$sqlScript = @"
CREATE DATABASE saif;
GO

USE saif;
GO

CREATE TABLE diagnostics (
    id INT IDENTITY(1,1) PRIMARY KEY,
    endpoint VARCHAR(100) NOT NULL,
    request_time DATETIME NOT NULL DEFAULT GETDATE(),
    client_ip VARCHAR(50) NOT NULL,
    response_status INT NOT NULL,
    execution_time_ms INT NOT NULL
);
GO

CREATE TABLE security_events (
    id INT IDENTITY(1,1) PRIMARY KEY,
    event_time DATETIME NOT NULL DEFAULT GETDATE(),
    event_type VARCHAR(50) NOT NULL,
    severity VARCHAR(20) NOT NULL,
    description VARCHAR(MAX) NOT NULL,
    source_ip VARCHAR(50) NULL
);
GO

-- Insert some sample security events
INSERT INTO security_events (event_type, severity, description, source_ip)
VALUES 
    ('FAILED_LOGIN', 'HIGH', 'Multiple failed login attempts', '192.168.1.100'),
    ('SQL_INJECTION_ATTEMPT', 'CRITICAL', 'Possible SQL injection detected in query parameter', '10.0.0.15'),
    ('SENSITIVE_DATA_ACCESS', 'MEDIUM', 'Access to sensitive customer data from unusual location', '203.0.113.42');
GO
"@

Set-Content -Path "../init-db.sql" -Value $sqlScript

# Navigate to the root directory for docker-compose
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path $scriptPath -Parent
$rootDir = Split-Path $scriptDir -Parent
Push-Location $rootDir

try {
    # Build and run Docker containers
    Write-Host "Building and starting containers..." -ForegroundColor Green
    # For newer Docker versions
    docker compose up -d --build
    
    # If the above fails, try with docker-compose (hyphenated) for older Docker versions
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Trying with docker-compose (older syntax)..." -ForegroundColor Yellow
        docker-compose up -d --build
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to start Docker containers. Check the error messages above."
        exit 1
    }
    
    Write-Host "Waiting for SQL Server to start (20 seconds)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 20
    
    # Get the container name for the database
    $dbContainer = docker ps --format "{{.Names}}" | Where-Object { $_ -like "*db*" }
    
    if ($dbContainer) {
        Write-Host "Initializing database..." -ForegroundColor Green
        docker exec $dbContainer /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P ComplexP@ss123 -i /var/opt/mssql/init-db.sql
        
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Database initialization might have failed. The application may not work correctly."
        }
    }
    else {
        Write-Warning "Could not find the database container. Database initialization skipped."
    }
    
    # Check if containers are running
    Write-Host "Checking container status..." -ForegroundColor Cyan
    docker ps
    
    # Get the container status for API and Web
    $apiContainer = docker ps --format "{{.Names}}" | Where-Object { $_ -like "*api*" }
    $webContainer = docker ps --format "{{.Names}}" | Where-Object { $_ -like "*web*" }
    
    Write-Host ""
    if ($apiContainer -and $webContainer) {
        Write-Host "Setup complete! The application is now running locally:" -ForegroundColor Green
        Write-Host "- Web: http://localhost" -ForegroundColor Yellow
        Write-Host "- API: http://localhost:8000" -ForegroundColor Yellow
    }
    else {
        Write-Warning "Not all containers are running. Please check the Docker logs."
    }
    
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Cyan
    Write-Host "- View logs: docker-compose logs -f" -ForegroundColor Gray
    Write-Host "- Stop containers: docker-compose down" -ForegroundColor Gray
    Write-Host "- Restart containers: docker-compose restart" -ForegroundColor Gray
}
finally {
    # Return to the original directory
    Pop-Location
}
