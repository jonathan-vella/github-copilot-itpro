# Demo Script: Bicep Quickstart with GitHub Copilot

⏱️ **Total Duration**: 30 minutes  
🎯 **Target Audience**: IT Pros, Cloud Architects, System Integrators  
📊 **Demonstrated Value**: 45 min → 10 min (78% time reduction)

---

## Pre-Demo Checklist

### 5 Minutes Before Demo

- [ ] Azure CLI logged in: `az login`
- [ ] VS Code open with GitHub Copilot active (check status bar)
- [ ] Demo resource group cleaned up: `az group delete -n rg-copilot-demo --yes`
- [ ] Have [prompts/effective-prompts.md](./prompts/effective-prompts.md) open in separate tab
- [ ] Close unnecessary tabs/windows for clean demo
- [ ] Test Copilot: Open new `.bicep` file, type `param`, verify suggestions appear

### Environment Setup

```powershell
# Verify tools
az --version          # Should be 2.50.0+
bicep --version       # Should be 0.20.0+
code --version        # Verify VS Code

# Set Azure subscription
az account set --subscription "your-subscription-id"
az account show --output table
```

---

## Demo Flow

### Phase 1: Scene Setting (5 minutes)

#### 1.1 Introduce the Scenario (2 min)

**Script:**
> "Today we're helping a financial services company deploy Azure infrastructure for a new application. They need a secure network with multiple tiers and storage. The challenge? Their team has limited Bicep experience and tight deadlines.
>
> Traditionally, this would take about 45 minutes: researching Bicep syntax, writing templates, debugging errors. With GitHub Copilot, we'll complete this in 10 minutes."

**Show the architecture diagram:**

- Open [scenario/architecture.md](./scenario/architecture.md)
- Highlight: VNet with 3 subnets, NSGs, storage account
- Mention security requirements (NSGs, private endpoints)

#### 1.2 Show Traditional Approach (3 min)

**Open**: [manual-approach/template.json](./manual-approach/template.json)

**Script:**
> "Here's what a traditional ARM template looks like. Notice:
>
> - 250+ lines of JSON
> - Complex syntax and nested objects
> - Easy to make mistakes
> - Difficult to read and maintain
> - No IntelliSense for resource properties"

**Scroll through** the JSON file slowly, highlighting complexity.

**Open**: [manual-approach/time-tracking.md](./manual-approach/time-tracking.md)

**Script:**
> "The manual approach breaks down like this:
>
> - 15 minutes: Research and setup
> - 20 minutes: Writing the template
> - 10 minutes: Debugging errors
> - Total: 45 minutes
>
> Now let's see how Copilot changes this."

---

### Phase 2: Copilot-Assisted Development (15 minutes)

#### 2.1 Create Network Infrastructure (7 min)

**Action:** Create new file `with-copilot/network.bicep`

**Script:**
> "I'll start with a natural language comment describing what I need."

**Type this prompt:**

```bicep
// Create an Azure Virtual Network named 'vnet-demo' with address space 10.0.0.0/16
// Include three subnets: web-tier (10.0.1.0/24), app-tier (10.0.2.0/24), data-tier (10.0.3.0/24)
// Add a location parameter and resource name parameter
```

**PAUSE** and let Copilot suggest.

**Expected Suggestion:**

```bicep
param location string = resourceGroup().location
param vnetName string = 'vnet-demo'
param addressPrefix string = '10.0.0.0/16'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'web-tier'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'app-tier'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
      {
        name: 'data-tier'
        properties: {
          addressPrefix: '10.0.3.0/24'
        }
      }
    ]
  }
}

output vnetId string = virtualNetwork.id
output subnetIds array = [for (subnet, i) in virtualNetwork.properties.subnets: subnet.id]
```

**Accept suggestion** (Tab or Enter).

**Script:**
> "Notice what Copilot did:
>
> - Used the latest API version (2023-05-01)
> - Created parameters with sensible defaults
> - Structured subnets correctly
> - Added outputs for the VNet ID (useful for linking resources)
> - Followed Bicep best practices
>
> This would have taken 15 minutes manually. We just did it in 30 seconds."

**Now add NSG:**

**Type this prompt:**

```bicep
// Add a Network Security Group for the web tier subnet
// Allow inbound HTTP (80) and HTTPS (443) from Internet
// Allow outbound to app-tier subnet on port 8080
```

**Accept Copilot's suggestion** (should generate NSG with rules).

**Script:**
> "Copilot understands the security context. It's creating NSG rules that:
>
> - Allow standard web traffic
> - Restrict access between tiers
> - Follow least-privilege principles
>
> This is production-ready security configuration."

**Save file:** `Ctrl+S`

#### 2.2 Create Storage Infrastructure (4 min)

**Action:** Create new file `with-copilot/storage.bicep`

**Type this prompt:**

