# Azure Arc Architecture

## Solution Architecture Overview

This document describes the Azure Arc hybrid cloud architecture for GlobalManu Corp's 500-server onboarding project.

---

## High-Level Architecture

```mermaid
graph TB
    subgraph "Azure Cloud"
        ARC[Azure Arc Service]
        AAD[Azure AD]
        RM[Azure Resource Manager]
        POL[Azure Policy]
        MON[Azure Monitor]
        LA[Log Analytics Workspace]
        SEC[Azure Security Center]
        KV[Azure Key Vault]
    end
    
    subgraph "On-Premises - 12 Facilities"
        subgraph "Facility 1-12"
            WIN[Windows Servers<br/>320 servers]
            LIN[Linux Servers<br/>180 servers]
            AGENT1[Arc Agent]
            AGENT2[Arc Agent]
        end
        
        VPN[Site-to-Site VPN]
    end
    
    WIN --> AGENT1
    LIN --> AGENT2
    AGENT1 --> VPN
    AGENT2 --> VPN
    VPN --> ARC
    ARC --> RM
    ARC --> AAD
    ARC --> POL
    ARC --> MON
    MON --> LA
    ARC --> SEC
    
    style ARC fill:#0078d4,color:#fff
    style WIN fill:#00a4ef,color:#fff
    style LIN fill:#f7931e,color:#fff
```

---

## Azure Arc Agent Architecture

```mermaid
graph LR
    subgraph "On-Premises Server"
        OS[Operating System<br/>Windows/Linux]
        AGENT[Azure Arc<br/>Connected Machine Agent]
        AZCM[azcmagent Service]
        HIMDS[Hybrid Instance<br/>Metadata Service]
        EXT[Extension Manager]
    end
    
    subgraph "Azure Services"
        ARC[Azure Arc Service]
        ARM[Azure Resource Manager]
        AAD[Azure AD]
        EXTSVC[Extension Service]
    end
    
    OS --> AGENT
    AGENT --> AZCM
    AGENT --> HIMDS
    AGENT --> EXT
    
    AZCM -->|HTTPS 443<br/>TLS 1.2| ARC
    HIMDS -->|Local REST API| OS
    EXT -->|Download & Install| EXTSVC
    
    ARC --> ARM
    ARC --> AAD
    
    style AGENT fill:#0078d4,color:#fff
    style ARC fill:#0078d4,color:#fff
```

**Key Components**:

- **azcmagent**: Core service managing heartbeat, authentication, and extension management
- **Hybrid Instance Metadata Service (HIMDS)**: Local REST API endpoint (169.254.169.254) providing Azure metadata
- **Extension Manager**: Handles installation and lifecycle of Arc VM extensions
- **Azure Arc Service**: Cloud service managing Arc-enabled servers as ARM resources

---

## Network Architecture

```mermaid
graph TB
    subgraph "Azure - East US 2"
        ARCSVC[Arc Service<br/>*.his.arc.azure.com]
        ARMAGENT[ARM Agent Service<br/>*.guestconfiguration.azure.com]
        ARCDATA[Arc Data Service<br/>*.dp.kubernetesconfiguration.azure.com]
        DOWNLOAD[Download Service<br/>download.microsoft.com]
        LOGIN[Azure AD<br/>login.microsoftonline.com]
        MGMT[ARM Endpoint<br/>management.azure.com]
        LA[Log Analytics<br/>*.ods.opinsights.azure.com]
    end
    
    subgraph "Corporate Network"
        subgraph "Americas (5 facilities)"
            AM_VPN[VPN Gateway<br/>1 Gbps]
            AM_SERVERS[150 servers]
        end
        
        subgraph "EMEA (4 facilities)"
            EM_VPN[VPN Gateway<br/>500 Mbps]
            EM_SERVERS[200 servers]
        end
        
        subgraph "APAC (3 facilities)"
            AP_VPN[VPN Gateway<br/>100-500 Mbps]
            AP_SERVERS[150 servers]
        end
        
        PROXY[Corporate Proxy<br/>Optional]
    end
    
    AM_SERVERS --> AM_VPN
    EM_SERVERS --> EM_VPN
    AP_SERVERS --> AP_VPN
    
    AM_VPN --> PROXY
    EM_VPN --> PROXY
    AP_VPN --> PROXY
    
    PROXY -->|HTTPS 443| ARCSVC
    PROXY -->|HTTPS 443| ARMAGENT
    PROXY -->|HTTPS 443| ARCDATA
    PROXY -->|HTTPS 443| DOWNLOAD
    PROXY -->|HTTPS 443| LOGIN
    PROXY -->|HTTPS 443| MGMT
    PROXY -->|HTTPS 443| LA
    
    style PROXY fill:#ffa500,color:#000
    style ARCSVC fill:#0078d4,color:#fff
```

