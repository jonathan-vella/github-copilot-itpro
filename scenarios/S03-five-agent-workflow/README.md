# Demo 03: Four-Step Agent Workflow for Azure Infrastructure

## 🎯 Overview

This demo showcases GitHub Copilot's **4-step agent workflow** for designing and implementing Azure infrastructure, starting with VS Code's built-in **Plan Agent** and handing off to specialized custom agents. Each step includes an **approval gate** where you review and approve before proceeding. It demonstrates how architects and IT professionals can leverage plan-driven development to move from business requirements to near-production-ready Bicep templates through a structured, iterative process.

> **Working Implementation**: The complete workflow output is available as near-production-ready infrastructure in [`../../infra/bicep/contoso-patient-portal/`](../../infra/bicep/contoso-patient-portal/) (1,070 lines of Bicep, 10 modules).

> **📖 Official Documentation**: See [VS Code Plan Agent Documentation](https://code.visualstudio.com/docs/copilot/chat/chat-planning) for complete details on the built-in planning features.

**Target Audience**: Solution Architects, Cloud Architects, Infrastructure Engineers, IT Professionals

**Scenario**: Design and implement a HIPAA-compliant patient portal for Contoso Healthcare

**Time**: 45-60 minutes (full workflow) or 15-20 minutes (abbreviated demo)

## 🌟 Why This Matters

Traditional infrastructure design involves:

- ⏱️ **Hours of manual work**: Requirements → Architecture → Code
- 📝 **Context loss**: Switching between tools and formats
- 🔄 **Rework**: Architectural decisions not reflected in code
- 📚 **Documentation lag**: Code and docs out of sync
- 🎯 **Scope creep**: No structured planning before implementation

**With 4-Step Workflow (Plan-First with Approval Gates)**:

- 📋 **Research before code**: VS Code Plan Agent researches comprehensively before any changes
- ✅ **Approval gates**: Review and approve each step before proceeding
- ⚡ **45 minutes**: Complete workflow from requirements to deployable code (vs. 18 hours manual)
- 🔗 **Automatic handoffs**: Context preserved between agents via UI controls
- ✅ **Aligned outputs**: Plan drives architecture drives implementation
- 📖 **Living documentation**: Plans saved as reusable `*.prompt.md` files
- 💰 **Cost-validated**: Budget estimates before implementation
- 📊 **Progress tracking**: Built-in todo list tracks completion during complex tasks
- 🎨 **Optional diagrams**: Generate Python architecture diagrams at any step

## 🤖 The Four Steps (Plus Optional Agents)

### Step 1: Plan Agent (`@plan`) - _VS Code Built-in - Start Here_

> **This is a built-in VS Code feature**, not a custom agent. It's designed to research and plan before any code changes are made.

- **Purpose**: Research tasks comprehensively using read-only tools and codebase analysis before implementation
- **Input**: High-level tasks (features, refactoring, bugs, infrastructure projects)
- **Output**:
  - High-level summary with breakdown of steps
  - Open questions for clarification
  - Saved plan as `*.prompt.md` file (editable prompt file)
  - Handoff controls to implementation agents
- **Key Features**:
  - **Read-only research**: Analyzes codebase without making changes
  - **Iterative refinement**: Stay in plan mode to refine before implementation
  - **Plan files**: Generates `*.prompt.md` files you can edit and reuse
  - **Todo tracking**: Creates todo list to track progress during complex tasks
  - **UI controls**: "Save Plan" or "Hand off to implementation agent" buttons

**How to Use**:

1. Open Chat view (`Ctrl+Alt+I`)
2. Select **Plan** from the agents dropdown
3. Enter your high-level task and submit
4. Preview the proposed plan draft and provide feedback for iteration
5. Once finalized, save the plan or hand off to an implementation agent

**Example Prompts**:

- "Design a HIPAA-compliant patient portal for Contoso Healthcare with $800/month budget"
- "Create infrastructure for a multi-tier web application with Azure App Service and SQL Database"
- "Implement zone-redundant deployment for existing application"

**Usage**: Always start with `@plan` for multi-step infrastructure projects. The plan ensures all requirements are considered before any code changes.

### Step 2: Azure Principal Architect (`azure-principal-architect`)

- **Purpose**: Azure Well-Architected Framework assessment (NO CODE CREATION)
- **Input**: Business requirements, constraints, technical needs
- **Output**: WAF scores, service recommendations, cost estimates, HIPAA compliance mapping
- **Approval Gate**: Review WAF assessment before proceeding
- **Handoff**: Architecture assessment → Bicep Planning Specialist
- **Optional**: Generate Architecture Diagram → diagram-generator

### Step 3: Bicep Planning Specialist (`bicep-plan`)

- **Purpose**: Machine-readable implementation plan
- **Input**: Architecture assessment
- **Output**: Resource definitions, dependencies, cost tables, deployment phases
- **Approval Gate**: Review implementation plan before code generation
- **Handoff**: Implementation plan → Bicep Implementation Specialist

### Step 4: Bicep Implementation Specialist (`bicep-implement`)

- **Purpose**: near-production-ready Bicep templates
- **Input**: Implementation plan
- **Output**: Modular Bicep templates, parameter files, deployment scripts
- **Approval Gate**: Review generated code before deployment
- **Handoff**: Templates ready for deployment
- **Regional Default**: `swedencentral` (renewable energy)
- **Naming Convention**: Generates unique suffixes using `uniqueString()` to prevent resource name collisions
- **Optional**: Generate Architecture Diagram → diagram-generator

### Optional: ADR Generator (`adr-generator`)

- **Purpose**: Document architectural decisions for enterprise governance
- **Input**: Architecture discussions, trade-offs, decisions from any step
- **Output**: Structured ADR in markdown format (saved to `/docs/adr/`)
- **Use Case**: Document key decisions during workflow (skip for speed-focused demos)

### Optional: Diagram Generator (`diagram-generator`)

- **Purpose**: Generate Python architecture diagrams using `diagrams` library
- **Input**: Architecture context from Step 2 or Step 4
- **Output**: Python file + PNG image in `docs/diagrams/`
- **Use Case**: Visual documentation for stakeholders

## 📋 Scenario: Contoso Healthcare Patient Portal

**Business Context**:

- **Organization**: Contoso Healthcare (mid-sized healthcare provider)
- **Need**: Secure patient portal for appointment scheduling, medical records access
- **Patients**: 10,000 active patients
- **Staff**: 50 clinical and administrative users
- **Compliance**: HIPAA mandatory (BAA required)

**Technical Requirements**:

- **Budget**: $800/month maximum
- **SLA**: 99.9% uptime minimum
- **Region**: Default `swedencentral` (can adjust for latency/compliance)
- **Performance**: Support 60+ concurrent users
- **Security**: Encryption at rest and in transit, audit logging, unique resource names

**Constraints**:

- Must deploy within 4 weeks
- Team has Azure experience but limited IaC expertise
- Prefer managed services over IaaS

## 🚀 Quick Start

### Prerequisites

- Visual Studio Code with GitHub Copilot (Plan Agent is built-in)
- Azure subscription (for deployment validation)
- Custom agents configured (see [FIVE-MODE-WORKFLOW.md](../../resources/copilot-customizations/FIVE-MODE-WORKFLOW.md))

### Run the Demo

1. **Navigate to prompts directory**:

   ```powershell
   cd scenarios/S03-five-agent-workflow/prompts
   ```

2. **Open VS Code**:

   ```powershell
   code .
   ```

3. **Open GitHub Copilot Chat** (`Ctrl+Alt+I`)

4. **Follow the five-agent workflow**:

   | Stage | Agent | Duration | Key Output |
   |-------|-------|----------|------------|
   | 0 | `@plan` (built-in) | 5-10 min | Implementation plan + `*.prompt.md` file |
   | 1 | `azure-principal-architect` | 10-15 min | WAF assessment + cost estimates |
   | 2 | `bicep-plan` | 5-10 min | Resource breakdown + Mermaid diagram |
   | 3 | `bicep-implement` | 10-15 min | Modular Bicep templates |
   | 4 | Validation & Deployment | 5-10 min | `bicep build` + `bicep lint` |

5. **Pro Tip**: Use the UI handoff controls at the end of each agent's response to seamlessly transition to the next agent with full context preserved.

See [DEMO-SCRIPT.md](DEMO-SCRIPT.md) for detailed walkthrough.

## 📁 Demo Structure

```bicep
S03-five-agent-workflow/
├── README.md                           # This file
├── DEMO-SCRIPT.md                      # Step-by-step presentation guide
├── scenario/
│   ├── business-requirements.md        # Customer scenario details
│   └── architecture-diagram.md         # Target architecture visual
├── prompts/
│   └── workflow-prompts.md             # All prompts for the workflow stages
├── solution/
│   ├── outputs/
│   │   ├── stage1-architecture-assessment.md   # WAF scores, recommendations
│   │   ├── stage2-implementation-plan.md       # Resource definitions, dependencies
│   │   └── stage3-validation-results.md        # Bicep validation outcomes
│   └── templates/
│       └── [Link to infra/bicep/contoso-patient-portal/]
```

## 🎬 Demo Flow

### Part 0: Planning with VS Code Plan Agent (5-10 minutes)

**Agent**: `@plan` (Built-in)

1. Open Copilot Chat (`Ctrl+Alt+I`)
2. Select **Plan** from the agents dropdown
3. Submit the high-level requirement:

   ```text
   Design a HIPAA-compliant patient portal for Contoso Healthcare.
   - 10,000 patients, 50 staff members
   - $800/month budget constraint
   - 99.9% SLA requirement
   - 3-month implementation timeline
   ```

4. Review the plan draft:
   - High-level summary of the approach
   - Breakdown of implementation steps
   - Open questions for clarification (answer these to refine)
5. **Iterate**: Provide feedback to refine the plan ("Add security considerations", "Include cost breakdown")
6. **Save or Handoff**:
   - Click **"Save Plan"** → Generates `*.prompt.md` file for later use
   - OR Click **"Hand off to implementation agent"** → Proceed to architecture

**Key Takeaway**: Plan Agent researches comprehensively before any code changes. The plan becomes a reusable `*.prompt.md` file.

### Part 1: Architecture Design (10-15 minutes)

**Agent**: `azure-principal-architect`

1. From Plan Agent handoff, or select Azure Principal Architect agent (`Ctrl+Shift+A`)
2. The plan context is automatically passed to the architect
3. Review outputs:
   - WAF scores (Security: 9/10, Reliability: 7/10, etc.)
   - Service recommendations with justification
   - Cost breakdown ($334/month vs $800 budget)
   - HIPAA compliance checklist
4. **Click "Plan Bicep Implementation" handoff button**

**Key Takeaway**: Agent provides comprehensive architecture assessment in ~2 minutes vs. hours of manual analysis.

### Part 2: Implementation Planning (10 minutes)

**Agent**: `bicep-plan`

1. Agent auto-selects from handoff
2. Review implementation plan:
   - 12 Azure resources with complete specs
   - Mermaid dependency diagram
   - 4-phase deployment strategy (35 tasks)
   - Cost estimation table
   - Testing procedures
3. **Click "Generate Bicep Code" handoff button**

**Key Takeaway**: Machine-readable plan bridges architecture and code, eliminating manual translation errors.

### Part 3: Bicep Template Generation (15 minutes)

**Agent**: `bicep-implement`

1. Agent auto-selects from handoff
2. Review generated templates:
   - `main.bicep` orchestrator
   - 11 modular templates
   - Parameter files for environments
   - Deployment automation script
3. Validate templates:

   ```powershell
   cd solution/templates
   bicep build main.bicep --stdout --no-restore
   bicep lint main.bicep
   ```

````

4. (Optional) What-if deployment:

   ```powershell
   .\deploy.ps1 -WhatIf
````

**Key Takeaway**: near-production-ready templates in minutes, following Azure best practices and security defaults.

## 📊 Value Metrics

| Metric                      | Traditional Approach     | With 5-Agent Workflow | Improvement        |
| --------------------------- | ------------------------ | --------------------- | ------------------ |
| **Planning & Requirements** | 1-2 hours                | 5 minutes             | **96% reduction**  |
| **Architecture Assessment** | 2-4 hours                | 5 minutes             | **96% reduction**  |
| **Implementation Planning** | 3-6 hours                | 5 minutes             | **95% reduction**  |
| **Bicep Template Creation** | 4-8 hours                | 10 minutes            | **95% reduction**  |
| **Total Time**              | 10-20 hours              | 45 minutes            | **96% reduction**  |
| **Context Loss**            | High (multiple handoffs) | None (automatic)      | **Eliminated**     |
| **Documentation**           | Manual, often outdated   | Auto-generated        | **Always current** |

**Time Savings**:

- Traditional approach: 18 hours
- With five-agent workflow: 1 hour
- **Time saved: 17 hours per project (94% reduction)**

## 🔑 Key Features Demonstrated

### Agent Handoffs

- **Automatic context transfer** between agents
- **No copy/paste required** - seamless workflow
- **Preserved decisions** - architecture drives implementation

### Security Defaults

- HTTPS-only enforcement
- TLS 1.2 minimum on all services
- Private endpoints for data tier
- Managed identities (no passwords)
- Entra ID Authentication for SQL Server
- NSG deny-all defaults

### Cost Optimization

- Service recommendations within budget
- Reservation opportunities identified
- Monthly cost breakdown with drivers
- Alternative SKU suggestions

### Compliance

- HIPAA compliance mapping
- Azure BAA coverage confirmation
- Encryption at rest and in transit
- Audit logging to Log Analytics

### Production Readiness

- Modular, maintainable templates
- Environment-specific parameters
- Deployment automation
- Validation procedures
- Rollback strategies

## 🎯 Learning Objectives

By the end of this demo, participants will:

1. ✅ Understand the **5-agent workflow** for Azure infrastructure (starting with Plan Agent)
2. ✅ Use VS Code's built-in **Plan Agent** to research before implementing
3. ✅ Generate and edit **`*.prompt.md` plan files** for reusable workflows
4. ✅ Use agent handoff buttons/controls for seamless transitions
5. ✅ Interpret WAF scores and architecture recommendations
6. ✅ Navigate implementation plans to understand dependencies
7. ✅ Validate generated Bicep templates
8. ✅ Articulate time savings and ROI to stakeholders

## 🛠️ Customization Options

### Adjust Scenario Complexity

**Simpler** (20-min demo):

- Remove private endpoints
- Use Basic tier services
- Single region deployment
- Skip ADR generation

**More Complex** (60-min demo):

- Add Azure Front Door with WAF
- Multi-region with Traffic Manager
- Azure Firewall for network security
- Customer-managed keys for encryption
- Include ADR generation for decisions

### Change Industry Vertical

- **Financial Services**: PCI-DSS compliance, fraud detection
- **Retail**: E-commerce platform, inventory management
- **Manufacturing**: IoT hub, predictive maintenance
- **Education**: Learning management system, student portal

### Vary Budget/Scale

- **Small**: $200/month (Basic tiers, single instance)
- **Medium**: $800/month (Standard tiers, zone redundancy) ← Current scenario
- **Large**: $5,000/month (Premium tiers, multi-region, advanced security)

## 📚 Resources

### Documentation

- [VS Code Plan Agent Documentation](https://code.visualstudio.com/docs/copilot/chat/chat-planning) - **Official VS Code docs for built-in Plan Agent**
- [Five-Agent Workflow Guide](../../resources/copilot-customizations/FIVE-MODE-WORKFLOW.md) - Complete documentation with Plan agent integration
- [15-Minute Demo Script](../../resources/copilot-customizations/AGENT-HANDOFF-DEMO.md) - Quick demonstration
- [Custom Agent Configuration](../../.github/agents/) - Agent definitions with swedencentral defaults
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Context Engineering Guide](https://code.visualstudio.com/docs/copilot/guides/context-engineering-guide) - Best practices for AI-assisted development

### Related Demos

- [Demo 01: Bicep Baseline (S01)](../S01-bicep-baseline/) - Intro to Bicep with Copilot

### Implementation Files

- [Bicep Templates](../../infra/bicep/contoso-patient-portal/)
- [Implementation Summary](../../infra/bicep/contoso-patient-portal/IMPLEMENTATION-SUMMARY.md)
- [Validation Checklist](../../infra/bicep/contoso-patient-portal/VALIDATION-CHECKLIST.md)

## 🎤 Presentation Tips

### Opening (2 minutes)

- **Hook**: "What if you could go from customer requirements to near-production-ready infrastructure in 30 minutes?"
- Present traditional timeline (2-3 days)
- Introduce 5-agent workflow concept (Plan Agent + 4 custom agents)

### During Demo (35 minutes)

- **Pause after each agent output** - let audience absorb
- **Highlight surprises** - "Notice Copilot included HIPAA compliance automatically"
- **Show before/after** - manual effort vs. agent output
- **Invite questions** - engage audience throughout

### Closing (3 minutes)

- **Summarize metrics** - 95% time reduction, 17 hours saved per project
- **Emphasize production-readiness** - not just quick, but correct
- **Call to action** - "Try this with your next project"

### Common Questions

**Q: Does this work for non-Azure clouds?**
A: Agents are Azure-specific, but the workflow pattern applies. Similar agents could be built for AWS/GCP.

**Q: Can I customize agent behavior?**
A: Yes! Edit agent.md files in `.github/agents/` to adjust instructions, add patterns, or change output formats.

**Q: What if I disagree with agent recommendations?**
A: Agents provide guidance, not mandates. You can edit outputs before proceeding to next stage or regenerate with different constraints.

**Q: Does this replace architects?**
A: No - it augments their capabilities. Architects still make decisions; agents handle time-consuming documentation and code generation.

## 🧪 Variations to Try

1. **Change Compliance Requirements**:

   - Swap HIPAA for PCI-DSS or SOC 2
   - Observe how recommendations change

2. **Adjust Budget**:

   - Set budget to $200/month or $5,000/month
   - See how SKU recommendations adapt

3. **Add Specific Requirements**:

   - "Must use Azure Firewall"
   - "Require multi-region active-active"
   - See how architecture adjusts

4. **Generate ADR**:
   - After Stage 1, use ADR Generator agent
   - Document decision to use Standard vs. Premium tiers

## ✅ Success Criteria

Demo is successful when audience:

- [ ] Understands the **5-agent workflow** concept (starting with VS Code's built-in Plan Agent)
- [ ] Recognizes Plan Agent as a **built-in VS Code feature** (not a custom agent)
- [ ] Understands how **`*.prompt.md` files** preserve and share implementation plans
- [ ] Sees value in automatic context handoffs via UI controls
- [ ] Recognizes time savings (96% reduction, 18 hours → 45 minutes)
- [ ] Appreciates near-production-ready output quality (unique suffixes, regional defaults)
- [ ] Wants to try it on their own projects

## 📝 Feedback & Improvement

This demo was created from an actual test execution of the 5-agent workflow. If you have suggestions for improvement:

1. Open an issue in the repository
2. Describe your scenario/variation
3. Share outcomes and lessons learned

---

**Demo Version**: 1.0.0  
**Last Updated**: November 18, 2025  
**Tested With**: GitHub Copilot (Claude Sonnet 4.5), Azure CLI 2.50.0+, Bicep 0.20.0+
