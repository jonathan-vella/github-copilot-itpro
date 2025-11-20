# Effective Prompts: ADR Generator Agent

## 🎯 Purpose

The ADR (Architectural Decision Record) Generator agent helps document architectural decisions with proper structure, rationale, and compliance considerations. This is valuable for Module A Control 2.1 evidence.

---

## 📝 Prompt Template

```text
Document the architectural decision to [DECISION] for [CONTEXT].

Consider the following:
- [REQUIREMENT 1]
- [REQUIREMENT 2]
- [CONSTRAINT 1]
- [CONSTRAINT 2]

Include: decision drivers, alternatives considered, consequences, and compliance implications.
```

---

## ✅ Effective Prompts

### Prompt 1: Database Selection Decision

```text
Document the architectural decision to use Azure SQL Database instead of SQL Managed Instance 
for the Contoso Task Manager application migration.

Consider the following context:
- Application: ASP.NET web application with 2GB database
- Performance: 100 transactions per second required
- SLA: 99.99% uptime target
- Cost sensitivity: Mid-sized manufacturing company
- Management: Limited DBA resources available

Include: decision drivers, alternatives considered, consequences, and compliance implications.
```

**Why this works**:

- ✅ Clearly states the decision (Azure SQL Database vs. SQL Managed Instance)
- ✅ Provides relevant context (application type, size, performance)
- ✅ Mentions constraints (cost, limited DBA resources)
- ✅ Requests specific sections (drivers, alternatives, consequences)

---

### Prompt 2: High Availability Architecture

```text
Document the architectural decision to implement high availability using Azure Load Balancer 
with multiple Virtual Machines instead of Azure App Service for the Contoso Task Manager 
web application.

Consider the following:
- Current state: Legacy IIS application on Windows Server
- Migration approach: Rehost (lift-and-shift) preferred
- SLA requirement: 99.99% uptime
- Team skillset: Strong Windows Server/IIS expertise, limited PaaS experience
- Timeline: 8-week migration window
- Future plans: Possible refactoring to App Service in 12-18 months

Include: decision rationale, risk assessment, migration complexity, and long-term strategy.
```

**Why this works**:

- ✅ Explains the "why" behind the decision (lift-and-shift strategy)
- ✅ Acknowledges team capabilities (IIS expertise)
- ✅ Considers timeline constraints
- ✅ Addresses future evolution path

---

### Prompt 3: Network Security Design

```text
Document the architectural decision to use public endpoints with Network Security Groups 
instead of Private Endpoints for the demo deployment of the Task Manager application.

Consider the following:
- Purpose: Specialization audit demonstration environment
- Duration: Temporary demo environment (not production)
- Complexity: Private endpoints add configuration complexity
- Audience: Partner technical teams learning Azure
- Security: NSGs provide adequate security for demo scenarios
- Cost: Private endpoints add monthly costs
- Timeline: Need quick setup for audit preparation

Include: security trade-offs, cost implications, demo vs. production considerations, 
and recommendations for production deployments.
```

**Why this works**:

- ✅ Acknowledges the trade-off (public vs. private endpoints)
- ✅ Provides clear context (demo environment, not production)
- ✅ Explains the decision factors (complexity, cost, timeline)
- ✅ Includes guidance for production scenarios

---

### Prompt 4: VM Sizing Decision

```powershell
Document the architectural decision to use Standard_D2s_v3 VM size for the IIS web servers 
in the Contoso Task Manager deployment.

Consider the following:
- Workload: ASP.NET web application (stateless)
- Performance: 100 transactions per second target, 500 concurrent users
- Current baseline: On-premises servers with 2 vCPU, 8 GB RAM
- Cost: Budget-conscious mid-sized company
- Scalability: Need ability to scale horizontally (add more VMs)
- Storage: Premium SSD required for better performance

Include: sizing methodology, performance testing approach, cost analysis, 
and scale-out strategy.
```

**Why this works**:

- ✅ Provides performance requirements and baselines
- ✅ Explains sizing methodology
- ✅ Considers cost and scalability
- ✅ Addresses storage requirements

---

### Prompt 5: Backup and DR Strategy

