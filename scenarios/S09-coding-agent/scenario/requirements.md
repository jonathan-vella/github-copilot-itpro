# S09: Coding Agent - Business Requirements

## Customer Profile

**Organization:** Contoso Healthcare
**Industry:** Healthcare
**Size:** Mid-market (500 employees, 10,000 patients)
**Azure Maturity:** Intermediate (existing Azure footprint, IaC adoption in progress)

---

## Business Context

Contoso Healthcare recently deployed a new patient portal infrastructure using Azure
Bicep templates. The deployment was successful, but the operations team has identified
a critical gap: **no monitoring or alerting is configured**.

### Current State

- Patient portal infrastructure deployed to Azure
- App Service, SQL Database, Key Vault, Storage all operational
- Log Analytics workspace exists but no alert rules
- Zero visibility into application health
- Operations team relies on user complaints to identify issues

### Problem Statement

> "We deployed the patient portal last week, and it's working great—but we have no
> idea if it's about to fail. If the database fills up or the app runs out of memory,
> we won't know until patients start calling. That's not acceptable for healthcare."
>
> — Alex Petrov, Cloud Operations Engineer

---

## Requirements

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Alert when App Service CPU exceeds threshold | High |
| FR-02 | Alert when App Service memory exceeds threshold | High |
| FR-03 | Alert when HTTP 5xx errors spike | High |
| FR-04 | Alert when response time degrades | Medium |
| FR-05 | Send email notifications for all alerts | High |
| FR-06 | Configurable alert thresholds | Medium |
| FR-07 | Ability to disable alerts per environment | Low |

### Non-Functional Requirements

| ID | Requirement | Details |
|----|-------------|---------|
| NFR-01 | Code quality | Must pass `bicep build` and `bicep lint` |
| NFR-02 | Maintainability | Follow existing code patterns and conventions |
| NFR-03 | Documentation | README must document alert configuration |
| NFR-04 | Region compliance | Use swedencentral (EU data residency) |
| NFR-05 | Tagging | Include Environment, ManagedBy, Project tags |

---

## Constraints

### Technical Constraints

- Must integrate with existing Bicep modules (not standalone deployment)
- Must use existing Log Analytics workspace (no new workspace)
- Alert thresholds must be parameterized for environment flexibility
- Module must follow CAF naming conventions

### Business Constraints

- Implementation needed before Friday go-live (3 days)
- Operations team has limited Bicep expertise
- No budget for third-party monitoring tools
- Must work within existing Azure subscription limits

### Compliance Constraints

- HIPAA: Audit trail required for all infrastructure changes
- Change management: All changes via Pull Request review
- EU GDPR: Data must remain in EU region

---

## Success Criteria

### Must Have (MVP)

- [ ] 4 alert rules operational in Azure
- [ ] Email notifications working
- [ ] Zero `bicep build` errors
- [ ] Integrated into existing main.bicep

### Should Have

- [ ] README documentation updated
- [ ] Alert thresholds configurable via parameters
- [ ] Module follows existing patterns

### Nice to Have

- [ ] Environment-specific alert tuning
- [ ] Additional alert types (SQL, Storage)
- [ ] Dashboard for alert visualization

---

## Stakeholders

| Role | Name | Interest |
|------|------|----------|
| Cloud Ops Engineer | Alex Petrov | Primary implementer, on-call responder |
| Platform Lead | Jordan Kim | Code review, pattern compliance |
| CISO | Morgan Chen | Security and compliance sign-off |
| CTO | Pat Williams | Go-live decision maker |

---

## Timeline

| Milestone | Date | Status |
|-----------|------|--------|
| Infrastructure deployed | Nov 18 | ✅ Complete |
| Monitoring gap identified | Nov 22 | ✅ Complete |
| Monitoring issue created | Nov 25 | 🔄 In Progress |
| PR created by Copilot | Nov 25 | ⏳ Pending |
| PR reviewed and merged | Nov 25 | ⏳ Pending |
| Alerts validated in portal | Nov 26 | ⏳ Pending |
| Production go-live | Nov 28 | ⏳ Pending |

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Copilot generates incorrect Bicep | Medium | Medium | Code review before merge |
| Alert thresholds too sensitive | Medium | Low | Start conservative, tune post-deploy |
| Missing alert for critical metric | Low | High | Review against Azure best practices |
| Integration breaks existing deployment | Low | High | Test in dev environment first |
