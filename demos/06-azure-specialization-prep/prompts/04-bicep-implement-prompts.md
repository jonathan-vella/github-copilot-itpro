# Effective Prompts: Bicep Implementation Specialist Agent

## 🎯 Purpose

The Bicep Implementation Specialist agent generates production-ready Bicep templates based on implementation plans. This creates reusable infrastructure as code for Module A Control 3.1 (Repeatable Deployment with ALZ) and Module B Control 3.4 (Automated Deployment).

---

## 📝 Prompt Template

```bicep
Generate Bicep templates based on the following implementation plan:

**Module Structure**:
[DESCRIBE MODULE ORGANIZATION]

**Configuration Requirements**:
[SPECIFY RESOURCES, PROPERTIES, DEPENDENCIES]

**Parameters**:
[DEFINE PARAMETER STRATEGY]

**Best Practices**:
- Use Azure Verified Modules (AVM) where available
- Follow security best practices
- Include comprehensive outputs
- Add descriptive comments and decorators

Generate: [MODULE NAME] with all required resources and configurations.
```

---

## ✅ Effective Prompts

### Prompt 1: Main Orchestration Template

```bicep
Generate the main Bicep orchestration template (main.bicep) for deploying the complete Contoso Task Manager infrastructure:

**Module Dependencies**:
1. network.bicep - Virtual network, subnets, NSGs, public IP
2. monitoring.bicep - Log Analytics workspace, Application Insights
3. compute.bicep - Windows Server VMs, availability set, extensions
4. database.bicep - Azure SQL Server and database
5. loadbalancer.bicep - Load balancer with backend pool and health probes

**Parameters Required**:
- location: Azure region (default: eastus)
- environment: Environment name (allowed: dev, staging, prod)
- adminUsername: VM administrator username
- adminPassword: VM administrator password (secure string)
- sqlAdminUsername: SQL administrator username
- sqlAdminPassword: SQL administrator password (secure string)
- tags: Common tags for all resources

**Resource Group Scope**:
- Deploy at resource group level
- Use targetScope = 'resourceGroup'

**Implementation Requirements**:
1. Call each module in correct dependency order
2. Pass outputs from one module as inputs to dependent modules
3. Apply common tags to all resources
4. Generate comprehensive outputs for all resource IDs and endpoints
5. Include descriptive comments for each module call

**Security Requirements**:
- Use @secure() decorator for all password parameters
- Use @description() decorators for all parameters
- Validate parameter values where appropriate
- No hardcoded credentials or secrets

**Best Practices**:
- Use consistent naming for module references
- Group related parameters together
- Include deployment metadata (timestamp, version)
- Add comments explaining dependency rationale

Generate the complete main.bicep file with all module calls, parameter definitions, and outputs.
```

**Why this works**:

- ✅ Clear module structure and dependencies
- ✅ Comprehensive parameter list with security considerations
- ✅ Specific deployment scope
- ✅ Security best practices (secure decorators)
- ✅ Requests complete, production-ready template

---

### Prompt 2: Network Module

