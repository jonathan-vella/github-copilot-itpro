# Effective Prompts for SBOM Generation with GitHub Copilot

This document contains proven prompts for generating SBOM-related PowerShell scripts using GitHub Copilot. These prompts have been tested and refined for optimal results.

---

## General Principles

### 1. Be Specific About Format

✅ **Good**: "Generate a CycloneDX 1.5 SBOM in JSON format"  
❌ **Poor**: "Create an SBOM"

### 2. Include Schema Requirements

✅ **Good**: "Include required fields: bomFormat, specVersion, serialNumber, version, metadata, components"  
❌ **Poor**: "Make it complete"

### 3. Specify Error Handling

✅ **Good**: "Include try/catch blocks and validate file existence"  
❌ **Poor**: "Make it robust"

### 4. Request Examples

✅ **Good**: "Add usage examples in .EXAMPLE sections"  
❌ **Poor**: "Add documentation"

---

## Application Dependency Scanning

### Prompt 1: Basic npm Package Scanner

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

**Expected Output**: Complete PowerShell script with parameter validation, JSON generation, and error handling

**Refinement Prompts**:

- "Add support for filtering devDependencies"
- "Include license information from package.json"
- "Add colored console output for better UX"
- "Generate unique bom-ref for each component"

### Prompt 2: Multi-Language Dependency Scanner

```yaml
Extend the script to support multiple package managers:
- npm (package.json)
- NuGet (packages.config or .csproj)
- pip (requirements.txt)
- Maven (pom.xml)

Detect package manager type automatically and parse accordingly.
```

**Use When**: Working with polyglot applications

---

## Container Image Analysis

### Prompt 3: Dockerfile Parser

```bicep
Create a PowerShell script that:
1. Parses a Dockerfile to extract base image information
2. Identifies FROM statements and extracts image name and tag
3. Analyzes RUN commands for installed packages
4. Generates CycloneDX 1.5 SBOM with container components
5. Includes base image, OS packages, and runtime dependencies
6. Has fallback logic if Syft tool not available
7. Parameters for Dockerfile path and output path
```

**Expected Output**: Script that parses Dockerfile and generates component list

**Refinement Prompts**:

- "Add integration with Syft CLI tool for comprehensive scanning"
- "Detect Alpine vs Debian vs Ubuntu base images"
- "Extract environment variables and exposed ports"
- "Add support for multi-stage builds"

### Prompt 4: Syft Integration

```yaml
Create a wrapper script that:
1. Checks if Syft is installed (syft version command)
2. If available, uses Syft to scan Docker image: syft <image> -o cyclonedx-json
3. If not available, falls back to Dockerfile parsing
4. Updates metadata timestamp in generated SBOM
5. Provides clear error messages and installation instructions
```

**Use When**: Integrating with existing container security tools

---

## Azure Infrastructure Inventory

### Prompt 5: Azure Resource Graph Query

```bicep
Create a PowerShell script that:
1. Uses Azure CLI to query resources in a resource group
2. Executes Azure Resource Graph query: "Resources | where resourceGroup =~ 'name'"
3. Extracts resource type, name, location, SKU, and API version
4. Generates CycloneDX 1.5 SBOM with Azure resources as platform components
5. Uses PURL format: pkg:azure/Microsoft.Web/sites@2023-12-01
6. Includes resource properties as component properties
7. Validates Azure CLI authentication before running
8. Parameters for resource group name and output path
```

**Expected Output**: Script that queries Azure and generates infrastructure SBOM

**Refinement Prompts**:

- "Add support for subscription-wide scanning"
- "Filter out resource types (e.g., exclude network interfaces)"
- "Include resource tags as component metadata"
- "Add pricing tier information for cost analysis"

### Prompt 6: Bicep Template Parsing

```bicep
Create a script that parses Bicep templates:
1. Read .bicep files recursively from a directory
2. Extract resource declarations (resource keyword)
3. Identify resource types and API versions
4. Parse module references and dependencies
5. Generate SBOM representing intended infrastructure state
6. Compare with deployed resources (requires Azure CLI)
```

**Use When**: Generating SBOMs from Infrastructure as Code before deployment

---

## SBOM Merging and Transformation

### Prompt 7: Multi-Source SBOM Merger

