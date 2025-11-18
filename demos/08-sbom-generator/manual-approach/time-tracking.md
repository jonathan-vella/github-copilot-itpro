# Manual SBOM Creation Time Tracking

## Total Time: 6 Hours (360 minutes)

This document tracks the time required to manually create a Software Bill of Materials (SBOM) for the HealthTech Patient Portal application without automation tools.

---

## Task 1: Application Dependencies Inventory (90 minutes)

### Activities

**Subtask 1.1: Open and Review package.json** (15 min)
- Navigate to project directories
- Open `src/api/package.json` in text editor
- Open `src/web/package.json` in separate window
- Understand project structure

**Subtask 1.2: Extract Dependencies** (30 min)
- Create Excel spreadsheet with columns: Name, Version, Type, License
- Manually type each dependency from package.json
- Copy-paste version numbers (careful not to miss characters)
- Repeat for devDependencies section
- Count: 24 packages from API, 16 from Web = 40 total

**Subtask 1.3: Research Licenses** (30 min)
- Visit npmjs.com for each package
- Search for package name
- Navigate to package page
- Find license information (sometimes buried in README)
- Common issues:
  - License not clearly stated
  - Multiple licenses listed (which one applies?)
  - Deprecated packages (license info missing)
- Add license to spreadsheet

**Subtask 1.4: Generate Package URLs (PURLs)** (15 min)
- Research PURL specification (refresh memory)
- Format: `pkg:npm/package-name@version`
- Manually construct PURL for each package
- Example: `pkg:npm/express@4.21.2`
- Validate format (easy to make typos)

### Challenges Encountered
- ❌ Nested dependencies not visible (only top-level)
- ❌ Miss 5-10 packages typically (human error)
- ❌ License info sometimes outdated on npmjs.com
- ❌ Tedious copy-paste prone to errors
- ❌ No validation that list is complete

### Output
- Excel file: `dependencies-inventory.xlsx`
- Columns: Package Name, Version, License, PURL
- Rows: ~35-40 (missed ~10 packages)
- Accuracy: ~80%

---

## Task 2: Container Image Analysis (120 minutes)

### Activities

**Subtask 2.1: Review Dockerfile** (20 min)
- Open `src/api/Dockerfile`
- Identify base image: `node:20-alpine`
- Note multi-stage build steps
- List RUN commands that install packages

**Subtask 2.2: Research Base Image** (40 min)
- Visit Docker Hub: https://hub.docker.com/_/node
- Find `node:20-alpine` tag
- Navigate to Alpine Linux documentation
- Determine Alpine version (often not obvious)
- Find Alpine package list URL
- Download Alpine 3.19 package database

**Subtask 2.3: Identify OS Packages** (30 min)
- Cross-reference Alpine packages with base image
- Key packages to document:
  - musl libc (C library)
  - OpenSSL version
  - ca-certificates
  - bash/sh shell
  - coreutils
- Manually type into Excel
- Verify versions match Alpine 3.19 release

**Subtask 2.4: Document Node.js Runtime** (20 min)
- Node.js version: 20.x (which specific patch version?)
- npm version (bundled with Node.js)
- V8 JavaScript engine version
- Visit Node.js release notes to find exact versions
- Add to spreadsheet

**Subtask 2.5: Container Layers** (10 min)
- Document logical layers:
  - Base OS (Alpine)
  - Node.js runtime
  - Application dependencies (npm install)
  - Application code
- Estimate sizes (no precise data)

### Challenges Encountered
- ❌ Hard to determine exact Alpine version from tag
- ❌ OS package database is large (~3,000 packages)
- ❌ Don't know which packages are actually in minimal image
- ❌ Node.js version might drift (20.x is moving target)
- ❌ No automated way to inspect layers
- ❌ Miss system libraries that are actually present

### Output
- Excel file: `container-components.xlsx`
- Documented: ~15-20 components (of ~50 actual)
- Accuracy: ~35% (many packages missed)
- Completeness: Low confidence

---

## Task 3: Azure Infrastructure Inventory (60 minutes)

### Activities

**Subtask 3.1: Azure Portal Review** (25 min)
- Login to Azure Portal
- Navigate to Resource Group: `rg-patient-portal-prod`
- Click each resource individually:
  - App Service (Web)
  - App Service (API)
  - Cosmos DB
  - Key Vault
  - Application Insights
  - Virtual Network
  - Private Endpoints (2x)
