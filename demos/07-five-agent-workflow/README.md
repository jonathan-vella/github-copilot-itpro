# Demo 07: Five-Agent Workflow for Azure Infrastructure

## 🎯 Overview

This demo showcases GitHub Copilot's **5-agent workflow** for designing and implementing Azure infrastructure using custom agents. It demonstrates how architects and IT professionals can leverage specialized agents to move from business requirements to production-ready Bicep templates through a structured, iterative process.

> **Working Implementation**: The complete workflow output is available as production-ready infrastructure in [`../../infra/bicep/contoso-patient-portal/`](../../infra/bicep/contoso-patient-portal/) (1,070 lines of Bicep, 10 modules).

**Target Audience**: Solution Architects, Cloud Architects, Infrastructure Engineers, IT Professionals

**Scenario**: Design and implement a HIPAA-compliant patient portal for Contoso Healthcare

**Time**: 45-60 minutes (full workflow) or 15-20 minutes (abbreviated demo)

## 🌟 Why This Matters

Traditional infrastructure design involves:
- ⏱️ **Hours of manual work**: Requirements → Architecture → Code
- 📝 **Context loss**: Switching between tools and formats
- 🔄 **Rework**: Architectural decisions not reflected in code
- 📚 **Documentation lag**: Code and docs out of sync

**With 5-Agent Workflow**:
- ⚡ **45 minutes**: Complete workflow from requirements to deployable code (vs. 18 hours manual)
- 🔗 **Automatic handoffs**: Context preserved between agents
- ✅ **Aligned outputs**: Architecture drives implementation
- 📖 **Living documentation**: Generated alongside infrastructure
- 💰 **Cost-validated**: Budget estimates before implementation

## 🤖 The Five Agents

### 0. Plan Agent (`@plan`) - *Start Here*
- **Purpose**: Break down complex infrastructure projects into step-by-step implementation plans
- **Input**: Business requirements, constraints, budget, compliance needs
- **Output**: Interactive planning session with clarifying questions, detailed implementation plan with phases, resource breakdown with cost estimates, deployment sequence
- **Handoff**: Implementation plan → ADR Generator (optional) or Azure Principal Architect
- **Key Feature**: Iterative refinement before any code is written

**Usage**: Always start with `@plan` for multi-step infrastructure projects

### 1. Azure Principal Architect (`azure-principal-architect`)
- **Purpose**: Azure Well-Architected Framework assessment
- **Input**: Business requirements, constraints, technical needs
- **Output**: WAF scores, service recommendations, cost estimates, HIPAA compliance mapping
- **Handoff**: Architecture assessment → Bicep Planning Specialist

### 3. Bicep Planning Specialist (`bicep-plan`)
- **Purpose**: Machine-readable implementation plan
- **Input**: Architecture assessment
- **Output**: Resource definitions, dependencies, cost tables, deployment phases
- **Handoff**: Implementation plan → Bicep Implementation Specialist

### 4. Bicep Implementation Specialist (`bicep-implement`)
- **Purpose**: Production-ready Bicep templates
- **Input**: Implementation plan
- **Output**: Modular Bicep templates, parameter files, deployment scripts
- **Handoff**: Templates ready for deployment
- **Regional Default**: `swedencentral` (renewable energy)
- **Naming Convention**: Generates unique suffixes using `uniqueString()` to prevent resource name collisions

### 2. ADR Generator (`adr_generator`) - *Optional*
- **Purpose**: Document architectural decisions for enterprise governance
- **Input**: Architecture discussions, trade-offs, decisions from Plan agent
- **Output**: Structured ADR in markdown format (saved to `/docs/adr/`)
- **Use Case**: Document key decisions during workflow (skip for speed-focused demos)
- **Handoff**: ADR → Azure Principal Architect

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

- Visual Studio Code with GitHub Copilot
- Azure subscription (for deployment validation)
- Custom agents configured (see [FIVE-MODE-WORKFLOW.md](../../resources/copilot-customizations/FIVE-MODE-WORKFLOW.md))

### Run the Demo

1. **Navigate to prompts directory**:
   ```powershell
   cd demos/07-five-agent-workflow/prompts
   ```

2. **Open VS Code**:
   ```powershell
   code .
   ```

3. **Open GitHub Copilot Chat** (`Ctrl+Shift+I`)

4. **Follow the five-agent workflow**:
   - Stage 0: Planning with `@plan` (5-10 min)
   - Stage 1: Architecture Design (15 min)
   - Stage 2: Implementation Planning (10 min)
   - Stage 3: Bicep Generation (15 min)
   - Stage 4: Validation & Deployment

See [DEMO-SCRIPT.md](DEMO-SCRIPT.md) for detailed walkthrough.

## 📁 Demo Structure

