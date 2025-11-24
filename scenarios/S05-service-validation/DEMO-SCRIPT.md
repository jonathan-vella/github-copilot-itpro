# S05: Service Validation Demo Script

**Duration**: 30-45 minutes  
**Audience**: DevOps engineers, SREs, QA engineers, Azure architects  
**Difficulty**: Intermediate

## Overview

This demo showcases **AI-assisted service validation** using GitHub Copilot agents to automate testing workflows:

- **UAT Assistant Agent** - Interactive user acceptance testing with automated report generation
- **Load Test Assistant Agent** - Performance validation with bottleneck analysis and scaling recommendations

**Key Value**: GitHub Copilot transforms manual testing into guided, automated workflows that reduce validation time by 70-80% while improving test coverage and documentation quality.

## Prerequisites

- Azure subscription with Contributor access
- Azure CLI installed and authenticated
- PowerShell 7+
- GitHub Copilot enabled in VS Code

## Demo Setup (Pre-Demo)

**Before the demo, ensure:**

1. Azure infrastructure is already deployed (SAIF API running)
2. Service URL is accessible: `https://app-saifv2-api-ss4xs2.azurewebsites.net`
3. UAT and Load Test agents are available in VS Code
4. GitHub Copilot Chat is active

**Note**: This demo focuses on testing validation, not infrastructure deployment.

---

## Demo Flow

### Phase 1: Introduction & Context (5 min)

**Show the deployed service:**

```bash
# Verify service is running
curl -s https://app-saifv2-api-ss4xs2.azurewebsites.net/ | jq
```

**Open scenario files:**
- `scenario/requirements.md` - Business requirements and acceptance criteria
- `scenario/architecture.md` - Technical architecture with Mermaid diagrams

**Key talking points:**
- "We have a HIPAA-compliant patient portal API deployed to Azure"
- "Challenge: How do we validate it meets acceptance criteria efficiently?"
- "Solution: GitHub Copilot agents guide us through comprehensive testing"

---

### Phase 2: UAT Testing with Agent (15 min)

**1. Start UAT Assistant** (2 min)

Open Copilot Chat and invoke the agent:

```
@uat-assistant I need to run UAT tests for my SAIF API
```

**2. Follow Interactive Prompts** (8 min)

The agent will ask questions - respond with:

- **Service URL**: `https://app-saifv2-api-ss4xs2.azurewebsites.net`
- **Critical endpoints**: `/`, `/api/ip`, `/api/sqlwhoami`, `/api/sqlsrcip`
- **Acceptance criteria**: "All endpoints return 200, response time < 600ms, database connectivity works"
- **Security requirements**: "HTTPS only, no sensitive data exposure"

**Show the generated test plan:**

```markdown
# UAT Test Plan
- [ ] Health check (< 600ms)
- [ ] Version endpoint (< 600ms)
- [ ] Identity verification (managed identity)
- [ ] Client information (IP address)
- [ ] Database connectivity (SQL queries)
- [ ] Security (HTTPS, no leaks)
- [ ] Error handling (404s)
- [ ] Performance (response times)
```

**3. Execute Tests** (3 min)

Agent will guide you to run:

```bash
cd validation/uat
export API_BASE_URL="https://app-saifv2-api-ss4xs2.azurewebsites.net"
./uat-tests.sh
```

**Show the results:**
- ✅ 24 tests executed
- ✅ 100% pass rate
- ✅ All endpoints validated
- ✅ Performance within SLA

**4. Generate Report** (2 min)

Ask the agent:
```
Populate the UAT report template with these results
```

**Show generated report:**
- Open `validation/uat/uat-report-template.md` (now filled)
- Highlight: Executive summary, detailed metrics, sign-off section
- **Value message**: "Manual testing would take 2-3 hours. With Copilot: 15 minutes."

---

### Phase 3: Load Testing with Agent (15 min)

**1. Start Load Test Assistant** (2 min)

```
@loadtest-assistant I need to load test my API
```

**2. Follow Interactive Prompts** (5 min)

Respond with:

- **Service URL**: `https://app-saifv2-api-ss4xs2.azurewebsites.net`
- **Endpoints**: `/`, `/api/ip`, `/api/sqlwhoami`, `/api/sqlsrcip`
- **Performance goals**: "500 RPS with p95 response time under 500ms"
- **Load pattern**: "Ramp-up" (gradual increase)
- **Duration & VUs**: "5 minutes, 50 VUs ramping to 200 VUs"

**Agent generates k6 script** - show the generated code:

```javascript
// load-test.js
export const options = {
  stages: [
    { duration: '1m', target: 50 },   // Ramp up
    { duration: '3m', target: 200 },  // Sustained
    { duration: '1m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    errors: ['rate<0.01'],
  },
};
```

**3. Execute Load Test** (5 min)

If k6 is installed:
```bash
cd validation/load-testing
k6 run load-test.js
```

If not, simulate with agent guidance:
```
Agent: [Simulates test execution]
Agent: Test complete! Results:
- RPS: 485 (Target: 500) ⚠️  
- p95: 445ms (Target: 500ms) ✅
- Error Rate: 0.2% ✅
- CPU: 78% ✅
```

**4. Analyze Results** (3 min)

Agent will:
- Identify bottlenecks (if any)
- Recommend scaling (e.g., "Consider upgrading to P2v3 for 600+ RPS")
- Calculate cost impact
- Generate performance grade (e.g., "Grade: B")

**Ask agent to generate report:**
```
Generate the load test report with recommendations
```

**Show generated report:**
- Open `validation/load-testing/load-test-report-template.md` (now filled)
- Highlight: Performance metrics, bottleneck analysis, scaling recommendations
- **Value message**: "Agent identified that database queries are the bottleneck and suggested connection pooling optimization"