**Required Network Endpoints**:

| Service | Endpoint | Port | Purpose |
|---------|----------|------|---------|
| Azure Arc | `*.his.arc.azure.com` | 443 | Agent communication |
| Guest Configuration | `*.guestconfiguration.azure.com` | 443 | Policy enforcement |
| Kubernetes Configuration | `*.dp.kubernetesconfiguration.azure.com` | 443 | Extension management |
| Azure AD | `login.microsoftonline.com` | 443 | Authentication |
| ARM | `management.azure.com` | 443 | Resource management |
| Log Analytics | `*.ods.opinsights.azure.com` | 443 | Monitoring data |
| Download | `download.microsoft.com` | 443 | Agent updates |

**Network Requirements**:
- Outbound HTTPS (443) connectivity from servers to Azure endpoints
- Proxy support for environments with restricted internet access
- Minimum bandwidth: 100 Kbps per server (1.5 GB/month per server)
- VPN/ExpressRoute for hybrid connectivity

---

## Deployment Architecture

```mermaid
sequenceDiagram
    participant Admin as IT Administrator
    participant PS as PowerShell Script
    participant SP as Service Principal
    participant Server as Target Server
    participant Arc as Azure Arc Service
    participant ARM as Azure Resource Manager
    participant AAD as Azure AD
    
    Admin->>PS: Execute Install-ArcAgentParallel.ps1
    PS->>SP: Retrieve credentials from Key Vault
    PS->>Server: Connect via WinRM/SSH
    PS->>Server: Download Arc agent installer
    Server->>Server: Install azcmagent
    PS->>Server: Run: azcmagent connect
    Server->>AAD: Authenticate with Service Principal
    AAD->>Server: Return access token
    Server->>Arc: Register server with token
    Arc->>ARM: Create Connected Machine resource
    ARM->>Arc: Return resource ID
    Arc->>Server: Registration complete
    Server->>PS: Report success
    PS->>Admin: Display results
    
    Note over PS,Server: Parallel execution<br/>50 servers at once
```

**Deployment Flow**:

1. **Authentication**: Service Principal retrieves access token from Azure AD
2. **Download**: Arc agent installer downloaded from Microsoft CDN
3. **Installation**: Agent installed as system service (Windows) or daemon (Linux)
4. **Connection**: `azcmagent connect` registers server with Azure Arc
5. **Resource Creation**: Server appears as ARM resource in Azure Portal
6. **Extension Deployment**: Monitoring, policy, and security extensions installed
7. **Validation**: Health check confirms connectivity and extension status

---

## Governance Architecture

```mermaid
graph TB
    subgraph "Azure Policy"
        DEF1[Tagging Policy<br/>Enforce CostCenter, Owner, Environment]
        DEF2[Security Baseline<br/>Windows/Linux hardening]
        DEF3[Monitoring Policy<br/>Require Log Analytics agent]
        DEF4[Update Management<br/>Require Update extension]
    end
    
    subgraph "Management Groups"
        MG_ROOT[Root MG]
        MG_PROD[Production MG]
        MG_DEV[Dev/Test MG]
    end
    
    subgraph "Subscriptions"
        SUB_PROD[Production Subscription]
        SUB_DEV[Dev Subscription]
    end
    
    subgraph "Resource Groups"
        RG_AM[RG-Americas-Prod]
        RG_EM[RG-EMEA-Prod]
        RG_AP[RG-APAC-Prod]
    end
    
    subgraph "Arc-Enabled Servers"
        ARC1[Americas: 150 servers]
        ARC2[EMEA: 200 servers]
        ARC3[APAC: 150 servers]
    end
    
    DEF1 --> MG_ROOT
    DEF2 --> MG_ROOT
    DEF3 --> MG_PROD
    DEF4 --> MG_PROD
    
    MG_ROOT --> MG_PROD
    MG_ROOT --> MG_DEV
    
    MG_PROD --> SUB_PROD
    MG_DEV --> SUB_DEV
    
    SUB_PROD --> RG_AM
    SUB_PROD --> RG_EM
    SUB_PROD --> RG_AP
    
    RG_AM --> ARC1
    RG_EM --> ARC2
    RG_AP --> ARC3
    
    style DEF1 fill:#7fba00,color:#000
    style DEF2 fill:#7fba00,color:#000
    style DEF3 fill:#7fba00,color:#000
    style DEF4 fill:#7fba00,color:#000
```

