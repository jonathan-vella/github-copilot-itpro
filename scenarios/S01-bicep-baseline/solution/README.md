# S01 Reference Solution

This folder contains **pre-built Bicep templates** that represent the output of the conversation-based
learning approach demonstrated in this scenario.

## Purpose

These templates serve as:

1. **Reference Implementation** - See the expected output of the learning conversation
2. **Deployment Verification** - Test the templates work in your environment
3. **Comparison Point** - Compare your conversation-generated code to near-production-ready code
4. **Backup for Demos** - Presenter fallback if live conversation needs acceleration

## When to Use These Templates

### ✅ Use the Pre-Built Templates When

- **Validating the demo environment** - Ensure Azure subscription can deploy the resources
- **Time-constrained sessions** - Need to show results without live coding
- **Post-demo reference** - Participants want to study the code later
- **CI/CD examples** - Showing automated deployment patterns

### ✅ Use the Conversation Approach When

- **Learning Bicep** - Building understanding of syntax and patterns
- **Teaching others** - Demonstrating the learning value of Copilot
- **Custom scenarios** - Your requirements differ from the demo
- **Building knowledge** - Want to understand WHY, not just copy code

## File Overview

```
solution/
├── README.md           # This file
├── main.bicep          # Orchestration template (calls modules)
├── network.bicep       # Network module (VNet, subnets, NSGs)
└── storage.bicep       # Storage module (account, private endpoint)
```

### main.bicep

The orchestration template that:

- Defines parameters for the deployment
- Calls network and storage modules
- Passes outputs between modules
- Sets resource tags and location

### network.bicep

The network module that creates:

- Virtual Network with address space
- Three subnets (web, app, data tiers)
- Network Security Groups for each tier
- NSG rules for tier-to-tier traffic control
- Outputs for subnet IDs

### storage.bicep

The storage module that creates:

- Storage Account with security hardening
- Private endpoint for secure access
- Private DNS zone and link
- Soft delete configuration
- Outputs for storage endpoints

## Recommended Workflow

### For Learners

```
1. Work through the conversation (examples/copilot-bicep-conversation.md)
2. Build your own templates through dialog with Copilot
3. Compare your output to these reference templates
4. Understand the differences and learn from them
```

### For Teams

```
1. Learn the patterns through conversation approach
2. Customize these templates for your organization
3. Add your naming conventions and tag policies
4. Use as starting point for production deployments
```

### For Demos

```
1. Start with live conversation (builds engagement)
2. If running short on time, pivot to these templates
3. Use validation/deploy.ps1 to show actual deployment
4. Reference these files for post-demo questions
```

## Deployment

```powershell
# From the validation folder
cd ../validation

# Deploy
./deploy.ps1 -ResourceGroupName "rg-meridian-dev" -Location "swedencentral"

# Verify
./verify.ps1 -ResourceGroupName "rg-meridian-dev"

# Cleanup
./cleanup.ps1 -ResourceGroupName "rg-meridian-dev"
```

## Architecture Reference

The templates create this architecture:

```
┌─────────────────────────────────────────────────────────────────┐
│  Resource Group: rg-meridian-dev                                │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Virtual Network: vnet-meridian-dev-swedencentral         │  │
│  │  Address Space: 10.0.0.0/16                              │  │
│  │                                                           │  │
│  │  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────┐ │  │
│  │  │ snet-web        │ │ snet-app        │ │ snet-data   │ │  │
│  │  │ 10.0.1.0/24     │ │ 10.0.2.0/24     │ │ 10.0.3.0/24 │ │  │
│  │  │ NSG: nsg-web    │ │ NSG: nsg-app    │ │ NSG: nsg-data│ │  │
│  │  └─────────────────┘ └─────────────────┘ └─────────────┘ │  │
│  │                                                           │  │
│  │  Private Endpoint ────────────────────────────────────┐  │  │
│  │                                                        │  │  │
│  └────────────────────────────────────────────────────────│──┘  │
│                                                           │     │
│  ┌────────────────────────────────────────────────────────│──┐  │
│  │  Storage Account: stmeridian{suffix}                   │  │  │
│  │  - HTTPS only                                          │  │  │
│  │  - TLS 1.2 minimum                                     │  │  │
│  │  - No public blob access                               │  │  │
│  │  - Soft delete enabled                                 │  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Security Features Implemented

| Feature               | Implementation                   | Why It Matters           |
| --------------------- | -------------------------------- | ------------------------ |
| NSG Deny-All Baseline | Priority 4096 deny rules         | Block unexpected traffic |
| Tier Isolation        | Web→App, App→Data only           | Prevent lateral movement |
| HTTPS Only            | `supportsHttpsTrafficOnly: true` | Encrypt in transit       |
| TLS 1.2               | `minimumTlsVersion: 'TLS1_2'`    | Modern encryption        |
| No Public Blobs       | `allowBlobPublicAccess: false`   | Prevent data leaks       |
| Private Endpoint      | Storage on private network       | No public exposure       |
| Soft Delete           | 7-day retention                  | Data recovery option     |

## Customization Points

### Environment-Specific Changes

```bicep
// For production, consider:
- Increase subnet sizes (/23 instead of /24)
- Add DDoS protection
- Configure diagnostic logging
- Add geo-redundancy for storage
- Implement Azure Policy assignments
```

### Organization-Specific Changes

```bicep
// Add your organization's:
- Naming conventions
- Required tags (CostCenter, Owner, etc.)
- Approved regions
- Compliance labels
```

---

_These templates demonstrate near-production-ready Bicep patterns. Use them as a reference after
learning the concepts through conversation with Copilot._
