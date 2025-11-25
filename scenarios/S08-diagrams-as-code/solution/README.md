# Solution Scripts - Legacy Automation

> ⚠️ **Note**: This demo has been refactored to prioritize **conversation-based learning** over
> script generation. The scripts in this folder are preserved for users who want automation
> AFTER learning the concepts.

## Recommended Approach

**Start here instead:**
- 📖 `../examples/copilot-diagrams-conversation.md` - Full conversation example
- 📋 `../DEMO-SCRIPT.md` - 20-minute presenter guide  
- 💡 `../prompts/effective-prompts.md` - Conversation prompts

## When to Use These Scripts

Use the automation scripts in this folder when:

1. ✅ **You've already learned diagrams-as-code** through conversation
2. ✅ **You need to generate many diagrams** quickly
3. ✅ **You're setting up CI/CD** for automated diagram generation
4. ✅ **You're an advanced user** who just needs a reference

## Script Descriptions

### architecture.py

Reference implementation showing a complete Azure architecture diagram.

**What it creates**:
- Azure 3-tier architecture diagram
- Uses Front Door, VMSS, App Service, SQL Database, Redis Cache, App Insights
- Demonstrates clusters, connections, and proper icon imports

**Usage**:
```bash
# Install dependencies
pip install diagrams
sudo apt-get install graphviz  # Linux
# brew install graphviz        # Mac

# Generate diagram
python architecture.py

# Output: azure_3-tier_architecture.png
```

### requirements.txt

Python dependencies for running the scripts.

**Contents**:
```
diagrams>=0.23.0
```

**Usage**:
```bash
pip install -r requirements.txt
```

## Limitations of Automation-First Approach

| Limitation | Impact |
|------------|--------|
| **No learning** | You get output but don't understand it |
| **Troubleshooting difficulty** | Hard to fix issues without concepts |
| **Can't customize effectively** | Don't know what options exist |
| **Dependency on re-asking** | Next diagram takes same time |
| **Team knowledge gap** | Can't teach others |

## Benefits of Learning-First Approach

| Benefit | Impact |
|---------|--------|
| **Transferable knowledge** | Future diagrams are 78% faster |
| **Independent modification** | Can update without help |
| **Team enablement** | Can teach colleagues |
| **Trade-off awareness** | Know when NOT to use diagrams-as-code |
| **Customization mastery** | Full control of styling options |

## Recommended Workflow

```
┌─────────────────────────────────────────────────────────────┐
│  Week 1-2: LEARNING PHASE                                   │
│  Use conversation approach with Copilot                     │
│  Goal: Understand concepts, not just output                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Week 3-4: MANUAL MASTERY                                   │
│  Create diagrams from scratch with minimal help             │
│  Goal: Confirm you can work independently                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Week 5+: AUTOMATION                                        │
│  Use scripts, CI/CD, templates                              │
│  Goal: Scale efficiently with understanding                 │
└─────────────────────────────────────────────────────────────┘
```

## Generating Custom Scripts

Once you understand diagrams-as-code, ask Copilot for automation:

```
I understand diagrams-as-code well now. I need to generate [N] similar 
diagrams for different environments. Can you help me create a template 
script that I can parameterize?
```

This works better AFTER learning because:
1. You can evaluate if the generated code is correct
2. You can modify it for your specific needs
3. You can troubleshoot issues independently
4. You can explain it to your team

## Script vs Conversation Comparison

| Aspect | Script Approach | Conversation Approach |
|--------|-----------------|----------------------|
| **Initial time** | 2 min (run script) | 20 min (conversation) |
| **Next diagram** | 2 min (ask again) | 5-10 min (do yourself) |
| **10 diagrams** | 20 min + no learning | 65 min + full mastery |
| **Team impact** | Individual only | Can teach others |
| **Customization** | Limited | Full control |
| **Troubleshooting** | Ask Copilot again | Fix yourself |

## Common Issues with Scripts

### Graphviz Not Found
```
ExecutableNotFound: failed to execute 'dot'
```
**Solution**: Install Graphviz on your system:
```bash
# Ubuntu/Debian
sudo apt-get install graphviz

# Mac  
brew install graphviz

# Windows
choco install graphviz
```

### Import Errors
```
ModuleNotFoundError: No module named 'diagrams'
```
**Solution**: Install the diagrams library:
```bash
pip install diagrams
```

### Icon Not Found
```
ImportError: cannot import name 'SomeService' from 'diagrams.azure.compute'
```
**Solution**: Check the correct icon name at https://diagrams.mingrammer.com/docs/nodes/azure

---

## Philosophy

**"Learn first, automate later."**

These scripts exist for efficiency at scale.
But efficiency without understanding is fragile.
Invest 20 minutes in learning - it pays back on every future diagram.

---

*For the recommended learning approach, see `../examples/copilot-diagrams-conversation.md`*