**Policy Inheritance**:

- **Root Management Group**: Organization-wide policies (tagging, security baselines)
- **Production Management Group**: Production-specific policies (monitoring, updates)
- **Subscriptions**: Subscription-level policies and RBAC assignments
- **Resource Groups**: Regional groupings for Arc-enabled servers

**Azure Policy Definitions**:

| Policy | Scope | Effect | Purpose |
|--------|-------|--------|---------|
| Require tags | Root MG | Deny | Enforce CostCenter, Owner, Environment, Application tags |
| Windows security baseline | Root MG | DeployIfNotExists | Apply Windows Server hardening |
| Linux security baseline | Root MG | DeployIfNotExists | Apply Linux hardening |
| Configure Log Analytics | Prod MG | DeployIfNotExists | Install monitoring agent |
| Enable Update Management | Prod MG | DeployIfNotExists | Install update extension |
| Guest Configuration | Root MG | AuditIfNotExists | Check configuration compliance |

---

## Monitoring Architecture

```mermaid
graph TB
    subgraph "Arc-Enabled Servers"
        WIN_SERVERS[Windows Servers<br/>320 servers]
        LIN_SERVERS[Linux Servers<br/>180 servers]
        
        AMA_WIN[Azure Monitor Agent<br/>Windows]
        AMA_LIN[Azure Monitor Agent<br/>Linux]
    end
    
    subgraph "Azure Monitor"
        DCR[Data Collection Rules]
        LA[Log Analytics Workspace<br/>GlobalManuCorp-LA]
        
        PERF[Performance Data<br/>CPU, Memory, Disk, Network]
        LOGS[System Logs<br/>Security, Application, System]
        EVENTS[Custom Events<br/>MES, ERP, IoT]
    end
    
    subgraph "Alerting & Visualization"
        ALERTS[Azure Monitor Alerts]
        WORKBOOKS[Azure Workbooks<br/>Operational Dashboards]
        DEFENDS[Microsoft Defender<br/>Security Alerts]
    end
    
    WIN_SERVERS --> AMA_WIN
    LIN_SERVERS --> AMA_LIN
    
    AMA_WIN --> DCR
    AMA_LIN --> DCR
    
    DCR --> LA
    
    LA --> PERF
    LA --> LOGS
    LA --> EVENTS
    
    LA --> ALERTS
    LA --> WORKBOOKS
    LA --> DEFENDS
    
    style LA fill:#0078d4,color:#fff
    style ALERTS fill:#ff8c00,color:#000
    style DEFENDS fill:#d13438,color:#fff
```

**Data Collection**:

**Performance Metrics** (collected every 60 seconds):
- CPU utilization (total, per-core)
- Memory (available, used, percentage)
- Disk I/O (read/write bytes, IOPS)
- Network (bytes sent/received, errors)

**Log Collection**:
- **Windows**: Security, Application, System event logs
- **Linux**: Syslog (auth, daemon, kern, user)
- **Custom**: Application-specific logs (MES, ERP, IoT collectors)

**Data Collection Rules**:
- **DCR-Production-Windows**: Windows Server performance + Security/System logs
- **DCR-Production-Linux**: Linux performance + Syslog
- **DCR-Custom-Applications**: Application-specific log files

**Alerting Examples**:
- High CPU: > 90% for 10 minutes
- Low memory: < 10% available for 5 minutes
- Disk space: < 10% free
- Arc agent disconnected: No heartbeat for 15 minutes
- Security: Failed logon attempts > 10 in 5 minutes

---

## Security Architecture

