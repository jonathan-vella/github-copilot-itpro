# Manual Approach: Time Tracking

## Scenario: PowerShell Automation for Azure Operations

**Objective**: Create PowerShell scripts for:

1. Resource reporting across subscriptions
2. Compliance auditing (untagged resources)
3. Orphaned resource cleanup
4. Bulk tagging operations

**Approach**: Manual development without GitHub Copilot assistance

---

## Timeline (Manual Development)

### Phase 1: Research & Planning (15 minutes)

**Time: 0:00 - 0:15**

- Search PowerShell documentation for Az module cmdlets
- Review Azure Resource Manager API patterns
- Research CSV export formatting options
- Look up parameter validation syntax
- Find examples of progress bar implementations
- **Challenges**:
  - Outdated examples in search results
  - Multiple conflicting patterns for same tasks
  - Unclear which Az modules are required

### Phase 2: Script Structure Setup (10 minutes)

**Time: 0:15 - 0:25**

- Create basic script templates
- Add comment-based help headers (manual typing)
- Define parameter blocks
- Set up error handling scaffolding
- **Issues**:
  - Typos in parameter attribute syntax (`[Parameter(Manditory=$true)]` vs `Mandatory`)
  - Forgot `CmdletBinding()` decorator initially
  - Had to look up proper help comment format

### Phase 3: Get-AzResourceReport Development (20 minutes)

**Time: 0:25 - 0:45**

- Write subscription context logic
- Implement Get-AzResource calls
- Create CSV export logic
- Add JSON export option
- Implement HTML report generation
- Add progress bars
- **Errors**:
  - First attempt: Forgot to select specific properties, output too verbose
  - Second attempt: Progress bar calculation off by one error
  - Third attempt: HTML export missing CSS styling
  - Debugging time: 8 minutes

### Phase 4: Find-UntaggedResources Development (15 minutes)

**Time: 0:45 - 1:00**

- Implement tag checking logic
- Add required tags validation
- Create color-coded console output
- Add CSV export functionality
- **Issues**:
  - Logic error in tag checking (used `-and` instead of `-or`)
  - Color formatting not working (wrong parameter name)
  - Had to test multiple times to get filtering right

### Phase 5: Remove-OrphanedResources Development (25 minutes)

**Time: 1:00 - 1:25**

- Research orphaned resource identification patterns
- Implement disk detection (`ManagedBy` property)
- Add NIC detection logic
- Create public IP identification
- Implement cost estimation logic
- Add safety confirmation prompts
- **Major Issues**:
  - Didn't know about `ManagedBy` property initially (10 min research)
  - Cost estimation values had to be manually looked up
  - Remove logic needed multiple safety checks (refactored 3 times)
  - Parallel processing attempt caused job management errors (abandoned)

### Phase 6: Set-BulkTags Development (20 minutes)

**Time: 1:25 - 1:45**

- Implement resource filtering
- Create tag merge logic
- Add dry-run mode
- Implement parallel processing with Start-Job
- Add confirmation prompts
- **Challenges**:
  - Parallel job management more complex than expected
  - Had to debug ArgumentList parameter passing
  - Job cleanup logic caused memory leaks initially
  - Progress calculation incorrect for batched operations

### Phase 7: Testing & Debugging (15 minutes)

**Time: 1:45 - 2:00**

- Test each script individually
- Fix parameter validation errors
- Correct output formatting issues
- Add missing error handling
- **Bugs Found**:
  - Scripts failed on subscriptions with no resources
  - Export paths not handling spaces correctly
  - Some error messages too generic
  - Progress bars not clearing properly

### Phase 8: Documentation & Polish (10 minutes)

**Time: 2:00 - 2:10**

- Complete comment-based help examples
- Add usage notes
- Create README documentation
- Add inline comments for complex logic

---

## Total Time Summary

