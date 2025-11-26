# S09: GitHub Copilot Coding Agent - Demo Script

> **Duration:** 10-15 minutes
> **Audience:** IT Pros, DevOps Engineers, Technical Decision Makers
> **Goal:** Show how Copilot Coding Agent autonomously implements infrastructure from GitHub Issues

---

## Pre-Demo Setup (15 minutes before)

### Environment Verification

```bash
# 1. Verify you're logged into GitHub CLI
gh auth status

# 2. Verify Copilot Coding Agent is available
# Go to any issue → Check if "Copilot" appears in assignee dropdown

# 3. Pre-open these browser tabs:
#    - This repository's Issues page
#    - Azure Portal (logged in)
#    - This demo script

# 4. Have VS Code open with the repo
```

### Backup Plan

If Copilot is slow or unavailable:

- Show a previously completed PR from Copilot
- Walk through the session logs explaining what happened
- Demo the interactive workflow instead (S03)

---

## Demo Timeline

| Time  | Phase          | What You're Doing                        |
| ----- | -------------- | ---------------------------------------- |
| 0:00  | Opening        | Set the scene, explain Coding Agent      |
| 2:00  | Issue Creation | Write/show the issue                     |
| 5:00  | Assignment     | Assign to Copilot, explain what happens  |
| 7:00  | Waiting        | Talk about use cases while Copilot works |
| 10:00 | PR Review      | Show the generated PR and code           |
| 13:00 | Wrap-up        | Metrics, Q&A                             |

---

## 🎬 Opening: What is Coding Agent? (0:00 - 2:00)

### What to Say

> "You're probably familiar with GitHub Copilot in VS Code—you type, it suggests code.
> But what if Copilot could work on tasks **while you're doing something else**?
>
> That's GitHub Copilot Coding Agent. You create a GitHub Issue describing what you need,
> assign it to Copilot, and it **autonomously** analyzes your codebase, implements the
> changes, and opens a Pull Request.
>
> Let me show you a real example. Imagine you've just deployed infrastructure for a
> patient portal, but you forgot to add monitoring. Your on-call shift starts tomorrow.
> Let's fix that—without writing any code ourselves."

### What to Show

1. Open the repository's Issues page
2. Briefly show the existing codebase (`infra/bicep/contoso-patient-portal/`)
3. Point out there's no monitoring module yet

---

## 📝 Stage 1: Creating the Issue (2:00 - 5:00)

### What to Do

**Option A: Use Pre-Written Issue (Recommended for smooth demo)**

1. Click **New Issue**
2. Select **"Copilot Agent Task"** template (if created)
3. Or paste this content:

```markdown
## Add Azure Monitor Alerts to Patient Portal

### Context

The patient portal infrastructure in `infra/bicep/contoso-patient-portal/` needs
monitoring before production go-live. Currently there are no alert rules configured.

### Requirements

**Alert Rules to Create:**

1. **CPU Alert**: Trigger when App Service CPU > 80% for 5 minutes
2. **Memory Alert**: Trigger when memory > 85% for 5 minutes
3. **HTTP 5xx Alert**: Trigger when HTTP 500 errors > 10 in 5 minutes
4. **Response Time Alert**: Trigger when avg response time > 3 seconds

**Action Group:**

- Create email action group for alerts
- Email parameter should be configurable

**Implementation Requirements:**

- Create new module: `modules/monitoring-alerts.bicep`
- Follow existing patterns in the codebase
- Use `swedencentral` region
- Include standard tags (Environment, ManagedBy, Project)
- Wire into `main.bicep`
- Update `README.md` with monitoring section

### Acceptance Criteria

- [ ] `bicep build` succeeds with no errors
- [ ] All 4 alert rules are created
- [ ] Action group is properly configured
- [ ] Module follows existing naming conventions
- [ ] README documents the new alerts
```

### What to Highlight

> "Notice how I'm writing this issue:
>
> - **Clear context**: I tell Copilot exactly where the code lives
> - **Specific requirements**: Not 'add monitoring' but specific alert thresholds
> - **Implementation guidance**: Follow existing patterns, specific region, tags
> - **Acceptance criteria**: How we'll know it's done
>
> The quality of your issue directly affects the quality of Copilot's output.
> Think of it as pair programming—you're giving your partner clear instructions."

---

## 🤖 Stage 2: Assigning to Copilot (5:00 - 7:00)

### What to Do

1. Click **Assignees** on the right sidebar
2. Select **Copilot** from the dropdown
3. Click **Submit new issue**

### What to Say