```
07-five-agent-workflow/
├── README.md                           # This file
├── DEMO-SCRIPT.md                      # Step-by-step presentation guide
├── scenario/
│   ├── business-requirements.md        # Customer scenario details
│   └── architecture-diagram.md         # Target architecture visual
├── prompts/
│   ├── stage1-architecture.md          # Azure Principal Architect prompt
│   ├── stage2-planning.md              # Bicep Planning Specialist prompt
│   └── stage3-implementation.md        # Bicep Implementation Specialist prompt
├── outputs/
│   ├── stage1-architecture-assessment.md   # WAF scores, recommendations
│   ├── stage2-implementation-plan.md       # Resource definitions, dependencies
│   └── stage3-validation-results.md        # Bicep validation outcomes
└── templates/
    └── [Link to infra/bicep/contoso-patient-portal/]
```

## 🎬 Demo Flow

### Part 1: Architecture Design (15 minutes)

**Agent**: `azure-principal-architect`

1. Present business scenario
2. Select Azure Principal Architect agent (`Ctrl+Shift+A`)
3. Submit Stage 1 prompt (requirements)
4. Review outputs:
   - WAF scores (Security: 9/10, Reliability: 7/10, etc.)
   - Service recommendations with justification
   - Cost breakdown ($334/month vs $800 budget)
   - HIPAA compliance checklist
5. **Click "Plan Bicep Implementation" handoff button**

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
   cd templates
   bicep build main.bicep --stdout --no-restore
   bicep lint main.bicep
   ```
4. (Optional) What-if deployment:
   ```powershell
   .\deploy.ps1 -WhatIf
   ```

**Key Takeaway**: Production-ready templates in minutes, following Azure best practices and security defaults.

## 📊 Value Metrics

| Metric | Traditional Approach | With 5-Agent Workflow | Improvement |
|--------|---------------------|----------------------|-------------|
| **Planning & Requirements** | 1-2 hours | 5 minutes | **96% reduction** |
| **Architecture Assessment** | 2-4 hours | 5 minutes | **96% reduction** |
| **Implementation Planning** | 3-6 hours | 5 minutes | **95% reduction** |
| **Bicep Template Creation** | 4-8 hours | 10 minutes | **95% reduction** |
| **Total Time** | 10-20 hours | 45 minutes | **96% reduction** |
| **Context Loss** | High (multiple handoffs) | None (automatic) | **Eliminated** |
| **Documentation** | Manual, often outdated | Auto-generated | **Always current** |

**ROI Example**: 
- SI Partner hourly rate: $150/hour
- Traditional approach: 18 hours × $150 = **$2,700**
- With Copilot: 1 hour × $150 = **$150**
- **Savings: $2,550 per project** (94% reduction)

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

1. ✅ Understand the 4-agent workflow for Azure infrastructure
2. ✅ Use agent handoff buttons for seamless transitions
3. ✅ Interpret WAF scores and architecture recommendations
4. ✅ Navigate implementation plans to understand dependencies
5. ✅ Validate generated Bicep templates
6. ✅ Articulate time savings and ROI to stakeholders

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
- [Five-Agent Workflow Guide](../../resources/copilot-customizations/FIVE-MODE-WORKFLOW.md) - Complete documentation with Plan agent
- [15-Minute Demo Script](../../resources/copilot-customizations/AGENT-HANDOFF-DEMO.md) - Quick demonstration
- [Custom Agent Configuration](../../.github/agents/) - Agent definitions with swedencentral defaults
- [Plan Agent Documentation](https://code.visualstudio.com/docs/copilot/chat/chat-planning) - Official VS Code docs
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)

### Related Demos
- [Demo 01: Bicep Quick Start](../01-bicep-quickstart/) - Intro to Bicep with Copilot
- [Demo 06: Azure Specialization Prep](../06-azure-specialization-prep/) - Advanced architectures

### Implementation Files
- [Bicep Templates](../../infra/bicep/contoso-patient-portal/)
- [Implementation Summary](../../infra/bicep/contoso-patient-portal/IMPLEMENTATION-SUMMARY.md)
- [Validation Checklist](../../infra/bicep/contoso-patient-portal/VALIDATION-CHECKLIST.md)

## 🎤 Presentation Tips

### Opening (2 minutes)
- **Hook**: "What if you could go from customer requirements to production-ready infrastructure in 30 minutes?"
- Present traditional timeline (2-3 days)
- Introduce 4-agent workflow concept

### During Demo (35 minutes)
- **Pause after each agent output** - let audience absorb
- **Highlight surprises** - "Notice Copilot included HIPAA compliance automatically"
- **Show before/after** - manual effort vs. agent output
- **Invite questions** - engage audience throughout

### Closing (3 minutes)
- **Summarize metrics** - 95% time reduction, $2,550 savings
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
- [ ] Understands the 5-agent workflow concept (starting with Plan agent)
- [ ] Sees value in automatic context handoffs
- [ ] Recognizes time savings (96% reduction, 18 hours → 45 minutes)
- [ ] Appreciates production-ready output quality (unique suffixes, regional defaults)
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