| Phase | Activity | Time |
|-------|----------|------|
| 1 | Research & Planning | 15 min |
| 2 | Script Structure | 10 min |
| 3 | Resource Report Script | 20 min |
| 4 | Untagged Resources Script | 15 min |
| 5 | Orphaned Resources Script | 25 min |
| 6 | Bulk Tagging Script | 20 min |
| 7 | Testing & Debugging | 15 min |
| 8 | Documentation | 10 min |
| **TOTAL** | **Complete Solution** | **130 minutes (2h 10m)** |

---

## Error Summary

### Syntax Errors

- Parameter attribute typos: 3 occurrences
- Variable name typos: 5 occurrences
- Missing semicolons/braces: 2 occurrences
- **Total time debugging syntax**: 12 minutes

### Logic Errors

- Incorrect filtering logic: 4 occurrences
- Off-by-one errors: 2 occurrences
- Wrong parameter types: 3 occurrences
- **Total time debugging logic**: 18 minutes

### Knowledge Gaps

- Unknown cmdlet properties: 3 researches (15 min)
- Parallel processing patterns: 2 researches (8 min)
- Azure pricing lookups: 1 research (5 min)
- **Total research time**: 28 minutes

---

## Key Pain Points

### Time Wasters

1. **Research Time**: 28 minutes searching for correct patterns and syntax
2. **Syntax Errors**: 12 minutes fixing typos and formatting
3. **Logic Debugging**: 18 minutes testing and fixing incorrect implementations
4. **Refactoring**: 15 minutes rewriting sections that didn't work as expected

### Frustration Points

- Outdated documentation examples that don't work with current Az modules
- Trial-and-error approach for complex features (parallel processing, progress bars)
- Having to context-switch between multiple browser tabs for different cmdlets
- Inconsistent parameter naming across Az cmdlets
- No immediate feedback on best practices or common patterns

### Quality Concerns

- First implementations were functional but not optimized
- Missing error handling initially
- Inconsistent code style across scripts
- Could have used more helper functions for DRY principle

---

## Team Impact (12-Person Team)

### Weekly Time Investment (Per Admin)

- Script development: 2 hours 10 minutes
- Testing in non-prod: 30 minutes
- Peer review: 20 minutes
- **Total per admin**: 3 hours

### Annual Team Time Investment

- Hours per admin per year: 3 hours × 4 major scripts = 12 hours
- Total team hours: 12 hours × 12 admins = **144 hours**

### Ongoing Maintenance

- Bug fixes and updates: 2 hours per script per year
- Total maintenance: 8 hours × 12 admins = **96 hours/year**

**Total Annual Time Investment**: 144 + 96 = **240 hours** (manual approach)

---

## Comparison: Manual vs. Copilot

| Metric | Manual Approach | With Copilot | Improvement |
|--------|----------------|--------------|-------------|
| Development Time | 130 minutes | 15 minutes | **88% reduction** |
| Syntax Errors | 10 errors | 0-1 errors | **90% reduction** |
| Research Time | 28 minutes | 2 minutes | **93% reduction** |
| Debugging Time | 30 minutes | 3 minutes | **90% reduction** |
| First-Run Success | 40% | 95% | **138% increase** |
| Code Quality | Good | Excellent | Best practices built-in |
| Annual Team Time | 240 hours | 29 hours | **211 hours saved** (88% reduction) |

---

## Key Learnings

### What Took Longest

1. Research and documentation lookup (28 min)
2. Debugging and fixing errors (30 min)
3. Implementing complex features from scratch (25 min for orphaned resources)

### What Could Have Been Avoided

- Most syntax errors (auto-completion would catch)
- Research time for standard patterns (Copilot knows best practices)
- Trial-and-error for complex features (Copilot suggests working patterns)
- Inconsistent code style (Copilot follows conventions)

### Hidden Costs

- **Context switching**: Interrupts flow, reduces productivity
- **Cognitive load**: Remembering syntax, parameter names, patterns
- **Missed optimizations**: Manual code often less efficient
- **Technical debt**: Quick solutions now = maintenance burden later