```bicep
Generate a Bicep module (network.bicep) for network infrastructure:

**Resources to Create**:
1. Virtual Network (10.0.0.0/16 address space)
2. Web Tier Subnet (10.0.1.0/24)
3. Data Tier Subnet (10.0.2.0/24)
4. Network Security Group for Web Tier (nsg-web-prod)
5. Network Security Group for Data Tier (nsg-data-prod)
6. Public IP Address for Load Balancer (Standard SKU, Static)

**NSG Rules for Web Tier**:
- Priority 100: Allow HTTP (80) inbound from Internet
- Priority 110: Allow HTTPS (443) inbound from Internet
- Priority 120: Allow RDP (3389) inbound from corporate network (203.0.113.0/24)
- Priority 4096: Deny all other inbound traffic

**NSG Rules for Data Tier**:
- Priority 100: Allow SQL (1433) inbound from web subnet (10.0.1.0/24)
- Priority 4096: Deny all other inbound traffic

**Parameters**:
- location: string (default: resourceGroup().location)
- environment: string (allowed values: dev, staging, prod)
- vnetAddressPrefix: string (default: '10.0.0.0/16')
- webSubnetPrefix: string (default: '10.0.1.0/24')
- dataSubnetPrefix: string (default: '10.0.2.0/24')
- corporateNetworkCidr: string (for RDP access)
- tags: object

**Outputs Required**:
- vnetId: Virtual network resource ID
- vnetName: Virtual network name
- webSubnetId: Web tier subnet resource ID
- dataSubnetId: Data tier subnet resource ID
- webNsgId: Web NSG resource ID
- dataNsgId: Data NSG resource ID
- publicIpId: Public IP resource ID
- publicIpAddress: Public IP address value

**Implementation Requirements**:
- Use Azure Verified Module for Virtual Network if available (avm/res/network/virtual-network)
- Associate NSGs with subnets in the VNet resource
- Enable diagnostic settings for NSGs (requires Log Analytics workspace ID as parameter)
- Use descriptive @description() decorators for all parameters and outputs
- Add comments explaining security rules
- Follow naming convention: <resource-type>-<tier>-<environment>

**Security Best Practices**:
- Default deny rules at lowest priority (4096)
- Explicit allow rules for required traffic only
- Separate NSGs for different security zones
- Enable NSG flow logs (add parameter for Log Analytics workspace)

Generate the complete network.bicep module with all resources, parameters, and outputs.
```

**Why this works**:

- ✅ Detailed resource specifications with CIDR blocks
- ✅ Complete NSG rule definitions with priorities
- ✅ Security-first design (deny-by-default)
- ✅ Comprehensive output specifications
- ✅ AVM module reference
- ✅ Naming conventions included

---

### Prompt 3: Compute Module with VM Extensions

```bicep
Generate a Bicep module (compute.bicep) for Windows Server VMs with IIS installation:

**Resources to Create**:
1. Availability Set (2 fault domains, 5 update domains)
2. Two Windows Server 2022 Datacenter VMs
3. Network Interfaces for each VM (connected to web subnet)
4. Premium SSD Managed Disks (P10, 128 GB for OS)
5. Custom Script Extension for IIS installation
6. Azure Monitor Agent Extension

**VM Configuration**:
- VM Size: Standard_D2s_v3 (2 vCPU, 8 GB RAM)
- OS: Windows Server 2022 Datacenter (latest image)
- OS Disk: Premium SSD, 128 GB, caching ReadWrite
- Computer Names: TASKWEB01, TASKWEB02
- Time Zone: Eastern Standard Time
- License Type: Windows_Server (Azure Hybrid Benefit eligible)

**Network Interface Configuration**:
- Private IP: Dynamic allocation
- Connected to web subnet (passed as parameter)
- Associated with Load Balancer backend pool (passed as parameter)

**Custom Script Extension Requirements**:
Install and configure IIS with the following PowerShell script:
```powershell
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Install-WindowsFeature -Name Web-Asp-Net45
New-WebAppPool -Name 'TaskManagerPool'
Set-ItemProperty IIS:\AppPools\TaskManagerPool -name processModel.identityType -value 2
New-Item -Path 'C:\inetpub\wwwroot\TaskManager' -ItemType Directory
# Configure IIS site binding
```

**Azure Monitor Agent Extension**:

- Connect to Log Analytics workspace (ID passed as parameter)
- Enable performance counters collection
- Enable Windows Event Logs collection

**Parameters**:

- location: string (default: resourceGroup().location)
- environment: string (allowed values: dev, staging, prod)
- adminUsername: string
- adminPassword: securestring
- vmSize: string (default: 'Standard_D2s_v3')
- vmCount: int (default: 2, min: 2, max: 4)
- subnetId: string (web subnet resource ID)
- loadBalancerBackendPoolId: string (from load balancer module)
- logAnalyticsWorkspaceId: string (for monitoring)
- tags: object

**Outputs Required**:

- vmIds: array of VM resource IDs
- vmNames: array of VM names
- privateIpAddresses: array of private IP addresses
- availabilitySetId: Availability set resource ID
- networkInterfaceIds: array of NIC resource IDs

**Implementation Requirements**:

- Use loop to create multiple VMs (based on vmCount parameter)
- Use Azure Verified Module for Virtual Machines if available
- Name VMs sequentially: vm-web01-prod, vm-web02-prod
- Include @description() decorators for all parameters
- Add comments explaining extension configurations
- Enable boot diagnostics
- Configure automatic updates

**Security Best Practices**:

- Use @secure() decorator for adminPassword
- No hardcoded credentials
- Parameterize sensitive values
- Enable VM encryption at rest (managed disk encryption)

Generate the complete compute.bicep module with all resources, extensions, parameters, and outputs.

```bicep

