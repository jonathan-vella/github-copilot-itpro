# Demo Script: SBOM Generator with GitHub Copilot

⏱️ **Total Duration**: 30 minutes  
🎯 **Target Audience**: Security teams, DevOps engineers, compliance officers, cloud architects

## Pre-Demo Setup (15 minutes before presentation)

### 1. Environment Verification

```powershell
# Verify PowerShell version (7.0+)
$PSVersionTable.PSVersion

# Verify Azure CLI
az --version

# Verify Node.js
node --version

# Login to Azure (if demonstrating infrastructure SBOM)
az login
az account set --subscription "your-subscription-id"

# Navigate to demo folder
cd c:\Repos\github-copilot-itpro\demos\08-sbom-generator
```

### 2. VS Code Setup

```powershell
# Open VS Code in demo folder
code .
```

**Checklist**:

- ✅ GitHub Copilot extension enabled (check status bar)
- ✅ Copilot Chat panel accessible (Ctrl+Shift+I)
- ✅ Sample app folder visible in Explorer
- ✅ Terminal ready

### 3. Prepare Backup Files

Keep `examples/` folder available in case live generation has issues. These pre-generated examples ensure the demo can continue smoothly.

---

## Demo Flow

### Phase 1: Scene Setting (5 minutes)

#### Opening Hook

> "Imagine you're a security engineer at HealthTech Solutions. Your CISO just asked: *'What software components are running in our patient portal application?'* You have 6 hours of manual work ahead - inventory npm packages, document container dependencies, catalog Azure resources, and format everything into an industry-standard SBOM. **What if GitHub Copilot could reduce that to 1 hour?**"

#### The Scenario

**Customer**: HealthTech Solutions - Healthcare SaaS provider  
**Application**: Patient ToDo tracking system (similar to their real portal)  
**Challenge**: Must provide SBOM for:

- HIPAA compliance audit (quarterly requirement)
- Enterprise customer security questionnaire
- Vulnerability management program
- Supply chain risk assessment

**Show the Sample Application**:

```powershell
# Open sample app structure
code sample-app/
```

Point out:

- `src/api/package.json` - **20+ npm dependencies**
- `src/api/Dockerfile` - **node:20-alpine base image**
- `infra/main.bicep` - **Azure App Service, Cosmos DB, Key Vault**

#### Manual Approach Pain Points

**Display**: `manual-approach/time-tracking.md`

> "Traditionally, this takes 6 hours:
>
> - 90 minutes: Manually list npm packages from package.json
> - 120 minutes: Research container base image components
> - 60 minutes: Document Azure resources and API versions
> - 90 minutes: Format into CycloneDX or SPDX JSON
> - 60 minutes: Generate reports and validate completeness
>
> And you have to do this **quarterly** - or more frequently when vulnerabilities are disclosed."

**Key Pain Points**:

