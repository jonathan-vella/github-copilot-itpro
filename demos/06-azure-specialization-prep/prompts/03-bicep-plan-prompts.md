# Effective Prompts: Bicep Planning Specialist Agent

## 🎯 Purpose

The Bicep Planning Specialist agent creates detailed infrastructure implementation plans using Azure Verified Modules (AVM). This generates evidence for Module A Control 3.1 (Repeatable Deployment with ALZ).

---

## 📝 Prompt Template

```
Create a detailed Bicep implementation plan for the following Azure infrastructure deployment:

**Requirements**:
[LIST INFRASTRUCTURE COMPONENTS]

**Configuration Details**:
[SPECIFY VM SIZES, TIERS, LOCATIONS, ETC.]

**Constraints**:
[SPECIFY AVM USAGE, SECURITY, NAMING, ETC.]

Provide: module structure, parameter strategy, deployment sequence, and validation approach.
```

---

## ✅ Effective Prompts

### Prompt 1: Complete High-Availability Infrastructure Plan

```
Create a detailed Bicep implementation plan for the following Azure infrastructure deployment:

**Requirements**:
1. Virtual Network with two subnets (web tier, data tier)
2. Two Windows Server 2022 VMs with IIS installed automatically
3. Azure Load Balancer (Standard SKU) with public IP address
4. Azure SQL Database (Standard S2 tier, 10GB initial size)
5. Network Security Groups for both subnets with security rules
6. Azure Monitor diagnostics and Log Analytics for all resources

**Configuration Details**:
- VM Size: Standard_D2s_v3 (2 vCPU, 8 GB RAM)
- OS Disks: Premium SSD (P10, 128 GB)
- Location: East US region
- Availability: Availability Set for VMs (99.95% SLA)
- Naming Convention: Follow Azure best practices (rg-audit-demo-prod, vm-web01-prod, etc.)
- Tags: Environment=Production, Project=TaskManager, ManagedBy=Bicep, SLA=99.99%

**Constraints**:
- Use Azure Verified Modules (AVM) where available
- Follow security best practices (NSG deny-by-default, SQL firewall rules)
- Include deployment validation scripts
- Generate reusable, modular Bicep code structure
- Support parameterization for dev/staging/prod environments

Provide: module structure, parameter strategy, deployment sequence, validation approach, and AVM recommendations.
```

**Why this works**:

- ✅ Complete infrastructure requirements listed
- ✅ Specific configuration details (VM sizes, disk types, tiers)
- ✅ Clear naming and tagging standards
- ✅ Emphasizes AVM usage and security
- ✅ Requests structured output (module structure, parameters, sequence)

---

### Prompt 2: Network Infrastructure Focus

```
Create a Bicep implementation plan focused on network infrastructure for a high-availability web application:

**Requirements**:
1. Virtual Network (10.0.0.0/16 address space)
2. Web tier subnet (10.0.1.0/24) for IIS VMs
3. Data tier subnet (10.0.2.0/24) for future private endpoints
4. Network Security Group for web tier (allow HTTP/HTTPS from internet, RDP from corporate IP)
5. Network Security Group for data tier (allow SQL from web tier only, deny all inbound from internet)
6. Azure Load Balancer (Standard SKU) with public IP, backend pool, and health probes
7. Diagnostic settings for NSG flow logs

**Configuration Details**:
- Region: East US
- Environment: Production
- Public IP: Static allocation, Standard SKU
- Health Probe: HTTP probe on port 80, 15-second interval
- Load Balancing Rules: Port 80 and 443, TCP protocol

**Constraints**:
- Use Azure Verified Module for Virtual Network (avm/res/network/virtual-network)
- Follow principle of least privilege for NSG rules
- Include DDoS Protection Basic (free tier)
- Support future expansion (additional subnets, VPN gateway)

Provide: module breakdown for network components, NSG rule definitions, parameter file structure, and deployment dependencies.
```

**Why this works**:

- ✅ Focused on specific infrastructure layer (networking)
- ✅ Detailed subnet planning with CIDR notation
- ✅ Security-first approach (NSG rules, least privilege)
- ✅ Specifies AVM module to use
- ✅ Considers future expansion