```mermaid
graph TB
    subgraph "Identity & Access"
        AAD[Azure AD]
        SP[Service Principal<br/>Arc-Onboarding-SP]
        RBAC1[Azure Connected Machine<br/>Onboarding Role]
        RBAC2[Log Analytics<br/>Contributor]
        MI[Managed Identity<br/>Per Arc Server]
    end
    
    subgraph "Secret Management"
        KV[Azure Key Vault<br/>GlobalManu-Secrets]
        SECRET[SP Credentials]
        CERT[Certificates]
    end
    
    subgraph "Security Services"
        DEFENDS[Microsoft Defender<br/>for Servers]
        VULN[Vulnerability Assessment]
        UPDATE[Update Management]
        CHANGE[Change Tracking]
    end
    
    subgraph "Network Security"
        NSG[Network Security Groups]
        FW[Azure Firewall]
        PROXY[Corporate Proxy]
    end
    
    SP --> RBAC1
    SP --> RBAC2
    SP --> AAD
    
    SP --> SECRET
    SECRET --> KV
    CERT --> KV
    
    MI --> AAD
    MI --> KV
    
    DEFENDS --> VULN
    DEFENDS --> UPDATE
    DEFENDS --> CHANGE
    
    style KV fill:#ffb900,color:#000
    style DEFENDS fill:#d13438,color:#fff
    style AAD fill:#0078d4,color:#fff
```

**Security Components**:

**Identity & Access Management**:
- **Service Principal**: Least-privilege SP for Arc onboarding
  - Role: Azure Connected Machine Onboarding (subscription scope)
  - Role: Log Analytics Contributor (workspace scope)
- **Managed Identity**: Each Arc server gets system-assigned managed identity
- **RBAC**: Role assignments at subscription, resource group, resource levels

**Secret Management**:
- **Azure Key Vault**: Centralized secret storage
  - Service Principal credentials (expires every 90 days)
  - Certificates for TLS mutual authentication
  - Access policies restrict retrieval to authorized identities

**Security Services**:
- **Microsoft Defender for Servers**: 
  - Vulnerability assessment scanning
  - Just-in-time VM access
  - File integrity monitoring
  - Adaptive application controls
- **Update Management**: Automated patching compliance
- **Change Tracking**: Configuration change detection

**Network Security**:
- All communication over TLS 1.2+
- Outbound-only connectivity (no inbound ports opened)
- Corporate proxy for internet access control
- NSGs on Azure VNet subnets (future ExpressRoute)

---

## Disaster Recovery & High Availability

```mermaid
graph LR
    subgraph "Regional Architecture"
        PRIMARY[Primary Region<br/>East US 2<br/>Log Analytics<br/>Azure Arc Service]
        SECONDARY[Secondary Region<br/>West US 2<br/>Log Analytics (DR)<br/>Azure Arc Service]
    end
    
    subgraph "On-Premises"
        SERVERS[500 Arc-Enabled<br/>Servers]
    end
    
    SERVERS -->|Primary Connection| PRIMARY
    SERVERS -.->|Failover Connection| SECONDARY
    
    PRIMARY -.->|Geo-Replication| SECONDARY
    
    style PRIMARY fill:#00a4ef,color:#fff
    style SECONDARY fill:#0078d4,color:#fff
```

**High Availability**:

- **Azure Arc Service**: Built-in 99.9% SLA, multi-region availability
- **Log Analytics Workspace**: Data replication within region
- **Agent Resilience**: 
  - Local buffering of telemetry (up to 24 hours)
  - Automatic reconnection after network outages
  - Retry logic with exponential backoff

**Disaster Recovery**:

- **Backup Log Analytics Workspace**: Geo-redundant workspace in secondary region
- **Policy Definitions**: Stored in ARM (automatically replicated)
- **Arc Agent Reinstall**: Scripts and documentation for rapid re-onboarding
- **RTO/RPO**: 
  - Agent reconnection: < 15 minutes
  - Full workspace failover: < 4 hours
  - Data loss: < 1 hour (buffered telemetry)

---

## Scalability Considerations

**Current Scale**:
- 500 servers across 12 facilities
- 320 Windows + 180 Linux
- 3 Azure subscriptions

**Future Scale Targets**:
- 2,000 servers (planned server expansion)
- 5 additional facilities (global growth)
- Multi-cloud (AWS/GCP hybrid in roadmap)

**Scaling Strategies**:

| Component | Current | Max Capacity | Scaling Method |
|-----------|---------|--------------|----------------|
| Arc Service | 500 servers | 5,000/subscription | Additional subscriptions |
| Log Analytics Workspace | 500 servers, ~50 GB/day | 2,000 GB/day | Data capping, multiple workspaces |
| Parallel Deployment | 50 concurrent | 200 concurrent | Increase PowerShell runspaces |
| Policy Assignments | 10 policies | 200 policies/scope | Management group hierarchy |
| Service Principal | 1 SP | 1 SP/subscription | Subscription separation |

