# S05 Service Validation - Architecture

## Logical Architecture

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TB
    subgraph "Azure Subscription"
        subgraph "Resource Group: rg-s05-validation-swc01"
            subgraph "Compute Tier"
                ASP[App Service Plan<br/>plan-saif-api-swc01<br/>Premium P1v3]
                API[App Service: app-saifv2-api-xxx<br/>Python 3.11 FastAPI<br/>Managed Identity Enabled]
                WEB[App Service: app-saifv2-web-xxx<br/>Static Frontend<br/>Managed Identity Enabled]
            end
            
            subgraph "Data Tier"
                SQL_SRV[SQL Server<br/>sql-saif-swc01-xxx<br/>Entra ID Admin Only]
                SQL_DB[SQL Database<br/>sqldb-saif-swc01<br/>Basic Tier]
            end
            
            subgraph "Container Registry"
                ACR[Azure Container Registry<br/>acrsaifxxx<br/>Premium Tier<br/>Zone Redundant]
            end
            
            subgraph "Monitoring"
                LOGS[Log Analytics Workspace<br/>log-saif-swc01]
                AI[Application Insights<br/>appi-saif-swc01]
            end
        end
    end
    
    Internet((Internet<br/>Users)) -->|HTTPS 443| WEB
    WEB -->|API Calls| API
    API -->|Entra ID Auth| SQL_DB
    SQL_SRV --> SQL_DB
    API -->|Pull Images| ACR
    WEB -->|Pull Images| ACR
    API -->|Telemetry| AI
    WEB -->|Telemetry| AI
    AI --> LOGS
    
    style Internet fill:#FF6B6B,stroke:#C92A2A,color:#fff
    style ASP fill:#00BCF2,stroke:#0078D4,color:#000
    style API fill:#4ECDC4,stroke:#2C7873,color:#000
    style WEB fill:#A8DADC,stroke:#457B9D,color:#000
    style SQL_SRV fill:#FFA94D,stroke:#F76707,color:#000
    style SQL_DB fill:#FFD43B,stroke:#F59F00,color:#000
    style ACR fill:#845EF7,stroke:#5F3DC4,color:#fff
    style LOGS fill:#51CF66,stroke:#2F9E44,color:#000
    style AI fill:#339AF0,stroke:#1971C2,color:#fff
```

## Application Architecture

### Request Flow

```mermaid
%%{init: {'theme':'neutral'}}%%
sequenceDiagram
    participant User
    participant AppService as App Service<br/>(API)
    participant ManagedID as Managed<br/>Identity
    participant SQL as Azure SQL<br/>Database
    participant AppInsights as Application<br/>Insights
    
    User->>AppService: GET /api/sqlwhoami
    AppService->>ManagedID: Request Access Token
    ManagedID-->>AppService: Token (Entra ID)
    AppService->>SQL: Query with Token Auth
    SQL-->>AppService: Query Result
    AppService->>AppInsights: Log Request
    AppService-->>User: JSON Response
    
    Note over AppService,SQL: No connection strings<br/>Zero secrets in config
```

### API Endpoints

```mermaid
%%{init: {'theme':'neutral'}}%%
graph LR
    subgraph "API Endpoints"
        ROOT[GET /<br/>Health Check]
        VER[GET /api/version<br/>Version Info]
        WHO[GET /api/whoami<br/>Identity Info]
        IP[GET /api/sourceip<br/>Client IP]
        SQLWHO[GET /api/sqlwhoami<br/>SQL Identity]
        SQLIP[GET /api/sqlsrcip<br/>SQL Connection]
    end
    
    subgraph "Response Types"
        ROOT --> JSON1[JSON: app_name, version, status]
        VER --> JSON2[JSON: version, build, commit]
        WHO --> JSON3[JSON: mi_name, client_id]
        IP --> JSON4[JSON: source_ip, headers]
        SQLWHO --> JSON5[JSON: sql_user, auth_type]
        SQLIP --> JSON6[JSON: sql_ip, connection_info]
    end
    
    style ROOT fill:#4ECDC4,stroke:#2C7873,color:#000
    style VER fill:#4ECDC4,stroke:#2C7873,color:#000
    style WHO fill:#FFD43B,stroke:#F59F00,color:#000
    style IP fill:#FFD43B,stroke:#F59F00,color:#000
    style SQLWHO fill:#FFA94D,stroke:#F76707,color:#000
    style SQLIP fill:#FFA94D,stroke:#F76707,color:#000