```text
Document the architectural decision for backup and disaster recovery strategy using 
Azure SQL Database automated backups instead of implementing geo-replication.

Consider the following:
- RTO (Recovery Time Objective): 4 hours acceptable
- RPO (Recovery Point Objective): 1 hour acceptable
- Database size: 2-5 GB (small)
- Change rate: Moderate (business hours activity)
- Cost: Limited DR budget
- Compliance: 30-day retention required
- Geographic scope: Single US region sufficient

Include: backup strategy, retention policies, recovery procedures, cost comparison, 
and future enhancements.
```

**Why this works**:

- ✅ Defines clear RTO/RPO requirements
- ✅ Provides database characteristics
- ✅ Explains budget constraints
- ✅ Addresses compliance requirements

---

## 🚫 Ineffective Prompts (Avoid These)

### ❌ Too Vague

```text
Document why we chose Azure SQL Database.
```

**Problems**:

- Missing context about the application
- No alternatives mentioned
- No constraints or requirements
- Too brief to generate quality output

---

### ❌ Too Technical, No Business Context

```text
Document the decision to use Azure SQL Database Standard S2 tier with 50 DTUs, 
point-in-time restore enabled, TDE encryption, and geo-redundant backups.
```

**Problems**:

- Only technical specifications
- No business requirements or drivers
- No explanation of why these specific choices
- Missing decision rationale

---

### ❌ Multiple Decisions in One Prompt

```text
Document all the architectural decisions for the Contoso migration including database, 
networking, compute, security, monitoring, and backup.
```

**Problems**:

- Too broad, multiple topics
- Won't generate focused ADR
- Better to create separate ADRs for each major decision

---

## 💡 Best Practices

### 1. Provide Clear Context

Always include:

- **Application details**: Type, size, performance requirements
- **Business constraints**: Budget, timeline, team skills
- **Technical requirements**: SLA, performance, security

### 2. Mention Alternatives

Help Copilot understand what you considered:

```text
Compare Azure SQL Database vs. SQL Managed Instance vs. SQL Server on VM
```

### 3. Request Specific Sections

Guide the structure:

```yaml
Include: decision drivers, alternatives considered, consequences, and compliance implications.
```

### 4. Use Proper Grammar and Spelling

- ✅ Clear, professional language
- ✅ Proper punctuation and capitalization
- ✅ No typos or abbreviations (unless industry-standard)

### 5. One Decision Per ADR

Focus on a single architectural decision:

- ✅ "Document the database service selection"
- ❌ "Document all infrastructure decisions"

---

## 📊 Prompt Quality Checklist

Before submitting your prompt, verify:

- [ ] **Clear decision statement** - What exactly are you deciding?
- [ ] **Sufficient context** - Application type, requirements, constraints
- [ ] **Alternatives mentioned** - What other options were considered?
- [ ] **Business factors** - Cost, timeline, team skills, compliance
- [ ] **Technical requirements** - Performance, SLA, security
- [ ] **Requested sections** - What should the ADR include?
- [ ] **Proper grammar** - No typos, clear language
- [ ] **Appropriate length** - Not too brief, not too verbose

---

## 🎓 Learning from Examples

### Good Example: Complete Context

```text
Document the architectural decision to deploy VMs in an Availability Set rather than 
Availability Zones for the Contoso Task Manager application.

Context:
- Application: Stateless ASP.NET web app behind load balancer
- SLA target: 99.99% (Availability Set provides 99.95%)
- Cost: Availability Zones add bandwidth costs between zones
- Simplicity: Availability Set simpler for initial deployment
- Region: East US (Availability Zones available)
- Future: Can migrate to Availability Zones if needed

Include: HA comparison, cost analysis, migration path, and SLA implications.
```

**What makes this effective**:

1. Specific decision (Availability Set vs. Zones)
2. Application context (stateless, load balanced)
3. SLA considerations (target vs. actual)
4. Cost factors (bandwidth between zones)
5. Simplicity considerations (deployment complexity)
6. Future flexibility (migration path)

---

## 📚 Related Resources

- [ADR Best Practices](https://adr.github.io/)
- [Azure Architecture Decision Guides](https://learn.microsoft.com/azure/architecture/guide/decision-guides/)
- [Architectural Decision Records (ADRs)](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)

---

**Last Updated**: November 2025  
**Agent Version**: 1.0