---

### Prompt 3: Compute Infrastructure with VM Extensions

```
Create a Bicep implementation plan for compute infrastructure with automated IIS installation:

**Requirements**:
1. Two Windows Server 2022 Datacenter VMs
2. Availability Set for 99.95% SLA
3. Premium SSD managed disks (P10, 128 GB for OS)
4. Custom Script Extension to install IIS and deploy application
5. Azure Monitor agent for diagnostics
6. Automatic updates configuration

**Configuration Details**:
- VM Size: Standard_D2s_v3 (2 vCPU, 8 GB RAM)
- Admin Username: azureadmin
- Authentication: Password (for demo), SSH keys (for production)
- Time Zone: Eastern Standard Time
- VM Names: vm-web01-prod, vm-web02-prod

**VM Extension Requirements**:
1. Install IIS role with ASP.NET 4.8
2. Create application pool "TaskManagerPool"
3. Deploy web application from storage account
4. Configure IIS bindings (HTTP on port 80)
5. Enable detailed IIS logging
6. Install Azure Monitor agent

**Constraints**:
- Use Azure Verified Module for Virtual Machines if available
- Parameterize admin credentials (do not hardcode)
- Include VM diagnostics settings
- Support scaling to 4 VMs in the future
- Include VM backup configuration

Provide: module structure for VMs and extensions, parameter strategy for credentials, deployment script with prerequisites, and post-deployment validation steps.
```

**Why this works**:

- ✅ Detailed VM specifications
- ✅ Automated configuration through extensions
- ✅ Security considerations (credential handling)
- ✅ Scalability requirements
- ✅ Comprehensive post-deployment validation

---

### Prompt 4: Database Infrastructure Plan

```
Create a Bicep implementation plan for Azure SQL Database with security and backup configuration:

**Requirements**:
1. Azure SQL Server (logical server)
2. Azure SQL Database (Standard S2 tier, 50 DTUs)
3. Firewall rules (allow Azure services, allow specific web tier subnet)
4. Transparent Data Encryption (TDE) enabled
5. Automated backups with 7-day point-in-time restore
6. Long-term backup retention (30 days)
7. Diagnostic settings for audit logging

**Configuration Details**:
- Server Name: sql-taskmanager-prod-<random> (globally unique)
- Database Name: sqldb-taskmanager-prod
- Collation: SQL_Latin1_General_CP1_CI_AS
- Max Size: 10 GB initial allocation
- Admin Login: sqladmin (parameterized password)
- TLS Version: 1.2 minimum

**Security Requirements**:
- Enable Advanced Data Security (Azure Defender for SQL)
- Configure threat detection policies
- Enable auditing to Log Analytics workspace
- Disable public access (except from Azure services and web subnet)
- Use Azure AD authentication (optional, but recommended)

**Backup and Recovery**:
- Automated backups: 7-day retention (included in tier)
- Long-term retention: Monthly backups for 30 days
- Geo-redundant backup storage
- Document recovery procedures

**Constraints**:
- Use Azure Verified Module for SQL Server if available
- Parameterize all credentials
- Generate strong passwords or use Key Vault references
- Include connection string outputs (with placeholder for password)
- Support database scaling without downtime

Provide: module structure for SQL resources, parameter strategy for credentials, security configuration details, backup policy definitions, and output specifications for connection strings.
```

**Why this works**:

- ✅ Comprehensive database requirements
- ✅ Security-first design (TDE, firewall, auditing)
- ✅ Backup and disaster recovery planning
- ✅ Credential management strategy
- ✅ Considers compliance and auditing

---

### Prompt 5: Monitoring and Observability Plan