```

## Security Architecture

### Authentication Flow

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TB
    subgraph "Managed Identity Flow"
        APP[App Service]
        IMDS[Azure Instance<br/>Metadata Service]
        ENTRA[Microsoft Entra ID]
        SQL[Azure SQL]
        
        APP -->|1. Request Token| IMDS
        IMDS -->|2. Authenticate| ENTRA
        ENTRA -->|3. Issue Token| IMDS
        IMDS -->|4. Return Token| APP
        APP -->|5. Connect with Token| SQL
        SQL -->|6. Validate Token| ENTRA
        ENTRA -->|7. Allow Access| SQL
    end
    
    style APP fill:#4ECDC4,stroke:#2C7873,color:#000
    style IMDS fill:#A8DADC,stroke:#457B9D,color:#000
    style ENTRA fill:#00BCF2,stroke:#0078D4,color:#000
    style SQL fill:#FFD43B,stroke:#F59F00,color:#000
```

### Security Controls

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TB
    subgraph "Defense in Depth"
        L1[Layer 1: HTTPS Only<br/>TLS 1.2 Minimum]
        L2[Layer 2: Managed Identity<br/>No Connection Strings]
        L3[Layer 3: Entra ID Auth<br/>No SQL Username/Password]
        L4[Layer 4: RBAC<br/>Least Privilege Access]
        L5[Layer 5: Application Insights<br/>Security Monitoring]
        L6[Layer 6: Audit Logs<br/>Compliance Evidence]
    end
    
    L1 --> L2 --> L3 --> L4 --> L5 --> L6
    
    style L1 fill:#FFE66D,stroke:#C7A800,color:#000
    style L2 fill:#A8DADC,stroke:#457B9D,color:#000
    style L3 fill:#4ECDC4,stroke:#2C7873,color:#000
    style L4 fill:#45B7D1,stroke:#2E86AB,color:#fff
    style L5 fill:#5F27CD,stroke:#341F97,color:#fff
    style L6 fill:#0078D4,stroke:#004578,color:#fff
```

## Validation & Testing Architecture

### Testing Workflow

```mermaid
%%{init: {'theme':'neutral'}}%%
graph LR
    subgraph "Pre-Deployment"
        BUILD[Container<br/>Build]
        PUSH[ACR<br/>Push]
        BICEP[Infrastructure<br/>Deployment]
    end
    
    subgraph "Post-Deployment Validation"
        API_TEST[API Endpoint<br/>Testing]
        LOAD_TEST[Load Testing<br/>quick-load-test.sh]
        PERF_BASE[Performance<br/>Baseline]
    end
    
    subgraph "Results"
        REPORT[Test Report<br/>Generation]
        AUDIT[Audit Evidence<br/>Export]
    end
    
    BUILD --> PUSH --> BICEP
    BICEP --> API_TEST
    API_TEST --> LOAD_TEST
    LOAD_TEST --> PERF_BASE
    PERF_BASE --> REPORT
    REPORT --> AUDIT
    
    style BUILD fill:#845EF7,stroke:#5F3DC4,color:#fff
    style PUSH fill:#845EF7,stroke:#5F3DC4,color:#fff
    style BICEP fill:#00BCF2,stroke:#0078D4,color:#000
    style API_TEST fill:#4ECDC4,stroke:#2C7873,color:#000
    style LOAD_TEST fill:#FFA94D,stroke:#F76707,color:#000
    style PERF_BASE fill:#FFD43B,stroke:#F59F00,color:#000
    style REPORT fill:#51CF66,stroke:#2F9E44,color:#000
    style AUDIT fill:#339AF0,stroke:#1971C2,color:#fff
```

### Load Testing Flow

```mermaid
%%{init: {'theme':'neutral'}}%%
sequenceDiagram
    participant Test as quick-load-test.sh
    participant API as App Service API
    participant SQL as Azure SQL
    participant AI as Application<br/>Insights
    
    loop 30 seconds, 20 concurrent requests
        Test->>API: GET / (Health Check)
        API-->>Test: 200 OK
        Test->>API: GET /api/version
        API-->>Test: 200 OK
        Test->>API: GET /api/sqlwhoami
        API->>SQL: Query with MI Token
        SQL-->>API: Result
        API-->>Test: 200 OK
        API->>AI: Log Metrics
    end
    
    Test->>Test: Calculate Statistics
    Test->>Test: Export Results
    
    Note over Test: Success Rate: 99.6%<br/>Avg Response: 145ms<br/>RPS: 41.5
