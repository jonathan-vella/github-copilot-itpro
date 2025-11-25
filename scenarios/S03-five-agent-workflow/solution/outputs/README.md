# Pre-Generated Agent Outputs

This folder contains example outputs from the five-agent workflow for the Contoso Healthcare
patient portal scenario. These are provided for **reference and validation**, not as the primary
learning tool.

## Purpose

These pre-generated outputs serve three purposes:

1. **Validation Reference** - Compare your live agent outputs against these examples
2. **Offline Demos** - Run the demo without live agent access if needed
3. **Teaching Examples** - Annotated outputs showing what to expect at each stage

## Files

| File | Stage | Agent | Description |
|------|-------|-------|-------------|
| `stage1-architecture-assessment.md` | Stage 1 | azure-principal-architect | WAF assessment and service recommendations |
| `stage2-implementation-plan.md` | Stage 3 | bicep-plan | Resource breakdown with dependency diagrams |

> **Note:** Stage 0 (@plan) and Stage 2 (adr_generator) outputs are not pre-generated because
> they're highly dependent on the specific conversation flow and clarifying questions asked.

## When to Use Pre-Generated vs. Live Generation

### Use Pre-Generated Outputs When

- **Offline Demos**: No internet access or agent availability issues
- **Time-Constrained Sessions**: Skip waiting for agent responses
- **Consistent Training**: Ensure all trainees see identical outputs
- **Validation Baseline**: Check if your live results match expected patterns

### Use Live Generation When (Recommended)

- **Learning Copilot**: Understanding how agents respond to different prompts
- **Customizing Architecture**: Your requirements differ from the scenario
- **Exploring Trade-offs**: Asking discovery questions about alternatives
- **Teaching Discovery**: Demonstrating how to ask "why" questions

## How These Were Generated

These outputs were created by running the actual prompts from `prompts/workflow-prompts.md`
through the corresponding agents with minimal follow-up questions. Your live results may differ
based on:

- Discovery questions you ask
- Follow-up prompts for clarification
- Variations in agent model behavior
- Updates to agent knowledge/capabilities

## Relationship to Other Files

```text
scenarios/S03-five-agent-workflow/
├── examples/
│   └── five-agent-conversation.md  ← Full conversation transcript (learning focus)
├── prompts/
│   └── workflow-prompts.md          ← Prompts to use with agents
├── solution/
│   ├── outputs/
│   │   ├── README.md               ← THIS FILE
│   │   ├── stage1-architecture-assessment.md
│   │   └── stage2-implementation-plan.md
│   └── templates/                   ← Reference Bicep templates (optional)
└── validation/
    └── verify-outputs.ps1           ← Validation script
```

### Learning Path

1. **Start with** `examples/five-agent-conversation.md` to see how discovery questions work
2. **Use** `prompts/workflow-prompts.md` as reference when running your own sessions
3. **Compare** your live outputs against these pre-generated outputs
4. **Generate** your own Bicep templates using the bicep-implement agent

## Expected Differences

Your live outputs should be similar but not identical. Look for:

| Element | Should Match | May Differ |
|---------|--------------|------------|
| WAF pillar scores | Within ±1 point | Exact scores |
| Recommended services | Core services (App Service, SQL, Key Vault) | Optional services |
| Cost estimates | Within ±20% | Exact figures |
| Mermaid diagrams | Resource types and dependencies | Layout and styling |
| Security recommendations | TLS, encryption, managed identity | Additional hardening |

## Validation Checklist

After running the workflow live, verify your outputs include:

### Stage 1 (Architecture Assessment)

- [ ] All 5 WAF pillars assessed with scores
- [ ] Confidence level stated
- [ ] Azure service recommendations with SKUs
- [ ] Monthly cost breakdown under $800
- [ ] HIPAA compliance mapping
- [ ] Trade-off discussions

### Stage 3 (Implementation Plan)

- [ ] Resource breakdown with types and API versions
- [ ] Mermaid dependency diagram
- [ ] Implementation phases (3-4 phases)
- [ ] Parameter definitions for dev/prod
- [ ] Testing and rollback strategy

## Updating These Files

If you need to regenerate these reference outputs:

1. Run the prompts from `workflow-prompts.md` through the appropriate agents
2. Save the agent's response as markdown
3. Add any annotations or highlights for teaching purposes
4. Update the date at the bottom of each file

---

**Last Updated:** 2025-01-15
