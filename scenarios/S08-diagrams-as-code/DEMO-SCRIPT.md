# Demo Script: Diagrams-as-Code with GitHub Copilot

## Overview

**Duration**: 20 minutes  
**Style**: Conversation-based learning (not script generation)  
**Goal**: Demonstrate Copilot as a learning partner for diagrams-as-code

## Pre-Demo Setup

### Required
- VS Code with GitHub Copilot Chat extension
- Internet connection for Copilot

### Optional (for running output)
- Python 3.6+
- Graphviz installed
- `diagrams` library (`pip install diagrams`)

### Backup Materials
- `examples/copilot-diagrams-conversation.md` (full transcript)
- `solution/architecture.py` (reference implementation)

---

## Demo Flow

### Phase 0: Scene Setting (2 minutes)

**[Show this slide or read aloud]**

> "Meet Marcus Chen, a Solutions Architect at TechVentures. He has a design review in 2 hours
> and needs to document their new microservices architecture. He's heard about diagrams-as-code
> but has never used it."

**[Talking Points]**

- Traditional approach: 45 minutes in Visio dragging boxes
- Problem: Binary files can't be version controlled
- Problem: Diagrams drift out of sync with actual architecture
- Solution: Diagrams-as-code with Copilot as learning partner

**[Open VS Code with Copilot Chat]**

---

### Phase 1: Understanding the Concept (3 minutes)

**[Type this prompt in Copilot Chat]**

```
I have a design review in 2 hours and need to document our Azure microservices 
architecture. I've heard about "diagrams as code" but never used it. Can you help 
me understand what it is and whether it's the right approach for my situation?
```

**[Narration while Copilot responds]**

> "Notice I'm not asking Copilot to 'generate a script.' I'm asking it to help me
> UNDERSTAND the concept first. This is the key difference in our approach."

**[Expected Copilot Response - Key Points to Highlight]**

1. **Definition**: Code that describes architecture, rendered to images
2. **Benefits**: Version control, consistency, automation
3. **Trade-offs**: Less freeform than Visio, learning curve
4. **Recommendation**: Good fit for architecture overviews

**🎓 Learning Moment: Trust Through Honesty**

> "Copilot is being honest about trade-offs. It's not just selling me on the tool -
> it's helping me make an informed decision. This is what a good mentor does."
>
> *Key Pattern*: A good learning partner presents options AND limitations, enabling informed decisions.

---

### Phase 2: Architecture Discovery (5 minutes)

**[Type this prompt]**

```
Great! I need an architecture overview showing our new e-commerce platform. We have:
- Azure Front Door for global load balancing
- Azure Kubernetes Service (AKS) cluster with 3 microservices
- Azure SQL Database and Redis Cache for data
- Azure Key Vault for secrets
- Application Insights for monitoring

How should I think about organizing this in a diagram?
```

**[Narration]**

> "I'm describing my architecture and asking HOW to organize it - not asking
> for code yet. This is architectural thinking, which is the real skill."

**[Expected Response - Highlight These Points]**

1. **Tiers**: Edge → Compute → Data → Platform
2. **Clusters**: Visual grouping of related services
3. **Connections**: Which services talk to which
4. **Flow direction**: Top-to-bottom recommendation

**[Interactive Moment]**

> "Let me refine this with more detail..."

**[Type follow-up]**

```
One clarification - the Order Service is the only one that writes to SQL. 
Product and User services only read. Does that change anything?
```

**🎓 Learning Moment: Iterative Refinement**

> "See how we're having a conversation? I'm refining my requirements, and Copilot
> is updating its understanding. This is how real architecture discussions work."
>
> *Key Pattern*: Discovery is iterative - each clarification improves the outcome.

---

### Phase 3: Code Generation with Understanding (5 minutes)

**[Type this prompt]**

```
Let's write the code! But please explain each part as we go - I want to understand 
what I'm writing, not just copy-paste.
```

**[Narration]**

> "The key phrase here is 'explain each part.' I want to LEARN, not just get output."

**[Expected Response - Walk Through Each Section]**

**Section 1: Imports**
```python
from diagrams import Diagram, Cluster, Edge
from diagrams.azure.network import FrontDoors
# ... more imports
```

> "Each Azure service has its own icon class. The library organizes by provider and category."

**Section 2: Diagram Context**
```python
with Diagram("Name", show=False, direction="TB"):
    # components go here
```

> "The `with` block creates the drawing context. Everything inside gets rendered."

**Section 3: Components**
```python
with Cluster("AKS Cluster"):
    product_svc = KubernetesServices("Product Service")
```

> "Clusters create visual groupings. The string is the label shown on the diagram."

**Section 4: Connections**
```python
front_door >> services  # >> means 'connects to'
```

> "The `>>` operator draws arrows. Lists work too - connect multiple at once."

**🎓 Learning Moment: Understanding Over Copying**

> "Notice Copilot explained WHY each piece exists, not just WHAT to type.
> This is the difference between copying code and understanding code."
>
> *Key Pattern*: Request explanations WITH code - "explain each part as we go" unlocks learning.

---

### Phase 4: Iteration and Customization (3 minutes)

**[Type this prompt]**

```
For the design review, I'd like to highlight that Order Service is the critical 
path for transactions. Can we make it stand out somehow?
```

