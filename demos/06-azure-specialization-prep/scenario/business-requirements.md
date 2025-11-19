# Business Requirements: Enterprise Task Manager Migration

## 🏢 Customer Profile

**Company**: Contoso Manufacturing Inc.  
**Industry**: Manufacturing & Supply Chain  
**Size**: 500 employees, $50M annual revenue  
**Location**: United States (primary), Europe (secondary)

## 📋 Project Overview

Contoso Manufacturing is migrating their on-premises Task Manager application to Azure as part of their cloud adoption strategy. This application is critical for daily operations, tracking work orders, maintenance tasks, and project assignments across multiple facilities.

### Current State (On-Premises)

- **Application**: ASP.NET web application on IIS 8.5
- **Infrastructure**:
  - 2 Windows Server 2012 R2 servers (no load balancing)
  - Manual failover process
  - SQL Server 2014 Standard on dedicated hardware
- **Performance**:
  - 80-100 transactions per second during peak hours
  - 500 concurrent users
  - 2GB database size
- **Availability**:
  - Current SLA: 99.5% (43 hours downtime/year)
  - Maintenance windows: 4 hours/month
  - Manual backups daily

### Pain Points

1. ❌ **Unreliable**: Frequent unplanned downtime affecting operations
2. ❌ **Manual processes**: Server patching requires 4-hour maintenance windows
3. ❌ **No disaster recovery**: Data loss risk, no geographic redundancy
4. ❌ **Outdated**: Windows Server 2012 R2 and SQL Server 2014 nearing end-of-life
5. ❌ **Limited scalability**: Cannot handle seasonal demand spikes
6. ❌ **Security concerns**: Aging OS, limited security controls

## 🎯 Business Objectives

### Primary Goals

1. **Improve Availability**: Achieve 99.99% uptime SLA (52 minutes downtime/year)
2. **Modernize Platform**: Move to current Azure services with automatic patching
3. **Enhance Security**: Implement Azure security best practices and controls
4. **Reduce Maintenance**: Eliminate manual maintenance windows
5. **Enable Scalability**: Support future growth and seasonal demand

### Success Criteria

- ✅ Deploy highly available infrastructure in Azure
- ✅ Achieve 99.99% availability target
- ✅ Support 100 transactions per second (20% growth buffer)
- ✅ Implement automated backups and disaster recovery
- ✅ Pass Azure Infrastructure and Database Migration Specialization audit
- ✅ Complete migration within 8-week timeline
- ✅ Zero data loss during migration

## 📊 Technical Requirements

### Performance Requirements

| Metric | Requirement | Measurement |
|--------|-------------|-------------|
| **Transactions/Second** | 100 TPS | Sustained during peak hours |
| **Response Time** | < 2 seconds | 95th percentile |
| **Concurrent Users** | 500 users | Simultaneous connections |
| **Database Size** | 2-5 GB | Current + 3-year growth |
| **Page Load Time** | < 3 seconds | First contentful paint |

### Availability Requirements

| Component | SLA Target | Implementation |
|-----------|------------|----------------|
| **Overall Application** | 99.99% | Load balanced VMs + Azure SQL |
| **Web Tier** | 99.95% | 2+ VMs across availability zones |
| **Database Tier** | 99.99% | Azure SQL Database (Standard/Premium) |
| **Load Balancer** | 99.99% | Azure Load Balancer |
| **Backup Retention** | 30 days | Automated daily backups |

### Security Requirements

#### Must Have

- 🔐 **Network Security**: Network Security Groups (NSGs) on all subnets
- 🔐 **Database Security**: Azure SQL firewall rules, TDE encryption at rest
- 🔐 **Identity**: Azure AD integration for administrative access
- 🔐 **Encryption**: TLS 1.2+ for all connections
- 🔐 **Monitoring**: Azure Monitor for security alerts
- 🔐 **Compliance**: Audit logging enabled on all resources

#### Nice to Have (Not Required for Demo)

- Private endpoints for Azure SQL (adds complexity for demo)
- Azure Bastion for VM access
- Key Vault for secrets management
- DDoS Protection Standard

### Scalability Requirements

- **Vertical Scaling**: Support VM size changes without downtime
- **Horizontal Scaling**: Manual scale-out capability (2-4 VMs)
- **Database Scaling**: Ability to increase DTUs/vCores as needed
- **Future Considerations**: Prepare for auto-scaling in future phase

## 🏗️ Infrastructure Requirements

### Compute

- **VM Size**: Standard_D2s_v3 or equivalent
  - 2 vCPUs, 8 GB RAM
  - Windows Server 2022 Datacenter
  - IIS 10 with ASP.NET 4.8
- **VM Count**: 2 VMs for high availability
- **Deployment**: Availability Set or Availability Zones
- **Disk**: Premium SSD for OS disk (P10, 128 GB)

### Networking

- **Virtual Network**: /16 CIDR block
- **Subnets**:
  - Web tier subnet: /24 (for VMs)
  - Database subnet: /24 (for future private endpoints)
- **Load Balancer**: Standard SKU with public IP
- **NSG Rules**: Allow HTTP/HTTPS from internet, RDP from approved IPs

### Database