```bicep
// Create a secure storage account for the application
// Requirements:
// - Blob storage with hot tier
// - HTTPS only, TLS 1.2 minimum
// - Disable public blob access
// - Enable blob soft delete (7 days)
// - Use location and tags parameters
```

**Accept Copilot's suggestion.**

**Expected Suggestion:**

```bicep
param location string = resourceGroup().location
param storageAccountName string = 'stdemo${uniqueString(resourceGroup().id)}'
param tags object = {}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

output storageAccountId string = storageAccount.id
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
```

**Script:**
> "Look at what Copilot included:
>
> - `uniqueString()` function for globally unique naming
> - All security requirements met (HTTPS, TLS 1.2, no public access)
> - Blob soft delete configured
> - Proper parent-child resource relationship
> - Useful outputs for connecting to the storage account
>
> This level of security configuration would take 10-15 minutes to research and implement manually."

**Save file:** `Ctrl+S`

#### 2.3 Create Main Orchestration File (4 min)

**Action:** Create new file `with-copilot/main.bicep`

**Type this prompt:**

```bicep
// Main orchestration template
// Deploy the network and storage modules
// Use parameters for location, environment (dev/prod), and tags
```

**Accept Copilot's suggestion.**

**Expected Suggestion:**

```bicep
param location string = resourceGroup().location
param environment string = 'dev'
param tags object = {
  Environment: environment
  ManagedBy: 'Bicep'
  Project: 'CopilotDemo'
}

module network 'network.bicep' = {
  name: 'network-deployment'
  params: {
    location: location
    vnetName: 'vnet-${environment}-demo'
  }
}

module storage 'storage.bicep' = {
  name: 'storage-deployment'
  params: {
    location: location
    storageAccountName: 'st${environment}demo${uniqueString(resourceGroup().id)}'
    tags: tags
  }
}

output vnetId string = network.outputs.vnetId
output storageAccountId string = storage.outputs.storageAccountId
output blobEndpoint string = storage.outputs.blobEndpoint
```

**Script:**
> "Copilot created a clean orchestration template:
>
> - Module references to our network and storage files
> - Consistent parameter passing
> - Environment-based naming (dev/prod)
> - Aggregated outputs from all modules
>
> This is exactly how you'd structure a production Bicep project."

**Save file:** `Ctrl+S`

---

### Phase 3: Validation & Deployment (8 minutes)

#### 3.1 Validate Bicep Code (2 min)

**Run validation:**

```powershell
# Build/compile the Bicep template
az bicep build --file with-copilot/main.bicep

# Validate against Azure
az deployment group validate `
  --resource-group rg-copilot-demo `
  --template-file with-copilot/main.bicep `
  --parameters location=eastus environment=demo
```

**Script:**
> "Bicep compilation succeeded. No syntax errors. Now validating against Azure to ensure the deployment will work."

**Show success message:**
> "Validation passed! The template is ready to deploy."

#### 3.2 Deploy to Azure (4 min)

**Run deployment script:**

```powershell
# Navigate to validation folder
cd validation

# Run deployment script
./deploy.ps1 -ResourceGroupName "rg-copilot-demo" -Location "eastus" -Environment "demo"
```

**Script:**
> "I'm running an automated deployment script. This will:
>
> 1. Create the resource group if it doesn't exist
> 2. Deploy the Bicep template
> 3. Report deployment status
>
> While this runs, let's talk about what we accomplished..."

**While deploying, highlight:**

| Metric | Manual | With Copilot | Improvement |
|--------|--------|--------------|-------------|
| Development Time | 45 min | 10 min | **78% faster** |
| Lines Typed | 250+ | 50 (prompts) | **80% less** |
| Errors Encountered | 3-5 | 0 | **Zero errors** |

**Script:**
> "We just built production-ready infrastructure in 10 minutes. That's 35 minutes saved. For a team deploying infrastructure daily, this adds up to hours per week."

#### 3.3 Verify Deployment (2 min)

**Run verification script:**

```powershell
./verify.ps1 -ResourceGroupName "rg-copilot-demo"
```

**Expected output:**

```

✅ Resource Group: rg-copilot-demo exists
✅ VNet: vnet-demo-demo deployed
✅ Subnets: 3 subnets configured
✅ NSG: nsg-web-tier attached
✅ Storage Account: stdemoXXXXXX deployed
✅ Storage Security: HTTPS only, TLS 1.2, no public access
✅ Blob Soft Delete: Enabled (7 days)

Deployment Status: SUCCESS ✅
Total Resources: 6
Deployment Time: 3m 42s

