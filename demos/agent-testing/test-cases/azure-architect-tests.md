# Azure Principal Architect Agent - Test Cases

**Agent:** azure-principal-architect  
**Version:** 1.1.0  
**Last Updated:** 2025-11-18

---

## Test 1: Basic WAF Assessment

### Objective
Validate that agent provides complete WAF assessment with scoring

### Test Input
```markdown
Assess this architecture against WAF pillars:

**Requirements:**
- Azure App Service (Basic B1 tier)
- Azure SQL Database (Standard S0)
- Single region: East US
- No redundancy
- Budget: $100/month

Provide complete assessment with scores.
```

### Expected Outputs
- [ ] All 5 WAF pillars assessed
- [ ] Scores provided for each pillar (X/10 format)
- [ ] Confidence level stated (High/Medium/Low)
- [ ] Trade-offs explicitly discussed
- [ ] Specific recommendations for each pillar
- [ ] Links to Microsoft documentation

### Expected Scoring Range
- **Security:** 5-7/10 (no private endpoints, basic tier limitations)
- **Reliability:** 3-5/10 (single region, no redundancy)
- **Performance:** 6-7/10 (basic tier limitations)
- **Cost:** 8-9/10 (within budget, optimized for cost)
- **Operational Excellence:** 5-6/10 (basic monitoring capabilities)

### Pass Criteria
- All 5 pillars scored
- Confidence level provided
- At least 3 specific recommendations
- Documentation links included

---

## Test 2: Cost Estimation Validation

### Objective
Verify agent provides accurate cost estimates

### Test Input
```markdown
Design an architecture for:
- Web application (App Service Standard S1)
- SQL Database (Standard S2)
- Storage Account (LRS, 100GB)
- Application Gateway (WAF_v2)
- Region: West Europe

Provide detailed cost breakdown.
```

### Expected Outputs
- [ ] Monthly cost estimate table
- [ ] Cost range (min-max) provided
- [ ] Cost per service/component
- [ ] Cost optimization suggestions
- [ ] Regional pricing notes if applicable

### Expected Cost Range
| Service | Expected Cost |
|---------|---------------|
| App Service (S1) | ~$70/month |
| SQL Database (S2) | ~$30/month |
| Storage (LRS 100GB) | ~$2/month |
| App Gateway (WAF_v2) | ~$300/month |
| **Total** | **$402/month** |

### Pass Criteria
- Cost estimate within ±20% of expected
- Table format used
- Optimization suggestions provided
- Cost drivers identified

---

## Test 3: Multi-Region Architecture

### Objective
Validate recommendations for high-availability multi-region scenarios

### Test Input
```markdown
Design a global web application:

**Requirements:**
- Users in North America, Europe, Asia-Pacific
- 99.99% SLA required
- Budget: $5,000/month
- PCI-DSS compliance needed
- Database with global read replicas

Assess against all WAF pillars and provide detailed architecture.
```

### Expected Outputs
- [ ] Multi-region strategy (Front Door or Traffic Manager)
- [ ] Regional service recommendations
- [ ] Compliance mapping to PCI-DSS requirements
- [ ] Cost breakdown per region
- [ ] Failover and disaster recovery strategy
- [ ] WAF scores with justification
- [ ] Reference to Azure Architecture Center patterns

### Pass Criteria
- Multi-region approach recommended
- All 5 WAF pillars scored
- Compliance requirements addressed
- Cost estimate provided
- Reference architecture linked

---

## Test 4: Security Optimization Focus

### Objective
Test agent's security-first recommendations

### Test Input
```markdown
Review this architecture for security improvements:

**Current State:**
- App Service with public endpoint
- SQL Database with public access
- Storage account with anonymous blob access
- No network segmentation
- Passwords in app settings

What security improvements should I make?
```

### Expected Outputs
- [ ] Security score (should be low, 2-4/10)
- [ ] Prioritized list of security improvements
- [ ] Specific Azure services for each improvement (Private Endpoints, Key Vault, etc.)
- [ ] Trade-off analysis (cost vs. security)
- [ ] Implementation guidance with documentation links
- [ ] Zero-trust principles mentioned

### Expected Recommendations
1. Implement Private Endpoints (priority: critical)
2. Move secrets to Azure Key Vault (priority: critical)
3. Implement NSGs and VNet integration (priority: high)
4. Enable Azure DDoS Protection (priority: medium)
5. Implement Azure AD authentication (priority: high)

### Pass Criteria
- Security prioritized in recommendations
- At least 5 specific improvements listed
- Cost impact of improvements discussed
- Links to security best practices

---

## Test 5: Cost Optimization Focus

### Objective
Validate cost-focused recommendations

### Test Input
```markdown
Optimize this architecture for cost:

**Current State:**
- 5x Premium P1v3 App Services (always on)
- Premium P2 SQL Database
- Premium LRS storage (hot tier)
- Application Gateway Standard_v2 with WAF
- All in West Europe
- Usage: 8am-6pm weekdays only

Budget target: Reduce by 50% without losing functionality during business hours.
```

### Expected Outputs
- [ ] Cost Optimization score provided
- [ ] Current cost estimate
- [ ] Optimized cost estimate
- [ ] Specific cost-saving recommendations
- [ ] Trade-offs clearly stated
- [ ] Implementation guidance

### Expected Recommendations
1. Downgrade App Services to Standard S1 (save ~$400/month)
2. Use Azure SQL serverless (save ~$200/month)
3. Implement auto-shutdown for off-hours (save ~$300/month)
4. Move storage to cool tier for infrequently accessed data (save ~$50/month)
5. Consider reserved instances for 30-50% savings

### Pass Criteria
- 50% cost reduction achieved
- Trade-offs explicitly stated
- Specific SKU recommendations
- Auto-scaling/shutdown strategies included