```bicep
Create a PowerShell script that:
1. Reads multiple CycloneDX SBOM JSON files from a directory
2. Merges all components into a single unified SBOM
3. Deduplicates components by name and version (configurable)
4. Updates metadata with combined information
5. Validates each input SBOM is valid CycloneDX format
6. Generates a new serialNumber (UUID) for the merged document
7. Parameters for input directory and output file path
8. Includes summary statistics (files merged, components deduplicated)
```

**Expected Output**: Script that combines multiple SBOMs intelligently

**Refinement Prompts**:

- "Add conflict resolution for components with same name but different versions"
- "Preserve component relationships and dependencies"
- "Track provenance (which source file each component came from)"
- "Add validation against CycloneDX schema"

### Prompt 8: Format Conversion

```yaml
Create a script to convert between SBOM formats:
- Input: CycloneDX JSON
- Output: SPDX 2.3 JSON

Map CycloneDX fields to SPDX equivalents:
- components → packages
- bom-ref → SPDXID
- purl → externalRefs
```

**Use When**: Need to provide SBOMs in multiple standard formats

---

## Report Generation

### Prompt 9: HTML Dashboard Generator

```bicep
Create a PowerShell script that:
1. Reads a CycloneDX SBOM JSON file
2. Generates an HTML report with:
   - Summary statistics (total components, types, licenses)
   - Pie chart showing component type distribution (use Google Charts API)
   - Sortable table with all components (name, version, type, PURL, license)
   - Risk summary section highlighting security concerns
3. Uses responsive CSS (Bootstrap or custom)
4. Includes JavaScript for interactivity (sorting, filtering)
5. Parameters for SBOM input path and HTML output path
```

**Expected Output**: Beautiful, interactive HTML dashboard

**Refinement Prompts**:

- "Add search/filter functionality for components"
- "Highlight components with known vulnerabilities (red badge)"
- "Include download buttons for CSV and JSON exports"
- "Add dark mode toggle"

### Prompt 10: CSV Export for Analysis

```powershell
Create a function to flatten SBOM to CSV:
1. Read CycloneDX SBOM JSON
2. Extract key fields: component name, version, type, PURL, license, bom-ref
3. Handle nested structures (licenses array, properties array)
4. Export to CSV with proper escaping
5. Include column headers
6. Support filtering by component type (e.g., libraries only)
```

**Use When**: Need to analyze SBOMs in Excel or other tools

---

## Validation and Quality Assurance

### Prompt 11: SBOM Validator

```yaml
Create a validation script that:
1. Reads a CycloneDX SBOM JSON file
2. Validates against CycloneDX 1.5 schema
3. Checks required fields are present:
   - bomFormat = "CycloneDX"
   - specVersion = "1.5"
   - serialNumber (valid UUID URN)
   - version (integer)
   - metadata.timestamp (valid ISO 8601)
   - components array exists
4. Validates each component has:
   - type (valid CycloneDX type)
   - name (non-empty)
   - bom-ref (unique across SBOM)
5. Reports validation errors with line numbers
6. Returns exit code 0 if valid, 1 if errors found
```

**Expected Output**: Comprehensive validation script

**Refinement Prompts**:

- "Add warnings for optional but recommended fields"
- "Validate PURL syntax against spec"
- "Check for common mistakes (duplicate bom-refs, invalid version strings)"
- "Generate validation report in Markdown format"

---

## CI/CD Integration

### Prompt 12: Azure DevOps Pipeline Task

```yaml
Create a PowerShell script suitable for Azure Pipelines:
1. Accept parameters via environment variables (AGENT_BUILDDIRECTORY, etc.)
2. Scan application, container, and infrastructure
3. Generate unified SBOM
4. Publish SBOM as pipeline artifact
5. Fail build if SBOM generation fails
6. Include timing and performance metrics
7. Support whatif mode for testing
```

**Use When**: Integrating SBOM generation into CI/CD

### Prompt 13: GitHub Actions Workflow

```yaml
Create a GitHub Actions workflow YAML that:
1. Triggers on push to main branch
2. Checks out repository
3. Runs SBOM generation scripts
4. Uploads SBOM artifacts to release
5. Creates GitHub issue if new high-risk components detected
6. Commits SBOM to repository (sboms/ directory)
```

**Use When**: Automating SBOM generation in GitHub

