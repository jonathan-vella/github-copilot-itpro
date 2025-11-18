---
title: "ADR-0001: Four-Mode Workflow Adoption for Azure Infrastructure Development"
status: "Accepted"
date: "2025-11-17"
authors: "GitHub Copilot IT Pro Repository Maintainers"
tags: ["architecture", "decision", "workflow", "copilot"]
supersedes: ""
superseded_by: ""
---

# ADR-0001: Four-Mode Workflow Adoption for Azure Infrastructure Development

## Status

**Accepted**

## Context

The github-copilot-itpro repository serves Microsoft field personnel and SI partners demonstrating GitHub Copilot value for Azure infrastructure work. The repository contains 5 complete demos showcasing 60-90% time savings across Bicep IaC, PowerShell automation, Azure Arc onboarding, troubleshooting, and documentation generation.

**Current Challenges:**

- Multiple Copilot customizations exist without clear workflow integration
- Architectural decisions in demos are implicit rather than documented
- No standardized process from architecture through implementation
- Partners struggle to understand when to use which customization mode
- Lack of architectural documentation for demo patterns

**Business Requirements:**

- Enable partners to deliver consistent demos
- Provide clear guidance on customization usage
- Document architectural patterns for reusability
- Establish best practices for Azure infrastructure with Copilot
- Support IT professionals learning cloud infrastructure

**Technical Constraints:**

- Must work with GitHub Copilot Chat and Custom Agents in VS Code
- Should leverage existing awesome-copilot community assets
- Must maintain 30-minute demo format compatibility
- Cannot introduce complex tooling dependencies

## Decision

Adopt a **four-mode workflow** integrating:

1. **ADR Generator (Custom Agent)** - Document architectural decisions with structured ADRs
2. **Azure Principal Architect (Chat Mode)** - Provide WAF-based architectural guidance
3. **Bicep Planning (Chat Mode)** - Create machine-readable infrastructure plans
4. **Bicep Implementation (Chat Mode)** - Generate Bicep code from plans

**Workflow Stages:**

```
Decision → Architecture → Planning → Implementation
    ↓           ↓            ↓           ↓
ADR Gen → Principal → Bicep Plan → Bicep Impl
```

**Integration Points:**

- ADRs reference architecture decisions made with Principal Architect mode
- Bicep Planning mode consumes architectural recommendations
- Bicep Implementation mode reads planning files from `.bicep-planning-files/`
- Demo scripts reference appropriate mode for each stage

## Consequences

### Positive

- **POS-001**: **Structured Decision Documentation** - Architectural decisions are captured in standardized ADR format, improving knowledge retention and onboarding
- **POS-002**: **Clear Workflow Stages** - Partners understand exactly which mode to use at each stage, reducing confusion
- **POS-003**: **Reusable Architecture Patterns** - ADRs document patterns that can be referenced across demos and customer engagements
- **POS-004**: **AI-Optimized Planning** - Machine-readable planning files enable better code generation by Bicep Implementation mode
- **POS-005**: **Alignment with Best Practices** - Leverages awesome-copilot community assets and Microsoft-recommended patterns
- **POS-006**: **Improved Demo Quality** - Presenters follow consistent process, enhancing credibility
- **POS-007**: **Better Knowledge Transfer** - New team members can review ADRs to understand architectural rationale

### Negative

- **NEG-001**: **Learning Curve** - Partners must learn four distinct modes and when to apply each
- **NEG-002**: **Increased Complexity** - More moving parts compared to single-mode approach
- **NEG-003**: **Maintenance Overhead** - Four modes require ongoing synchronization and documentation updates
- **NEG-004**: **Initial Time Investment** - Creating ADRs and planning files adds upfront time before implementation
- **NEG-005**: **Mode Switching Friction** - Users must activate/deactivate modes during workflow progression

## Alternatives Considered

### Alternative 1: Single General-Purpose Chat Mode

- **ALT-001**: **Description**: Use one comprehensive chat mode for all Azure infrastructure tasks
- **ALT-002**: **Rejection Reason**: Lacks specialization; difficult to optimize prompts for diverse tasks (architecture vs. code generation); conflates planning and implementation concerns

### Alternative 2: Direct Bicep Generation Without Planning

- **ALT-003**: **Description**: Skip planning stage, generate Bicep code directly from requirements
- **ALT-004**: **Rejection Reason**: Produces lower-quality code without structured planning; misses opportunity to validate architecture before implementation; harder to review and modify

### Alternative 3: Multiple Unintegrated Modes

- **ALT-005**: **Description**: Provide various modes without establishing workflow relationships
- **ALT-006**: **Rejection Reason**: Current state causing confusion; no guidance on mode selection; lacks cohesive narrative for demos

### Alternative 4: External Architecture Tools Integration

- **ALT-007**: **Description**: Integrate external tools like Azure Advisor, Cost Management for architecture guidance
- **ALT-008**: **Rejection Reason**: Adds deployment complexity; breaks demo flow; requires Azure subscriptions and permissions; not compatible with 30-minute demo format

## Implementation Notes

- **IMP-001**: **Phase 1 (Immediate)**: Install ADR Generator agent, create `/docs/adr/` directory, document workflow adoption (this ADR)
- **IMP-002**: **Phase 2 (Week 1)**: Consolidate chat modes to `resources/copilot-customizations/chatmodes/`, create workflow documentation
- **IMP-003**: **Phase 3 (Week 1-2)**: Create 5 ADRs for existing demo patterns (3-tier architecture, Arc strategy, PowerShell standards, AVM adoption)
- **IMP-004**: **Phase 4 (Week 2)**: Update Demo 1 and Demo 5 scripts to showcase four-mode workflow
- **IMP-005**: **Partner Training**: Create quick reference card and mode selection flowchart for field personnel
- **IMP-006**: **Success Metrics**: Track partner adoption, demo quality scores, ADR count, usage analytics

**Migration Strategy:**

- Existing demos continue functioning unchanged
- Enhanced demos showcase four-mode workflow
- Partners adopt progressively, not required immediately
- Backward compatibility maintained for custom instructions

**Monitoring and Success Criteria:**

- Minimum 5 ADRs created within 2 weeks
- All 3 chat modes documented with clear usage guidance
- Demo scripts updated with mode references
- Partner feedback collected after 30 days

## References

- **REF-001**: [awesome-copilot ADR Generator](https://github.com/github/awesome-copilot/blob/main/agents/adr-generator.agent.md)
- **REF-002**: [awesome-copilot Bicep Planning Mode](https://github.com/github/awesome-copilot/blob/main/chatmodes/bicep-plan.chatmode.md)
- **REF-003**: [Azure Architecture Center - Architecture Decision Records](https://learn.microsoft.com/azure/architecture/guide/design-principles/document-decisions)
- **REF-004**: [GitHub Copilot Custom Agents Documentation](https://docs.github.com/copilot/customizing-copilot/creating-custom-agents)
- **REF-005**: [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)

---

**Decision History:**

- 2025-11-17: Initial proposal and acceptance
