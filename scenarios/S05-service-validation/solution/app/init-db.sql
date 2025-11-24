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
