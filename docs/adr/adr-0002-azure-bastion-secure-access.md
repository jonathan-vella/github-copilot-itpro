# ADR-0002: Azure Bastion vs Jump Boxes for Demo Environment Secure Access

## Status

Accepted

## Date

2025-11-17

## Context

### Problem Statement

Demo environments in this repository require secure RDP/SSH access to virtual machines for:

- Live demonstrations to customers and partners
- Testing infrastructure deployments
- Troubleshooting scenarios in Demo 4 (Troubleshooting Assistant)

### Technical Constraints

- Demos must complete within 30-minute time windows
- Demo environments are temporary (created and destroyed frequently)
- Must demonstrate Azure security best practices
- Budget-conscious approach required
- Minimal management overhead desired

### Business Requirements

- Provide secure access without public IPs on VMs
- Align with Azure Well-Architected Framework security pillar
- Enable quick demo setup and teardown
- Demonstrate modern Azure patterns to IT Pros transitioning from traditional infrastructure

## Decision

We will use **Azure Bastion** as the standard secure access method for VMs in all demo environments.

## Consequences

### Positive

**POS-001: Enhanced Security Posture**

- No public IP addresses required on VMs
- No exposed RDP/HTTPS ports (3389/22) to internet
- Integrated with Azure Active Directory for authentication
- Demonstrates Azure security best practices to demo audiences

**POS-002: Simplified Network Security**

- No Jump Box VM to patch, manage, or secure
- No NSG rules allowing RDP/SSH from internet
- Reduced attack surface area
- Cleaner network architecture diagrams for demos

**POS-003: Improved Demo Experience**

- Browser-based access (no RDP client installation required)
- Works from any device with modern browser
- Single-click access from Azure Portal
- No VPN or complex network setup needed

**POS-004: Compliance and Audit Benefits**

- All access logged through Azure Activity Log
- Centralized access control via Azure RBAC
- Meets enterprise security requirements
- Can demonstrate compliance features to customers

**POS-005: Infrastructure as Code Simplicity**

- Standard Bicep module can be reused across demos
- Fewer resources to manage in templates
- Consistent deployment pattern

### Negative

**NEG-001: Additional Azure Cost**

- Azure Bastion costs ~$140/month when deployed
- Cannot use free tier for this service
- Cost multiplies if deployed in multiple demo environments simultaneously
- Mitigation: Deploy only when needed, cleanup after demos

**NEG-002: Deployment Time**

- Bastion takes 5-10 minutes to provision
- Slower than creating a simple Jump Box VM
- Impacts demo setup time
- Mitigation: Pre-deploy for scheduled demos

**NEG-003: Cannot Demonstrate Traditional Patterns**

- Some customers still use Jump Box approach
- Cannot show legacy pattern migration stories
- Limited comparison scenarios
- Mitigation: Document Jump Box approach in demo notes as "old way"

**NEG-004: Regional Availability**

- Not available in all Azure regions
- May limit demo region choices
- Potential impact on multi-region demo scenarios
- Mitigation: Use Bastion-supported regions for demos

**NEG-005: Feature Limitations**

- Cannot copy/paste files easily (requires Premium SKU)
- No native tunneling for complex scenarios
- SharePoint not accessible like traditional Jump Box
- Mitigation: Use Azure Storage for file transfers in demos

## Alternatives Considered

### Alternative 1: Traditional Jump Box VM

**ALT-001: Deploy a dedicated Windows/Linux VM as Jump Box**

- Lower cost (~$30/month for B2s VM)
- Faster deployment (2-3 minutes)
- Familiar pattern for traditional IT Pros
- Allows file transfers and complex tooling

**ALT-002: Rejected**

- Requires management overhead (patching, monitoring, backups)
- Needs public IP or VPN connection
- NSG rules expose RDP/SSH to internet (security risk)
- Does not demonstrate modern Azure patterns
- Additional complexity in Bicep templates (VM, disk, NIC, public IP, NSG rules)

### Alternative 2: Just-in-Time (JIT) VM Access

**ALT-003: Use Azure Security Center JIT VM Access**