---

## Advanced Scenarios

### Prompt 14: Vulnerability Integration

```yaml
Extend the SBOM script to query vulnerability databases:
1. For each component, query NVD (National Vulnerability Database)
2. Check GitHub Advisory Database via API
3. Add vulnerability information to SBOM (CycloneDX vulnerabilities extension)
4. Generate risk score based on CVSS scores
5. Highlight critical vulnerabilities in report
```

**Use When**: Combining SBOM with security scanning

### Prompt 15: License Compliance Checker

```bash
Create a script that analyzes SBOM for license compliance:
1. Extract all license information from components
2. Categorize licenses: Permissive (MIT, Apache), Copyleft (GPL), Proprietary
3. Flag potential conflicts (e.g., GPL in proprietary software)
4. Generate compliance report with recommendations
5. Export list of components requiring legal review
```

**Use When**: Supporting legal/compliance teams

---

## Iterative Refinement Techniques

### Technique 1: Start Simple, Add Complexity

**Initial Prompt**: "Create a script that reads package.json and outputs component names"

**Refinement 1**: "Add version numbers and format as JSON"

**Refinement 2**: "Convert to CycloneDX format with metadata"

**Refinement 3**: "Add error handling and parameter validation"

### Technique 2: Show Examples

**Prompt**: "Generate CycloneDX SBOM. Here's an example structure: [paste sample SBOM]. Follow this format exactly."

**Benefit**: Copilot understands the desired output format

### Technique 3: Specify Edge Cases

**Prompt**: "Handle these scenarios:

- package.json doesn't exist (error message)
- No dependencies (empty components array)
- Version has ^ or ~ prefix (remove before PURL)
- Output path is directory not file (generate filename)"

**Benefit**: More robust error handling

---

## Common Pitfalls and Solutions

### Pitfall 1: Incomplete SBOM Schema

**Problem**: Copilot misses required fields like serialNumber

**Solution**: Explicitly list required fields in prompt

### Pitfall 2: Invalid JSON Syntax

**Problem**: Generated JSON has trailing commas or unescaped quotes

**Solution**: Add "Ensure valid JSON syntax, no trailing commas"

### Pitfall 3: No Error Handling

**Problem**: Script fails silently on invalid input

**Solution**: Request "Include try/catch blocks and validation"

### Pitfall 4: Hardcoded Values

**Problem**: Timestamps, paths, or names are hardcoded

**Solution**: Specify "Use parameters for all configurable values"

---

## Prompt Templates

### Template 1: Script Generation

```bicep
Create a PowerShell script that:
1. [Primary function]
2. [Input processing]
3. [Core logic]
4. [Output generation]
5. [Error handling]
6. Parameters: [list parameters with types]
7. Example usage: [show example command]
```

### Template 2: Function Addition

```powershell
Add a function to the existing script that:
- Name: [function name]
- Purpose: [what it does]
- Parameters: [input parameters]
- Returns: [return type/value]
- Integrates with: [existing function name]
```

### Template 3: Enhancement Request

```yaml
Enhance the script to:
- Add feature: [describe new capability]
- Improve: [existing aspect to improve]
- Ensure: [quality requirement]
- Maintain: [backward compatibility requirement]
```

---

## Testing Your Prompts

### Checklist

- ✅ Prompt is specific and unambiguous
- ✅ Expected output format is clear
- ✅ Error handling requirements stated
- ✅ Parameters and examples included
- ✅ Edge cases mentioned
- ✅ Quality requirements specified

### Iteration Strategy

1. **First Pass**: Get basic working code
2. **Second Pass**: Add error handling and validation
3. **Third Pass**: Improve user experience (output formatting, help text)
4. **Fourth Pass**: Add advanced features and optimizations

---

## Resources

- [CycloneDX Specification](https://cyclonedx.org/specification/overview/)
- [SPDX Specification](https://spdx.github.io/spdx-spec/)
- [PowerShell Approved Verbs](https://learn.microsoft.com/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)
- [Azure Resource Graph](https://learn.microsoft.com/azure/governance/resource-graph/overview)

---

**Last Updated**: November 18, 2025  
**Maintainer**: GitHub Copilot IT Pro Field Guide Team  
**Feedback**: Submit improvements via GitHub Issues