```

**Script:**
> "All resources deployed successfully. Everything is configured exactly as specified. Let's review what we created..."

**Open Azure Portal** (optional):

- Show VNet with subnets
- Show NSG rules
- Show storage account security settings

---

### Phase 4: Key Takeaways & Q&A (2 minutes)

#### 4.1 Summarize Value (1 min)

**Script:**
> "Let's recap what GitHub Copilot enabled:
>
> **Speed**: 10 minutes vs. 45 minutes (78% faster)
>
> - Generated 250+ lines of code from natural language prompts
> - Zero syntax errors
> - Production-ready security configuration
>
> **Quality**:
>
> - Latest API versions
> - Azure best practices built-in
> - Consistent naming and structure
>
> **Learning Accelerator**:
>
> - No prior Bicep expertise required
> - Learn by doing
> - Context-aware suggestions teach best practices
>
> **Business Impact**:
>
> - Faster time to production
> - Lower training costs
> - Reduced operational overhead
> - More time for strategic work"

#### 4.2 Next Steps (1 min)

**Script:**
> "Here's how to get started:
>
> **For IT Pros:**
>
> 1. Clone this repository
> 2. Follow the demo script
> 3. Experiment with your own scenarios
>
> **For Partners:**
>
> 1. Use the [Partner Toolkit](../../partner-toolkit/) for customer demos
> 2. Customize prompts for your client scenarios
> 3. Share success stories with the community
>
> **Next Demo:**
>
> - [Demo 2: PowerShell Automation](../02-powershell-automation/) - Automate Azure operations
> - [Demo 3: Azure Arc Onboarding](../03-azure-arc-onboarding/) - Manage hybrid environments"

---

## Demo Cleanup

### After the Demo

```powershell
# Clean up Azure resources
cd validation
./cleanup.ps1 -ResourceGroupName "rg-copilot-demo"

# Verify cleanup
az group show --name rg-copilot-demo
# Should return "ResourceGroupNotFound"
```

---

## Troubleshooting Guide

### Copilot Not Suggesting

**Issue:** Copilot doesn't suggest code after typing prompt

**Solutions:**

1. Press `Ctrl+Enter` to open Copilot panel
2. Check VS Code status bar - ensure Copilot icon is active
3. Verify file is saved with `.bicep` extension
4. Try rephrasing the prompt

### Deployment Failures

**Issue:** `az deployment group create` fails

**Solutions:**

```powershell
# Check template validation
az bicep build --file main.bicep

# Validate before deploying
az deployment group validate --resource-group rg-copilot-demo --template-file main.bicep

# Check Azure quota/limits
az vm list-usage --location eastus --output table
```

### Authentication Issues

**Issue:** Azure CLI not authenticated

**Solutions:**

```powershell
# Re-login
az login

# Set subscription
az account set --subscription "your-subscription-id"
az account show
```

---

## Presentation Tips

### Engaging Your Audience

1. **Pause after Copilot suggestions**: Let the audience see the magic happen
2. **Highlight surprises**: "Notice Copilot added outputs automatically"
3. **Compare to manual**: Show ARM template complexity vs. Bicep simplicity
4. **Invite participation**: "What else should we add?" - take prompt suggestions
5. **Share war stories**: Relate to real-world infrastructure challenges

### Backup Plans

**If Copilot is slow/unresponsive:**

- Have pre-written code in `backup/` folder
- Copy-paste and explain what Copilot would have generated

**If Azure deployment is slow:**

- Continue to Phase 4 while deployment runs in background
- Show Portal view of existing deployment

**If demo environment fails:**

- Use screenshots from `screenshots/` folder
- Walk through pre-deployed environment

### Time Management

| Phase | Target Time | Flex Time |
|-------|-------------|-----------|
| Scene Setting | 5 min | +2 min |
| Copilot Dev | 15 min | -5 min |
| Deployment | 8 min | +3 min |
| Takeaways | 2 min | +1 min |
| **Total** | **30 min** | **±5 min** |

**If running short on time:**

- Skip manual approach walkthrough (Phase 1.2)
- Use pre-deployed resources for verification

**If you have extra time:**

- Add monitoring (Log Analytics prompt)
- Demonstrate Copilot Chat for explanations
- Show how to refactor/improve code with Copilot

---

## Additional Resources

### Prompts to Keep Handy

From [prompts/effective-prompts.md](./prompts/effective-prompts.md):

```bicep
// Add diagnostic settings for the storage account to send logs to Log Analytics

// Create a private endpoint for the storage account in the data-tier subnet

// Add tags to all resources with Environment, Owner, and CostCenter

// Generate a parameter file for production environment
```

### Related Demos

- **[Demo 2: PowerShell Automation](../02-powershell-automation/)** - Build on this with automated operations
- **[Demo 3: Azure Arc Onboarding](../03-azure-arc-onboarding/)** - Extend to hybrid scenarios
- **[Skills Bridge: IaC Fundamentals](../../skills-bridge/iac-fundamentals/)** - Deep dive for learners

---

**🎯 Goal**: Show that GitHub Copilot is an efficiency multiplier for IT Pros, not just developers  
**💡 Key Message**: "10 minutes with Copilot = 45 minutes of manual work"  
**🚀 Call to Action**: "Start using Copilot today - your future self will thank you"

[🏠 Back to Demo README](./README.md) | [📚 View All Demos](../../README.md#-featured-demos)