- ❌ Error-prone manual tracking (typically miss 20% of components)
- ❌ Difficult to keep current (quarterly updates lag reality)
- ❌ Format complexity (CycloneDX/SPDX schemas are intricate)
- ❌ No automation (can't integrate into CI/CD)

---

### Phase 2: Copilot Demo - SBOM Generation (18 minutes)

#### Part 1: Application SBOM from package.json (5 minutes)

**Objective**: Generate SBOM from npm dependencies using Copilot

**Step 1**: Create the PowerShell script with Copilot

```powershell
# Create new file
code with-copilot/New-ApplicationSBOM.ps1
```

**Prompt in Copilot Chat**:

```bicep
Create a PowerShell script that:
1. Reads a package.json file and extracts all dependencies and devDependencies
2. Generates a CycloneDX 1.5 SBOM in JSON format
3. Includes component name, version, type, and package URL (purl)
4. Uses proper CycloneDX schema with required fields: bomFormat, specVersion, serialNumber, version, metadata, components
5. Saves output to a JSON file
6. Includes parameters for input and output paths
7. Has comprehensive error handling
```

**Action**: Accept Copilot's suggestions and refine iteratively

**Key Points to Highlight**:

- 🎯 Copilot understands CycloneDX schema structure
- 🎯 Generates proper PURL format (pkg:npm/package@version)
- 🎯 Includes metadata section with timestamp
- 🎯 Handles both dependencies and devDependencies

**Step 2**: Run the script

```powershell
# Execute the generated script
./with-copilot/New-ApplicationSBOM.ps1 `
    -PackageJsonPath "sample-app/src/api/package.json" `
    -OutputPath "examples/application-sbom.json"

# Display results
code examples/application-sbom.json
```

**Expected Results**:

- ✅ ~20-25 components identified
- ✅ Proper CycloneDX format
- ✅ Complete with metadata

**Talking Point**:
> "In 5 minutes, we've generated an SBOM that would have taken 90 minutes manually. Copilot understood the CycloneDX schema, parsed package.json, and created a standards-compliant SBOM. Notice the accuracy - it captured **all** dependencies, including versions and package URLs."

---

#### Part 2: Container SBOM from Docker Image (4 minutes)

**Objective**: Analyze Docker container for software components

**Step 1**: Create container scanning script

```powershell
# Create new file
code with-copilot/New-ContainerSBOM.ps1
```

**Prompt in Copilot Chat**:

```bicep
Create a PowerShell script that:
1. Uses Syft (if available) or parses a Dockerfile to generate container SBOM
2. Extracts base image information (node:20-alpine)
3. Identifies OS packages and system libraries
4. Generates CycloneDX 1.5 SBOM format
5. Includes container layers as components
6. Has fallback to Dockerfile parsing if Syft not installed
7. Parameters for image name and output path
```

**Action**: Let Copilot generate the script

**Key Points to Highlight**:

- 🎯 Copilot suggests industry-standard tool (Syft)
- 🎯 Provides fallback approach (Dockerfile parsing)
- 🎯 Understands container layer concepts

**Step 2**: Run the script (or show pre-generated example)

```powershell
# If Syft is installed:
./with-copilot/New-ContainerSBOM.ps1 `
    -ImageName "node:20-alpine" `
    -OutputPath "examples/container-sbom.json"

# Otherwise, show pre-generated example:
code examples/container-sbom.json
```

**Expected Results**:

- ✅ Base image identified (node:20-alpine)
- ✅ OS packages listed (Alpine Linux packages)
- ✅ Node.js runtime version captured

**Talking Point**:
> "Container images often have hundreds of components - OS packages, system libraries, runtime dependencies. Manually documenting these would take 2+ hours. Copilot helped us create a script that automates this in minutes, and we can run it on every build."

---

#### Part 3: Infrastructure SBOM from Azure Resources (5 minutes)

**Objective**: Inventory Azure infrastructure components

**Step 1**: Create infrastructure scanning script

```powershell
# Create new file
code with-copilot/New-InfrastructureSBOM.ps1
```

**Prompt in Copilot Chat**:

```bicep
Create a PowerShell script that:
1. Uses Azure Resource Graph to query all resources in a resource group
2. Extracts resource type, SKU, API version, location for each resource
3. Generates CycloneDX 1.5 SBOM with Azure resources as components
4. Uses PURL format for Azure resources: pkg:azure/Microsoft.Web/sites@2023-12-01
5. Includes resource properties (SKU, tier, capacity)
6. Requires Azure CLI authentication
7. Parameters for resource group name and output path
```

**Action**: Accept Copilot's suggestions

**Key Points to Highlight**:

- 🎯 Copilot knows Azure Resource Graph query syntax
- 🎯 Understands Azure resource types and API versions
- 🎯 Generates appropriate PURL format for cloud resources

**Step 2**: Run the script (or show example if no Azure resources)

```powershell
# If Azure resources are deployed:
./with-copilot/New-InfrastructureSBOM.ps1 `
    -ResourceGroupName "rg-todo-app-prod" `
    -OutputPath "examples/infrastructure-sbom.json"

# Otherwise, show Bicep template scanning:
code examples/infrastructure-sbom.json
```

**Expected Results**:

- ✅ App Service identified with SKU
- ✅ Cosmos DB with API version
- ✅ Key Vault with tier
- ✅ Networking components

**Talking Point**:
> "Infrastructure is often overlooked in SBOMs, but it's critical for cloud applications. Azure resources have versions, SKUs, and configurations that matter for security and compliance. This script queries Azure Resource Graph to capture everything automatically."

---

#### Part 4: Merge and Report Generation (4 minutes)

**Objective**: Combine all SBOMs and create human-readable report

**Step 1**: Create merge script

```powershell
# Create new file
code with-copilot/Merge-SBOMDocuments.ps1
```

**Prompt in Copilot Chat**:

```bicep
Create a PowerShell script that:
1. Reads multiple CycloneDX SBOM JSON files from a directory
2. Merges all components into a single unified SBOM
3. Deduplicates components by name and version
4. Updates metadata with combined information
5. Validates the merged SBOM against CycloneDX schema
6. Generates a new serialNumber for the merged document
7. Parameters for input directory and output file
```

**Step 2**: Create report export script

```powershell
# Create new file
code with-copilot/Export-SBOMReport.ps1
```

**Prompt in Copilot Chat**:

```

Create a PowerShell script that:

1. Reads a CycloneDX SBOM JSON file
2. Generates an HTML report with:
   - Summary statistics (total components, component types)
   - Component table with name, version, type, license
   - Dependency graph visualization
   - Risk summary section
3. Also exports CSV format for spreadsheet analysis
4. Includes filtering by component type
5. Parameters for input file, output format (HTML/CSV), and output path

```

**Step 3**: Run the scripts

```powershell
# Merge all SBOMs
./with-copilot/Merge-SBOMDocuments.ps1 `
    -InputPath "examples" `
    -OutputFile "examples/merged-sbom.json"

# Generate HTML report
./with-copilot/Export-SBOMReport.ps1 `
    -SBOMPath "examples/merged-sbom.json" `
    -OutputFormat "HTML" `
    -OutputPath "examples/sbom-report.html"

# Open the HTML report
start examples/sbom-report.html
```

**Expected Results**:

- ✅ Single unified SBOM with ~60+ components
- ✅ Beautiful HTML dashboard
- ✅ Component statistics and breakdown
- ✅ Ready for stakeholder review

**Talking Point**:
> "Now we have a complete, comprehensive SBOM covering application dependencies, container components, and Azure infrastructure. The HTML report makes it easy for non-technical stakeholders to understand what's in the system. This entire process took us **1 hour** instead of **6 hours**."

---

### Phase 3: Validation & Impact (5 minutes)

#### Show the Complete SBOM

**Display**: `examples/merged-sbom.json` and `examples/sbom-report.html`

**Key Metrics to Call Out**:

| Metric | Manual | With Copilot | Improvement |
|--------|--------|--------------|-------------|
| **Total Time** | 6 hours | 1 hour | **85% faster** |
| **Components Found** | ~45 (80% coverage) | ~60 (98% coverage) | **+33% more** |
| **Accuracy** | 80% | 98% | **+22.5%** |
| **Format Support** | 1-2 formats | 5+ formats | **Multi-tool compatible** |
| **Update Frequency** | Quarterly (manual) | On-demand/CI/CD | **Continuous** |

#### Business Value Discussion

**ROI Calculation**:

```yaml
Per SBOM:
- Manual: 6 hours × $150/hr = $900
- With Copilot: 1 hour × $150/hr = $150
- Savings: $750 per SBOM

Quarterly (4 per year):
- Annual savings: $3,000 per application
- Time saved: 20 hours

Enterprise (100 apps):
- Annual savings: $300,000
- Time saved: 2,000 hours (1 FTE)
```

**Use Cases Enabled**:

1. ✅ **Vulnerability Response**: Query SBOMs when CVE disclosed (hours vs. days)
2. ✅ **Customer Compliance**: Provide SBOM to enterprise customers immediately
3. ✅ **Regulatory Audits**: Always audit-ready (HIPAA, SOC2, PCI-DSS)
4. ✅ **License Compliance**: Identify open-source licenses proactively
5. ✅ **CI/CD Integration**: Automate SBOM generation on every deployment

#### Real-World Scenario

> "Imagine Log4Shell happens again tomorrow. With automated SBOMs, you can query all applications in minutes to find affected systems. Without SBOMs, you're spending days manually checking each application. **That's the difference between a 4-hour incident response and a 4-day emergency.**"

---

### Phase 4: Wrap-Up (2 minutes)

#### Key Takeaways

**For Security Teams**:

- ✅ Comprehensive visibility into all software components
- ✅ Faster vulnerability response (hours instead of days)
- ✅ Continuous compliance (automate in CI/CD)

**For IT Professionals**:

- ✅ 85% time reduction (6 hours → 1 hour)
- ✅ Higher accuracy (98% vs. 80% manual)
- ✅ Multi-format support (CycloneDX, SPDX, HTML, CSV)

**For Management**:

- ✅ Cost savings: $3,000/year per application
- ✅ Risk reduction: Proactive vulnerability management
- ✅ Compliance: Always audit-ready
- ✅ Customer confidence: Professional SBOM deliverables

#### Next Steps

1. **Try It Yourself**: Clone this repo and run the demo
2. **Integrate into CI/CD**: Automate SBOM generation on every build
3. **Establish Governance**: Create SBOM policy and retention requirements
4. **Connect to Security Tools**: Integrate with vulnerability scanners
5. **Train Your Team**: Share effective prompts and techniques

#### Call to Action

> "GitHub Copilot isn't just for developers writing application code. It's an **efficiency multiplier** for security teams, compliance officers, and cloud architects. Start small - generate one SBOM today. Then scale to your entire portfolio. The time you save can be reinvested in proactive security."

---

## Backup Plans

### If Live Demo Fails

1. **Pre-generated examples available**: Show `examples/` folder
2. **Walk through code**: Explain the generated PowerShell scripts
3. **Show HTML report**: Open `sbom-report.html` in browser
4. **Focus on prompts**: Demonstrate Copilot Chat interactions

### If Copilot Suggestions Slow

1. **Use prepared prompts**: Copy from `prompts/effective-prompts.md`
2. **Accept partial suggestions**: Build iteratively
3. **Show pre-written scripts**: Explain how they were generated
4. **Emphasize technique**: Focus on prompting strategies

### If Audience Questions Interrupt

**Common Questions & Answers**:

**Q**: "Does this work with other languages (Python, .NET)?"  
**A**: "Yes! The same approach works with pip (requirements.txt), NuGet (packages.config), Maven (pom.xml), etc. Copilot understands all major package managers."

**Q**: "Can we integrate this into our CI/CD pipeline?"  
**A**: "Absolutely! These PowerShell scripts can run in Azure Pipelines, GitHub Actions, or Jenkins. Generate SBOM on every build and store as build artifact."

**Q**: "What about license compliance?"  
**A**: "Great question! We can extend these scripts to query package registries for license information and include in the SBOM. CycloneDX has a licenses field specifically for this."

**Q**: "How do we handle private/internal components?"  
**A**: "You can add internal component registries to the scanning process. CycloneDX supports custom properties for internal tracking numbers, approval status, etc."

**Q**: "What's the cost of GitHub Copilot?"  
**A**: "GitHub Copilot is $10/user/month for individuals, or $19/user/month for business. Given the $3,000/year savings per application, ROI is immediate even with one quarterly SBOM."

---

## Post-Demo Follow-Up

### Materials to Share

1. **Demo repository**: Link to github-copilot-itpro
2. **Prompts document**: `prompts/effective-prompts.md`
3. **ROI calculator**: `partner-toolkit/roi-calculator.xlsx`
4. **Sample outputs**: `examples/` folder

### Suggested Next Steps

1. **Schedule POC**: 2-week trial with 3-5 applications
2. **Pilot Program**: Select one team to adopt SBOM automation
3. **Training Session**: Hands-on workshop with Copilot
4. **Policy Development**: Establish SBOM governance standards

---

## Presenter Notes

### Energy & Pacing

- **Scene Setting** (5 min): Build urgency, relate to audience pain
- **Demo** (18 min): Keep momentum, don't get stuck debugging
- **Validation** (5 min): Drive home the impact with metrics
- **Wrap-Up** (2 min): Inspire action, provide clear next steps

### Body Language

- **Enthusiasm**: This is genuinely exciting technology
- **Confidence**: Trust Copilot, but have backup plans
- **Engagement**: Make eye contact, read audience reactions
- **Pause for Impact**: After showing time savings metrics

### Voice & Tone

- **Conversational**: Not reading a script
- **Authentic**: Share real experiences with Copilot
- **Empathetic**: Acknowledge the pain of manual SBOM creation
- **Optimistic**: Focus on possibilities, not limitations

### Common Pitfalls to Avoid

- ❌ **Don't** get stuck troubleshooting in front of audience
- ❌ **Don't** apologize for Copilot's suggestions
- ❌ **Don't** dive too deep into JSON schema details
- ❌ **Don't** skip the business value discussion
- ✅ **Do** keep moving forward with backup examples
- ✅ **Do** highlight surprising/impressive Copilot moments
- ✅ **Do** relate to audience's specific challenges
- ✅ **Do** end with clear, actionable next steps

---

**Demo prepared by**: GitHub Copilot IT Pro Field Guide  
**Last updated**: November 18, 2025  
**Estimated prep time**: 15 minutes  
**Estimated delivery time**: 30 minutes  
**Recommended practice runs**: 2-3 times before live delivery
