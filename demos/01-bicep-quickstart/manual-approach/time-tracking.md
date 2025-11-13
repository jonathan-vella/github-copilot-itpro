# Time Tracking: Manual Approach (Without Copilot)

**Engineer**: Demo User  
**Date**: January 2025  
**Scenario**: Deploy three-tier network infrastructure with secure storage  
**Approach**: Traditional manual development (ARM/Bicep without AI assistance)

---

## Summary

| Metric | Time | Notes |
|--------|------|-------|
| **Research & Planning** | 15 minutes | Reading documentation, planning structure |
| **Code Development** | 35 minutes | Writing templates manually |
| **Debugging & Fixes** | 15 minutes | 3 deployment attempts with errors |
| **Documentation** | 10 minutes | Writing comments and README |
| **Total Development Time** | **75 minutes** | Does not include learning curve |
| **Deployment Time** | 3 minutes | Azure deployment |
| **Total End-to-End** | **78 minutes** | From start to verified deployment |

---

## Detailed Timeline

### Phase 1: Research & Planning (15 minutes)

**00:00-05:00** - Research Bicep Syntax (5 min)
- Open Microsoft Learn documentation
- Search for "Azure VNet Bicep examples"
- Search for "Network Security Group Bicep"
- Search for "Storage Account Bicep"
- Copy example snippets to reference file

**05:00-10:00** - Review API Versions (5 min)
- Check current API versions for:
  - `Microsoft.Network/virtualNetworks`
  - `Microsoft.Network/networkSecurityGroups`
  - `Microsoft.Storage/storageAccounts`
- Verify compatibility between versions
- **Challenge**: Different examples use different versions—which is correct?

**10:00-15:00** - Plan Architecture (5 min)
- Sketch network layout
- Define subnet CIDRs
- Plan NSG rules
- Decide on storage configuration
- **Decision**: Use modular approach (separate files)

---

### Phase 2: Network Infrastructure (20 minutes)

**15:00-20:00** - VNet Basic Structure (5 min)
- Create `network.bicep` file
- Write parameters section:
  ```bicep
  param location string = resourceGroup().location
  param vnetName string
  param addressPrefix string
  ```
- Start VNet resource block
- **Challenge**: Forgot `@description()` decorators—add them later

**20:00-30:00** - VNet with Subnets (10 min)
- Add addressSpace property
- Add subnets array
- Define 3 subnets (web, app, data)
- **Issues encountered**:
  - Typo: `addressPrefixes` vs `addressPrefix` (wasted 2 min)
  - Incorrect indentation (Bicep LSP caught it)
  - Missing comma in subnets array

**30:00-35:00** - Network Security Groups (5 min)
- Create NSG for web tier
- Add security rules
- **Challenge**: What's the right priority order for rules?
- **Challenge**: Deny rule needs to be last (priority 4096)
- Repeat for app tier and data tier
- **Issues encountered**:
  - Copy-paste error: Used wrong subnet IP in destination
  - Forgot to associate NSG with subnet initially

---

### Phase 3: Storage Infrastructure (10 minutes)

**35:00-40:00** - Storage Account Basics (5 min)
- Create `storage.bicep` file
- Add parameters
- Start storage account resource
- **Challenge**: Storage account name must be globally unique—how to generate?
- **Solution**: Use `uniqueString(resourceGroup().id)`

**40:00-45:00** - Storage Security Configuration (5 min)
- Add `supportsHttpsTrafficOnly: true`
- **Challenge**: What's the property name for minimum TLS version?
- Look up documentation: `minimumTlsVersion`
- **Challenge**: What's the property to disable public access?
- Look up documentation: `allowBlobPublicAccess`
- Add blob service configuration
- **Issue**: Forgot `parent:` reference initially—deployment error

---

### Phase 4: Main Orchestration (5 minutes)

**45:00-50:00** - Create Main Template (5 min)
- Create `main.bicep` file
- Add module references
- **Challenge**: What's the correct syntax for modules?
- Reference documentation: `module name 'path' = { }`
- Add parameters to pass through
- Add outputs
- **Issue**: Forgot to pass `environment` parameter—had to fix

---

### Phase 5: First Deployment Attempt (10 minutes)

