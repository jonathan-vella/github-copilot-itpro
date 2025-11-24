# Effective Prompts: Azure Principal Architect Agent

## 🎯 Purpose

The Azure Principal Architect agent applies Azure Well-Architected Framework (WAF) best practices to assess architecture designs. This generates evidence for Module A Control 2.2 and Module B Control 2.2.

---

## 📝 Prompt Template

```yaml
Conduct a comprehensive Well-Architected Framework assessment for the following architecture:

**Infrastructure**:
[DESCRIBE ARCHITECTURE COMPONENTS]

**Requirements**:
[LIST KEY REQUIREMENTS]

Assess all five WAF pillars (Reliability, Security, Cost Optimization, Operational Excellence, 
Performance Efficiency) and provide specific recommendations with priority levels.
```

---

## ✅ Effective Prompts

### Prompt 1: Complete Architecture Assessment

```yaml
Conduct a comprehensive Well-Architected Framework assessment for the following architecture:

**Infrastructure**:
- 2 Windows Server 2022 VMs (Standard_D2s_v3) running IIS with ASP.NET application
- Azure Load Balancer (Standard SKU) with public IP for high availability
- Azure SQL Database (Standard S2 tier, 50 DTUs, 10 GB)
- Virtual Network with two subnets (web tier, data tier)
- Network Security Groups on both subnets
- Azure Monitor with Log Analytics workspace
- Azure Backup for VM disk backups

**Requirements**:
- 99.99% availability SLA target
- Support 100 transactions per second
- Security is a priority (public endpoints for demo, but security controls required)
- Cost optimization within reasonable limits for production workload
- Operational simplicity (limited operations team)

Assess all five WAF pillars (Reliability, Security, Cost Optimization, Operational Excellence, 
Performance Efficiency) and provide specific recommendations with priority levels (High, Medium, Low).
```

**Why this works**:

- ✅ Complete infrastructure description
- ✅ Clear requirements and constraints
- ✅ Requests assessment of all 5 pillars
- ✅ Asks for prioritized recommendations

---

### Prompt 2: Reliability-Focused Assessment

```yaml
Conduct a Well-Architected Framework assessment focused on the Reliability pillar for this architecture:

**Infrastructure**:
- 2 IIS VMs in an Availability Set
- Azure Load Balancer with health probes (port 80, 15-second interval)
- Azure SQL Database with automated backups (7-day retention)
- No geographic redundancy (single region deployment)

**Requirements**:
- Target: 99.99% availability (52 minutes downtime/year)
- Current estimate: 99.95% with Availability Set
- RTO: 4 hours, RPO: 1 hour
- No planned maintenance windows allowed

**Questions to address**:
1. Can we achieve 99.99% SLA with current design?
2. What are the single points of failure?
3. Should we implement Availability Zones instead?
4. Is Azure SQL Database tier sufficient for reliability?
5. What disaster recovery enhancements are needed?

Provide specific recommendations to close the gap between 99.95% and 99.99% availability.
```

**Why this works**:

- ✅ Focused on specific pillar (Reliability)
- ✅ Identifies the gap (99.95% vs. 99.99%)
- ✅ Asks targeted questions
- ✅ Requests actionable recommendations

---

### Prompt 3: Security Assessment with Constraints

```yaml
Conduct a Well-Architected Framework security assessment for this demo architecture:

**Infrastructure**:
- 2 Windows VMs with public IPs (behind load balancer)
- Azure SQL Database with public endpoint
- NSGs allowing HTTP/HTTPS from internet, RDP from specific IPs
- No Azure Bastion, no Private Endpoints, no Key Vault
- Azure AD integration for admin access
- TLS 1.2 enforced for SQL connections

**Context**:
- This is a DEMO environment for audit preparation
- Security is important, but avoiding complexity for learning purposes
- Public endpoints required for easy access during demos
- Budget constraints limit use of premium security features

**Assessment Needed**:
1. What security controls are adequate for a demo environment?
2. What are the acceptable risks vs. unacceptable risks?
3. How should we document security decisions for audit?
4. What warnings should we add for production deployments?

Provide security recommendations categorized as:
- MUST HAVE (even for demo)
- SHOULD HAVE (production requirement)
- NICE TO HAVE (future enhancement)
```

**Why this works**:

- ✅ Honest about demo vs. production trade-offs
- ✅ Asks for categorized recommendations
- ✅ Addresses audit documentation needs
- ✅ Considers learning objectives

---