```

## CI/CD Integration

### Pipeline Architecture

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TB
    subgraph "Source Control"
        GIT[GitHub Repository]
    end
    
    subgraph "Build Stage"
        BUILD_API[Build API Container]
        BUILD_WEB[Build Web Container]
        SCAN[Security Scan<br/>Trivy/Checkov]
    end
    
    subgraph "Deploy Stage"
        DEPLOY_INFRA[Deploy Bicep]
        DEPLOY_APP[Deploy Containers]
    end
    
    subgraph "Validation Stage"
        API_VAL[API Validation]
        LOAD_VAL[Load Testing]
        REPORT_VAL[Report Generation]
    end
    
    subgraph "Notification"
        SUCCESS[✅ Success<br/>Slack/Email]
        FAIL[❌ Failure<br/>Slack/Email]
    end
    
    GIT --> BUILD_API
    GIT --> BUILD_WEB
    BUILD_API --> SCAN
    BUILD_WEB --> SCAN
    SCAN --> DEPLOY_INFRA
    DEPLOY_INFRA --> DEPLOY_APP
    DEPLOY_APP --> API_VAL
    API_VAL --> LOAD_VAL
    LOAD_VAL --> REPORT_VAL
    REPORT_VAL -->|Pass| SUCCESS
    REPORT_VAL -->|Fail| FAIL
    
    style GIT fill:#24292E,stroke:#000,color:#fff
    style BUILD_API fill:#845EF7,stroke:#5F3DC4,color:#fff
    style BUILD_WEB fill:#845EF7,stroke:#5F3DC4,color:#fff
    style SCAN fill:#FFA94D,stroke:#F76707,color:#000
    style DEPLOY_INFRA fill:#00BCF2,stroke:#0078D4,color:#000
    style DEPLOY_APP fill:#4ECDC4,stroke:#2C7873,color:#000
    style API_VAL fill:#FFD43B,stroke:#F59F00,color:#000
    style LOAD_VAL fill:#FFD43B,stroke:#F59F00,color:#000
    style REPORT_VAL fill:#51CF66,stroke:#2F9E44,color:#000
    style SUCCESS fill:#51CF66,stroke:#2F9E44,color:#000
    style FAIL fill:#FF6B6B,stroke:#C92A2A,color:#fff
```

## Resource Topology

### Resource Hierarchy

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TD
    SUB[Azure Subscription]
    
    SUB --> RG[Resource Group<br/>rg-s05-validation-swc01]
    
    RG --> ASP[App Service Plan<br/>plan-saif-api-swc01]
    RG --> API[App Service API<br/>app-saifv2-api-xxx]
    RG --> WEB[App Service Web<br/>app-saifv2-web-xxx]
    RG --> SQL_SRV[SQL Server<br/>sql-saif-swc01-xxx]
    RG --> SQL_DB[SQL Database<br/>sqldb-saif-swc01]
    RG --> ACR[Container Registry<br/>acrsaifxxx]
    RG --> LOGS[Log Analytics<br/>log-saif-swc01]
    RG --> AI[Application Insights<br/>appi-saif-swc01]
    
    ASP --> API
    ASP --> WEB
    SQL_SRV --> SQL_DB
    API -.Uses MI.-> SQL_DB
    API -.Pulls from.-> ACR
    WEB -.Pulls from.-> ACR
    API -.Logs to.-> AI
    WEB -.Logs to.-> AI
    AI --> LOGS
    
    style SUB fill:#E8F4F8,stroke:#0078D4,stroke-width:2px,color:#000
    style RG fill:#CCE5FF,stroke:#0078D4,color:#000
    style ASP fill:#00BCF2,stroke:#0078D4,color:#000
    style API fill:#4ECDC4,stroke:#2C7873,color:#000
    style WEB fill:#A8DADC,stroke:#457B9D,color:#000
    style SQL_SRV fill:#FFA94D,stroke:#F76707,color:#000
    style SQL_DB fill:#FFD43B,stroke:#F59F00,color:#000
    style ACR fill:#845EF7,stroke:#5F3DC4,color:#fff
    style LOGS fill:#51CF66,stroke:#2F9E44,color:#000
    style AI fill:#339AF0,stroke:#1971C2,color:#fff
