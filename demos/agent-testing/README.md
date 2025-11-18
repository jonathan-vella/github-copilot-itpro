# GitHub Copilot Custom Agent Testing Suite

**Version:** 1.0  
**Last Updated:** 2025-11-18

## Overview

This testing suite validates the quality, consistency, and functionality of the four custom GitHub Copilot agents used in the IT Pro field guide repository.

## Agents Under Test

1. **ADR Generator** - Document architectural decisions
2. **Azure Principal Architect** - WAF assessments and architecture guidance
3. **Bicep Planning Specialist** - Infrastructure implementation planning
4. **Bicep Implementation Specialist** - Bicep code generation

---

## Directory Structure

```
demos/agent-testing/
├── README.md                          # This file
├── Run-AgentTests.ps1                 # Automated test runner
├── Generate-TestReport.ps1            # Test report generator
├── test-cases/                        # Test scenario definitions
│   ├── adr-generator-tests.md
│   ├── azure-architect-tests.md
│   ├── bicep-plan-tests.md
│   └── bicep-implement-tests.md
├── expected-outputs/                  # Expected results for comparison
│   ├── adr-generator/
│   ├── azure-architect/
│   ├── bicep-plan/
│   └── bicep-implement/
├── actual-outputs/                    # Actual test outputs
│   ├── adr-generator/
│   ├── azure-architect/
│   ├── bicep-plan/
│   └── bicep-implement/
├── test-scenarios/                    # Reusable test scenarios
│   ├── simple-web-app.md
│   ├── multi-region-ha.md
│   ├── hub-spoke-network.md
│   └── microservices-aks.md
└── baseline/                          # Pre-improvement baseline results
    └── run-2025-11-18/
```

---

## Test Types

### 1. Functional Tests
**Purpose:** Verify agents produce correct output format and structure

**Examples:**
- ADR includes all required sections
- Architect assessment covers all 5 WAF pillars
- Planning creates valid Mermaid diagrams
- Implementation generates valid Bicep code

### 2. Quality Tests
**Purpose:** Validate completeness, accuracy, and usefulness

**Examples:**
- Cost estimates within ±20% accuracy
- Dependency diagrams accurately represent relationships
- Security best practices properly implemented
- Documentation is clear and actionable

### 3. Integration Tests
**Purpose:** Ensure agents work together seamlessly

**Examples:**
- Handoffs between agents function correctly
- Context preserved across agent transitions
- Outputs from one agent correctly consumed by next
- Four-mode workflow completes successfully

### 4. Regression Tests
**Purpose:** Verify improvements don't break existing functionality

**Examples:**
- Simple scenarios still work as before
- Existing outputs remain valid
- Performance doesn't degrade
- No new errors introduced

---

## Running Tests

### Quick Start

```powershell
# Run all tests
.\Run-AgentTests.ps1 -Agent all -Verbose

# Test specific agent
.\Run-AgentTests.ps1 -Agent azure-architect

# Test specific scenario
.\Run-AgentTests.ps1 -Agent bicep-plan -Scenario "hub-spoke-network"

# Run regression tests only
.\Run-AgentTests.ps1 -TestType regression

# Generate HTML report
.\Generate-TestReport.ps1 -OutputPath ".\test-results.html"
```

### Manual Testing Workflow

1. **Select Agent:** Press `Ctrl+Shift+A` and choose agent
2. **Load Test Scenario:** Copy prompt from `test-cases/` file
3. **Execute Test:** Submit prompt to agent
4. **Capture Output:** Save agent response to `actual-outputs/`
5. **Compare Results:** Use VS Code diff view to compare with expected output
6. **Document Results:** Update test results in tracking file

---

## Test Scenarios

### Simple Web App
**Complexity:** Low  
**Resources:** App Service, SQL Database, Storage Account  
**Best For:** Basic functionality testing

### Multi-Region HA
**Complexity:** Medium  
**Resources:** Front Door, App Services (2 regions), SQL geo-replication  
**Best For:** Cost estimation, WAF assessment

### Hub-Spoke Network
**Complexity:** Medium  
**Resources:** VNets, Azure Firewall, VNet peering, Private DNS  
**Best For:** Dependency visualization, network planning

### Microservices on AKS
**Complexity:** High  
**Resources:** AKS, ACR, Key Vault, App Gateway, Multiple microservices  
**Best For:** Progressive implementation, complex scenarios

---

## Success Criteria

### Per-Agent Criteria

#### ADR Generator
- [ ] ADR file created in `/docs/adr/` with correct naming
- [ ] All required sections present and complete
- [ ] At least 2 alternatives documented
- [ ] Both positive and negative consequences listed
- [ ] Proper coded bullet points (POS-XXX, NEG-XXX)
- [ ] Front matter properly formatted