**Why this works**:
- ✅ Complete VM specifications including sizes and images
- ✅ Detailed extension configurations with actual scripts
- ✅ Loop implementation for scalability
- ✅ Security considerations (secure parameters, encryption)
- ✅ Comprehensive dependency management
- ✅ Production-ready configuration

---

### Prompt 4: Database Module with Security

```

Generate a Bicep module (database.bicep) for Azure SQL Database with comprehensive security:

**Resources to Create**:

1. Azure SQL Server (logical server)
2. Azure SQL Database
3. Firewall Rules (Azure services, web subnet)
4. Transparent Data Encryption configuration
5. Auditing settings to Log Analytics
6. Advanced Data Security (Azure Defender for SQL)

**SQL Server Configuration**:

- Server Name: sql-taskmanager-<environment>-<uniqueString> (globally unique)
- Version: 12.0 (latest)
- Administrator Login: Parameterized username
- Administrator Password: Parameterized secure string
- Minimum TLS Version: 1.2
- Public Network Access: Enabled (for demo, disable for production)
- Azure AD Administrator: Optional, parameterized

**SQL Database Configuration**:

- Database Name: sqldb-taskmanager-<environment>
- SKU: Standard S2 (50 DTUs)
- Max Size: 10 GB
- Collation: SQL_Latin1_General_CP1_CI_AS
- Zone Redundant: false (true for production)
- Auto-pause: Disabled
- Read Scale: Disabled

**Firewall Rules**:

1. Allow Azure Services: Start IP 0.0.0.0, End IP 0.0.0.0
2. Allow Web Subnet: Use subnet address range from parameters
3. Allow Management IP: Parameterized corporate IP for management access

**Security Features**:

- Transparent Data Encryption: Enabled (default)
- Advanced Data Security: Enabled with vulnerability assessments
- Auditing: Enabled, send logs to Log Analytics workspace
- Threat Detection: Enabled with email notifications
- Data Classification: Configure sensitivity labels (optional)

**Backup Configuration**:

- Short-term retention: 7 days (included in Standard tier)
- Long-term retention: Monthly backups, 30-day retention
- Geo-redundant backup: Enabled
- Point-in-time restore: Enabled (automatic)

**Parameters**:

- location: string (default: resourceGroup().location)
- environment: string (allowed values: dev, staging, prod)
- sqlServerName: string (provide uniqueString in default)
- sqlAdminUsername: string
- sqlAdminPassword: securestring
- databaseName: string (default: 'sqldb-taskmanager')
- databaseSku: string (default: 'S2')
- maxSizeBytes: int (default: 10GB in bytes)
- webSubnetCidr: string (for firewall rule)
- managementIpAddress: string (for admin access)
- logAnalyticsWorkspaceId: string (for auditing)
- alertEmailAddresses: array (for threat detection notifications)
- tags: object

**Outputs Required**:

- sqlServerId: SQL Server resource ID
- sqlServerName: SQL Server fully qualified domain name
- databaseId: Database resource ID
- databaseName: Database name
- connectionString: Connection string template (without password)

**Implementation Requirements**:

- Use Azure Verified Module for SQL Server if available
- Generate globally unique server name using uniqueString()
- Implement conditional deployment based on environment
- Include @description() decorators for all parameters
- Add comments explaining security configurations
- Output connection string with placeholder for password

**Security Best Practices**:

- Use @secure() decorator for SQL admin password
- Minimum TLS 1.2 enforcement
- Enable auditing and threat detection
- Implement firewall rules with least privilege
- Enable Advanced Data Security
- Use parameterized alert email addresses

**Example Connection String Output**:

```yaml
Server=tcp:{serverName}.database.windows.net,1433;Initial Catalog={databaseName};Persist Security Info=False;User ID={username};Password={your_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
```

Generate the complete database.bicep module with all resources, security configurations, parameters, and outputs.

```bicep

**Why this works**:
- ✅ Comprehensive security configuration (TDE, auditing, threat detection)
- ✅ Detailed backup and retention policies
- ✅ Firewall rules with least privilege
- ✅ Parameterized for different environments
- ✅ Connection string output for application integration
- ✅ Production-ready security posture

---

### Prompt 5: Load Balancer Module

```

Generate a Bicep module (loadbalancer.bicep) for Azure Load Balancer:

**Resources to Create**:

1. Azure Load Balancer (Standard SKU)
2. Frontend IP Configuration (using existing public IP)
3. Backend Address Pool
4. Health Probe for HTTP traffic
5. Load Balancing Rules for HTTP and HTTPS
6. Optional: NAT Rules for RDP access to VMs

**Load Balancer Configuration**:

- Name: lb-web-<environment>
- SKU: Standard
- Tier: Regional
- Frontend IP: Use existing public IP (passed as parameter)

**Backend Pool Configuration**:

- Name: be-pool-web
- VMs: Add network interfaces (passed as array parameter)

**Health Probe Configuration**:

- Name: health-probe-http
- Protocol: HTTP
- Port: 80
- Interval: 15 seconds
- Unhealthy threshold: 2 consecutive failures
- Request Path: /

**Load Balancing Rules**:

1. HTTP Rule:
   - Name: lb-rule-http
   - Frontend Port: 80
   - Backend Port: 80
   - Protocol: TCP
   - Session Persistence: None
   - Idle Timeout: 4 minutes
   - Enable Floating IP: false

2. HTTPS Rule:
   - Name: lb-rule-https
   - Frontend Port: 443
   - Backend Port: 443
   - Protocol: TCP
   - Session Persistence: None
   - Idle Timeout: 4 minutes
   - Enable Floating IP: false

**Optional NAT Rules** (for management):

- NAT Rule 1: Frontend Port 50001 → VM1 RDP Port 3389
- NAT Rule 2: Frontend Port 50002 → VM2 RDP Port 3389

**Parameters**:

- location: string (default: resourceGroup().location)
- environment: string (allowed values: dev, staging, prod)
- publicIpId: string (existing public IP resource ID)
- networkInterfaceIds: array (array of NIC resource IDs to add to backend pool)
- enableNatRules: bool (default: false, set true for management access)
- tags: object

**Outputs Required**:

- loadBalancerId: Load balancer resource ID
- loadBalancerName: Load balancer name
- backendPoolId: Backend address pool resource ID
- frontendIpAddress: Frontend IP configuration ID
- healthProbeId: Health probe resource ID

**Implementation Requirements**:

- Use Azure Verified Module for Load Balancer if available
- Add diagnostic settings for Load Balancer metrics
- Include @description() decorators for all parameters
- Add comments explaining rules and probes
- Conditional NAT rules based on parameter

**Monitoring Requirements**:

- Enable diagnostic logs for:
  - LoadBalancerAlertEvent
  - LoadBalancerProbeHealthStatus
- Send logs to Log Analytics workspace (ID passed as parameter)

**Best Practices**:

- Use Standard SKU for zone redundancy support
- Configure appropriate health probe intervals
- Set idle timeout based on application behavior
- Document NAT rule port mappings

Generate the complete loadbalancer.bicep module with all resources, rules, parameters, and outputs.

```yaml

**Why this works**:
- ✅ Complete load balancer configuration
- ✅ Health probe specifications with timing
- ✅ Multiple load balancing rules
- ✅ Optional NAT rules for management
- ✅ Monitoring and diagnostics included
- ✅ Production-ready settings

---

### Prompt 6: Monitoring Module

```

Generate a Bicep module (monitoring.bicep) for comprehensive Azure Monitor configuration:

**Resources to Create**:

1. Log Analytics Workspace
2. Application Insights
3. Diagnostic Settings for all infrastructure resources
4. Azure Monitor Alert Rules
5. Action Group for notifications

**Log Analytics Workspace Configuration**:

- Name: log-taskmanager-<environment>
- SKU: PerGB2018 (pay-as-you-go)
- Retention: 30 days (dev), 90 days (prod)
- Daily Quota: 1 GB (dev), 5 GB (prod)

**Application Insights Configuration**:

- Name: appi-taskmanager-<environment>
- Application Type: web
- Kind: web
- Workspace Based: true (linked to Log Analytics)
- Sampling: 100% for dev, 50% for prod

**Diagnostic Settings** (create for each resource type):

1. Virtual Machines: Performance counters, Windows Event Logs
2. SQL Database: QueryStoreRuntimeStatistics, Errors, Deadlocks, SQLInsights
3. Load Balancer: LoadBalancerAlertEvent, LoadBalancerProbeHealthStatus
4. NSGs: NetworkSecurityGroupEvent, NetworkSecurityGroupRuleCounter

**Alert Rules to Create**:

1. VM CPU Alert:
   - Name: alert-vm-cpu-high
   - Metric: Percentage CPU
   - Condition: Greater than 80%
   - Evaluation Frequency: 5 minutes
   - Window Size: 15 minutes
   - Severity: Warning (2)

2. VM Memory Alert:
   - Name: alert-vm-memory-high
   - Metric: Available Memory Bytes
   - Condition: Less than 1 GB
   - Evaluation Frequency: 5 minutes
   - Window Size: 15 minutes
   - Severity: Warning (2)

3. SQL DTU Alert:
   - Name: alert-sql-dtu-high
   - Metric: dtu_consumption_percent
   - Condition: Greater than 80%
   - Evaluation Frequency: 5 minutes
   - Window Size: 15 minutes
   - Severity: Error (1)

4. Load Balancer Health:
   - Name: alert-lb-probe-failure
   - Metric: DipAvailability
   - Condition: Less than 100%
   - Evaluation Frequency: 5 minutes
   - Window Size: 5 minutes
   - Severity: Critical (0)

**Action Group Configuration**:

- Name: ag-taskmanager-ops
- Short Name: tm-ops
- Email Notifications: ops-team@contoso.com
- SMS Notifications: +1-555-0100 (optional)
- Webhook: Optional integration URL

**Parameters**:

- location: string (default: resourceGroup().location)
- environment: string (allowed values: dev, staging, prod)
- retentionInDays: int (default based on environment)
- dailyQuotaGb: int (default based on environment)
- vmResourceIds: array (VMs to monitor)
- sqlDatabaseId: string (database to monitor)
- loadBalancerId: string (load balancer to monitor)
- nsgResourceIds: array (NSGs to monitor)
- alertEmailAddresses: array (notification recipients)
- alertPhoneNumbers: array (SMS recipients, optional)
- tags: object

**Outputs Required**:

- logAnalyticsWorkspaceId: Workspace resource ID
- logAnalyticsWorkspaceName: Workspace name
- applicationInsightsId: App Insights resource ID
- applicationInsightsInstrumentationKey: Instrumentation key
- applicationInsightsConnectionString: Connection string
- actionGroupId: Action group resource ID

**Implementation Requirements**:

- Use loop to create diagnostic settings for multiple resources
- Use conditional logic for environment-specific configurations
- Include @description() decorators for all parameters
- Add comments explaining alert thresholds
- Support different retention periods per environment

**Best Practices**:

- Separate critical, error, and warning alert severities
- Configure appropriate evaluation frequencies
- Set realistic thresholds based on workload
- Enable sampling in Application Insights for cost control
- Use workspace-based Application Insights

Generate the complete monitoring.bicep module with all resources, alert rules, diagnostic settings, parameters, and outputs.

```bicep

**Why this works**:
- ✅ Comprehensive monitoring strategy
- ✅ Multiple alert rules with specific thresholds
- ✅ Diagnostic settings for all resource types
- ✅ Environment-specific configurations
- ✅ Action group for notifications
- ✅ Production-ready observability

---

## 🚫 Ineffective Prompts (Avoid These)

### ❌ Too Generic

```

Generate a Bicep template for VMs in Azure.

```bicep

**Problems**:
- No VM specifications (size, OS, quantity)
- No network configuration
- No parameters defined
- No outputs specified
- Missing security configurations

---

### ❌ Missing Resource Properties

```

Create a network.bicep module with a VNet and two subnets.

```yaml

**Problems**:
- No address spaces specified
- No NSG configurations
- No subnet associations
- No outputs defined
- Missing security rules

---

### ❌ No Parameter Strategy

```

Generate database.bicep for Azure SQL with all features enabled.

```bicep

**Problems**:
- No parameter definitions
- No credential handling strategy
- "All features" is too vague
- No security configurations specified
- Missing firewall rules

---

## 💡 Best Practices

### 1. Specify Complete Resource Configurations

Be explicit about every property:
```

SQL Database Configuration:

- SKU: Standard S2 (50 DTUs)
- Max Size: 10 GB
- Collation: SQL_Latin1_General_CP1_CI_AS
- Zone Redundant: false
- TLS Version: 1.2 minimum

```text

### 2. Define Comprehensive Parameter Lists

Include all parameters with types and defaults:
```

Parameters:

- location: string (default: resourceGroup().location)
- environment: string (allowed: dev, staging, prod)
- adminUsername: string
- adminPassword: securestring (use @secure decorator)
- vmSize: string (default: 'Standard_D2s_v3')

```text

### 3. Request All Necessary Outputs

Specify outputs for dependent modules:
```

Outputs Required:

- vnetId: Virtual network resource ID
- subnetId: Subnet resource ID
- nsgId: NSG resource ID
- publicIpAddress: Public IP address value

```text

### 4. Emphasize Security Best Practices

Always mention security requirements:
```

Security Requirements:

- Use @secure() decorator for passwords
- Minimum TLS 1.2
- NSG deny-by-default rules
- Enable encryption at rest
- No hardcoded credentials

```text

### 5. Include Decorators and Comments

Request documentation in code:
```

Implementation Requirements:

- Use @description() for all parameters
- Use @allowed() for enumerated values
- Use @minValue/@maxValue for numeric constraints
- Add comments explaining complex configurations

```text

### 6. Reference Azure Verified Modules

Direct to use official modules:
```

Best Practices:

- Use Azure Verified Module for Virtual Network (avm/res/network/virtual-network)
- Reference AVM parameters and outputs
- Document any custom modifications

```bicep

---

## 📊 Prompt Quality Checklist

Before submitting your prompt:

- [ ] **All resources specified** - Complete list with types
- [ ] **Resource properties defined** - Sizes, SKUs, configurations
- [ ] **Parameters comprehensive** - All inputs with types and defaults
- [ ] **Security decorators requested** - @secure() for sensitive values
- [ ] **Description decorators requested** - @description() for all parameters
- [ ] **Outputs specified** - All necessary outputs for dependencies
- [ ] **Comments requested** - Explain complex logic
- [ ] **AVM usage mentioned** - Reference verified modules
- [ ] **Security best practices** - TLS, encryption, firewalls
- [ ] **Naming conventions** - Consistent resource naming pattern

---

## 🎓 Learning from Examples

### Excellent Example: Complete Module Implementation

```

Generate a complete Bicep module (network.bicep) for network infrastructure supporting a high-availability web application for Azure Infrastructure and Database Migration Specialization audit evidence:

**Business Context**:

- Application: ASP.NET Task Manager on IIS
- Environment: Production deployment for audit
- Security: Public endpoints for demo (document deviation from private endpoint best practice)
- Compliance: Must align with Azure Landing Zone design areas

**Resources to Create**:

1. **Virtual Network**:
   - Name: vnet-taskmanager-prod-eastus
   - Address Space: 10.0.0.0/16
   - Location: East US
   - DNS Servers: Default Azure DNS

2. **Subnets**:
   a. Web Tier Subnet:
      - Name: snet-web-prod
      - Address Prefix: 10.0.1.0/24
      - Service Endpoints: Microsoft.Sql (for future private endpoint)

   b. Data Tier Subnet:
      - Name: snet-data-prod
      - Address Prefix: 10.0.2.0/24
      - Service Endpoints: Microsoft.Sql
      - Delegation: None (reserved for future use)

3. **Network Security Group - Web Tier** (nsg-web-prod):
   - Priority 100: Allow HTTP (80) inbound from Internet (0.0.0.0/0)
   - Priority 110: Allow HTTPS (443) inbound from Internet (0.0.0.0/0)
   - Priority 120: Allow RDP (3389) inbound from corporate network (203.0.113.0/24)
   - Priority 130: Allow HTTP (80) outbound to Internet (for Windows Updates)
   - Priority 140: Allow HTTPS (443) outbound to Internet
   - Priority 150: Allow SQL (1433) outbound to data subnet (10.0.2.0/24)
   - Priority 4096: Deny all other inbound traffic
   - Associate with web subnet

4. **Network Security Group - Data Tier** (nsg-data-prod):
   - Priority 100: Allow SQL (1433) inbound from web subnet only (10.0.1.0/24)
   - Priority 110: Allow SQL (1433) inbound from corporate network (for management)
   - Priority 4096: Deny all other inbound traffic
   - Associate with data subnet

5. **Public IP Address**:
   - Name: pip-lb-taskmanager-prod
   - SKU: Standard
   - Allocation: Static
   - DNS Label: taskmanager-prod-<uniqueString>
   - Availability Zone: Zone-redundant

6. **Diagnostic Settings** (for audit evidence):
   - Enable NSG Flow Logs for both NSGs
   - Send to Log Analytics workspace (ID passed as parameter)
   - Retention: 30 days
   - Traffic Analytics: Enabled

**Parameters**:

```bicep
@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Environment name (dev, staging, prod)')
@allowed([
  'dev'
  'staging'
  'prod'
])
param environment string = 'prod'

@description('Virtual network address space (CIDR notation)')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Web tier subnet address prefix (CIDR notation)')
param webSubnetPrefix string = '10.0.1.0/24'

@description('Data tier subnet address prefix (CIDR notation)')
param dataSubnetPrefix string = '10.0.2.0/24'

@description('Corporate network CIDR for management access (RDP, SQL)')
param corporateNetworkCidr string = '203.0.113.0/24'

@description('Log Analytics workspace resource ID for diagnostics')
param logAnalyticsWorkspaceId string

@description('Common tags applied to all resources')
param tags object = {
  Environment: environment
  Project: 'TaskManager'
  ManagedBy: 'Bicep'
  AuditRequired: 'Yes'
}
```bicep

**Outputs Required**:

```bicep
@description('Virtual network resource ID')
output vnetId string

@description('Virtual network name')
output vnetName string

@description('Web tier subnet resource ID')
output webSubnetId string

@description('Data tier subnet resource ID')
output dataSubnetId string

@description('Web tier NSG resource ID')
output webNsgId string

@description('Data tier NSG resource ID')
output dataNsgId string

@description('Public IP resource ID')
output publicIpId string

@description('Public IP address (static)')
output publicIpAddress string

@description('Public IP DNS FQDN')
output publicIpFqdn string
```

**Implementation Requirements**:

1. **Azure Verified Modules**:
   - Use AVM for Virtual Network: `avm/res/network/virtual-network`
   - If AVM not available, implement following AVM patterns
   - Document any deviations from AVM standard structure

2. **Resource Naming**:
   - Follow Azure naming conventions: `<resource-type>-<workload>-<environment>-<region>`
   - Use consistent naming throughout module
   - Examples: vnet-taskmanager-prod-eastus, snet-web-prod, nsg-web-prod

3. **Security Best Practices**:
   - Implement deny-by-default NSG rules (priority 4096)
   - Explicit allow rules for required traffic only
   - Separate NSGs for different security zones
   - Enable NSG Flow Logs for audit compliance
   - Document security rule rationale in comments

4. **Code Quality**:
   - Use `@description()` decorator for ALL parameters and outputs
   - Use `@allowed()` decorator for enumerated values
   - Add descriptive comments for each resource
   - Explain security rules with inline comments
   - Group related security rules with comment headers

5. **Diagnostic Settings**:
   - Enable diagnostics for both NSGs
   - Send logs to Log Analytics workspace
   - Configure appropriate retention period
   - Enable Traffic Analytics for network visibility

6. **Dependency Management**:
   - Create NSGs before VNet (for subnet association)
   - Associate NSGs with subnets in VNet resource
   - Ensure Public IP created independently (no dependencies)

7. **Audit Evidence**:
   - Generate deployment logs showing ALZ alignment
   - Document network topology design area
   - Show resource organization with tags
   - Demonstrate security configuration

**Azure Landing Zone Alignment**:

- ✅ **Identity**: Not applicable (network layer)
- ✅ **Networking**: Hub-spoke consideration, security zones, NSG segmentation
- ✅ **Resource Organization**: Consistent naming, comprehensive tagging
- ✅ **Security**: NSG deny-by-default, least privilege access, flow logs

**Expected Module Structure**:

```bicep
// network.bicep - Network Infrastructure Module
// Purpose: Deploys VNet, subnets, NSGs, and public IP for Contoso Task Manager
// ALZ Alignment: Network topology, security, resource organization

targetScope = 'resourceGroup'

// ============================================
// PARAMETERS
// ============================================

// [Parameter definitions with decorators]

// ============================================
// VARIABLES
// ============================================

// [Calculated values, resource names]

// ============================================
// RESOURCES
// ============================================

// Network Security Groups (create first for subnet association)
resource webNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = { ... }
resource dataNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = { ... }

// Virtual Network with Subnets
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = { ... }

// Public IP Address
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = { ... }

// Diagnostic Settings for NSGs
resource webNsgDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = { ... }
resource dataNsgDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = { ... }

// ============================================
// OUTPUTS
// ============================================

// [All output definitions]
```bicep

**Validation Requirements**:

- Bicep build should complete without errors or warnings
- Resource names should follow naming conventions consistently
- All NSG rules should have descriptive comments
- All parameters should have @description() decorators
- Outputs should provide all necessary values for dependent modules

Generate the complete network.bicep module following all requirements above, including comprehensive comments, proper decorators, security best practices, and audit-ready documentation.

```

**What makes this excellent**:

1. ✅ Complete business context (application, environment, audit purpose)
2. ✅ Detailed resource specifications (names, IPs, rules, priorities)
3. ✅ Comprehensive parameter definitions with decorators
4. ✅ Complete output specifications for dependencies
5. ✅ Security best practices (deny-by-default, least privilege)
6. ✅ AVM usage guidance
7. ✅ Naming conventions with examples
8. ✅ ALZ alignment documentation
9. ✅ Expected code structure
10. ✅ Validation requirements
11. ✅ Inline comments requested
12. ✅ Audit evidence considerations

---

## 📚 Related Resources

- [Azure Verified Modules (AVM)](https://aka.ms/avm)
- [Bicep Language Reference](https://learn.microsoft.com/azure/azure-resource-manager/bicep/file)
- [Bicep Best Practices](https://learn.microsoft.com/azure/azure-resource-manager/bicep/best-practices)
- [Bicep Functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure Resource Reference](https://learn.microsoft.com/azure/templates/)
- [Azure Naming Conventions](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)

---

**Last Updated**: November 2025  
**Agent Version**: 1.0
