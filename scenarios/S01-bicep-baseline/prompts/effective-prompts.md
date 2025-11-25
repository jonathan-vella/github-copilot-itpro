# S01: Effective Prompts for Azure Bicep Learning

This guide shows how to use **discovery questions** rather than generation commands when learning
Azure Bicep with GitHub Copilot. The goal is to build understanding, not just produce templates.

---

## Prompt Philosophy

### ❌ Script Generation (What to Avoid)

```
Generate a Bicep template for a VNet with 3 subnets
```

This produces code you can't maintain or troubleshoot.

### ✅ Conversation-Based Learning (Recommended)

```
I'm new to Azure networking. Can you explain what a Virtual Network is and how it
compares to VMware's Distributed Switch? Then help me build one step by step.
```

This builds understanding you can apply everywhere.

---

## Phase 1: Understanding Azure IaC

### Starting the Conversation

**If coming from traditional infrastructure**:
```
I've managed on-premises infrastructure for years but never done infrastructure-as-code.
What is Bicep and why would I use it instead of the Azure portal?
```

**If coming from VMware**:
```
I'm a VMware admin starting Azure. I've heard about Bicep and ARM templates. Can you
explain what they are and how they compare to PowerCLI scripts for vSphere automation?
```

**If coming from other cloud**:
```
I've used CloudFormation in AWS. How does Azure's Bicep compare? What concepts transfer
and what's different?
```

### Deepening Understanding

**About the relationship to ARM**:
```
I've seen ARM templates that are hundreds of lines of JSON. How does Bicep simplify that?
What happens when I deploy a Bicep file - does it become ARM JSON?
```

**About tooling**:
```
What tools do I need to work with Bicep? What VS Code extensions should I install?
```

**About when to use it**:
```
When should I use Bicep vs clicking in the Azure portal? Are there situations where
the portal is better?
```

---

## Phase 2: Architecture Discovery

### Mapping Existing Knowledge

**VMware networking**:
```
In VMware, I use Distributed Switches with Port Groups and NSX for firewall rules.
How do those concepts map to Azure networking? What are the equivalents?
```

**Traditional networking**:
```
I understand VLANs, subnets, and firewall rules from traditional networking. How does
Azure implement these concepts? What's the same and what's different?
```

**AWS networking**:
```
I'm familiar with AWS VPCs, subnets, and security groups. How do Azure networking
concepts compare?
```

### Architecture Questions

**Three-tier application**:
```
I'm building a three-tier application with web, app, and database layers. In my current
VMware environment, I separate these on different Port Groups with NSX rules controlling
traffic between them. How would I design this in Azure?
```

**Network segmentation**:
```
Security requires me to isolate web-facing resources from database servers. What Azure
services help me achieve this isolation? How does it compare to network segmentation
I'd do with VLANs?
```

**Hybrid connectivity**:
```
We have on-premises servers that need to connect to Azure. What are my options and
when would I use each one?
```

---

## Phase 3: Building Network Foundation

### Learning While Building

**Starting the VNet**:
```
Let's create my first Virtual Network in Bicep. I need three subnets for web, app, and
data tiers. Can you show me the code and explain each part as we go? I want to understand
what I'm writing, not just copy it.
```

**Understanding parameters**:
```
Why do we use parameters in Bicep? When should something be a parameter vs hardcoded?
Can you show me how to add validation so someone can't deploy with incorrect values?
```

**Understanding resources**:
```
I see 'Microsoft.Network/virtualNetworks@2023-05-01' in the resource definition. What
does the @2023-05-01 mean? How do I know which API version to use?
```

### NSG Questions

**Understanding NSGs**:
```
Now I need to control traffic between subnets like I would with NSX firewall rules.
What are Network Security Groups and how do they work?
```

**Rule priority**:
```
I see NSG rules have priority numbers. How does Azure evaluate multiple rules? What
happens if there's a conflict?
```

**Tier-to-tier control**:
```
Web tier should talk to app tier, app should talk to database, but web should NEVER
talk directly to database. How do I configure NSG rules for this?
```

**Deny by default**:
```
In NSX, I configure 'deny all' as a baseline and then add explicit allows. How do I
implement the same philosophy with Azure NSGs?
```

---

## Phase 4: Building Storage Foundation

### Security-Focused Questions

**Starting with security**:
```
I need a storage account for sensitive customer data. What security settings should I
configure and why does each one matter?
```

**Understanding each setting**:
```
I see 'supportsHttpsTrafficOnly: true' in the configuration. What attack does this
prevent? Are there any downsides to enabling it?
```