#### Azure Principal Architect
- [ ] All 5 WAF pillars assessed with scores (X/10)
- [ ] Confidence level provided (High/Medium/Low)
- [ ] Cost estimates included with ranges ($X-Y/month)
- [ ] Trade-offs explicitly discussed
- [ ] Reference to Azure Architecture Center
- [ ] Specific Azure services and SKUs recommended

#### Bicep Planning Specialist
- [ ] Plan file created in `.bicep-planning-files/`
- [ ] Resource breakdown with YAML blocks
- [ ] Mermaid dependency diagram included and valid
- [ ] Cost estimation table with totals
- [ ] Testing strategy documented
- [ ] Rollback procedures included
- [ ] Phase-based implementation plan

#### Bicep Implementation Specialist
- [ ] Valid Bicep files generated
- [ ] `bicep build` succeeds without errors
- [ ] `bicep lint` passes (or warnings documented)
- [ ] Required tags on all resources
- [ ] Security defaults properly configured
- [ ] Outputs properly defined
- [ ] Deployment script generated (complex scenarios)

### Overall Workflow Criteria
- [ ] Four-agent workflow completes end-to-end
- [ ] Handoffs preserve context correctly
- [ ] Total time reduced by 30%+ vs. manual approach
- [ ] User clarification questions reduced by 50%+

---

## Metrics Tracking

### Baseline Metrics (Before Improvements)
| Metric | Value | Date Measured |
|--------|-------|---------------|
| Average workflow time | 60 min | TBD |
| Clarification questions | 8-10 | TBD |
| Cost estimate accuracy | N/A | TBD |
| Test pass rate | N/A | TBD |

### Current Metrics
| Metric | Value | Date Measured | Change |
|--------|-------|---------------|--------|
| Average workflow time | TBD | TBD | TBD |
| Clarification questions | TBD | TBD | TBD |
| Cost estimate accuracy | TBD | TBD | TBD |
| Test pass rate | TBD | TBD | TBD |

---

## Test Execution Log

### Run #1: Baseline (Scheduled: 2025-11-22)
**Objective:** Establish baseline before improvements  
**Status:** Not Started  
**Results:** Pending

### Run #2: Priority 1 Validation (Scheduled: 2025-11-29)
**Objective:** Validate cost estimation features  
**Status:** Not Started  
**Results:** Pending

### Run #3: Full Validation (Scheduled: 2025-12-13)
**Objective:** Complete regression and quality testing  
**Status:** Not Started  
**Results:** Pending

---

## Issue Tracking

### Open Issues
None currently

### Resolved Issues
None currently

### Known Limitations
- Manual test execution required (automation in progress)
- Cost accuracy validation requires Azure deployment
- Mermaid diagram validation limited to syntax checking

---

## Contributing

### Adding New Test Cases

1. **Create test scenario** in `test-scenarios/`
2. **Document test case** in appropriate `test-cases/*.md` file
3. **Create expected output** in `expected-outputs/`
4. **Update test runner** if needed for automation
5. **Document success criteria**

### Improving Test Runner

1. **Fork and branch** the repository
2. **Enhance `Run-AgentTests.ps1`** with new features
3. **Test improvements** on all agent types
4. **Submit pull request** with documentation

---

## Resources

### Documentation
- [Four-Mode Workflow](../../resources/copilot-customizations/FOUR-MODE-WORKFLOW.md)
- [Agent Definitions](../../.github/agents/)
- [Agent Improvements Roadmap](../../docs/agent-improvements/ROADMAP.md)
- [Testing Results](../../docs/agent-improvements/TESTING-RESULTS.md)

### Tools
- **VS Code:** Primary testing environment
- **GitHub Copilot:** Custom agents
- **PowerShell 7+:** Test automation
- **Bicep CLI:** Template validation
- **Azure CLI:** Deployment testing

---

## FAQ

### Q: How often should tests be run?
**A:** Run full test suite:
- After any agent definition changes
- Before releasing new agent versions
- Weekly during active development
- Monthly for maintenance

### Q: What if a test fails?
**A:** 
1. Review actual vs. expected output
2. Determine if failure is regression or expected change
3. Update agent definition if regression found
4. Update expected output if change is intentional
5. Document the issue and resolution

### Q: Can tests be automated?
**A:** Partially. Currently:
- ✅ Syntax validation (automated)
- ✅ Output format checking (automated)
- ⚠️ Content quality (manual review)
- ⚠️ Cost accuracy (requires Azure deployment)
- ⚠️ User experience (manual evaluation)

### Q: How do I add a new test scenario?
**A:** 
1. Create scenario definition in `test-scenarios/`
2. Add test case to relevant `test-cases/*.md`
3. Create expected output sample
4. Update test runner to include new scenario
5. Document in this README

---

**Maintained By:** GitHub Copilot IT Pro Team  
**Questions:** Open an issue in the repository  
**Last Test Run:** Not yet executed