---

## Cost Architecture

```mermaid
graph TB
    subgraph "Azure Costs"
        ARC_FREE[Arc Connectivity<br/>$0/server]
        DEFENDER[Defender for Servers<br/>$5/server/month<br/>$2,500/month]
        LA_INGEST[Log Analytics Ingestion<br/>~50 GB/day<br/>$2.30/GB<br/>$3,450/month]
        LA_RETENTION[Log Analytics Retention<br/>90 days free<br/>$0.10/GB after<br/>$500/month estimate]
        STORAGE[Diagnostic Storage<br/>$0.02/GB<br/>$50/month]
    end
    
    subgraph "Total Monthly Cost"
        TOTAL[$6,500/month<br/>$78,000/year]
    end
    
    ARC_FREE --> TOTAL
    DEFENDER --> TOTAL
    LA_INGEST --> TOTAL
    LA_RETENTION --> TOTAL
    STORAGE --> TOTAL
    
    style TOTAL fill:#7fba00,color:#000
```

**Cost Breakdown**:

| Service | Unit Cost | Quantity | Monthly | Annual |
|---------|-----------|----------|---------|--------|
| Arc Connectivity | $0 | 500 servers | $0 | $0 |
| Defender for Servers | $5/server | 500 servers | $2,500 | $30,000 |
| Log Analytics Ingestion | $2.30/GB | 1,500 GB | $3,450 | $41,400 |
| Log Analytics Retention | $0.10/GB | 5,000 GB | $500 | $6,000 |
| Storage (Diagnostics) | $0.02/GB | 2,500 GB | $50 | $600 |
| **Total** | - | - | **$6,500** | **$78,000** |

**Cost Optimization**:
- Use data collection rules to filter unnecessary logs
- Set retention policies based on compliance requirements (31/90/365 days)
- Leverage commitment tiers for Log Analytics (save 15-30%)
- Right-size Defender coverage (exclude non-critical servers)
- Monitor with Azure Cost Management + Budgets

**ROI Comparison**:
- Azure costs: $78,000/year
- Operational savings: $300,000+/year
- **Net savings: $222,000+/year**

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Hybrid Connectivity** | Azure Arc Connected Machine Agent | Server onboarding to Azure |
| **Identity** | Azure AD, Service Principal, Managed Identity | Authentication and authorization |
| **Governance** | Azure Policy, Guest Configuration | Compliance and configuration management |
| **Monitoring** | Azure Monitor, Log Analytics, Azure Monitor Agent | Telemetry and observability |
| **Security** | Microsoft Defender for Servers, Update Management | Vulnerability and patch management |
| **Automation** | PowerShell 7.x, Azure CLI, Azure Automation | Deployment and operations |
| **Secret Management** | Azure Key Vault | Credential storage |
| **Networking** | Site-to-Site VPN, Corporate Proxy | Hybrid connectivity |

---

## Deployment Tooling

**Infrastructure as Code**:
- **PowerShell Scripts**: Agent deployment, policy configuration, monitoring setup
- **Azure Bicep** (future): Policy definitions, RBAC assignments, workspaces
- **ARM Templates** (legacy): Extension deployments

**Automation Platform**:
- **Local Execution**: PowerShell scripts run from jump box
- **Azure Automation** (future): Scheduled runs, runbook execution
- **GitHub Actions** (future): CI/CD for policy updates

**Version Control**:
- **GitHub Repository**: All scripts, documentation, IaC stored in Git
- **Branching Strategy**: Main (production), develop (testing), feature branches

---

## Integration Points

**Existing Systems**:
- **SCCM**: Phased decommissioning, coordinate with Arc Update Management
- **Ansible**: Continue for configuration management, integrate with Arc Guest Configuration
- **Monitoring Tools**: Migrate from Nagios/Zabbix to Azure Monitor over 6 months
- **ServiceNow**: ITSM integration via Azure Monitor alerts (webhook)

**Future Integrations**:
- **Azure Sentinel**: SIEM integration for security analytics
- **Azure Automation**: Runbook execution for remediation
- **Azure DevOps**: CI/CD pipelines for policy updates
- **Power BI**: Custom reporting dashboards

---

**Architecture Version**: 1.0  
**Last Updated**: November 2025  
**Owner**: Cloud Infrastructure Team
