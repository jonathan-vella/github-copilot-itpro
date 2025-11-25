# S05 Service Validation - Effective Prompts

## The Discovery-First Approach

> "The best prompts aren't commands—they're conversations that uncover what you
> actually need to validate."

This guide emphasizes **asking the right questions** before generating tests. The agents
are designed to guide you through discovery, not just execute commands.

---

## Understanding Before Generating

### Why Discovery Matters

Most validation failures come from testing the wrong things:

| Common Mistake | Discovery Question |
|----------------|-------------------|
| Testing happy paths only | "What would cause this to fail in production?" |
| Generic performance tests | "What load pattern matches your actual traffic?" |
| Missing compliance checks | "Who needs to sign off on this validation?" |
| Arbitrary thresholds | "What SLA did you commit to customers?" |

### The Five Discovery Questions

Before any validation session, answer these:

1. **What are you actually testing?** (Not just the URL—the business capability)
2. **What does success look like?** (Define pass criteria upfront)
3. **Who needs to approve this?** (Compliance, security, business stakeholders)
4. **What would cause failure in production?** (Edge cases matter)
5. **How will you prove it worked?** (Evidence, not just pass/fail)

---

## UAT Assistant Discovery Patterns

### Starting with Context (Not Commands)

**❌ Task-first approach:**

```text
@uat-assistant Write UAT tests for my API
```

**✅ Discovery-first approach:**

```text
@uat-assistant I need to validate a healthcare API before production.
It handles patient data and needs HIPAA compliance evidence.
```

The agent will now ask the RIGHT follow-up questions.

### Discovery Questions the Agent Will Ask

When you start a UAT session, expect these questions:

```text
Agent: What service are you testing?
→ Your answer shapes the test categories

Agent: What does success look like for your stakeholders?
→ Defines acceptance criteria beyond "it works"

Agent: Are there compliance or security requirements?
→ Adds compliance tests most people forget

Agent: What would cause this validation to fail?
→ Identifies edge cases and failure scenarios

Agent: Who needs to sign off on the results?
→ Ensures report format meets approval needs
```

### Understanding Test Categories

Before running tests, understand what each category validates:

**Functional Validation** (16 tests):

- Why: Proves the API does what it's supposed to do
- Includes: Endpoints, responses, data formats, error handling
- Evidence: Response codes, payload structure, error messages

**Compliance Validation** (4 tests):

- Why: Proves regulatory requirements are met
- Includes: No PHI exposure, encryption, audit trails
- Evidence: Headers checked, logs verified, security scan

**Performance Baseline** (4 tests):

- Why: Establishes baseline for load testing
- Includes: Response times, database efficiency
- Evidence: Timing measurements, resource utilization

### Teaching Moment: Why 24 Tests?

Ask the agent:

```text
Why did you suggest these specific 24 tests instead of a different number?
```

Understanding the test design helps you:

- Add custom tests for your specific requirements
- Know which tests to prioritize when time is limited
- Explain the coverage to stakeholders

---

## Load Test Assistant Discovery Patterns

### Understanding Before Testing

**❌ Generic request:**

```text
@loadtest-assistant Load test my API
```

**✅ Contextual request:**

```text
@loadtest-assistant I need to prove our API can handle Black Friday traffic.
We expect 5x normal load for 2 hours starting at 6 AM.
```

### Critical Discovery: Load Pattern Selection

The agent will ask about load patterns. Understanding these matters:

```text
Agent: What load pattern matches your production reality?

Option 1: Ramp-up (gradual increase)
→ Use for: Capacity planning, finding breaking points
→ Reality: Most web traffic grows gradually

Option 2: Spike (sudden burst)
→ Use for: Flash sales, viral events, marketing campaigns
→ Reality: Systems often fail on sudden spikes, not gradual load

Option 3: Sustained (constant load)
→ Use for: Stability testing, memory leak detection
→ Reality: 24/7 services need to prove long-term stability

Option 4: Step (incremental increases)
→ Use for: Finding exact limits, pricing tier decisions
→ Reality: "How many users can this tier handle?"
```

**Ask the agent:**

```text
Why does the load pattern choice affect my test design so much?
```

### Understanding Performance Thresholds

Before accepting default thresholds, understand them:

```text
Agent: What are your performance targets?

You: I'm not sure what's reasonable.

Agent: Let me help you decide:
- p95 < 200ms = Excellent (SaaS products, real-time apps)
- p95 < 500ms = Good (Standard web applications)
- p95 < 1000ms = Acceptable (Background processes, batch jobs)
- p95 > 1000ms = Needs improvement

What response time would frustrate your users?
```

### Teaching Moment: Bottleneck Analysis

When results come back, don't just read numbers—understand them:

```text
Ask: What's causing the bottleneck at 180 concurrent users?

Agent: Database connection pool exhausted. Here's why:
- Default pool: 30 connections
- Each request holds connection: 50ms avg
- At 180 VUs × 50ms = 9000ms connection-seconds/second
- Pool capacity: 30 × 1000ms = 30,000ms connection-seconds/second
- Reality: Not all requests are 50ms—some are 200ms+
- Result: Pool exhaustion at peak load

Solution: Increase pool to 100 connections ($0 cost change)
Alternative: Optimize slow queries (reduce hold time)
```