- Time-bound access to VMs
- No additional resources required
- Lower cost (uses existing VMs)
- Good security posture with temporary access

**ALT-004: Rejected**

- Still requires public IPs on VMs
- Requires Azure Defender (additional cost ~$15/VM/month)
- More complex to demonstrate in 30-minute format
- Requires manual approval workflow that slows demos
- Not as intuitive for IT Pros new to Azure

### Alternative 3: Azure Virtual Desktop (AVD)

**ALT-005: Deploy AVD session hosts for remote access**

- Provides full Windows desktop experience
- Can install any tools needed
- Multi-user support
- Good for longer training sessions

**ALT-006: Rejected**

- Significant additional cost ($150+ per month)
- Complex setup and management
- Overkill for simple demo access needs
- Would consume too much demo time to explain
- Not relevant to infrastructure demos

### Alternative 4: Direct VNet Peering to Demo Network

**ALT-007: Peer demo VNets to a secure management network**

- No public access required
- Low cost (peering is inexpensive)
- Good for permanent environments
- Could support multiple demos

**ALT-008: Rejected**

- Requires permanent management VNet infrastructure
- Complex network design for temporary demos
- Presenters would need VPN to management VNet
- Does not demonstrate Bastion, a key Azure security service
- Difficult to explain in customer-facing demos

## Implementation Notes

**IMP-001: Phased Rollout**

- Phase 1 (Immediate): Update Demo 1 (Bicep Quickstart) to include Bastion
- Phase 2 (Week 1): Add Bastion to Demo 3 (Azure Arc) for hybrid scenarios
- Phase 3 (Week 2): Create reusable Bicep module in /resources/bicep-modules/
- Phase 4 (Week 3): Update all demo documentation with Bastion access instructions

**IMP-002: Cost Optimization Strategy**

- Deploy Bastion only in active demo environments
- Use cleanup scripts to remove Bastion after demos
- Consider shared Bastion for multiple demo VNets (hub-spoke pattern)
- Document cost-saving alternatives in demo notes

**IMP-003: Bicep Module Standards**

- Create /resources/bicep-modules/bastion/main.bicep
- Include Standard SKU by default (Basic for cost-sensitive demos)
- Add parameters for subnet configuration
- Include diagnostic settings for monitoring
- Add outputs for Bastion resource ID

**IMP-004: Demo Script Updates**

- Add "Accessing VMs" section to all demo scripts
- Include screenshots of Azure Portal Bastion experience
- Document browser requirements (Edge, Chrome recommended)
- Add troubleshooting section for common connection issues

**IMP-005: Validation Criteria**

- Test Bastion deployment in all supported demo regions
- Verify RDP access to Windows VMs (Demo 1, 2)
- Verify SSH access to Linux VMs (Demo 3)
- Confirm deployment time < 10 minutes
- Validate cleanup scripts remove Bastion resources

**IMP-006: Success Metrics**

- Track demo environment setup time (target: < 15 minutes including Bastion)
- Monitor Azure costs for Bastion across all demos
- Collect partner feedback on Bastion demo experience
- Measure customer questions about secure access vs. traditional methods

## References

**REF-001: Azure Bastion Documentation**
https://learn.microsoft.com/azure/bastion/bastion-overview

**REF-002: Azure Well-Architected Framework - Security**
https://learn.microsoft.com/azure/architecture/framework/security/

**REF-003: Azure Bastion Pricing**
https://azure.microsoft.com/pricing/details/azure-bastion/

**REF-004: Bicep Module for Azure Bastion (Azure Verified Modules)**
https://github.com/Azure/bicep-registry-modules/tree/main/modules/network/bastion-host

**REF-005: Jump Box vs Bastion Comparison (Azure Architecture Center)**
https://learn.microsoft.com/azure/architecture/guide/security/access-azure-bastion

## Decision History

- **2025-11-17**: Initial proposal and acceptance
  - Reviewed by: Repository maintainers
  - Approved for implementation in all demos
  - Cost analysis completed, deemed acceptable for demo purposes