```

## Deployment Validation

### Post-Deployment Checks

```mermaid
%%{init: {'theme':'neutral'}}%%
flowchart TD
    Start([Deploy Infrastructure]) --> Check1{All Resources<br/>Deployed?}
    Check1 -->|Yes| Check2{App Service<br/>Accessible?}
    Check1 -->|No| Fail1[❌ Deployment Failed]
    
    Check2 -->|Yes| Check3{SQL Connection<br/>Works?}
    Check2 -->|No| Fail2[❌ App Service Down]
    
    Check3 -->|Yes| Check4{All Endpoints<br/>Return 200?}
    Check3 -->|No| Fail3[❌ SQL Auth Failed]
    
    Check4 -->|Yes| Check5{Load Test<br/>Passes?}
    Check4 -->|No| Fail4[❌ API Errors]
    
    Check5 -->|Yes| Check6{Performance<br/>Meets Baseline?}
    Check5 -->|No| Fail5[❌ Load Test Failed]
    
    Check6 -->|Yes| Success[✅ Validation Complete]
    Check6 -->|No| Fail6[❌ Performance Below Target]
    
    style Start fill:#E8F4F8,stroke:#0078D4,color:#000
    style Success fill:#51CF66,stroke:#2F9E44,color:#000
    style Fail1 fill:#FF6B6B,stroke:#C92A2A,color:#fff
    style Fail2 fill:#FF6B6B,stroke:#C92A2A,color:#fff
    style Fail3 fill:#FF6B6B,stroke:#C92A2A,color:#fff
    style Fail4 fill:#FF6B6B,stroke:#C92A2A,color:#fff
    style Fail5 fill:#FF6B6B,stroke:#C92A2A,color:#fff
    style Fail6 fill:#FF6B6B,stroke:#C92A2A,color:#fff
```

## Monitoring & Observability

### Telemetry Flow

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TB
    subgraph "Application Layer"
        API_APP[API Application]
        WEB_APP[Web Application]
    end
    
    subgraph "Collection Layer"
        AI_SDK[Application Insights SDK]
    end
    
    subgraph "Storage Layer"
        AI_SVC[Application Insights Service]
        LOGS_WS[Log Analytics Workspace]
    end
    
    subgraph "Analysis Layer"
        QUERIES[KQL Queries]
        WORKBOOKS[Azure Workbooks]
        ALERTS[Alert Rules]
    end
    
    API_APP -->|Requests, Dependencies| AI_SDK
    WEB_APP -->|Page Views, Events| AI_SDK
    AI_SDK --> AI_SVC
    AI_SVC --> LOGS_WS
    LOGS_WS --> QUERIES
    LOGS_WS --> WORKBOOKS
    LOGS_WS --> ALERTS
    
    style API_APP fill:#4ECDC4,stroke:#2C7873,color:#000
    style WEB_APP fill:#A8DADC,stroke:#457B9D,color:#000
    style AI_SDK fill:#FFD43B,stroke:#F59F00,color:#000
    style AI_SVC fill:#339AF0,stroke:#1971C2,color:#fff
    style LOGS_WS fill:#51CF66,stroke:#2F9E44,color:#000
    style QUERIES fill:#FFA94D,stroke:#F76707,color:#000
    style WORKBOOKS fill:#845EF7,stroke:#5F3DC4,color:#fff
    style ALERTS fill:#FF6B6B,stroke:#C92A2A,color:#fff
```

### Key Metrics

```mermaid
%%{init: {'theme':'neutral'}}%%
graph LR
    subgraph "Performance Metrics"
        RT[Response Time<br/>Target: < 500ms]
        RPS[Requests/Second<br/>Target: > 10]
        AVAIL[Availability<br/>Target: > 99%]
    end
    
    subgraph "Reliability Metrics"
        SR[Success Rate<br/>Target: > 99%]
        ER[Error Rate<br/>Target: < 1%]
        DEP[Dependency Health<br/>SQL Availability]
    end
    
    subgraph "Resource Metrics"
        CPU[CPU Usage<br/>Monitor: < 80%]
        MEM[Memory Usage<br/>Monitor: < 90%]
        CONN[SQL Connections<br/>Monitor Pool]
    end
    
    style RT fill:#4ECDC4,stroke:#2C7873,color:#000
    style RPS fill:#4ECDC4,stroke:#2C7873,color:#000
    style AVAIL fill:#4ECDC4,stroke:#2C7873,color:#000
    style SR fill:#FFD43B,stroke:#F59F00,color:#000
    style ER fill:#FFD43B,stroke:#F59F00,color:#000
    style DEP fill:#FFD43B,stroke:#F59F00,color:#000
    style CPU fill:#FFA94D,stroke:#F76707,color:#000
    style MEM fill:#FFA94D,stroke:#F76707,color:#000
    style CONN fill:#FFA94D,stroke:#F76707,color:#000
```

