### Automate Markdown Linting: Nightly Run & Issue Creation on Failure

Enhance the existing markdown validation workflow to run every night at 1am (using a scheduled cron job). If markdownlint detects any problems, automatically create a GitHub issue listing all markdownlint errors found. Assign this issue to the copilot coding agent.

## Requirements

- Modify `.github/workflows/markdown-validation.yml`:
  - Add a `schedule` workflow trigger to run every day at 01:00 UTC using cron syntax (`0 1 * * *`)
  - After running markdownlint, if there are any errors:
    - Collect the output and create a new GitHub issue in this repo
    - The issue should be titled "Automated markdownlint problems [2025-11-25]"
    - The body should include the list of violations/errors found
    - Assign the issue to the copilot coding agent
    - Only create the issue if problems are detected

## Suggested Implementation

- Use a step after markdownlint that checks for nonzero exit code
- On error, use `actions/github-script` or similar to create the issue programmatically with markdownlint output
- Ensure the workflow does not create duplicate issues for the same set of errors
- The workflow should continue to run on push and pull_request events as it currently does

## Action file reference

[.github/workflows/markdown-validation.yml](https://github.com/jonathan-vella/github-copilot-itpro/blob/main/.github/workflows/markdown-validation.yml)