### Prompt 4: Cost Optimization Review

```yaml
Conduct a Well-Architected Framework cost optimization assessment for this architecture:

**Current Monthly Costs** (East US):
- 2 × Standard_D2s_v3 VMs
- 2 × Premium SSD P10 disks
- Azure Load Balancer (Standard)
- Public IP (Static)
- Azure SQL Database (Standard S2)
- Bandwidth (~100 GB/month)
- Azure Monitor (Logs)
**Total: Use Azure Pricing Calculator for current rates**

**Requirements**:
- Must maintain 99.99% availability target
- Must support 100 TPS performance
- Cannot compromise security
- Acceptable to optimize for cost where it doesn't impact SLA

**Questions**:
1. Are we over-provisioned anywhere?
2. Can we use Reserved Instances or Savings Plans?
3. Is Standard S2 the right database tier?
4. Can we reduce monitoring costs without losing visibility?
5. What alternative architectures would be more cost-effective?

Provide cost optimization recommendations with estimated monthly savings for each.
```

**Why this works**:

- ✅ Provides current cost baseline
- ✅ Clear constraints (maintain SLA and performance)
- ✅ Asks specific cost-related questions
- ✅ Requests savings estimates

---

### Prompt 5: Performance Efficiency Assessment

```yaml
Conduct a Well-Architected Framework performance efficiency assessment for this architecture:

**Architecture**:
- Load Balancer distributing traffic to 2 VMs
- VMs: Standard_D2s_v3 (2 vCPU, 8 GB RAM, Premium SSD)
- Application: ASP.NET web app (stateless)
- Database: Azure SQL Standard S2 (50 DTUs)

**Performance Requirements**:
- 100 transactions per second (TPS) sustained
- 500 concurrent users
- < 2 seconds response time (95th percentile)
- < 3 seconds page load time

**Current Performance Baseline** (from on-premises):
- 80-100 TPS during peak hours
- Average response time: 1.5 seconds
- Database queries: < 100ms average

**Questions**:
1. Is VM sizing appropriate for 100 TPS workload?
2. Is database tier adequate (50 DTUs sufficient)?
3. Should we implement caching (Redis)?
4. How should we monitor and detect performance degradation?
5. What load testing should we conduct before go-live?

Provide performance optimization recommendations and monitoring strategy.
```

**Why this works**:

- ✅ Specific performance targets
- ✅ Provides baseline metrics for comparison
- ✅ Asks about monitoring and testing
- ✅ Considers optimization opportunities

---

### Prompt 6: Operational Excellence Assessment

```yaml
Conduct a Well-Architected Framework operational excellence assessment:

**Current Operations**:
- Infrastructure: Deployed via Bicep templates
- Monitoring: Azure Monitor with basic metrics
- Logging: Application logs to local files only
- Updates: Manual Windows patching monthly
- Deployment: Manual deployment process
- Documentation: Basic runbooks

**Team Context**:
- Small operations team (3 people)
- Limited Azure experience (6 months)
- Traditional Windows Server background
- 24/5 coverage (business hours only)

**Gaps Identified**:
- No CI/CD pipeline
- No automated testing
- No centralized logging
- No alerting configured
- No disaster recovery runbooks

**Questions**:
1. What operational practices should we implement immediately?
2. How can we automate routine operations?
3. What monitoring and alerting should we configure?
4. How should we handle incidents and postmortems?
5. What documentation is required for audit evidence?

Provide operational excellence recommendations prioritized for a small team with limited resources.
```

**Why this works**:

- ✅ Describes current state honestly
- ✅ Acknowledges team constraints
- ✅ Identifies specific gaps
- ✅ Asks for prioritized, realistic recommendations

---

## 🚫 Ineffective Prompts (Avoid These)

### ❌ Too Generic

```text
Assess my Azure architecture for best practices.
```

**Problems**:

- No architecture description
- No specific requirements
- No guidance on focus areas
- Too vague to generate useful output

---

### ❌ Missing Requirements

```yaml
Review this setup: 2 VMs, load balancer, SQL database.
```

**Problems**:

- Lacks details (VM sizes, database tier, network config)
- No SLA or performance requirements
- No context about workload or constraints
- Can't assess appropriateness without requirements

---

### ❌ Only Asking for Validation

```yaml
Tell me if this architecture is good: [architecture description]
```

**Problems**:

- Asks for yes/no instead of assessment
- Doesn't request specific recommendations
- No prioritization guidance
- Missing context about trade-offs

---

