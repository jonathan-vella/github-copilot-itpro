# GitHub Copilot Agent Handoff Demo

This demo showcases the **four-agent workflow** for Azure infrastructure development, demonstrating how custom agents work together through handoff buttons.

## 🎯 Demo Objective

Show how GitHub Copilot custom agents collaborate to take an infrastructure idea from **architectural decision** → **WAF assessment** → **implementation plan** → **production-ready Bicep code**.

**Duration**: 15-20 minutes

## 🚀 Prerequisites

- VS Code with GitHub Copilot extension
- Copilot Chat panel open (`Ctrl+Alt+I` or `Cmd+Alt+I`)
- Custom agents installed in `.github/agents/`
- Azure knowledge (audience should understand basic concepts)

## 📋 Demo Script

### Phase 1: Document Architectural Decision (ADR Generator) - *Optional*

> **⏭️ Skip this phase** if you want to focus on infrastructure speed (start at Phase 2). This phase is valuable for showing enterprise governance capabilities.

**Goal**: Create an Architecture Decision Record documenting a technical choice.

1. **Invoke the ADR Generator**:
   - Press `Ctrl+Shift+A` (or click **Agent** button in Copilot Chat)
   - Select `adr_generator` from the dropdown

2. **Provide the prompt**:

```text
   Document the decision to use a hub network topology for an Azure test environment.
   
   Context:
   - Need central connectivity for testing/validation
   - Single region (East US), minimal cost
   - Must support basic network segmentation
   - Foundation for future spoke networks
   
   Include rationale, alternatives (flat network, multiple VNets, Azure Virtual WAN), 
   and consequences (positive and negative).
```

1. **Review the ADR**:
   - Copilot creates a structured ADR with:
     - Status, Context, Decision, Consequences
     - Alternatives Considered with rejection reasons
     - Implementation notes
     - Validation criteria

2. **Use the Handoff Button** ⭐:
   - Look at the bottom of the response
   - Click **"Review Against WAF Pillars"** button
   - This automatically invokes `azure-principal-architect` with context

---

### Phase 2: Assess Against Well-Architected Framework (Azure Principal Architect)

**Goal**: Evaluate the architectural decision using Azure Well-Architected Framework.

1. **Agent automatically invoked** (via handoff from Phase 1)
   - If not, manually invoke:

```text
     Assess the hub network topology decision against 
     Azure Well-Architected Framework pillars. Use the ADR from 
     #file:docs/adr/adr-0003-hub-network-topology-test.md
```

- (Using `azure-principal-architect` agent from dropdown)

1. **Review the WAF Assessment**:
   - Copilot evaluates across 5 pillars:
     - **Reliability**: Availability, resilience
     - **Security**: Network isolation, access control
     - **Cost Optimization**: Resource costs, efficiency
     - **Operational Excellence**: Deployment, monitoring
     - **Performance Efficiency**: Network throughput, latency
   - Provides overall score (e.g., 7.2/10)
   - Lists specific recommendations

2. **Use the Handoff Button** ⭐:
   - Click **"Generate Implementation Plan"**
   - Automatically invokes `bicep-plan` with architecture context

---

### Phase 3: Create Implementation Plan (Bicep Planning Specialist)

**Goal**: Generate a detailed, machine-readable implementation plan.

1. **Agent automatically invoked** (via handoff from Phase 2)
   - If not, manually invoke:

```text
     Create a detailed Bicep implementation plan for the hub network.
     Include all resources, dependencies, security configurations, and deployment phases.
     Reference #file:docs/adr/adr-0003-hub-network-topology-test.md
```

- (Using `bicep-plan` agent from dropdown)

1. **Review the Implementation Plan**:
   - Copilot creates `.bicep-planning-files/INFRA.{goal}.md` with:
     - **Resources section**: YAML specs for each Azure resource

       ```yaml
       - name: vnet-hub-test
         type: Microsoft.Network/virtualNetworks
         apiVersion: 2023-05-01
         properties: {...}

```

     - **Implementation Phases**: Logical grouping (Network, Security, Monitoring, Governance)
     - **Architecture Diagram**: Mermaid diagram showing relationships
     - **Dependencies**: Resource deployment order
     - **Time Estimate**: Expected deployment duration

3. **Use the Handoff Button** ⭐:
   - Click **"Generate Bicep Code"**
   - Automatically invokes `bicep-implement` with plan details

---

### Phase 4: Generate Bicep Templates (Bicep Implementation Specialist)

**Goal**: Create production-ready, modular Bicep templates.

1. **Agent automatically invoked** (via handoff from Phase 3)
   - If not, manually invoke:

```

     Implement the Bicep templates based on the plan in 
     #file:.bicep-planning-files/INFRA.hub-network-test.md
     
     Output to: infrastructure/hub-network-demo/

```

   - (Using `bicep-implement` agent from dropdown)

2. **Review the Generated Code**:
   - Copilot creates:
     - `main.bicep` - Subscription-scoped orchestration
     - `modules/*.bicep` - Modular templates (VNet, NSGs, storage, etc.)
     - `parameters/*.json` - Parameter files for environments
     - `deploy.ps1`, `validate.ps1`, `cleanup.ps1` - Deployment scripts
     - `README.md` - Complete documentation