---

## Test 6: Requirement Clarification

### Objective
Verify agent asks clarifying questions when requirements are vague

### Test Input
```markdown
I need an Azure architecture for my application.
```

### Expected Outputs
- [ ] Agent asks clarifying questions before providing recommendations
- [ ] Questions cover critical aspects (scale, budget, compliance, etc.)
- [ ] Questions are specific and actionable
- [ ] No assumptions made without asking

### Expected Questions (should ask at least 4-5)
1. What type of application? (web, mobile, API, etc.)
2. Expected user load? (concurrent users, requests/second)
3. SLA requirements? (99%, 99.9%, 99.99%?)
4. Budget constraints? (monthly spend limit)
5. Compliance requirements? (PCI-DSS, HIPAA, etc.)
6. Geographic distribution? (single region or global?)
7. Data residency requirements?

### Pass Criteria
- No recommendations provided without clarification
- At least 4 questions asked
- Questions cover multiple WAF pillars

---

## Test 7: Reference Architecture Linking

### Objective
Ensure agent links to relevant Azure Architecture Center patterns

### Test Input
```markdown
Design a microservices architecture on Azure with:
- 10+ microservices
- API Gateway
- Service mesh
- Event-driven communication
- CQRS pattern
```

### Expected Outputs
- [ ] Reference to Azure Architecture Center
- [ ] Specific pattern links (Microservices, CQRS, Event-driven)
- [ ] AKS recommended for container orchestration
- [ ] Service mesh options discussed (Istio, Linkerd, Dapr)
- [ ] Event Grid or Service Bus for messaging
- [ ] APIM for API Gateway

### Expected Links (at least 2-3)
- Microservices architecture style
- Event-driven architecture
- CQRS pattern
- AKS baseline architecture

### Pass Criteria
- At least 2 Architecture Center links
- Specific Azure services for each component
- Architectural patterns referenced correctly

---

## Test 8: Regional Recommendations

### Objective
Validate region-specific guidance

### Test Input
```markdown
Design architecture for a European company:

**Requirements:**
- GDPR compliance required
- Users primarily in Germany, France, UK
- 99.95% SLA
- Data must not leave EU
- AI/ML workloads (GPU required)

Which Azure regions should I use and why?
```

### Expected Outputs
- [ ] Primary region recommendation (likely West Europe or North Europe)
- [ ] Secondary region for HA (paired region)
- [ ] GDPR/data residency considerations explained
- [ ] Service availability verified (GPU VMs in recommended regions)
- [ ] Latency considerations for user locations
- [ ] Compliance certifications mentioned

### Expected Recommendations
- Primary: West Europe or North Europe
- Secondary: Paired region (North Europe or West Europe)
- Notes on Germany regions for strict data residency
- Verification of GPU VM availability

### Pass Criteria
- Region recommendations provided with justification
- GDPR compliance addressed
- Service availability confirmed
- Paired regions for HA mentioned

---

## Test 9: Trade-off Analysis

### Objective
Verify explicit trade-off discussions

### Test Input
```markdown
I want maximum reliability AND lowest cost for a web application.
```

### Expected Outputs
- [ ] Agent explicitly states these goals conflict
- [ ] Trade-offs clearly explained
- [ ] Multiple options provided with different trade-off profiles
- [ ] Recommended approach with rationale
- [ ] Cost vs. reliability graph or comparison

### Expected Discussion Points
- Multi-region = higher reliability but 2-3x cost
- Single region with availability zones = good balance
- Basic tier = lowest cost but limited reliability (no SLA)
- Standard tier = balanced cost/reliability
- Premium tier = highest reliability but 3-5x cost

### Pass Criteria
- Conflict acknowledged
- Multiple options presented
- Trade-offs quantified where possible
- Recommended approach with clear rationale

---

## Test 10: Confidence Level Accuracy

### Objective
Verify agent appropriately indicates confidence in recommendations

### Test Input
```markdown
Design an IoT solution for:
- 50,000 devices
- Telemetry every 30 seconds
- [No other details provided]
```

### Expected Outputs
- [ ] Confidence level: Low or Medium (due to missing requirements)
- [ ] Explicit statement of assumptions made
- [ ] List of unknowns that would increase confidence
- [ ] Provisional recommendations with caveats

### Expected Unknowns to Mention
- Message size (affects bandwidth and cost)
- Analytics requirements (hot path vs. cold path)
- Command & control needs (cloud-to-device messaging)
- Security requirements (per-device authentication)
- Geographic distribution of devices
- Budget constraints

### Pass Criteria
- Confidence level: Medium or Low (not High)
- At least 3 unknowns identified
- Assumptions explicitly stated
- Recommendations caveated appropriately

---

## Regression Tests

### Regression 1: Simple Architecture (v1.0.0 baseline)
Ensure simple architectures still work as before

**Input:** Basic App Service + SQL Database  
**Expected:** Quick recommendation without unnecessary complexity  
**Pass:** Output similar to v1.0.0 (plus new features)

### Regression 2: No Breaking Changes
Ensure existing prompts still work

**Input:** Any prompt that worked in v1.0.0  
**Expected:** Still produces valid output  
**Pass:** No errors, output format consistent

---

## Performance Benchmarks

| Test | Expected Response Time | Actual | Status |
|------|------------------------|--------|--------|
| Basic WAF Assessment | < 30 seconds | TBD | Not Run |
| Cost Estimation | < 30 seconds | TBD | Not Run |
| Multi-Region Design | < 45 seconds | TBD | Not Run |
| Security Optimization | < 30 seconds | TBD | Not Run |

---

**Test Suite Version:** 1.0  
**Agent Version:** 1.1.0  
**Total Tests:** 10 core + 2 regression  
**Last Reviewed:** 2025-11-18