**[Expected Response - Multiple Options]**

1. **Edge styling**: `Edge(color="red", style="bold")`
2. **Labels**: `Edge(label="transactions")`
3. **Nested clusters**: Background colors

**[Show the enhanced code]**

```python
# Critical transaction path (highlighted)
front_door >> Edge(color="darkred", style="bold", label="transactions") >> order_svc
order_svc >> Edge(color="darkred", style="bold", label="write") >> sql_db
```

**🎓 Learning Moment: Options Enable Mastery**

> "Copilot gave me OPTIONS, not just one answer. It's teaching me the styling
> capabilities so I can make my own choices in the future."
>
> *Key Pattern*: Ask "what are my options?" to learn the full capability space.

---

### Phase 5: Best Practices (2 minutes)

**[Type this prompt]**

```
Quick question - how should I manage this going forward? We have 5 architects 
on the team who all maintain different diagrams.
```

**[Expected Response - Team Practices]**

1. **Repository structure**: `docs/architecture/*.py`
2. **Shared styling**: Common `diagram_styles.py`
3. **CI/CD integration**: Auto-generate on changes
4. **Version control**: Code diffs show exactly what changed

**🎓 Learning Moment: Meta-Learning for Scale**

> "This is the meta-learning - not just how to create ONE diagram, but how to
> scale diagrams-as-code across a team. Copilot is teaching organizational practices."
>
> *Key Pattern*: Always ask about team adoption and best practices - the real value is in scaling.

---

## Wrap-Up (2 minutes)

### Show the Value

**[Display or read]**

| Metric | Traditional | With Copilot |
|--------|-------------|--------------|
| First diagram | 45 min | 20 min |
| Future diagrams | 30-45 min | 5-10 min |
| Version control | ❌ | ✅ |
| Team consistency | Manual | Automated |

### Key Messages

1. **Learning over generating**: Marcus didn't just get a script - he learned a skill
2. **Conversation over commands**: Natural dialogue, not one-shot prompts
3. **Understanding over copying**: Can now create diagrams independently
4. **Transferable skills**: Can teach his team the same approach

### Call to Action

> "In 20 minutes, Marcus went from 'never used diagrams-as-code' to understanding
> the library, creating a professional diagram, and knowing how to scale it to his team.
> His next diagram will take 5-10 minutes, not 45."

---

## Backup Plans

### If Copilot is Slow/Unavailable

1. Open `examples/copilot-diagrams-conversation.md`
2. Walk through the transcript manually
3. Show the learning progression

### If Time is Short (10-minute version)

1. **Skip Phase 1** - Start at Phase 2 with architecture description
2. **Combine Phases 3-4** - Show complete code with styling
3. **Brief Phase 5** - Mention team practices without demo

### If Live Demo Fails

1. Have `solution/architecture.py` ready to run
2. Show pre-generated PNG
3. Focus on the conversation approach concept

---

## Q&A Preparation

### Expected Questions

**Q: "What about AWS/GCP?"**
> "The `diagrams` library supports all three. Change `diagrams.azure.*` to 
> `diagrams.aws.*` or `diagrams.gcp.*`. Copilot knows the icon namespaces."

**Q: "Can it do sequence diagrams?"**
> "The `diagrams` library is for architecture diagrams. For sequence diagrams,
> use Mermaid.js - Copilot knows that too. Different tools for different purposes."

**Q: "What about complex diagrams with hundreds of components?"**
> "Break into multiple diagrams - overview, network detail, data flow. Each diagram
> should tell ONE story. Copilot can help you decide how to split them."

**Q: "How does this compare to AWS Architecture Icons in PowerPoint?"**
> "PowerPoint is manual, can't be versioned, drifts from reality. Diagrams-as-code
> can be automated in CI/CD - regenerate every time infrastructure changes."

**Q: "Can non-technical stakeholders use this?"**
> "They consume the PNG/SVG output, not the code. The output is professional-quality.
> Technical team maintains the code, business sees the diagrams."

---

## Presenter Notes

### Tone
- **Curious, not expert**: Model the learning mindset
- **Collaborative**: "Let's figure this out together with Copilot"
- **Honest about trade-offs**: Don't oversell diagrams-as-code

### Key Phrases to Use
- "Notice I'm asking WHY, not just HOW"
- "Copilot is teaching me, not just generating"
- "This is transferable knowledge"
- "Next time will take 5 minutes"

### Things to Avoid
- Don't say "Copilot wrote this for me" → Say "Copilot taught me to write this"
- Don't skip explanations → Understanding is the value
- Don't rush through code → Each piece has a lesson

---

## Success Criteria

### Demo Successful If:
- ✅ Audience sees conversation-based learning (not script generation)
- ✅ Copilot explains concepts (not just code)
- ✅ Iteration shown (refinement, not one-shot)
- ✅ Business value clear (time savings, version control)
- ✅ Knowledge transfer emphasized (next diagram faster)

### Audience Takeaways:
- "I could learn diagrams-as-code with Copilot"
- "This saves significant time for architecture documentation"
- "Understanding matters more than copying code"
- "Copilot is a learning partner, not just a code generator"

---

*This demo script supports the conversation-based learning approach. 
Focus on the dialogue, not just the output.*