3. **Validation**:
   - Agent automatically runs:

     ```powershell
     bicep build main.bicep --stdout
     bicep lint main.bicep
     bicep format main.bicep
```

- Shows compilation success with no errors

1. **Optional Handoff**:
   - Click **"Review Security & Compliance"** to return to `azure-principal-architect`
   - Or click **"Update Plan Status"** to mark tasks complete in planning file

---

## 🎪 Key Demo Highlights

### 1. **Handoff Buttons Are the Magic** ✨

- Point out that clicking buttons **automatically switches agents**
- Context is passed seamlessly (no copy/paste needed)
- Agent names and prompts are pre-configured in `.agent.md` files

### 2. **Machine-Readable Plans**

- Show how planning file uses structured YAML
- Implementation agent reads this directly (not relying on LLM interpretation)
- Plans can be version-controlled and reviewed in PRs

### 3. **Production-Ready Code**

- Generated Bicep uses:
  - Latest API versions (2023-05-01+)
  - Security best practices (TLS 1.2, deny-by-default NSGs)
  - Modular architecture (separate modules for each resource type)
  - Comprehensive documentation
- Passes validation (build, lint, format)

### 4. **Time Savings**

   | Task | Manual Time | With Agents | Savings |
   |------|-------------|-------------|---------|
   | ADR Writing | 45 min | 2 min | 96% |
   | WAF Assessment | 60 min | 3 min | 95% |
   | Implementation Plan | 90 min | 5 min | 94% |
   | Bicep Templates | 120 min | 10 min | 92% |
   | **Total** | **5.25 hours** | **20 minutes** | **94%** |

---

## 💡 Demo Tips

### Before the Demo

- ✅ Clear chat history for clean demo
- ✅ Have sample ADR topic ready (or use hub network example)
- ✅ Test handoff buttons work (they're defined in `.github/agents/*.agent.md`)
- ✅ Ensure agents are accessible via Agent dropdown (`Ctrl+Shift+A`)

### During the Demo

- **Pause after each handoff** - Let audience see the button click
- **Show the agent files** - Open `.github/agents/bicep-plan.agent.md` to show handoff YAML
- **Highlight context preservation** - Point out how details carry forward
- **Demo validation** - Show Bicep compilation succeeding
- **Compare to manual** - Show an old manual Bicep file vs. generated one

### Common Questions

**Q: Do handoffs work if I invoke agent manually?**

- A: Yes, handoff buttons appear regardless of how agent is invoked

**Q: Can I customize the handoff prompts?**

- A: Yes, edit the `handoffs:` section in `.agent.md` files

**Q: What if a handoff button doesn't appear?**

- A: Check the agent's YAML frontmatter has `handoffs:` configured. The agent may have failed to provide handoff buttons if response was too long.

**Q: Can agents hand off back and forth?**

- A: Yes! The architect can hand to planner, planner to implementer, implementer back to architect for review.

---

## 📊 Demo Success Metrics

By the end of the demo, audience should understand:

- ✅ How to invoke custom agents (Agent button dropdown)
- ✅ That handoff buttons automatically switch agents with context
- ✅ The four-agent workflow (ADR → WAF → Plan → Implement)
- ✅ How agents produce production-ready outputs (not just suggestions)
- ✅ The time savings compared to manual approach (90%+)

---

## 🎬 Demo Variations

### Short Demo (5 minutes)

- Start at Phase 3 with pre-created ADR and WAF assessment
- Show plan generation → Bicep implementation → validation

### Deep Dive Demo (30 minutes)

- Complete all 4 phases
- Show editing an agent file to add a new handoff
- Deploy to Azure and validate resources
- Demonstrate cleanup script

### Troubleshooting Focus

- Show what happens when Bicep has errors
- Demonstrate how to fix issues iteratively
- Show how to update implementation plan and re-generate code

---

## 📁 Files Created During Demo

After completing all phases:

```text
github-copilot-itpro/
├── docs/adr/
│   └── adr-0003-hub-network-topology-test.md       # Phase 1 output
├── .bicep-planning-files/
│   └── INFRA.hub-network-test.md                   # Phase 3 output
└── infrastructure/hub-network-demo/
    ├── main.bicep                                  # Phase 4 output
    ├── modules/
    │   ├── virtual-network.bicep
    │   ├── network-security-groups.bicep
    │   └── ...
    ├── parameters/
    │   └── main.parameters.test.json
    ├── deploy.ps1
    ├── validate.ps1
    ├── cleanup.ps1
    └── README.md
```

**Clean Up After Demo**:

```powershell
# Delete test files
Remove-Item docs/adr/adr-0003-*.md
Remove-Item .bicep-planning-files/INFRA.hub-network-test.md
Remove-Item infrastructure/hub-network-demo -Recurse
```

---

## 🔗 Related Documentation

- [Five-Agent Workflow Guide](./FIVE-MODE-WORKFLOW.md) - Complete workflow documentation
- [Agent Configuration](../../.github/agents/) - Agent YAML files with handoffs
- [Copilot Instructions](../../.github/copilot-instructions.md) - Repository context for Copilot

---

**Demo Prepared By**: Infrastructure Team  
**Last Updated**: November 2025  
**Version**: 1.0