---

### Phase 4: Report Sign-Off & Wrap-Up (5 min)

**1. Review Both Reports** (2 min)

Show side-by-side:
- `uat-report-template.md` - Functional validation
- `load-test-report-template.md` - Performance validation

**Key highlights:**
- ✅ All UAT tests passed (24/24)
- ✅ Load test achieved 485 RPS (target: 500)
- ✅ p95 response time: 445ms (target: <500ms)
- ⚠️ Identified: Database connection pool could be optimized
- 📊 Recommendation: Implement connection pooling for 20% performance gain

**2. Sign-Off Process** (1 min)

Show the sign-off sections in reports:
- QA Engineer approval
- Technical Lead approval
- Business stakeholder approval

**3. Key Takeaways** (2 min)

**Time Savings:**
- **Manual UAT**: 2-3 hours → **With Copilot**: 15 minutes (80% reduction)
- **Manual Load Test**: 4-5 hours → **With Copilot**: 15 minutes (85% reduction)

**Quality Improvements:**
- Comprehensive test coverage (24 test cases)
- Professional reports with executive summaries
- Actionable recommendations with cost analysis
- Consistent testing process across teams

**Value proposition:**
> "GitHub Copilot agents transform ad-hoc testing into a structured, repeatable process. You get enterprise-grade validation in a fraction of the time, with better documentation and actionable insights."

---

## Key Talking Points Throughout Demo

### UAT Assistant Benefits
- 🤖 **Guided Workflow**: Step-by-step prompts eliminate guesswork
- 📋 **Auto-Generated Checklists**: Comprehensive test plans based on your requirements
- 📊 **Professional Reports**: Executive summaries with sign-off sections
- ⚡ **Time Savings**: 80% reduction in UAT execution time
- 🔁 **Repeatable**: Same quality every time, regardless of tester experience

### Load Test Assistant Benefits
- 🎯 **Intelligent Configuration**: Asks the right questions to build optimal test plans
- 🛠️ **Multi-Tool Support**: Generates scripts for k6, Azure Load Testing, or Artillery
- 🔍 **Bottleneck Analysis**: Identifies performance issues with root cause analysis
- 💰 **Cost-Aware Recommendations**: Scaling suggestions include Azure pricing impact
- 📈 **Performance Grading**: A-F grades make results easy to communicate to stakeholders

### Business Value
- **ROI**: 70-80% time reduction = more testing cycles = higher quality
- **Consistency**: Standardized testing process across all teams
- **Documentation**: Audit-ready reports generated automatically
- **Knowledge Transfer**: Junior engineers get senior-level guidance
- **Scalability**: Same workflow for 5 endpoints or 500 endpoints

---

## Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| Agent not responding | Ensure GitHub Copilot subscription is active |
| UAT tests fail | Check `API_BASE_URL` environment variable is set |
| k6 not installed | Agent can simulate results or guide Azure Load Testing setup |
| Reports not populating | Ensure test output is captured and shared with agent |
| Custom endpoints needed | Agent adapts to any API structure - just specify in prompts |

---

## Success Metrics

**Demo is successful when:**
- ✅ UAT Assistant completes full workflow (discovery → execution → report) in < 15 min
- ✅ All 24 UAT tests pass with 100% success rate
- ✅ Load Test Assistant generates k6 script and analyzes results in < 15 min
- ✅ Performance meets targets (p95 < 500ms, error rate < 1%)
- ✅ Both reports are generated with actionable recommendations
- ✅ Audience understands how to use agents in their own projects

---

## Demo Variants

### Short Version (15 min)
- Show UAT Assistant workflow only
- Use pre-executed test results
- Focus on report generation

### Extended Version (60 min)
- Add manual testing comparison (show old way vs. new way)
- Run actual k6 load test (not simulated)
- Show CI/CD integration examples
- Demonstrate agent handoffs between UAT → Load Test

### Workshop Format (90 min)
- Attendees bring their own APIs
- Guide them through using both agents
- Hands-on: Generate tests for their services
- Group review of generated reports

---

## Follow-Up Resources

### Documentation
- [UAT Assistant Agent](.github/agents/uat-assistant.agent.md)
- [Load Test Assistant Agent](.github/agents/loadtest-assistant.agent.md)
- [Effective Prompts Guide](prompts/effective-prompts.md)
- [UAT Report Template](validation/uat/uat-report-template.md)
- [Load Test Report Template](validation/load-testing/load-test-report-template.md)

### Tools & Frameworks
- [GitHub Copilot](https://github.com/features/copilot)
- [k6 Load Testing](https://k6.io/)
- [Azure Load Testing](https://learn.microsoft.com/azure/load-testing/)
- [Pester Testing Framework](https://pester.dev/)

### Related Demos
- **S01: Bicep Quickstart** - Infrastructure deployment
- **S02: PowerShell Automation** - Azure automation with Copilot
- **S06: Azure Specialization Prep** - Azure certifications with AI assistance

---

## Appendix: Agent Prompts Cheat Sheet

### UAT Assistant Quick Start
```
@uat-assistant I need to run UAT tests for [service name]
```

### Load Test Assistant Quick Start
```
@loadtest-assistant I need to load test [service name]
```

### Useful Follow-Up Prompts

**During UAT:**
- "Add a test for [specific functionality]"
- "What's the current pass rate?"
- "Show me only failed tests"
- "Generate executive summary"

**During Load Testing:**
- "What's causing the bottleneck?"
- "How much would scaling to [SKU] cost?"
- "Compare these results to previous test"
- "Show performance trend over last 3 tests"

**For Reports:**
- "Populate the template with current results"
- "Add recommendations section"
- "Include cost-benefit analysis"
- "Generate sign-off checklist"
