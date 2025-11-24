# Scenario: Service Validation for Production Deployment

## Business Context

Contoso Healthcare is deploying a new patient portal API to Azure. Before going to production, the operations team needs to validate:

1. **Security compliance** - Azure Policy requires Entra ID-only authentication
2. **Performance requirements** - API must handle 500 concurrent users with <500ms response time
3. **Resilience** - Application must recover from infrastructure failures
4. **Operational readiness** - Automated testing pipeline for future releases

## Technical Requirements

### Infrastructure

- **Region**: Sweden Central (primary), Germany West Central (alternative)
- **Compute**: Azure App Services with zone redundancy
- **Database**: Azure SQL with Entra ID-only authentication
- **Container Registry**: Azure Container Registry with managed identity auth
- **Observability**: Log Analytics + Application Insights

### Security Requirements

- No SQL username/password in configuration
- Managed identity for all Azure service communication
- Private endpoints where possible (future enhancement)
- Azure Policy compliance (SFI-ID4.2.2: SQL DB - Safe Secrets Standard)

### Performance Requirements

| Metric | Target |
|--------|--------|
| Concurrent Users | 500 |
| Response Time (p95) | < 500ms |
| Requests per Second | > 1000 |
| Error Rate | < 0.1% |

### Resilience Requirements

The application must recover gracefully from:
- CPU spike (80%+ utilization)
- Memory pressure (90%+ usage)
- Network latency (100ms+ added)
- Database connection loss
- Pod/container restart

## Testing Strategy

### Phase 1: Infrastructure Validation
- Deploy infrastructure with Bicep
- Verify managed identity configuration
- Confirm Entra ID SQL authentication
- Validate zone redundancy setup

### Phase 2: Load Testing
- Baseline test: 100 users, 5 minutes
- Stress test: 500 users, 10 minutes
- Spike test: 0→500→0 users, 15 minutes
- Endurance test: 200 users, 30 minutes

### Phase 3: Chaos Engineering
- CPU spike experiment (80% load)
- Memory pressure experiment (90% usage)
- Network latency injection (+100ms)
- Database connection pool exhaustion
- Container restart simulation

### Phase 4: User Acceptance Testing
- Health check endpoint
- SQL connectivity test
- Managed identity token acquisition
- API version verification
- Database query performance

## Success Criteria

- ✅ Infrastructure deploys successfully
- ✅ All load tests meet performance targets
- ✅ Application recovers from all chaos experiments
- ✅ 100% UAT test pass rate
- ✅ Zero security findings (no hardcoded secrets)

## Constraints

- Budget: Standard/Premium tier only (no Enterprise SKUs)
- Timeline: 2 weeks for full validation
- Team: 3 DevOps engineers, 1 SRE
- Automation: All tests must run in CI/CD pipeline

## Out of Scope

- Multi-region deployment (Phase 2)
- Private endpoints (Phase 2)
- Custom domain/SSL certificates
- Production data migration
- Penetration testing