```
Create a Bicep implementation plan for comprehensive monitoring and observability:

**Requirements**:
1. Log Analytics workspace (PerGB2018 pricing tier)
2. Application Insights for web application monitoring
3. Diagnostic settings for all resources (VMs, SQL, NSGs, Load Balancer)
4. Azure Monitor alert rules for critical metrics
5. Action groups for email and SMS notifications

**Monitoring Targets**:
- VMs: CPU > 80%, Memory > 85%, Disk > 90%
- SQL Database: DTU > 80%, Failed connections, Deadlocks
- Load Balancer: Health probe failures, Backend availability
- NSGs: DDoS attacks, suspicious traffic patterns

**Alert Configuration**:
- Critical Alerts: Immediate notification (SMS + Email)
- Warning Alerts: Email only
- Notification Recipients: ops-team@contoso.com, +1-555-0100
- Alert Evaluation: 5-minute frequency

**Dashboard Requirements**:
1. VM performance metrics (CPU, memory, disk, network)
2. SQL Database performance (DTU usage, query performance)
3. Application metrics (response time, error rate, availability)
4. Security events (NSG denials, failed login attempts)

**Constraints**:
- Use Azure Verified Modules for monitoring resources
- Parameterize alert thresholds for different environments
- Include workbook templates for common scenarios
- Support integration with existing monitoring tools
- Keep costs under $50/month for demo environment

Provide: module structure for monitoring components, alert rule definitions, parameter strategy for thresholds, dashboard JSON templates, and cost optimization recommendations.
```

**Why this works**:

- ✅ Complete observability strategy
- ✅ Specific alert thresholds and recipients
- ✅ Dashboard requirements defined
- ✅ Cost consciousness
- ✅ Integration considerations

---

### Prompt 6: Complete End-to-End Deployment Plan

```
Create a comprehensive Bicep implementation plan for the entire Contoso Task Manager infrastructure:

**Infrastructure Overview**:
- Resource Group: rg-audit-demo-prod (East US)
- Virtual Network: Hub-spoke topology consideration
- Compute: 2 IIS VMs in Availability Set
- Load Balancer: Standard SKU with public IP
- Database: Azure SQL Database (Standard S2)
- Monitoring: Log Analytics, Application Insights, Alerts

**Deployment Requirements**:
1. Main orchestration template (main.bicep)
2. Modular design with separate files for each tier
3. Parameter files for dev, staging, prod environments
4. Deployment validation before actual provisioning
5. What-if analysis capability
6. Rollback strategy

**Module Structure Requirements**:
- network.bicep: VNet, subnets, NSGs, public IP
- compute.bicep: VMs, availability set, extensions
- database.bicep: SQL Server, database, firewall rules
- loadbalancer.bicep: Load balancer, backend pool, probes, rules
- monitoring.bicep: Log Analytics, App Insights, diagnostics
- outputs.bicep: Centralized outputs for all resources

**Parameter Strategy**:
- Environment-specific values (dev, staging, prod)
- Sensitive values (passwords, connection strings) via Key Vault
- Common values (location, tags) in shared parameters
- VM sizing based on environment
- Database tier based on environment

**Deployment Sequence**:
1. Network infrastructure (VNet, subnets, NSGs)
2. Monitoring infrastructure (Log Analytics workspace)
3. Compute infrastructure (VMs with dependencies on network)
4. Database infrastructure (SQL with dependencies on network)
5. Load balancer (depends on VMs being provisioned)
6. Diagnostic settings (depends on all resources and Log Analytics)

**Validation Requirements**:
- Pre-deployment: Bicep linting, what-if analysis
- During deployment: Resource validation, dependency checking
- Post-deployment: Connectivity tests, health checks, performance validation

**Constraints**:
- Use Azure Verified Modules (AVM) wherever available
- Follow naming conventions: <resource-type>-<workload>-<environment>-<region>
- Implement tags: Environment, Project, Owner, CostCenter, ManagedBy
- Security by default: NSG deny-all, SQL firewall, TLS 1.2
- Document all deviations from AVM standard patterns

**Audit Evidence Requirements**:
- Generate deployment logs for Module B Control 3.1
- Document ALZ alignment for Module A Control 3.1
- Create architecture diagrams from Bicep visualization
- Produce resource inventory for audit documentation

Provide: Complete module structure with file names, detailed parameter file structure for each environment, deployment script (PowerShell) with validation steps, dependency map showing deployment order, AVM module mapping, and audit documentation checklist.
```