---

## Advanced Discovery Techniques

### Cross-Referencing Requirements

Use this pattern to ensure complete coverage:

```text
@uat-assistant Here are our acceptance criteria from the requirements doc.
Help me map each requirement to a specific test:

1. All endpoints return within 600ms
2. Database connectivity verified
3. No credentials exposed in responses
4. HTTPS enforced
5. Health check available for monitoring
```

Agent will map requirements → tests → evidence.

### Compliance Evidence Generation

For regulated industries (healthcare, finance, government):

```text
@uat-assistant This validation needs to satisfy an auditor.
What evidence should we capture beyond pass/fail results?
```

Agent will suggest:

- Timestamp every test execution
- Capture request/response pairs (sanitized)
- Log who ran the tests and when
- Generate checksums for report integrity
- Include environment details (versions, configurations)

### Failure Mode Exploration

Discover edge cases before production finds them:

```text
@uat-assistant What failure scenarios should we test that aren't obvious?
```

Agent considers:

- What if the database is slow but not down?
- What if authentication succeeds but authorization fails?
- What if partial data is returned (pagination edge cases)?
- What if concurrent requests modify the same resource?
- What if the upstream service returns valid but stale data?

---

## Agent-Specific Prompt Patterns

### UAT Assistant Prompts

**Starting a session:**

```text
@uat-assistant I need to validate [service name] for [purpose].
Key stakeholders are [who needs sign-off].
Critical requirements: [list compliance/security needs].
```

**During execution:**

```text
"Why did that test fail?"
"What should I check manually to verify this?"
"Add a test for [specific scenario]"
"Skip the database tests—they're not in scope"
```

**Completing validation:**

```text
"Generate the report with executive summary"
"What's the overall confidence level?"
"List the tests that need manual verification"
```

### Load Test Assistant Prompts

**Starting a session:**

```text
@loadtest-assistant I need to validate [service] can handle [scenario].
Production traffic pattern: [description].
SLA commitments: [targets].
```

**During analysis:**

```text
"What's causing the p95 spike at 3 minutes?"
"Is this a client or server bottleneck?"
"How much would it cost to handle 2x this load?"
"Compare this to our last test run"
```

**Planning improvements:**

```text
"What's the cheapest fix for this bottleneck?"
"Generate the configuration changes needed"
"What should we monitor in production?"
```

---

## Testing the Tests: Meta-Validation

### Validating Your Test Design

Before running tests, ask:

```text
@uat-assistant Review my test plan. What am I missing?
```

```text
@loadtest-assistant Is this load pattern realistic for our use case?
```

### Understanding Coverage Gaps

After tests complete:

```text
"What scenarios weren't covered by these tests?"
"What would a malicious user try that we didn't test?"
"What integration points didn't we validate?"
```

### Calibrating Confidence

```text
"On a scale of 1-10, how confident should I be in this validation?"
"What additional testing would increase confidence?"
"What's the risk of going to production with these results?"
```

---

## CI/CD Integration Prompts

### Pipeline Design Discovery

```text
@uat-assistant We want to run these tests in CI/CD.
What's the minimum test set that should block deployments?
Which tests should run post-deployment as smoke tests?
```

### Performance Gate Configuration

```text
@loadtest-assistant Help me set up a performance gate.
What metrics should block a release?
What's a reasonable threshold for a staging environment?
```

---

## Report Generation Prompts

### Executive Summary

```text
"Generate a one-paragraph executive summary for non-technical stakeholders"
```

### Technical Details

```text
"Include the raw test output for debugging purposes"
```

### Action Items

```text
"List specific action items ranked by priority and effort"
```

### Sign-Off Readiness

```text
"Is this report ready for sign-off? What's missing?"
```

---

## Learning Moment Prompts

Use these to deepen your understanding:

```text
"Explain why you chose that test approach"
"What would happen if we skipped this test category?"
"How does this compare to industry best practices?"
"What would you do differently for a financial service?"
"Teach me how to interpret these load test metrics"
```

---

## Quick Reference: Discovery Questions

### Before UAT

- [ ] What business capability am I validating?
- [ ] What compliance requirements apply?
- [ ] Who needs to sign off?
- [ ] What would cause production failures?
- [ ] What evidence do auditors need?

### Before Load Testing

- [ ] What's my actual traffic pattern?
- [ ] What SLA did I commit to?
- [ ] What's my current baseline?
- [ ] Who pays if this fails in production?
- [ ] What scaling options do I have?

### After Any Test

- [ ] Do I understand WHY tests passed/failed?
- [ ] Can I explain results to stakeholders?
- [ ] What risks remain after this validation?
- [ ] What should I monitor in production?
- [ ] When should I re-validate?

---

*"Testing isn't about proving your code works. It's about proving your
system delivers what stakeholders actually need."*
