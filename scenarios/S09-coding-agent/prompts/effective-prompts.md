# Effective Prompts for Copilot Coding Agent

> **Key Insight:** With Coding Agent, your "prompt" is the GitHub Issue itself.
> The quality of your issue directly determines the quality of Copilot's implementation.

---

## Issue Writing Framework

### The CRISP Method

| Element | Description | Example |
|---------|-------------|---------|
| **C**ontext | Where is the code? What exists? | "The patient portal in `infra/bicep/contoso-patient-portal/`" |
| **R**equirements | What specifically needs to be done? | "Add 4 alert rules: CPU, Memory, HTTP 5xx, Response Time" |
| **I**mplementation | How should it be built? | "Create module `monitoring-alerts.bicep`, follow existing patterns" |
| **S**tandards | What conventions apply? | "swedencentral region, standard tags, CAF naming" |
| **P**roof | How do we verify success? | "bicep build succeeds, all alerts created" |

---

## Issue Templates by Task Type

### 1. Add New Module

```markdown
## Add [Module Name] to [Project]

### Context
[Brief description of the existing infrastructure and why this module is needed]

The infrastructure in `[path/to/code]` currently [describe current state].

### Requirements

**Resources to Create:**
1. [Resource 1 with specific configuration]
2. [Resource 2 with specific configuration]
3. [Resource 3 with specific configuration]

**Configuration:**
- [Key configuration 1]
- [Key configuration 2]

### Implementation Requirements
- Create new module: `modules/[module-name].bicep`
- Follow patterns in `modules/[existing-module].bicep`
- Use `swedencentral` region
- Include tags: Environment, ManagedBy, Project
- Wire into `main.bicep`
- Update `README.md`

### Acceptance Criteria
- [ ] `bicep build main.bicep` succeeds
- [ ] [Specific functional requirement 1]
- [ ] [Specific functional requirement 2]
- [ ] README updated with new module documentation
```

### 2. Update Existing Code

```markdown
## Update [Component] in [Project]

### Context
The [component] in `[path/to/file]` needs to be updated because [reason].

Current state: [describe what exists]
Desired state: [describe what should change]

### Changes Required

**File: `[path/to/file1]`**
- [ ] Change [X] from [current] to [new]
- [ ] Add [new configuration]

**File: `[path/to/file2]`**
- [ ] Update [Y] to include [Z]

### Constraints
- Do NOT change [protected aspects]
- Maintain backward compatibility with [existing consumers]
- Follow [specific pattern or standard]

### Acceptance Criteria
- [ ] All changes applied correctly
- [ ] `bicep build` / `terraform validate` succeeds
- [ ] [Specific validation requirement]
```

### 3. Documentation Task

```markdown
## Generate Documentation for [Component]

### Context
The [component] in `[path/to/code]` lacks proper documentation.

### Documentation Requirements

**README.md should include:**
1. Overview of what the module/code does
2. Prerequisites
3. Parameters/variables table with descriptions
4. Usage examples
5. Outputs and what they're used for

**Inline comments should:**
- Explain complex logic
- Document parameter choices
- Reference Azure documentation where helpful

### Style Requirements
- Use Mermaid diagrams for architecture
- Follow existing README patterns in the repo
- Keep descriptions concise but complete

### Acceptance Criteria
- [ ] README.md created/updated
- [ ] All parameters documented
- [ ] At least one usage example included
- [ ] Architecture diagram (if applicable)
```

---

## Good vs. Bad Issues

### ❌ Bad Issue

```markdown
Title: Add monitoring

Add some monitoring to the patient portal.
```

**Why it fails:**
- No context (which patient portal? where?)
- No specific requirements (what kind of monitoring?)
- No implementation guidance
- No acceptance criteria

### ✅ Good Issue

```markdown
Title: Add Azure Monitor alerts to patient portal infrastructure

## Context
The patient portal infrastructure in `infra/bicep/contoso-patient-portal/` 
was deployed last week but has no monitoring configured. We need alerts 
before the production go-live on Friday.

## Requirements

**Alert Rules:**
1. CPU Alert: > 80% for 5 minutes → Warning
2. Memory Alert: > 85% for 5 minutes → Warning
3. HTTP 5xx Alert: > 10 errors in 5 minutes → Critical
4. Response Time Alert: > 3 seconds average → Warning

**Action Group:**
- Create action group `ag-patient-portal-alerts`
- Email notifications (email address as parameter)
- Severity levels should determine notification urgency

## Implementation
- Create `modules/monitoring-alerts.bicep`
- Follow the pattern used in `modules/app-service.bicep`
- Use Log Analytics workspace from `modules/log-analytics.bicep`
- Default region: swedencentral
- Tags: Environment, ManagedBy, Project

## Acceptance Criteria
- [ ] `bicep build main.bicep` succeeds with no errors
- [ ] 4 alert rules created with specified thresholds
- [ ] Action group properly configured
- [ ] Module integrated into main.bicep
- [ ] README.md updated with monitoring documentation
```

---

## Tips for Better Results

### 1. Reference Existing Code

```markdown
Follow the pattern used in `modules/key-vault.bicep` for:
- Parameter naming conventions
- Output structure
- Error handling
```

### 2. Be Specific About Thresholds

```markdown
❌ "Alert when CPU is high"
✅ "Alert when CPU > 80% for 5 consecutive minutes"
```

### 3. Include Constraints

```markdown
**Constraints:**
- Do NOT modify existing alert rules
- Use existing Log Analytics workspace (don't create new)
- Maximum 10 alert rules (Azure limit consideration)
```

### 4. Specify File Locations

```markdown
**Files to create:**
- `modules/monitoring-alerts.bicep` (new)

**Files to modify:**
- `main.bicep` (add module reference)
- `README.md` (add documentation section)
```

### 5. Provide Examples When Helpful

```markdown
**Example alert rule format:**
```bicep
resource cpuAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-cpu-${appServiceName}'
  // ... Copilot should follow this pattern
}
```
```

---

## Scoping Your Issues

### Right-Sized Issues

| Too Small | Right Size | Too Large |
|-----------|------------|-----------|
| "Fix typo in README" | "Add monitoring module with 4 alerts" | "Refactor entire infrastructure" |
| "Add one parameter" | "Create new storage module" | "Convert Terraform to Bicep" |
| "Update one tag" | "Apply tags across all modules" | "Redesign architecture" |

### Signs Your Issue is Too Large

- More than 10 files need changes
- Multiple unrelated concerns
- Would take > 4 hours manually
- Requires design decisions

**Solution:** Break into multiple issues with dependencies

```markdown
Issue 1: Create base monitoring module (no alerts)
Issue 2: Add CPU and memory alerts (depends on #1)
Issue 3: Add HTTP and response time alerts (depends on #1)
Issue 4: Create monitoring dashboard (depends on #2, #3)
```

---

## Iterating with Copilot

### If the PR Needs Changes

Comment directly on the PR:

```markdown
@github-copilot Please make these changes:

1. The CPU threshold should be 85%, not 80%
2. Add a "Critical" severity alert for CPU > 95%
3. Include the action group in the module outputs
```

Copilot will push additional commits to address feedback.

### If Starting Over

Close the PR and create a new issue with clarified requirements.

---

## Discovery Questions

Before writing your issue, ask yourself:

1. **What exists?** What code/infrastructure is already in place?
2. **What's missing?** What specific gap am I filling?
3. **What patterns?** What conventions should Copilot follow?
4. **What constraints?** What should NOT change?
5. **How to verify?** How will I know it's correct?

These questions become the structure of your issue.