**Why this works**:

- ✅ Comprehensive, production-ready plan
- ✅ Clear module boundaries and dependencies
- ✅ Environment parameterization strategy
- ✅ Deployment sequence with rationale
- ✅ Validation at multiple stages
- ✅ Audit evidence generation
- ✅ Security and compliance considerations

---

## 🚫 Ineffective Prompts (Avoid These)

### ❌ Too Vague

```
Create a plan for deploying Azure infrastructure using Bicep.
```

**Problems**:

- No specific requirements
- No infrastructure components listed
- No constraints or standards
- Too generic to produce useful output

---

### ❌ Missing Technical Details

```
Plan the deployment of VMs and a database in Azure.
```

**Problems**:

- No VM sizes, quantities, or OS specified
- No database type or tier mentioned
- No network configuration
- No security or monitoring requirements

---

### ❌ Only Listing Components Without Context

```
Create a plan for: VNet, 2 VMs, Load Balancer, SQL Database, NSGs.
```

**Problems**:

- No configuration details
- No relationships between components
- No deployment sequence
- No parameter strategy
- Missing validation approach

---

## 💡 Best Practices

### 1. Provide Complete Infrastructure Requirements

List all components with relationships:

```
Requirements:
1. Virtual Network with subnets (specify CIDR ranges)
2. VMs (specify size, OS, quantity, configuration)
3. Load Balancer (specify SKU, health probes, rules)
4. Database (specify service, tier, size, backup)
5. Monitoring (specify metrics, alerts, dashboards)
```

### 2. Specify Configuration Details

Be explicit about:

- **VM sizing**: Standard_D2s_v3, not "medium VM"
- **Database tier**: Standard S2 (50 DTUs), not "standard database"
- **Disk types**: Premium SSD P10, not "fast disk"
- **Networking**: 10.0.1.0/24, not "subnet for web tier"

### 3. Emphasize AVM Usage

Direct the agent to use verified modules:

```
Constraints:
- Use Azure Verified Modules (AVM) where available
- Specify which AVM modules to use: avm/res/network/virtual-network
- Document any custom modules needed
```

### 4. Request Structured Output

Ask for specific deliverables:

```
Provide:
- Module structure with file names
- Parameter strategy for each environment
- Deployment sequence with dependencies
- Validation approach (pre, during, post)
- AVM module recommendations
```

### 5. Include Security and Compliance

Always mention:

```
Security Requirements:
- NSG rules following least privilege
- SQL firewall rules
- TLS 1.2 minimum
- Encryption at rest and in transit
- Diagnostic logging enabled
```

### 6. Define Parameter Strategy

Specify how to handle different values:

```
Parameters:
- Environment-specific: VM size, database tier
- Sensitive: Passwords, connection strings (Key Vault)
- Common: Location, tags, naming prefix
```

---

## 📊 Prompt Quality Checklist

Before submitting your prompt:

- [ ] **All infrastructure components listed** - No missing pieces
- [ ] **Configuration details specified** - Sizes, tiers, SKUs
- [ ] **Naming conventions defined** - How resources should be named
- [ ] **Tags specified** - Environment, Project, Owner, etc.
- [ ] **Security requirements stated** - NSGs, firewalls, encryption
- [ ] **AVM usage emphasized** - Request specific modules
- [ ] **Parameter strategy needed** - How to handle different values
- [ ] **Deployment sequence requested** - What order to deploy
- [ ] **Validation approach requested** - Pre/during/post checks
- [ ] **Audit evidence considered** - What documentation is needed

---

## 🎓 Learning from Examples

### Excellent Example: Complete Planning Prompt