**50:00-52:00** - Validate Template (2 min)
```powershell
az bicep build --file main.bicep
```
**Result**: ❌ Error - "Property 'addressPrefixes' expected array but got string"

**52:00-55:00** - Fix Validation Error (3 min)
- Open network.bicep
- Find issue: `addressPrefixes` should be an array
- Change to: `addressPrefixes: [ addressPrefix ]`
- Re-validate
**Result**: ✅ Validation passed

**55:00-58:00** - Deploy to Azure (3 min)
```powershell
az deployment group create `
  --resource-group rg-demo `
  --template-file main.bicep `
  --parameters environment=demo
```
**Result**: ❌ Deployment failed - "Resource 'nsg-web-demo' not found when referenced by subnet"

---

### Phase 6: Second Deployment Attempt (5 minutes)

**58:00-60:00** - Debug NSG Association Error (2 min)
- **Issue**: NSG must exist before VNet references it
- **Solution**: Need `dependsOn` or change structure
- Open network.bicep
- Ensure NSGs are defined before VNet resource

**60:00-63:00** - Redeploy (3 min)
```powershell
az deployment group create ...
```
**Result**: ❌ Deployment failed - "Storage account name 'stdemoXXXXX' contains invalid characters"

---

### Phase 7: Third Deployment Attempt (5 minutes)

**63:00-65:00** - Fix Storage Account Name (2 min)
- **Issue**: Storage account names can't have uppercase or hyphens
- Open storage.bicep
- Change to all lowercase: `st${toLower(environment)}${uniqueString(...)}`
- **Issue**: Name too long (26 characters, max 24)
- Shorten to: `st${environment}${uniqueString(...).substring(0,8)}`

**65:00-68:00** - Deploy Again (3 min)
```powershell
az deployment group create ...
```
**Result**: ✅ Deployment succeeded!

**68:00-70:00** - Verify Resources (2 min)
- Check VNet in Azure Portal
- Check subnets and NSGs
- Check storage account
- **Issue**: Storage account has public access enabled (should be disabled)
- **Decision**: Fix for next iteration

---

### Phase 8: Documentation (10 minutes)

**70:00-75:00** - Write Comments (5 min)
- Add `@description()` decorators to parameters
- Add header comments to each file
- Document security configurations

**75:00-80:00** - Create README (5 min)
- Write deployment instructions
- Document prerequisites
- List resources created
- Add troubleshooting notes

---

## Common Errors Encountered

### Syntax Errors (5 occurrences)
1. ❌ `addressPrefixes` as string instead of array
2. ❌ Missing comma in array
3. ❌ Wrong indentation level
4. ❌ Typo in property name
5. ❌ Missing closing brace

**Time Lost**: ~8 minutes

### Logic Errors (3 occurrences)
1. ❌ NSG not available when referenced by subnet
2. ❌ Storage account name invalid characters
3. ❌ Storage account name too long

**Time Lost**: ~10 minutes

### Configuration Mistakes (2 occurrences)
1. ❌ Public access enabled on storage (security risk)
2. ❌ Forgot to pass environment parameter to module

**Time Lost**: ~3 minutes

**Total Debugging Time**: ~21 minutes

---

## Challenges Faced

### 1. Documentation Lookup
- **Issue**: Constantly switching between editor and browser
- **Impact**: 10+ minutes spent searching documentation
- **Example**: "What's the property for minimum TLS version?"

### 2. API Version Confusion
- **Issue**: Different examples use different API versions
- **Impact**: 5 minutes deciding which version to use
- **Risk**: Using outdated versions can cause issues later

### 3. Syntax Memorization
- **Issue**: Don't remember exact Bicep syntax
- **Impact**: Frequent errors, need to reference examples
- **Examples**:
  - Module syntax: `module name 'path' = { }`
  - Array vs. string properties
  - Resource referencing: `resource.id` vs `resource.name`

### 4. Copy-Paste Errors
- **Issue**: Copying NSG rules, forgot to update IP addresses
- **Impact**: 3 minutes debugging why rules weren't working
- **Risk**: Security vulnerabilities if rules are wrong

### 5. Debugging Cryptic Errors
- **Issue**: ARM errors are not always clear
- **Example**: "Resource not found when referenced" (which resource?)
- **Impact**: 10 minutes trial-and-error debugging

---

## Comparison: Expected vs. Actual

| Phase | Expected | Actual | Difference |
|-------|----------|--------|------------|
| **Research** | 10 min | 15 min | +5 min (API versions unclear) |
| **Network Code** | 15 min | 20 min | +5 min (syntax errors) |
| **Storage Code** | 8 min | 10 min | +2 min (name validation) |
| **Orchestration** | 5 min | 5 min | On time ✅ |
| **Debugging** | 5 min | 21 min | +16 min (3 failed deployments) |
| **Documentation** | 5 min | 10 min | +5 min (more complex than expected) |
| **Total** | **48 min** | **81 min** | **+33 min (69% over estimate)** |

---

## What Took the Longest

1. **Debugging errors** (21 min) - 26% of total time
2. **Writing network code** (20 min) - 25% of total time
3. **Research & documentation** (15 min) - 19% of total time
4. **Writing storage code** (10 min) - 12% of total time
5. **Documentation** (10 min) - 12% of total time

**Key Insight**: Over 45% of time spent on debugging and research, not actual coding.

---

## Skills/Knowledge Required

To complete this task manually, you need:

### Technical Skills
- ✅ Bicep syntax and structure
- ✅ Azure networking concepts (VNets, subnets, NSGs)
- ✅ Azure storage security best practices
- ✅ ARM template deployment experience
- ✅ PowerShell or Azure CLI proficiency

### Domain Knowledge
- ✅ Understanding of network segmentation
- ✅ Security rule priorities and defaults
- ✅ Azure naming conventions
- ✅ API version compatibility
- ✅ Resource dependencies

### Tools
- ✅ VS Code with Bicep extension
- ✅ Azure CLI
- ✅ Access to Azure documentation
- ✅ Azure subscription with proper permissions

**Learning Curve**: 2-3 weeks for someone new to Bicep (not included in time tracking)

---

## Cost of Manual Approach

### Direct Costs
- **Engineer time**: 81 minutes = 1.35 hours
- **Hourly rate**: $75/hour (average cloud engineer)
- **Cost per deployment**: $101.25

### Indirect Costs
- **Delayed delivery**: 1+ hour longer than with Copilot
- **Error correction**: 3 failed deployments (wasted Azure compute)
- **Knowledge gaps**: Need experienced engineer ($100-150/hour)
- **Opportunity cost**: Could have worked on strategic tasks

### Team Impact (5 engineers, 3 deployments/week)
- **Monthly time**: 81 min × 3 × 4 = 16.2 hours
- **Monthly cost**: 16.2 × $75 × 5 = **$6,075**
- **Annual cost**: **$72,900**

---

## Lessons Learned (Manual Approach)

### What Worked
✅ **Modular approach**: Separating network and storage into modules kept code organized  
✅ **Validation first**: Running `az bicep build` before deployment caught syntax errors early  
✅ **Incremental development**: Building one resource at a time reduced debugging complexity  

### What Didn't Work
❌ **Copying from docs**: Examples were outdated or incomplete, caused errors  
❌ **Trial and error**: Guessing API properties wasted time, should have read docs fully  
❌ **Rushing deployment**: Should have validated more thoroughly before first deployment  

### What Could Have Helped
💡 **Better IDE support**: More autocomplete for Bicep properties  
💡 **Error messages**: Clearer deployment errors would have saved debugging time  
💡 **Templates/snippets**: Pre-built code snippets for common scenarios  

---

## Conclusion

The manual approach took **81 minutes** of development time, with over **25% spent debugging errors**. The process required extensive Azure and Bicep knowledge, frequent documentation lookups, and multiple deployment attempts.

**Key Challenges**:
1. Memorizing Bicep syntax and Azure resource schemas
2. Debugging cryptic error messages
3. Finding correct API versions
4. Ensuring security best practices

**Impact**: High cognitive load, slow iteration cycles, risk of security mistakes.

**Recommendation**: For teams doing frequent infrastructure deployments, tools like GitHub Copilot can eliminate most of these challenges, reducing time by 70-80% and improving code quality.

---

**Compare to**: [Time Tracking with Copilot](../with-copilot/time-tracking.md) to see the difference!

[🏠 Back to Demo README](../README.md)
