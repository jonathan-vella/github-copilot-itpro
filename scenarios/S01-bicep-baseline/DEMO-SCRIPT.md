# S01: Azure Bicep Fundamentals - Demo Script

**Duration**: 30 minutes  
**Setup Required**: VS Code with GitHub Copilot Chat, Azure CLI (optional for deployment)  
**Backup**: `examples/copilot-bicep-conversation.md`

---

## Pre-Demo Checklist

- [ ] VS Code open with empty workspace
- [ ] GitHub Copilot Chat panel visible
- [ ] Copilot-instructions.md loaded (for Azure context)
- [ ] Azure CLI authenticated (optional)
- [ ] `examples/copilot-bicep-conversation.md` ready as backup

---

## Phase 0: Scene Setting (2 minutes)

### The Story

> *"Let me introduce Elena Rodriguez. She's a Cloud Infrastructure Engineer at Meridian Financial
> with 10 years of VMware experience. Her team has been running vSphere clusters, managing NSX
> firewall rules, and automating with PowerCLI.*
>
> *Now Elena has her first Azure project: deploy a secure network and storage foundation for a
> new customer-facing application. She's heard about Bicep but never written a line of it. She has
> two weeks to deliver.*
>
> *How would Elena traditionally approach this?*
> - *Search Azure docs (30+ minutes reading)*
> - *Find sample templates (hit-or-miss quality)*
> - *Copy-paste-modify (trial and error)*
> - *Debug deployment errors (Google each one)*
>
> *Let's see how Copilot transforms this experience by becoming her learning partner."*

### Key Point

> *"The goal isn't just to generate templates - Elena could find templates online. The goal is to
> **build understanding** so she can maintain, troubleshoot, and extend her infrastructure
> independently."*

---

## Phase 1: Understanding Azure IaC (5 minutes)

### Teaching Moment

> *"Elena starts where any engineer should - understanding the tools before using them.
> Watch how she uses Copilot not as a code generator, but as a knowledgeable colleague."*

### Live Demo

Open Copilot Chat and type:

```
I'm a VMware admin starting my first Azure project. I've heard about Bicep but don't
understand what it is or why I'd use it instead of clicking around in the Azure portal.
Can you explain what Bicep is and when I should use it?
```

**Copilot explains**: Bicep is Azure's declarative IaC language, compiles to ARM templates, etc.

### Follow-up

```
How does Bicep compare to ARM templates? I've seen some JSON templates that were
hundreds of lines long and seemed really complex.
```

**Teaching Moment**:
> *"Notice Elena isn't asking 'generate a template.' She's building foundational knowledge.
> This 2-minute investment pays off throughout the project."*

### Key Concepts Introduced

- Bicep is human-readable DSL
- Compiles to ARM JSON
- First-class VS Code support
- Modules for organization
- Parameters for reusability

---

## Phase 2: Architecture Discovery (5 minutes)

### Teaching Moment

> *"Now Elena maps her VMware knowledge to Azure. This is critical - she's not starting
> from zero, she's translating concepts she already understands."*

### Live Demo

```
I'm very familiar with VMware networking - vSphere Distributed Switches, port groups,
NSX firewall rules. How do Azure networking concepts map to what I already know?
```

**Copilot provides mapping**: VNet = Distributed Switch, Subnet = Port Group, NSG = NSX Firewall

### Follow-up

```
For my new application, I need web, application, and database tiers - just like I'd set
up in VMware with separate port groups. What would that look like in Azure networking?
```

**Key Teaching Moment**:
> *"Watch what Copilot does here. It doesn't just give subnet ranges - it explains **why**
> you'd separate tiers and how NSGs control traffic between them. Elena learns the architecture
> pattern, not just the syntax."*

### Concept Mapping (Show This)