**TLS version**:
```
Why do we set 'minimumTlsVersion: TLS1_2'? What's wrong with older versions?
```

**Public access**:
```
What does 'allowBlobPublicAccess: false' do? I thought storage accounts were private
by default?
```

### Private Endpoint Questions

**Understanding the concept**:
```
What's a private endpoint? Is it like putting the storage on a private network segment
where only certain VMs can access it?
```

**When to use it**:
```
When should I use a private endpoint vs service endpoints vs public access with firewall
rules? What are the tradeoffs?
```

**DNS considerations**:
```
I've heard private endpoints require DNS configuration. Can you explain what's needed
and why?
```

---

## Phase 5: Orchestration & Best Practices

### Module Organization

**Understanding modules**:
```
I now have network.bicep and storage.bicep. How do I tie them together? In PowerCLI,
I'd have a main script that calls other scripts. What's the equivalent in Bicep?
```

**Passing values**:
```
My storage module needs the subnet ID from my network module. How do I pass values
between modules in Bicep?
```

**Output usage**:
```
Why do we define outputs? When would I use them vs just knowing the resource names?
```

### Environment Management

**Multiple environments**:
```
My team needs to deploy to dev, test, and production. In my current workflow, I have
different configuration files per environment. What's the Bicep equivalent?
```

**Parameter files**:
```
Show me how to create parameter files for different environments. How do I deploy
with a specific parameter file?
```

**Environment-specific settings**:
```
Dev should use cheaper SKUs, prod should use premium with redundancy. How do I
structure my Bicep to handle this cleanly?
```

### CI/CD Integration

**Pipeline integration**:
```
Eventually this needs to run in Azure DevOps or GitHub Actions. How should I structure
my files for team collaboration and automated deployment?
```

**What-if deployments**:
```
Before deploying to production, I want to see what changes will be made. Is there an
equivalent to Terraform plan in Bicep?
```

**Deployment validation**:
```
How do I validate my Bicep templates without actually deploying them? What checks
should I run in my CI pipeline?
```

---

## Troubleshooting Questions

### When Deployment Fails

**Understanding errors**:
```
I'm getting this deployment error: [paste error]. Can you explain what it means
and how to fix it?
```

**Common issues**:
```
My deployment says 'resource not found' for a resource that should exist. What
causes this and how do I debug it?
```

**Dependency issues**:
```
My deployment sometimes fails with timing issues - like one resource isn't ready
when another needs it. How do I handle dependencies in Bicep?
```

### Code Review Questions

**Security review**:
```
Can you review this storage account configuration and tell me if I'm missing any
security settings for production use?
```

**Best practice review**:
```
I've written this NSG configuration. Does it follow Azure best practices? What
would you improve?
```

---

## Advanced Discovery Questions

### For Deep Understanding

**API versions**:
```
I see different API versions for resources. How do I know which version to use?
What happens if I use an old version?
```

**Conditional deployment**:
```
I want to deploy a resource only in production, not in dev. How do I make
conditional deployments in Bicep?
```

**Loops and arrays**:
```
I have 10 NSG rules to create. Is there a way to loop through them instead of
writing each one individually?
```

**Existing resources**:
```
My network team already created the VNet. I need to add resources to the same
VNet. How do I reference existing resources in Bicep?
```

### For Team Scenarios

**Collaboration patterns**:
```
Multiple team members will work on this Bicep code. What practices help us avoid
conflicts and maintain quality?
```

**Shared modules**:
```
We want to create reusable modules for the whole organization. What's the best way
to share and version Bicep modules?
```

---

## Prompt Patterns Reference

### The Context-First Pattern
```
[Background about yourself and experience]
[What you're trying to accomplish]
[What you want to understand, not just generate]
```

### The Why Pattern
```
I see [code/configuration]. Why is it done this way? What would happen if I
[changed something]?
```

### The Compare Pattern
```
How does [Azure concept] compare to [familiar concept from VMware/AWS/on-prem]?
What transfers and what's different?
```

### The Review Pattern
```
Can you review this [code] and tell me:
1. Are there security issues?
2. Does it follow best practices?
3. What would you improve?
```

### The Debug Pattern
```
I'm getting [error/unexpected behavior]. Here's my code: [paste relevant code].
Can you explain what's wrong and how to fix it?
```

---

## Key Principle

**Invest 2 minutes asking "why" to save 20 minutes debugging later.**

The goal is to build understanding that transfers to future projects, not to generate
templates you can't maintain.

---

*These prompts guide conversation-based learning for Azure Bicep. Focus on understanding,
not just code generation.*