- Screenshot each resource overview page

**Subtask 3.2: Document Resource Details** (20 min)
- For each resource, record in Excel:
  - Resource name
  - Resource type (e.g., Microsoft.Web/sites)
  - SKU/Tier (e.g., P1v3 Premium)
  - Region (swedencentral)
  - API version (hard to find!)
- Navigate to JSON view in Portal to find API version
- Copy resource ID

**Subtask 3.3: Review Bicep Templates** (15 min)
- Open `infra/main.bicep`
- Cross-reference deployed resources with template
- Verify API versions in Bicep match Azure
- Note: Some resources deployed manually (not in IaC)
- Add missing resources to spreadsheet

### Challenges Encountered
- ❌ API version not visible in Portal UI (must view JSON)
- ❌ Some resources deployed outside IaC (inconsistent)
- ❌ Resource dependencies not obvious
- ❌ SKU details buried in sub-pages
- ❌ Private endpoints hard to track (linked resources)
- ❌ No historical record (what changed since last SBOM?)

### Output
- Excel file: `azure-resources.xlsx`
- Resources documented: 8 main + 2 private endpoints = 10 total
- Accuracy: ~90% (infrastructure is simpler than app/container)
- Completeness: Good, but API versions uncertain

---

## Task 4: Format to SBOM Standard (90 minutes)

### Activities

**Subtask 4.1: Research SBOM Format** (20 min)
- Review CycloneDX specification: https://cyclonedx.org/specification/overview/
- Download CycloneDX 1.5 JSON schema
- Read required fields: bomFormat, specVersion, serialNumber, version, metadata, components
- Review example SBOM documents
- Understand component structure

**Subtask 4.2: Create JSON Document** (40 min)
- Open text editor (VS Code)
- Start with metadata section:
  - timestamp (current UTC time in ISO 8601)
  - Generate UUID for serialNumber (use online generator)
  - Add organization info
  - Add component metadata (application name, version)
- Create components array
- Manually convert Excel rows to JSON objects:
  ```json
  {
    "type": "library",
    "name": "express",
    "version": "4.21.2",
    "purl": "pkg:npm/express@4.21.2"
  }
  ```
- Repeat for all 40+ application components
- Add container components with type: "operating-system" or "platform"
- Add Azure resources with type: "platform"

**Subtask 4.3: Validate JSON** (20 min)
- Save file as `patient-portal-sbom.json`
- Use online JSON validator
- First attempt: Syntax errors (missing commas, wrong brackets)
- Fix errors, revalidate
- Validate against CycloneDX schema (upload to online validator)
- Schema validation fails: Missing required "bom-ref" fields
- Add bom-ref to each component (unique identifiers)
- Revalidate until passes

**Subtask 4.4: Manual Review** (10 min)
- Read through entire SBOM
- Check for obvious errors:
  - Version number typos
  - Duplicate entries
  - Missing components (based on memory)
- Add 2-3 forgotten packages

### Challenges Encountered
- ❌ CycloneDX schema is complex (250+ properties)
- ❌ JSON syntax errors easy to make manually
- ❌ bom-ref requirement not initially obvious
- ❌ Component relationships hard to express
- ❌ No automated validation during creation
- ❌ Formatting inconsistencies
- ❌ License field structure confusing (object vs. string)

### Output
- File: `patient-portal-sbom.json`
- Format: CycloneDX 1.5 JSON
- Size: ~500 lines
- Valid: Yes (after 3 validation attempts)
- Complete: ~80% (estimated, hard to verify)

---

## Task 5: Generate Reports (60 minutes)

### Activities

**Subtask 5.1: Create PowerPoint for Stakeholders** (25 min)
- Open PowerPoint
- Slide 1: Title - "Patient Portal SBOM - Q4 2025"
- Slide 2: Summary Statistics
  - Total components: 55
  - npm packages: 40
  - Container components: 10
  - Azure resources: 10
  - Date generated: Manual entry
- Slide 3: Component Breakdown (pie chart, manually created)
- Slide 4: High-Risk Components (identify security concerns)
- Slide 5: License Summary (MIT: 38, Apache: 5, Other: 2)
- Format slides, add company branding

