## Description

<!-- Provide a brief description of your changes. What does this PR do? Why is it needed? -->

## Related Issue

<!-- Link to the related issue, e.g., "Fixes #123" or "Closes #456" -->

Fixes #

## Type of Change

<!-- Mark the appropriate option with an "x" -->

- [ ] 🆕 New scenario or demo
- [ ] ✨ New feature or module
- [ ] 🐛 Bug fix
- [ ] 📝 Documentation update
- [ ] 🔧 Refactoring (no functional changes)
- [ ] 🧪 Test improvements
- [ ] ⚙️ Configuration change

## Changes Made

<!-- Describe the specific changes you made. Include file paths if helpful. -->

-

## Testing Performed

<!-- Describe how you tested your changes. Include validation steps for Azure deployments. -->

- [ ] Tested in a clean Azure subscription (if applicable)
- [ ] Ran validation scripts (if applicable to scenarios)
- [ ] Verified resource cleanup (if applicable)
- [ ] Tested locally with relevant tools (Bicep CLI, Terraform, PowerShell)

## Time Savings (if applicable)

<!-- Document any time savings metrics for new demos or features -->

| Task                      | Traditional Approach | With GitHub Copilot |
| ------------------------- | -------------------- | ------------------- |
| Bicep template creation   | X min                | Y min               |

## Pre-Submission Checklist

<!-- Verify all items before requesting review -->

### Code Quality

- [ ] Code follows repository structure and naming conventions
- [ ] Bicep/Terraform templates use latest stable API versions
- [ ] PowerShell scripts follow PSScriptAnalyzer rules
- [ ] No hardcoded secrets, subscription IDs, or sensitive data

### Documentation

- [ ] README updated with any new features or changes
- [ ] DEMO-SCRIPT.md updated (if applicable)
- [ ] Prompts are documented in `prompts/effective-prompts.md`
- [ ] Mermaid diagrams render correctly

### Validation

- [ ] Markdown files pass linting: `markdownlint '**/*.md' --ignore node_modules --config .markdownlint.json`
- [ ] All links work and images load
- [ ] Validation scripts are included (for scenarios)
- [ ] CHANGELOG.md updated (if applicable)

## Screenshots (if applicable)

<!-- Add screenshots to help explain your changes, especially for UI or diagram changes -->

## Additional Notes

<!-- Add any other context, dependencies, or notes for reviewers -->
