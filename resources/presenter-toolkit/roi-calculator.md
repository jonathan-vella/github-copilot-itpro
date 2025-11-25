# ROI Calculator for GitHub Copilot

This calculator helps you build a business case for GitHub Copilot adoption, using measured time savings from
real Infrastructure-as-Code workflows.

## 🎯 Quick ROI Summary

**Break-Even Point**: Save **2-3 hours per month** to cover the $19/user/month subscription cost.

**Typical ROI**: 5-15x return on investment for active IaC developers.

---

## 📊 Time Savings by Scenario

These measurements come from the repository's documented scenarios (S01-S09):

| Scenario | Manual Time | With Copilot | Time Saved | Savings % |
|----------|-------------|--------------|------------|-----------|
| S01 - Bicep Baseline (Hub & Spoke) | 4-6 hours | 30-45 min | 3.5-5.5 hours | 85-90% |
| S02 - Terraform Baseline | 4-6 hours | 30-45 min | 3.5-5.5 hours | 85-90% |
| S03 - Five-Agent Workflow | 18 hours | 45 min | 17.25 hours | 96% |
| S04 - Documentation Generation | 3-4 hours | 20-30 min | 2.5-3.5 hours | 85-90% |
| S05 - Service Validation | 2-3 hours | 15-20 min | 1.75-2.75 hours | 85-90% |
| S06 - Troubleshooting | 1-4 hours | 10-15 min | 0.75-3.75 hours | 80-90% |
| S07 - SBOM Generator | 2-3 hours | 15-20 min | 1.75-2.75 hours | 85-90% |
| S08 - Diagrams as Code | 2-3 hours | 15-20 min | 1.75-2.75 hours | 85-90% |
| S09 - Coding Agent | 2-4 hours | 15-30 min | 1.5-3.5 hours | 85-90% |

📖 **Methodology**: See [Time Savings Evidence](../../docs/time-savings-evidence.md) for measurement details.

---

## 🧮 ROI Calculator

### Step 1: Input Your Variables

| Variable | Your Value | Example |
|----------|-----------|---------|
| Number of IaC engineers | _____ | 5 |
| Average hourly cost (loaded) | $_____ | $100 |
| Infrastructure projects per month | _____ | 8 |
| Hours per project (manual) | _____ | 6 |
| Expected Copilot adoption rate | _____% | 80% |

### Step 2: Calculate Monthly Costs

```text
Copilot Cost = Engineers × $19/month
Example: 5 × $19 = $95/month
```

### Step 3: Calculate Monthly Savings

```text
Hours Saved = Projects × Manual Hours × Savings Rate × Adoption Rate
Example: 8 projects × 6 hours × 85% × 80% = 32.6 hours/month

Dollar Savings = Hours Saved × Hourly Cost
Example: 32.6 hours × $100 = $3,264/month
```

### Step 4: Calculate ROI

```text
Net Savings = Dollar Savings - Copilot Cost
Example: $3,264 - $95 = $3,169/month

ROI = Net Savings / Copilot Cost × 100
Example: $3,169 / $95 × 100 = 3,336% ROI
```

---

## 📋 Pre-Built Scenarios

### Small Team (3 engineers, 4 projects/month)

| Metric | Value |
|--------|-------|
| Copilot Cost | $57/month |
| Hours Saved | 16.3 hours/month |
| Dollar Savings | $1,632/month |
| Net Savings | $1,575/month |
| **Annual Net Savings** | **$18,900** |
| ROI | 2,763% |

### Medium Team (10 engineers, 12 projects/month)

| Metric | Value |
|--------|-------|
| Copilot Cost | $190/month |
| Hours Saved | 48.9 hours/month |
| Dollar Savings | $4,896/month |
| Net Savings | $4,706/month |
| **Annual Net Savings** | **$56,472** |
| ROI | 2,477% |

### Large Team (25 engineers, 30 projects/month)

| Metric | Value |
|--------|-------|
| Copilot Cost | $475/month |
| Hours Saved | 122.4 hours/month |
| Dollar Savings | $12,240/month |
| Net Savings | $11,765/month |
| **Annual Net Savings** | **$141,180** |
| ROI | 2,477% |

---

## 📈 Additional Value (Hard to Quantify)

Beyond direct time savings, consider these benefits:

### Quality Improvements

| Benefit | Impact |
|---------|--------|
| Reduced misconfigurations | Fewer production incidents |
| Built-in security defaults | Lower security risk |
| Consistent naming conventions | Easier maintenance |
| Better documentation | Faster knowledge transfer |

### Team Benefits

| Benefit | Impact |
|---------|--------|
| Faster onboarding | Junior engineers productive sooner |
| Reduced cognitive load | Less burnout, higher retention |
| Knowledge sharing | Best practices spread organically |
| Focus on architecture | More time for high-value work |

### Organizational Benefits

| Benefit | Impact |
|---------|--------|
| Faster time-to-market | Competitive advantage |
| Standardization | Cross-team consistency |
| Reduced technical debt | Cleaner codebase over time |
| Audit trail | Copilot history for compliance |

---

## 🎯 Presenting ROI to Stakeholders

### For Technical Leaders

Focus on:

- Specific time savings per task type
- Quality improvements (fewer incidents)
- Team productivity and morale

### For Financial Leaders

Focus on:

- Hard dollar savings (hours × rate)
- Break-even timeline (typically < 1 month)
- Comparison to other productivity investments

### For Executive Leadership

Focus on:

- Strategic value (faster delivery, reduced risk)
- Competitive positioning (AI-augmented teams)
- Talent attraction and retention

---

## 📊 Comparison: Copilot vs. Alternatives

| Alternative | Cost | Effectiveness | Notes |
|-------------|------|---------------|-------|
| **Do Nothing** | $0 | 0% savings | Status quo, no improvement |
| **More Training** | $2-5K/person | 10-20% improvement | One-time, decays over time |
| **Hire More Staff** | $150K+/year | Linear scaling | Expensive, slow to ramp |
| **Better Templates** | $0 (internal time) | 20-30% improvement | Maintenance overhead |
| **GitHub Copilot** | $228/year | 85-95% improvement | Continuous improvement |

---

## 🔢 Quick Reference Formulas

```text
Monthly Copilot Cost = Engineers × $19

Monthly Hours Saved = Projects × Avg_Project_Hours × 0.85 × Adoption_Rate

Monthly Dollar Savings = Hours_Saved × Hourly_Rate

Monthly Net Savings = Dollar_Savings - Copilot_Cost

Annual Net Savings = Monthly_Net_Savings × 12

ROI Percentage = (Net_Savings / Copilot_Cost) × 100

Break-Even Hours = $19 / Hourly_Rate
  (Example: $19 / $100 = 0.19 hours = 11 minutes saved per month to break even)
```

---

## 📚 Resources

- [Time Savings Evidence](../../docs/time-savings-evidence.md) - Detailed methodology
- [Demo Delivery Guide](demo-delivery-guide.md) - Presenting to stakeholders
- [GitHub Copilot Pricing](https://github.com/features/copilot) - Official pricing page
- [Objection Handling](objection-handling.md) - Address budget concerns