## Cost Projection

### Monthly Infrastructure Costs (Sweden Central)

| Resource | SKU/Tier | Quantity | Unit Cost | Monthly Cost |
|----------|----------|----------|-----------|--------------|
| **App Service Plan** | Premium P1v3 | 1 | ~$120 | **$120.00** |
| **SQL Database** | Basic (5 DTU) | 1 | ~$5 | **$5.00** |
| **SQL Server** | Logical Server | 1 | $0 | **$0.00** |
| **Container Registry** | Premium | 1 | ~$50 | **$50.00** |
| **Log Analytics** | Pay-as-you-go | 5 GB | $2.30/GB | **$11.50** |
| **Application Insights** | Enterprise | Included | $0 | **$0.00** |
| **Total** | - | - | - | **~$186.50/month** |

> **Cost Optimization Tips**:
>
> - Use **Basic SQL tier** for demos (reduces to $5/month)
> - Downgrade **ACR to Basic** tier for non-prod (reduces to $5/month)
> - Use **Standard App Service Plan** if zone redundancy not required (reduces to $75/month)
> - **Optimized Demo Cost**: ~$85/month

## Compliance Mapping

### Azure Infrastructure Specialization - Module B Control 4.1

| Control Requirement | Implementation | Evidence |
|---------------------|----------------|----------|
| **Service Validation** | Automated load testing | quick-load-test.sh results |
| **Performance Testing** | Baseline establishment | Performance reports |
| **API Testing** | Endpoint validation | Test execution logs |
| **Audit Evidence** | Timestamped logs | Exported test reports |
| **Repeatability** | CI/CD integration | Pipeline configurations |

### Security Compliance

| Standard | Requirement | Implementation |
|----------|-------------|----------------|
| **GDPR** | Data residency | Sweden Central (EU) |
| **HIPAA** | Encryption | TLS 1.2, AES-256 at rest |
| **SOC 2** | Access control | RBAC, Managed Identity |
| **Azure Security Benchmark** | Identity-based auth | No connection strings |

## Data Flow

### Read Operation

```mermaid
%%{init: {'theme':'neutral'}}%%
sequenceDiagram
    participant Client
    participant AppService as App Service
    participant MI as Managed Identity
    participant SQL as Azure SQL
    participant AppInsights as App Insights
    
    Client->>AppService: GET /api/sqlwhoami
    AppService->>MI: Acquire Token for SQL
    MI-->>AppService: Access Token
    AppService->>SQL: SELECT SYSTEM_USER (with token)
    SQL-->>AppService: Query Result
    AppService->>AppInsights: Log Request (success, 145ms)
    AppService-->>Client: 200 OK + JSON Response
```

### Write Operation (Future)

```mermaid
%%{init: {'theme':'neutral'}}%%
sequenceDiagram
    participant Client
    participant AppService as App Service
    participant MI as Managed Identity
    participant SQL as Azure SQL
    participant AppInsights as App Insights
    
    Client->>AppService: POST /api/data
    AppService->>MI: Acquire Token for SQL
    MI-->>AppService: Access Token
    AppService->>SQL: INSERT INTO table (with token)
    SQL-->>AppService: Rows Affected
    AppService->>AppInsights: Log Request (success, 187ms)
    AppService-->>Client: 201 Created + JSON Response
```

---

## Architecture Highlights

- 🔒 **Zero Secrets**: Managed Identity for all authentication (no connection strings)
- 📊 **Observable**: Application Insights + Log Analytics for full telemetry
- ✅ **Validated**: Automated load testing with performance baselines
- 🚀 **Scalable**: Premium App Service Plan with zone redundancy
- 💰 **Cost-Effective**: ~$186/month (optimized to ~$85/month for demo)
- 🛡️ **Secure**: Entra ID-only SQL auth, HTTPS enforcement, TLS 1.2+
- 📋 **Audit-Ready**: Complete evidence trail for Module B Control 4.1

[🏠 Back to Requirements](./requirements.md) | [📚 Back to Demo README](../README.md)