| VMware | Azure | What Elena Learns |
|--------|-------|-------------------|
| Distributed Switch | Virtual Network | Network isolation boundary |
| Port Group | Subnet | Traffic segmentation |
| NSX Firewall Rule | NSG Rule | Layer 4 filtering |
| VLAN | Subnet + NSG | Microsegmentation |

---

## Phase 3: Building Network Foundation (7 minutes)

### Teaching Moment

> *"Now Elena writes her first Bicep. But watch - she doesn't ask 'generate a VNet.'
> She asks Copilot to **teach her** while building."*

### Live Demo

Create a new file `network.bicep`:

```
Let's start building my network infrastructure. I need to create a Virtual Network
with three subnets for web, app, and data tiers. Can you show me the Bicep code and
explain each part as we go? I want to understand what I'm writing, not just copy it.
```

**Copilot explains as it builds**:
- `param` decorators and validation
- `resource` keyword and API versions
- Properties and their purposes
- `output` for cross-module references

### Key Walkthrough Points

**When Copilot shows parameters**:
> *"See the `@description` decorators? These aren't just comments - they appear in the
> deployment UI. Elena learns documentation best practices immediately."*

**When Copilot shows the VNet resource**:
> *"Notice the API version `2023-05-01`. Copilot uses current versions automatically.
> If Elena copied an old template from StackOverflow, it might use deprecated properties."*

### Security Extension

```
What about NSGs? In VMware, I'd use NSX to control traffic between tiers - web can
talk to app, app can talk to database, but web can't go directly to database. How do
I do that in Azure?
```

**Teaching Moment**:
> *"This is where Copilot shines as a security teacher. Watch it explain the 'deny by default'
> philosophy and show how to build explicit allow rules."*

---

## Phase 4: Building Storage Foundation (5 minutes)

### Teaching Moment

> *"Elena needs storage for application data. Again, she doesn't just ask for code -
> she asks Copilot to explain security considerations."*

### Live Demo

Create a new file `storage.bicep`:

```
Now I need a storage account for application data. This will hold sensitive customer
information, so security is critical. What settings should I configure and why?
```

**Copilot covers**:
- HTTPS only enforcement
- TLS 1.2 minimum
- Public access restrictions
- Soft delete for data protection
- Private endpoints for secure access

### Key Security Points

> *"Watch Copilot explain **why** each setting matters:*
> - *`supportsHttpsTrafficOnly: true` - prevents man-in-the-middle attacks*
> - *`allowBlobPublicAccess: false` - no accidental data leaks*
> - *`minimumTlsVersion: 'TLS1_2'` - compliance requirement*
>
> *Elena learns security rationale, not just syntax."*

### Private Endpoint Discussion

```
What's a private endpoint? Is that like having the storage on a private network
segment in VMware where only certain VMs can access it?
```

**Teaching Moment**:
> *"This VMware-to-Azure mapping is exactly how experienced engineers learn fastest.
> Elena understands the **concept** through familiar terms, then learns the Azure implementation."*

---

## Phase 5: Orchestration & Best Practices (8 minutes)

### Teaching Moment

> *"Elena now has network.bicep and storage.bicep. How does she tie them together
> and set up her project for team collaboration?"*

### Live Demo

Create `main.bicep`:

```
I now have network.bicep and storage.bicep. How do I organize these for a real
project? In VMware, I'd have templates and use PowerCLI to orchestrate deployments.
What's the equivalent pattern in Bicep?
```

**Copilot explains**:
- Module concept (like calling functions)
- Parameter passing between modules
- Output chaining
- Separation of concerns

### Parameters for Environments

```
My team needs to deploy to dev, test, and production. In VMware, I'd have different
PowerCLI parameter files. What's the equivalent in Bicep?
```

**Copilot shows parameter files**: `main.dev.bicepparam`, `main.prod.bicepparam`

### CI/CD Preparation

```
Eventually this needs to run in a CI/CD pipeline. How should I structure my files
so my team can collaborate and automate deployments?
```