**Subtask 5.2: Export CSV for Security Tools** (15 min)
- Flatten JSON to CSV format
- Open Excel
- Import JSON (doesn't work well, nested structure)
- Manually create CSV rows
- Columns: Name, Version, Type, License, PURL
- Save as `patient-portal-components.csv`

**Subtask 5.3: Write Summary Document** (20 min)
- Open Word
- Create "SBOM Summary - Patient Portal Q4 2025"
- Sections:
  - Executive Summary
  - Methodology
  - Findings
  - Recommendations
  - Next Steps
- Write 2-3 paragraphs per section
- Include table of high-priority components
- Add references to Excel/JSON files
- Export as PDF

### Challenges Encountered
- ❌ No automated way to generate charts from SBOM
- ❌ JSON to CSV conversion loses nested data
- ❌ PowerPoint charts created manually (error-prone)
- ❌ Summary document repetitive across quarters
- ❌ No version control (files emailed, lost track)

### Output
- PowerPoint: `SBOM-Summary-Q4-2025.pptx` (8 slides)
- CSV: `patient-portal-components.csv` (55 rows)
- PDF: `SBOM-Summary-Document.pdf` (5 pages)
- Email with attachments sent to compliance team

---

## Summary of Manual Process

### Total Time Breakdown

| Task | Time | Percentage |
|------|------|------------|
| **Application Dependencies** | 90 min | 25% |
| **Container Analysis** | 120 min | 33% |
| **Infrastructure Inventory** | 60 min | 17% |
| **SBOM Formatting** | 90 min | 25% |
| **Report Generation** | 60 min | 17% |
| **TOTAL** | **6 hours** | **100%** |

### Accuracy Assessment

| Layer | Components Found | Estimated Actual | Accuracy |
|-------|------------------|------------------|----------|
| **Application** | 40 | 50 | 80% |
| **Container** | 20 | 60 | 33% |
| **Infrastructure** | 10 | 11 | 91% |
| **Overall** | **70** | **121** | **58%** |

**Note**: Many container OS packages missed. Nested npm dependencies not captured.

### Quality Issues

**Errors Found in Manual SBOMs** (from previous audits):
- ❌ Typos in version numbers (e.g., "4.21.2" → "4.12.2")
- ❌ Wrong licenses (copied from wrong package page)
- ❌ Duplicate entries with different spellings
- ❌ Missing critical security components
- ❌ Outdated information (packages upgraded since last SBOM)
- ❌ Inconsistent formatting across quarterly reports
- ❌ No validation against actual deployed system

### Cost Calculation

**Labor Cost**:
- Senior Security Engineer: $150/hour
- Time: 6 hours
- **Cost per SBOM: $900**

**Frequency**: Quarterly (4 times per year)
- **Annual cost: $3,600 per application**

**HealthTech Portfolio**: 5 applications
- **Total annual cost: $18,000**

### Pain Points (Most Frustrating)

1. 😤 **Tedious copying** - 2+ hours of manual data entry
2. 😤 **Error-prone** - Typos, missed components, wrong versions
3. 😤 **No validation** - Can't verify completeness
4. 😤 **Quickly outdated** - Quarterly SBOM is stale within weeks
5. 😤 **Not scalable** - Adding applications multiplies effort
6. 😤 **Inefficient** - Can't reuse work, starts from scratch
7. 😤 **Slow response** - When CVE disclosed, takes days to assess

---

## Why Automation is Critical

**Current State**:
- ⏱️ 6 hours per SBOM
- 📊 ~58% accuracy
- 📅 Quarterly updates (96 days stale)
- 💰 $900 per SBOM
- 🐌 Slow vulnerability response

**Desired State with Copilot**:
- ⏱️ <1 hour per SBOM (85% reduction)
- 📊 ~98% accuracy (+40 percentage points)
- 📅 On-demand updates (CI/CD integration)
- 💰 $150 per SBOM ($750 savings)
- ⚡ 4-hour vulnerability response

**Annual Savings**: $3,000 per application × 5 applications = **$15,000/year**

---

**Document Purpose**: Establish baseline for comparison with automated approach  
**Author**: Security Team (composite of multiple manual SBOM efforts)  
**Date**: November 18, 2025  
**Use**: Demo material to show pain points of manual process