```
Create a detailed Bicep implementation plan for a high-availability web application infrastructure for the Azure Infrastructure and Database Migration Specialization audit:

**Business Context**:
- Customer: Contoso Manufacturing
- Application: ASP.NET Task Manager (IIS-hosted)
- SLA Requirement: 99.99% availability
- Performance: 100 transactions per second
- Environment: Production deployment for audit evidence

**Infrastructure Requirements**:
1. **Networking**:
   - Virtual Network: 10.0.0.0/16
   - Web Subnet: 10.0.1.0/24 (for VMs)
   - Data Subnet: 10.0.2.0/24 (for SQL private endpoint in future)
   - NSG for Web: Allow HTTP/HTTPS inbound, RDP from corporate (203.0.113.0/24)
   - NSG for Data: Allow SQL (1433) from web subnet only

2. **Compute**:
   - 2 × Windows Server 2022 VMs
   - Size: Standard_D2s_v3 (2 vCPU, 8 GB RAM)
   - Disks: Premium SSD P10 (128 GB OS disk)
   - Availability Set: 2 fault domains, 5 update domains
   - Extensions: IIS installation, Azure Monitor agent, custom script for app deployment

3. **Load Balancing**:
   - Azure Load Balancer (Standard SKU)
   - Public IP: Static, Standard SKU
   - Backend Pool: Both VMs
   - Health Probe: HTTP on port 80, 15-second interval
   - Rules: HTTP (80) and HTTPS (443)

4. **Database**:
   - Azure SQL Server (logical)
   - Database: Standard S2 (50 DTUs, 10 GB)
   - Firewall: Allow Azure services, allow web subnet
   - Security: TDE enabled, auditing to Log Analytics
   - Backup: 7-day retention, geo-redundant

5. **Monitoring**:
   - Log Analytics workspace (PerGB2018 tier)
   - Application Insights for web app
   - Diagnostic settings on all resources
   - Alerts: VM CPU > 80%, SQL DTU > 80%, LB probe failures

**Configuration Standards**:
- Location: East US
- Naming: <type>-<app>-<env>-<region> (e.g., vm-taskmanager-prod-eastus01)
- Tags: Environment=Production, Project=TaskManager, Owner=IT-Ops, ManagedBy=Bicep, SLA=99.99%, AuditRequired=Yes

**Deployment Constraints**:
- Use Azure Verified Modules (AVM) from Microsoft
- Security by default: Deny-all NSG rules, SQL firewall, TLS 1.2 minimum
- Parameterize for dev/staging/prod environments
- Generate audit-ready deployment logs
- Include what-if analysis capability
- Support rollback scenarios

**Audit Requirements** (Module A Control 3.1):
- Document ALZ alignment (Identity, Networking, Resource Organization)
- Generate deployment evidence logs
- Create architecture diagrams from Bicep visualization
- Produce resource inventory with tags

**Deliverables Required**:
1. Module structure with file names (network.bicep, compute.bicep, etc.)
2. Main orchestration template structure
3. Parameter file structure for prod environment
4. Deployment sequence with dependency explanation
5. PowerShell deployment script with validation
6. AVM module mapping (which modules to use)
7. Output specifications (resource IDs, endpoints, connection strings)
8. Validation checklist (pre-deployment, post-deployment)
9. Audit documentation approach

Provide a comprehensive implementation plan covering all aspects above, with specific recommendations for Azure Verified Modules, parameter organization, deployment automation, and audit evidence generation.
```

**What makes this excellent**:

1. ✅ Business context provided (customer, SLA, performance)
2. ✅ Complete infrastructure specification with all tiers
3. ✅ Detailed configuration (sizes, IPs, ports, rules)
4. ✅ Security requirements throughout
5. ✅ Naming and tagging standards
6. ✅ AVM usage emphasized
7. ✅ Audit requirements explicit
8. ✅ Specific deliverables requested
9. ✅ Environment parameterization
10. ✅ Validation and rollback considerations

---

## 📚 Related Resources

- [Azure Verified Modules (AVM)](https://aka.ms/avm)
- [Bicep Best Practices](https://learn.microsoft.com/azure/azure-resource-manager/bicep/best-practices)
- [Azure Landing Zones](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Bicep Modules](https://learn.microsoft.com/azure/azure-resource-manager/bicep/modules)
- [Azure Naming Conventions](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)

---

**Last Updated**: November 2025  
**Agent Version**: 1.0