**Teaching Moment**:
> *"Elena learns the professional pattern: separate modules, parameter files per environment,
> outputs for downstream automation. This is how Azure teams work."*

### Final Structure Review

```
infra/
├── main.bicep              # Orchestration
├── main.dev.bicepparam     # Dev settings
├── main.prod.bicepparam    # Production settings
├── modules/
│   ├── network.bicep       # Network resources
│   └── storage.bicep       # Storage resources
└── README.md               # Documentation
```

---

## Phase 6: Wrap-Up (3 minutes)

### Deployment Demo (Optional)

If Azure CLI is available:

```powershell
# Validate the template
az deployment group validate \
    --resource-group rg-meridian-dev \
    --template-file main.bicep \
    --parameters main.dev.bicepparam

# Deploy (if time permits)
az deployment group create \
    --resource-group rg-meridian-dev \
    --template-file main.bicep \
    --parameters main.dev.bicepparam
```

### Value Recap

> *"Let's review what Elena accomplished in 30 minutes:*
>
> **Traditional Approach** (45-60 minutes):
> - Search docs and samples: 20 min
> - Copy-paste-modify: 15 min
> - Debug errors: 15 min
> - No deep understanding
>
> **Conversation Approach** (30 minutes):
> - Understood Bicep fundamentals: 5 min
> - Mapped VMware → Azure concepts: 5 min
> - Built network with NSGs: 7 min
> - Built secure storage: 5 min
> - Learned module organization: 8 min
>
> **The difference**: Elena can now troubleshoot her own code, explain it to teammates,
> and adapt it for future projects. She built **knowledge**, not just templates."*

### Key Metrics

| Metric | Traditional | Conversation | Improvement |
|--------|-------------|--------------|-------------|
| Time to first deployment | 45-60 min | 30 min | 50% faster |
| Understanding gained | Minimal | Complete | Invaluable |
| Future project time | 30-45 min | 10-15 min | 67% faster |
| Security coverage | Hit-or-miss | Comprehensive | ✅ |
| Can maintain independently | Limited | Yes | ✅ |

### Call to Action

> *"Elena's journey shows how Copilot transforms IaC learning. The value isn't in generating
> templates faster - it's in building **understanding** so engineers become self-sufficient.*
>
> *Next: Try this yourself. Start with your own scenario, map your existing knowledge,
> and let Copilot teach you while you build."*

---

## Backup Scenarios

### If Copilot Gives Generic Responses

**Reset with context**:
```
I have 10 years of VMware experience - vSphere, NSX, PowerCLI. I'm learning Azure
and Bicep for my first Azure project. Can you help me understand [concept] in terms
I'd recognize from the VMware world?
```

### If Participant Asks About ARM Templates

```
What's the difference between Bicep and ARM templates? When would I use one vs the other?
```

### If Participant Asks About Terraform

> *"Great question. Terraform is another excellent IaC tool - we cover it in S02. Bicep is
> Azure-native and sometimes has features before Terraform. Choose based on your team's needs."*

### If Deployment Fails

Show the error to Copilot:
```
I'm getting this deployment error: [paste error]. Can you explain what it means
and how to fix it?
```

---

## Post-Demo Resources

### For Participants
- `examples/copilot-bicep-conversation.md` - Full conversation transcript
- `solution/` - Reference Bicep templates
- `validation/` - Deployment and verification scripts

### For Presenters
- `prompts/effective-prompts.md` - Prompt patterns for each phase
- `scenario/requirements.md` - Elena's business requirements
- `scenario/architecture.md` - Target architecture diagram

### Extended Learning
- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [S02: Terraform Baseline](../S02-terraform-baseline/) - Multi-cloud alternative
- [S03: Five-Agent Workflow](../S03-five-agent-workflow/) - Enterprise patterns

---

*This demo script guides presenters through a 30-minute conversation-based learning experience
for Azure Bicep fundamentals. Focus on teaching, not just generating.*
