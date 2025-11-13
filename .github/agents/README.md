# GitHub Copilot Custom Agents

This directory contains custom agent definitions for GitHub Copilot coding agent. Custom agents provide specialized expertise for specific tasks in this repository.

## What are Custom Agents?

Custom agents are specialized configurations that give GitHub Copilot additional context and expertise for specific types of tasks. They help Copilot understand domain-specific requirements and best practices.

## Available Agents

Currently, no custom agents are defined. Potential agents for this repository include:

### 1. Bicep Template Specialist
- **Purpose**: Create and review Azure Bicep templates
- **Expertise**: Azure resources, security best practices, API versions
- **When to use**: Creating new infrastructure templates or reviewing existing ones

### 2. PowerShell Automation Expert
- **Purpose**: Write and improve PowerShell automation scripts
- **Expertise**: Azure PowerShell, error handling, automation patterns
- **When to use**: Building automation scripts or improving script quality

### 3. Documentation Generator
- **Purpose**: Create and update technical documentation
- **Expertise**: Markdown, Mermaid diagrams, Azure architecture
- **When to use**: Writing README files, runbooks, or architectural documentation

### 4. Demo Validator
- **Purpose**: Ensure demo quality and consistency
- **Expertise**: Demo structure, validation scripts, metrics tracking
- **When to use**: Reviewing new demos or validating demo completeness

## Creating a Custom Agent

To create a custom agent:

1. Create a new markdown file in this directory (e.g., `bicep-specialist.md`)
2. Follow the structure below:

```markdown
# Agent Name: [Agent Name]

## Description
[Brief description of the agent's purpose and expertise]

## Specialization
- [Area of expertise 1]
- [Area of expertise 2]
- [Area of expertise 3]

## Instructions
[Detailed instructions for how the agent should approach tasks]
```

3. Reference the agent in issue descriptions when assigning tasks to Copilot

## Example Agent Definition

See the example in the main [copilot-instructions.md](../copilot-instructions.md#creating-a-custom-agent) file.

## Resources

- [GitHub Copilot Custom Agents Documentation](https://docs.github.com/en/copilot/tutorials/coding-agent/get-the-best-results#creating-custom-agents)
- [Repository Copilot Instructions](../copilot-instructions.md)

---

**Note**: Custom agents are an advanced feature. Start with the main copilot-instructions.md file for general guidance.
