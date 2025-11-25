# Effective Prompts for Diagrams-as-Code

## Conversation Approach Philosophy

The goal is **learning**, not just code generation. These prompts are designed to help you understand
diagrams-as-code concepts so you can create and modify diagrams independently.

### Key Principles

1. **Ask WHY before HOW** - Understand the concept before implementing
2. **Admit what you don't know** - "I've never used this" gets better teaching
3. **Request explanations** - "Explain each part as we go"
4. **Iterate and refine** - Build complexity through conversation
5. **Ask about trade-offs** - Understanding limitations is knowledge

---

## Phase 1: Understanding the Concept

### Starting from Zero
```
I need to document our Azure architecture for a design review. I've heard about 
"diagrams as code" but never used it. Can you help me understand what it is and 
whether it's the right approach for my situation?
```

### Comparing Approaches
```
What are the pros and cons of diagrams-as-code vs. traditional tools like Visio 
or Draw.io? I want to make an informed decision.
```

### Specific Fit Questions
```
I have [describe your situation - deadline, team size, type of diagram].
Is diagrams-as-code a good fit, or should I use something else?
```

---

## Phase 2: Architecture Discovery

### Describing Your Architecture
```
I need to diagram our [type of system]. We have:
- [Component 1 and its role]
- [Component 2 and its role]
- [Component 3 and its role]

How should I think about organizing this in a diagram?
```

### Refining Connections
```
One clarification - [specific detail about how components interact].
Does that change how we should organize the diagram?
```

### Asking About Tiers
```
What are the common ways to organize Azure/AWS/GCP architectures visually?
Should I group by tier, by function, or something else?
```

### Understanding Clusters
```
What's the best way to visually group related services in diagrams-as-code?
For example, I have [list of related services].
```

---

## Phase 3: Code Generation with Understanding

### Learning-First Code Generation
```
Let's write the code! But please explain each part as we go - I want to 
understand what I'm writing, not just copy-paste.
```

### Understanding Imports
```
What does each import do in the diagrams library? I see references to 
Diagram, Cluster, Edge - what's the purpose of each?
```

### Understanding Icons
```
How do I find the right icon for [Azure Service Name]? What's the naming 
convention for icons in the diagrams library?
```

### Understanding Connections
```
What do the >> and << operators mean? How do I add labels to connections?
Can you show me examples of different connection styles?
```

---

## Phase 4: Customization and Iteration

### Highlighting Important Paths
```
I'd like to highlight [specific component/path] as critical. How can I 
make it stand out visually?
```

### Adding Labels
```
Can I add text labels to show things like "read-only" or "primary" on 
the connections? How?
```

### Changing Layout
```
The diagram is flowing left-to-right but I want top-to-bottom. How do I 
change the layout direction?
```

### Styling Clusters
```
Can I add background colors or borders to the clusters to make them more 
distinct? What options do I have?
```

### Multiple Options Request
```
Give me a few different options for [styling goal]. I want to understand 
what's possible before choosing.
```

---

## Phase 5: Best Practices

### Team Adoption
```
How should I manage diagrams-as-code across a team of [N] architects? 
What's the recommended folder structure and workflow?
```

### Version Control
```
Should I commit the generated images or just the Python code? What's the 
best practice for Git?
```

### CI/CD Integration
```
Can I automate diagram generation in CI/CD? What would that pipeline look like?
```

### Shared Styling
```
How can I ensure consistent styling across multiple diagrams created by 
different team members?
```

---

## Follow-Up and Refinement Prompts

### When You Don't Understand
```
I don't understand what [specific term/concept] means. Can you explain it 
with a simple example?
```

### When Code Doesn't Work
```
I got this error: [error message]. What does it mean and how do I fix it?
```

### When Output Looks Wrong
```
The diagram doesn't look right - [describe the issue]. What might be wrong 
with my code?
```

### Exploring Alternatives
```
Is there another way to accomplish [goal]? I want to understand my options.
```

---

## Advanced Questions

### After Learning the Basics
```
Now that I understand the basics, are there any advanced features I should 
know about? Things like [nested clusters, custom icons, subgraphs]?
```

### Multi-Cloud Diagrams
```
Can I mix Azure, AWS, and on-premises components in the same diagram? 
How does that work?
```

### Programmatic Generation
```
I have a list of resources in [JSON/YAML]. Can I generate diagrams 
programmatically from data?
```

### Documentation Integration
```
How do I embed these diagrams in Markdown documentation so they stay 
up-to-date?
```

---

## Common Mistakes to Avoid

### ❌ Wrong Approach: Script-First
```
Generate a Python script for an Azure architecture diagram
```
*This gets code but no understanding. Next time you'll ask again.*

### ✅ Right Approach: Learning-First
```
I want to create an Azure architecture diagram using Python. I've never 
used diagrams-as-code before. Can you help me understand the concept and 
walk me through creating one step by step?
```
*This builds transferable knowledge. Next time you'll be faster.*

### ❌ Wrong: One-Shot Requests
```
Create a diagram with Azure Front Door, AKS, SQL, and Redis
```
*This skips the learning.*

### ✅ Right: Iterative Conversation
```
I need to diagram these components: [list]. How should I think about 
organizing them before we write any code?
```
*This teaches architectural thinking.*

---

## Use Case Templates

### Design Review Scenario
```
I have a design review in [timeframe] and need to document [what]. I've 
[never/sometimes] used diagrams-as-code. Can you help me understand if 
it's right for this situation and walk me through creating a diagram?
```

### Documentation Update Scenario
```
Our architecture has changed - we added [new component]. I have an existing 
diagram.py file. How do I update it, and can you explain what I'm changing?
```

### Team Standardization Scenario
```
Our team of [N] architects all create diagrams differently. How can we 
standardize on diagrams-as-code? What shared conventions should we establish?
```

### Client Deliverable Scenario
```
I need to create professional architecture diagrams for a customer 
presentation. What are the best practices for making diagrams-as-code 
output look polished?
```

---

## Success Indicators

You're using prompts effectively when:

1. ✅ You understand **why** code is structured a certain way
2. ✅ You can **modify** diagrams without asking for help
3. ✅ You can **teach** the approach to others
4. ✅ Your **next diagram** takes less time
5. ✅ You know the **limitations** as well as capabilities
6. ✅ You're having a **conversation**, not issuing commands

---

## Philosophy

**"Learn first, generate later."**

Understanding diagrams-as-code concepts makes you effective.
Automation makes you efficient.
Do both - in that order.

---

*These prompts are designed for conversation-based learning with GitHub Copilot.
The goal is transferable knowledge, not just immediate output.*
