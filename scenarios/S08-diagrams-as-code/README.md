# Demo 08: Diagrams as Code with Python

## Overview

This demo showcases how GitHub Copilot can help IT Professionals adopt "Diagrams as Code" using the Python `diagrams` library. Instead of manually dragging and dropping icons in Visio or PowerPoint, you define your architecture in Python code. This allows for version control, consistency, and automation.

**Duration**: 15 minutes
**Target Audience**: Cloud Architects, DevOps Engineers, Developers
**Difficulty**: Beginner

## Business Value

### The Challenge

- **Drift**: Diagrams quickly become outdated as infrastructure changes.
- **Inconsistency**: Different architects use different icons and styles.
- **No Version Control**: Binary files (Visio, PPT) are hard to diff and track changes.
- **Manual Effort**: aligning boxes and arrows takes time away from actual design.

### The Copilot Solution

GitHub Copilot understands the `diagrams` library and can translate natural language architecture descriptions into Python code instantly.

- **Speed**: Generate complex diagrams in seconds.
- **Consistency**: Use standard Azure/AWS/GCP icons automatically.
- **Maintainability**: Update diagrams by changing a few lines of code.
- **Version Control**: Treat diagrams like code (PRs, diffs, history).

## Prerequisites

- Python 3.6+
- Graphviz installed (usually required for `diagrams`)
- VS Code with GitHub Copilot

## Scenario

You need to document a standard 3-tier web application architecture on Azure for a design review. Instead of drawing it manually, you will use Python code to generate it.

**Architecture Components**:
- Azure DNS
- Azure Load Balancer
- Web Tier (VM Scale Set)
- App Tier (App Service)
- Data Tier (SQL Database + Redis Cache)
- Monitoring (Application Insights)

## What You'll Build

A Python script that generates a high-quality architecture diagram image.

## Files in This Demo

```
scenarios/S08-diagrams-as-code/
├── README.md                        # This file
├── DEMO-SCRIPT.md                   # Step-by-step walkthrough
├── solution/
│   ├── architecture.py              # The Python script
│   └── requirements.txt             # Python dependencies
└── prompts/
    └── effective-prompts.md         # Copilot prompts
```

## Quick Start

1. **Install Dependencies**:
   ```bash
   pip install diagrams
   # Ensure Graphviz is installed on your OS (e.g., 'sudo apt-get install graphviz')
   ```

2. **Run the Script**:
   ```bash
   python solution/architecture.py
   ```

3. **View Output**:
   Open the generated `architecture.png` file.

## Related Demos

- [Demo 04: Documentation Generation (S04)](../S04-documentation-generation/)

