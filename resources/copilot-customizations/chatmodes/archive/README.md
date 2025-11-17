# Archived Chat Modes

These chat modes have been **superseded by Custom Agents** as of November 2025.

## Why Archived?

The github-copilot-itpro repository has migrated to a **four-agent workflow** architecture, which provides:
- ✅ Superior tool integration through MCP servers
- ✅ Consistent agent invocation syntax (\@agent-name\)
- ✅ Better context management and memory
- ✅ Unified experience across VS Code, CLI, and web

## Superseded Chat Modes → Custom Agents

| Archived Chat Mode | Replaced By | Location |
|-------------------|-------------|----------|
| \zure-principal-architect.chatmode.md\ | **@azure-principal-architect** | \.github/agents/azure-principal-architect.agent.md\ |
| \icep-plan.chatmode.md\ | **@bicep-plan** | \.github/agents/bicep-plan.agent.md\ |
| \icep-implement.chatmode.md\ | **@bicep-implement** | \.github/agents/bicep-implement.agent.md\ |

## Migration Guide

**Old Approach (Chat Modes):**
\\\
#azure-principal-architect Design a secure hub-spoke network
\\\

**New Approach (Custom Agents):**
\\\
@azure-principal-architect Design a secure hub-spoke network
\\\

## Why Keep These Files?

These files are retained for:
1. **Historical reference** - Understanding the evolution of the repository
2. **Rollback capability** - If agents need to be reverted
3. **Content preservation** - The documentation and prompts may be useful

## See Also

- [Four-Agent Workflow Documentation](../FOUR-MODE-WORKFLOW.md)
- [Custom Agents Installation Guide](/.github/agents/)
- [Repository README](/README.md)