- **Service**: Azure SQL Database
- **Tier**: Standard S2 (50 DTUs) or General Purpose 2 vCores
- **Size**: 10 GB initial allocation
- **Backup**:
  - Point-in-time restore: 7 days
  - Long-term retention: 30 days
- **Geo-replication**: Optional for future phase

### Naming Convention

Following Azure naming best practices:

- Resource Group: `rg-audit-demo-prod`
- Virtual Network: `vnet-prod-taskmanager-eastus`
- Subnets: `snet-web-prod`, `snet-data-prod`
- VMs: `vm-web01-prod`, `vm-web02-prod`
- Load Balancer: `lb-web-prod`
- SQL Server: `sql-taskmanager-prod-<random>`
- SQL Database: `sqldb-taskmanager-prod`

### Tags

All resources must include:

```bicep
tags: {
  Environment: 'Production'
  Project: 'Task Manager Migration'
  Owner: 'IT Operations'
  CostCenter: 'IT-Operations'
  ManagedBy: 'Bicep'
  BusinessUnit: 'Manufacturing'
  Criticality: 'High'
  SLA: '99.99%'
  AuditRequired: 'Yes'
}
```

## 📅 Project Timeline

### Phase 1: Assessment (Week 1-2)

- Workload assessment with Azure Migrate
- Dependency mapping
- Performance baseline
- Risk assessment

### Phase 2: Design (Week 2-4)

- Architecture design using agents
- Well-Architected Framework review
- Security design
- Network topology planning

### Phase 3: Deployment (Week 4-6)

- Infrastructure provisioning with Bicep
- Application deployment and configuration
- Load balancer setup
- Database migration

### Phase 4: Testing & Validation (Week 6-7)

- Performance testing (100 TPS validation)
- High availability testing
- Disaster recovery testing
- Security validation

### Phase 5: Cutover (Week 8)

- Final data sync
- DNS cutover
- Production monitoring
- Post-deployment documentation

## 📚 Audit Evidence Requirements

This project must generate documentation for:

### Module A: Azure Essentials Cloud Foundation

- **Control 1.1**: Business strategy assessment (Cloud Adoption Strategy Evaluator, FinOps Review)
- **Control 2.1**: Security baseline (Microsoft Defender for Cloud, Security Review)
- **Control 2.2**: Well-Architected Review (assessment output)
- **Control 3.1**: Azure Landing Zone deployment (Bicep templates, ALZ Review)
- **Control 3.2**: Skilling plan for Contoso IT team
- **Control 3.3**: Operations management (Azure Monitor configuration)

### Module B: Infrastructure and Database Migration

- **Control 1.1**: Workload assessment (Azure Migrate reports)
- **Control 2.1**: Solution design (architecture diagrams, design docs)
- **Control 2.2**: Well-Architected Review (pillar assessments)
- **Control 3.1**: Infrastructure deployment (Bicep templates, deployment logs)
- **Control 3.2**: Database migration (migration tool outputs)
- **Control 3.3**: Migration tools (Azure Migrate, Database Migration Service)
- **Control 3.4**: Automated deployment (CI/CD pipeline with Bicep)
- **Control 4.1**: Service validation (testing reports, performance validation)
- **Control 4.2**: Post-deployment documentation (runbooks, SOPs)

## 💰 Cost Estimate

### Monthly Azure Costs (East US region)

| Service | SKU/Size | Quantity | Monthly Cost |
|---------|----------|----------|--------------|
| **VMs** | Standard_D2s_v3 | 2 | $140 |
| **Disks** | Premium SSD P10 | 2 | $30 |
| **Load Balancer** | Standard | 1 | $20 |
| **Public IP** | Static | 1 | $4 |
| **Azure SQL** | Standard S2 | 1 | $150 |
| **Bandwidth** | Outbound | ~100 GB | $10 |
| **Azure Monitor** | Logs & Metrics | 1 | $20 |
| **Total** | | | **~$374/month** |

**Annual Cost**: ~$4,488  
**On-Premises Equivalent**: ~$15,000/year (hardware, licenses, maintenance)  
**Annual Savings**: ~$10,512 (70% cost reduction)

## 🎓 Skills Development

Contoso IT team will need training on:

- Azure fundamentals and portal navigation
- Azure Virtual Machines management
- Azure SQL Database administration
- Azure Monitor and diagnostics
- Infrastructure as Code (Bicep)
- Azure security best practices
- High availability patterns in Azure

**Recommended Certifications**:

- AZ-900: Azure Fundamentals
- AZ-104: Azure Administrator
- AZ-305: Azure Solutions Architect

## ✅ Acceptance Criteria

The project will be considered successful when:

1. ✅ Application deployed and accessible via load balancer public IP
2. ✅ 99.99% availability achieved over 30-day period
3. ✅ Performance tests show sustained 100+ TPS
4. ✅ All security controls implemented and validated
5. ✅ Automated backups configured and tested
6. ✅ Disaster recovery procedures documented and tested
7. ✅ Complete audit evidence package generated
8. ✅ IT team trained on Azure operations
9. ✅ Customer sign-off received
10. ✅ All documentation delivered

---

**Document Owner**: Azure Solutions Architect  
**Last Updated**: November 2025  
**Version**: 1.0