> "Now I assign this to Copilot. Watch what happens..."
>
> [Copilot will add a comment saying it's starting work]
>
> "Copilot is now:
>
> 1. Analyzing our entire codebase structure
> 2. Understanding the existing Bicep patterns
> 3. Planning the implementation
> 4. Writing the code
> 5. Creating a branch and PR
>
> This typically takes 2-10 minutes depending on complexity. While we wait,
> let me tell you about other use cases..."

---

## ⏳ Stage 3: While Waiting (7:00 - 10:00)

### What to Say (Fill Time)

> "Here are perfect tasks for Coding Agent:
>
> **Infrastructure additions:**
>
> - Add monitoring to existing deployments (like we're doing)
> - Create new Bicep modules following existing patterns
> - Add tags or update configurations across modules
>
> **Documentation:**
>
> - Generate README files for undocumented code
> - Add inline comments to complex templates
> - Create architecture diagrams
>
> **Refactoring:**
>
> - Convert inline resources to modules
> - Update API versions across all files
> - Apply naming convention changes
>
> **What's NOT ideal:**
>
> - Greenfield architecture design (use interactive agents)
> - Security-critical changes (need human design)
> - Complex multi-system integrations"

### Check Progress

- Refresh the issue page to see Copilot's status comments
- If PR appears, move to Stage 4

---

## 🔍 Stage 4: Reviewing the PR (10:00 - 13:00)

### What to Do

1. Click the PR link in the issue (or go to Pull Requests)
2. Show the **Files Changed** tab
3. Show the **Session Logs** (Copilot's reasoning)

### What to Highlight

**In the PR description:**

> "Look at this PR description—Copilot explains what it did and why.
> This is your audit trail."

**In the code:**

> "Let's look at the generated Bicep:
>
> - It followed our naming conventions
> - Used the same parameter patterns as other modules
> - Included the required tags
> - Wired everything into main.bicep"

**Session logs:**

> "These session logs show Copilot's reasoning. This is incredibly valuable for
> understanding why it made certain decisions—and for debugging if something's wrong."

### Live Validation

```bash
# In VS Code terminal
cd infra/bicep/contoso-patient-portal
bicep build main.bicep
bicep lint main.bicep
```

> "Zero errors. This is near-production-ready code."

---

## 🎯 Wrap-up: The Results (13:00 - 15:00)

### State the Metrics

> "Let's talk about what just happened:
>
> | Task                      | Manual        | With Coding Agent     |
> | ------------------------- | ------------- | --------------------- |
> | Write monitoring module   | 2-3 hours     | 5 min (issue writing) |
> | Research alert thresholds | 30 min        | Included              |
> | Wire into existing code   | 30 min        | Included              |
> | Update documentation      | 30 min        | Included              |
> | **Total**                 | **3-4 hours** | **5 min + review**    |
>
> That's **90%+ time savings** on a routine infrastructure task."

### Call to Action

> "To use Coding Agent yourself:
>
> 1. Verify it's enabled in your GitHub org (Copilot Business/Enterprise)
> 2. Start with small, well-defined tasks
> 3. Write detailed issues—the more context, the better results
> 4. Always review the PR before merging
>
> Questions?"

---

## 🆘 Troubleshooting During Demo

| Problem                 | Quick Fix                                                                               |
| ----------------------- | --------------------------------------------------------------------------------------- |
| Can't assign to Copilot | "Coding Agent requires Copilot Business/Enterprise. Let me show a completed example..." |
| Copilot taking > 10 min | "Complex tasks take longer. Let me show a previously completed PR while we wait..."     |
| PR has errors           | "Great teaching moment! Let's ask Copilot to fix it..." → Comment on PR                 |
| Wrong implementation    | "This is why we review! Let me show how to request changes..."                          |

### Backup: Pre-Completed PR

If you need to show a completed example, reference:

- A previous PR created by Copilot in this repo
- Or walk through what the PR would contain using the `examples/` folder

---

## 📝 Anticipated Q&A

### "How is this different from Copilot Chat?"

> "Copilot Chat is interactive—you're in the loop the whole time. Coding Agent is
> asynchronous—you write an issue, walk away, and come back to a PR. Use Chat for
> exploration and complex design; use Coding Agent for well-defined implementation tasks."

### "Can Copilot access external services?"

> "Copilot Coding Agent works within your repository. It can read your code, understand
> patterns, and create PRs. It doesn't deploy to Azure or access external APIs.
> You still deploy through your normal CI/CD pipeline."

### "What if it makes mistakes?"

> "Always review the PR! Copilot is incredibly capable, but it's augmenting your
> expertise, not replacing it. The PR workflow ensures nothing gets merged without
> human approval."

### "Is this secure for enterprise use?"

> "Yes. Copilot operates within your repository's permission model. It creates PRs
> that go through your normal review process. Session logs provide audit trails.
> It's designed for enterprise workflows."

### "What tasks work best?"

> "Well-defined, scoped tasks with clear acceptance criteria:
>
> - Add feature X following existing pattern Y
> - Create module for Z with these specific requirements
> - Update configuration across all files
>
> Avoid vague requests like 'improve the code' or massive refactors."

---

## 📊 Quick Reference

### Issue Writing Checklist

- [ ] Clear context (where is the code?)
- [ ] Specific requirements (not vague)
- [ ] Implementation guidance (patterns, conventions)
- [ ] Constraints (region, tags, naming)
- [ ] Acceptance criteria (how to verify)

### Key Metrics

| Metric               | Value             |
| -------------------- | ----------------- |
| Time to write issue  | 5-10 minutes      |
| Copilot processing   | 2-10 minutes      |
| Review time          | 5-15 minutes      |
| **Total**            | **15-35 minutes** |
| Traditional approach | 3-4 hours         |
| **Time savings**     | **85-90%**        |

### Copilot Coding Agent Requirements

- GitHub Copilot Business or Enterprise
- Coding Agent enabled by org admin
- Repository access configured for Copilot
- Works with public and private repos
