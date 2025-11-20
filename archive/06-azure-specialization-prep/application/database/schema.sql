-- Contoso Task Manager Database Schema
-- Azure SQL Database
-- Version: 1.0

-- Create Tasks table
CREATE TABLE Tasks (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    CompletedDate DATETIME2 NULL
);

-- Create index on Status for faster queries
CREATE INDEX IX_Tasks_Status ON Tasks(Status);

-- Create index on CreatedDate for sorting
CREATE INDEX IX_Tasks_CreatedDate ON Tasks(CreatedDate DESC);

-- Insert sample data for demo
INSERT INTO Tasks (Title, Description, Status, CreatedDate) VALUES
('Deploy Azure Infrastructure', 'Deploy VMs, load balancer, and Azure SQL Database using Bicep templates', 'Completed', DATEADD(day, -7, GETDATE())),
('Configure Network Security Groups', 'Set up NSG rules for web tier and data tier subnets', 'Completed', DATEADD(day, -6, GETDATE())),
('Install IIS and Deploy Application', 'Install IIS role, configure application pool, deploy ASP.NET application', 'Completed', DATEADD(day, -5, GETDATE())),
('Configure Azure Load Balancer', 'Set up health probes and load balancing rules', 'Completed', DATEADD(day, -4, GETDATE())),
('Setup Azure Monitor', 'Configure monitoring, metrics, and alerting', 'Pending', DATEADD(day, -3, GETDATE())),
('Conduct Load Testing', 'Perform load testing to validate 100 TPS requirement', 'Pending', DATEADD(day, -2, GETDATE())),
('Complete WAF Assessment', 'Run Well-Architected Framework assessment on all 5 pillars', 'Pending', DATEADD(day, -1, GETDATE())),
('Prepare Audit Documentation', 'Generate evidence for Module A and Module B controls', 'Pending', GETDATE()),
('Conduct Security Review', 'Review NSG rules, SQL firewall, and encryption settings', 'Pending', GETDATE()),
('Finalize Runbooks', 'Document operational procedures and disaster recovery steps', 'Pending', GETDATE());

-- Query to verify data
SELECT 
    Id,
    Title,
    Status,
    CreatedDate,
    CASE 
        WHEN Status = 'Completed' THEN '✓'
        ELSE '○'
    END as StatusIcon
FROM Tasks
ORDER BY CreatedDate DESC;

-- Query for statistics (useful for validation)
SELECT 
    COUNT(*) as TotalTasks,
    SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as CompletedTasks,
    SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) as PendingTasks
FROM Tasks;