## 💡 Best Practices

### 1. Describe Complete Architecture

Include all components:

```yaml
Infrastructure:
- Compute: [VM sizes, quantity, OS]
- Storage: [disk types, sizes]
- Networking: [VNet, subnets, load balancer, NSGs]
- Database: [service, tier, configuration]
- Monitoring: [what's configured]
```

### 2. State Clear Requirements

Be specific about:

- SLA targets (99.99% availability)
- Performance targets (100 TPS, < 2s response time)
- Security requirements (encryption, access controls)
- Cost constraints (budget limits)
- Team capabilities (skill levels, staffing)

### 3. Request Prioritized Recommendations

Ask for:

```yaml
Provide recommendations with priority:
- HIGH: Critical issues affecting SLA or security
- MEDIUM: Important improvements for production readiness
- LOW: Nice-to-have optimizations
```

### 4. Focus on Specific Pillars When Needed

For targeted assessments:

- Reliability assessment when SLA is critical
- Security assessment for compliance requirements
- Cost assessment when over budget
- Performance assessment for scaling concerns

### 5. Include Context About Trade-offs

Help Copilot understand your constraints:

```powershell
Context:
- Demo environment (not production)
- Learning-focused (simplicity preferred)
- Budget-conscious (mid-sized company)
- Timeline-driven (8-week migration)
```

---

## 📊 Prompt Quality Checklist

Before submitting your prompt:

- [ ] **Complete architecture description** - All components listed
- [ ] **Clear requirements** - SLA, performance, cost targets
- [ ] **Appropriate scope** - All 5 pillars or specific focus?
- [ ] **Context provided** - Team skills, constraints, timeline
- [ ] **Specific questions** - What exactly do you want to know?
- [ ] **Prioritization requested** - High/Medium/Low importance
- [ ] **Actionable focus** - Asking for recommendations, not just evaluation
- [ ] **Proper formatting** - Well-structured, easy to read

---

## 🎓 Learning from Examples

### Excellent Example: Multi-Pillar Assessment

```text
Conduct a comprehensive Well-Architected Framework assessment for the Contoso Task Manager 
migration to Azure:

**Infrastructure**:
- Compute: 2 × Standard_D2s_v3 VMs (Windows Server 2022, IIS 10, ASP.NET 4.8)
- Storage: Premium SSD P10 (128 GB) for OS disks
- Networking: VNet (10.0.0.0/16), 2 subnets (web /24, data /24), NSGs on both
- Load Balancing: Azure Load Balancer (Standard) with public IP, health probes on port 80
- Database: Azure SQL Database (Standard S2, 50 DTUs, 10 GB, 7-day backup retention)
- Monitoring: Azure Monitor, Log Analytics workspace, basic VM metrics
- High Availability: Availability Set for VMs, SQL automatic failover

**Business Requirements**:
- SLA: 99.99% availability target (52 min downtime/year max)
- Performance: 100 TPS sustained, 500 concurrent users, < 2s response time
- Security: Public endpoints (demo), but NSGs, SQL firewall, TLS 1.2 required
- Cost: Production-like demo environment (use Azure Pricing Calculator)
- Team: 3-person ops team, moderate Azure experience, strong Windows background
- Timeline: Deploy in 4 weeks for specialization audit

**Assessment Scope**:
Assess all five WAF pillars:
1. Reliability: Can we achieve 99.99% SLA? What are SPOFs?
2. Security: Adequate for demo? What's required for production?
3. Cost Optimization: Are we over-provisioned? Savings opportunities?
4. Operational Excellence: Monitoring, alerting, automation gaps?
5. Performance Efficiency: Will it support 100 TPS? Load testing approach?

For each pillar, provide:
- Current state assessment (strengths and risks)
- Priority recommendations (High/Medium/Low)
- Specific action items
- Estimated effort to implement
```

**What makes this excellent**:

1. Complete infrastructure description with specific SKUs
2. Clear business requirements across all dimensions
3. Explicit assessment scope (all 5 pillars)
4. Specific questions for each pillar
5. Structured output request
6. Context about team and timeline

---

## 📚 Related Resources

- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
- [Well-Architected Review Assessment](https://learn.microsoft.com/assessments/azure-architecture-review/)
- [Azure Architecture Center](https://learn.microsoft.com/azure/architecture/)
- [WAF Pillars Documentation](https://learn.microsoft.com/azure/well-architected/pillars)

---

**Last Updated**: November 2025  
**Agent Version**: 1.0
