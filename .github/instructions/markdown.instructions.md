---
description: 'Documentation and content creation standards for markdown files'
applyTo: '**/*.md'
---

# Markdown Documentation Standards

Standards for creating consistent, accessible, and well-structured markdown documentation. Follow these guidelines to ensure documentation quality across the repository.

## General Instructions

- Use ATX-style headings (`##`, `###`) - never use H1 (`#`) in content (reserved for document title)
- Limit line length to 120 characters for readability
- Use LF line endings (enforced by `.gitattributes`)
- Include meaningful alt text for all images
- Validate with `markdownlint` before committing

## Content Structure

| Element | Rule | Example |
|---------|------|---------|
| Headings | Use `##` for H2, `###` for H3, avoid H4+ | `## Section Title` |
| Lists | Use `-` for unordered, `1.` for ordered | `- Item one` |
| Code blocks | Use fenced blocks with language | ` ```bicep ` |
| Links | Descriptive text, valid URLs | `[Azure docs](https://...)` |
| Images | Include alt text | `![Architecture diagram](./img.png)` |
| Tables | Align columns, include headers | See examples below |

## Code Blocks

Specify the language after opening backticks for syntax highlighting:

### Good Example - Language-specified code block

````markdown
```bicep
param location string = 'swedencentral'
```
````

### Bad Example - No language specified

````markdown
```
param location string = 'swedencentral'
```
````

## Mermaid Diagrams

Always include the theme directive for dark mode compatibility:

### Good Example - Mermaid with theme directive

```markdown
​```mermaid
%%{init: {'theme':'neutral'}}%%
graph LR
    A[Start] --> B[End]
​```
```

### Bad Example - Missing theme directive

```markdown
​```mermaid
graph LR
    A[Start] --> B[End]
​```
```

## Lists and Formatting

- Use `-` for bullet points (not `*` or `+`)
- Use `1.` for numbered lists (auto-increment)
- Indent nested lists with 2 spaces
- Add blank lines before and after lists

### Good Example - Proper list formatting

```markdown
Prerequisites:

- Azure CLI 2.50+
- Bicep CLI 0.20+
- PowerShell 7+

Steps:

1. Clone the repository
2. Run the setup script
3. Verify installation
```

### Bad Example - Inconsistent list markers

```markdown
Prerequisites:
* Azure CLI 2.50+
+ Bicep CLI 0.20+
- PowerShell 7+
```

## Tables

- Include header row with alignment
- Keep columns aligned for readability
- Use tables for structured comparisons

```markdown
| Resource | Purpose | Example |
|----------|---------|---------|
| Key Vault | Secrets management | `kv-contoso-dev` |
| Storage | Blob storage | `stcontosodev` |
```

## Links and References

- Use descriptive link text (not "click here")
- Verify all links are valid and accessible
- Prefer relative paths for internal links

### Good Example - Descriptive links

```markdown
See the [deployment guide](./docs/deployment.md) for setup instructions.
Refer to [Azure Bicep documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/) for syntax details.
```

### Bad Example - Non-descriptive links

```markdown
Click [here](./docs/deployment.md) for more info.
```

## Front Matter (Optional)

For blog posts or published content, include YAML front matter:

```yaml
---
post_title: 'Article Title'
author1: 'Author Name'
post_slug: 'url-friendly-slug'
post_date: '2025-01-15'
summary: 'Brief description of the content'
categories: ['Azure', 'Infrastructure']
tags: ['bicep', 'iac', 'azure']
---
```

**Note**: Front matter fields are project-specific. General documentation files may not require all fields.

## Patterns to Avoid

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| H1 in content | Conflicts with title | Use H2 (`##`) as top level |
| Deep nesting (H4+) | Hard to navigate | Restructure content |
| Long lines (400+ chars) | Poor readability | Break at 120 chars |
| Missing code language | No syntax highlighting | Specify language |
| "Click here" links | Poor accessibility | Use descriptive text |
| Excessive whitespace | Inconsistent appearance | Single blank lines |

## Validation

Run these commands before committing markdown:

```bash
# Lint all markdown files
markdownlint '**/*.md' --ignore node_modules --config .markdownlint.json

# Check for broken links (if using markdown-link-check)
markdown-link-check README.md
```

## Maintenance

- Review documentation when code changes
- Update examples to reflect current patterns
- Remove references to deprecated features
- Verify all links remain valid
