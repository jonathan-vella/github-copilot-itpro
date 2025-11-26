# GitHub Copilot ROI Calculator for IT Pros

> **Use this worksheet to calculate expected ROI for GitHub Copilot adoption in your IT team.**

---

## Quick Calculator

### Step 1: Enter Your Team Details

| Input                   | Your Value | Notes                                            |
| ----------------------- | ---------- | ------------------------------------------------ |
| **Number of IT Pros**   | \_\_\_     | Cloud architects, infra engineers, DevOps        |
| **Average hourly rate** | $\_\_\_/hr | Fully loaded cost (salary + benefits + overhead) |
| **Working hours/month** | 160        | Standard assumption                              |

---

### Step 2: Estimate Current Time Allocation

_Based on research, IT Pros typically spend their time as follows. Adjust percentages to match your reality._

| Task Category                             | Industry Average | Your Team % | Hours/Month (per person) |
| ----------------------------------------- | ---------------- | ----------- | ------------------------ |
| IaC Development (Bicep, Terraform, ARM)   | 25%              | \_\_\_%     | \_\_\_ hrs               |
| Scripting & Automation (PowerShell, Bash) | 15%              | \_\_\_%     | \_\_\_ hrs               |
| Troubleshooting & Debugging               | 20%              | \_\_\_%     | \_\_\_ hrs               |
| Documentation                             | 15%              | \_\_\_%     | \_\_\_ hrs               |
| Research & Learning                       | 15%              | \_\_\_%     | \_\_\_ hrs               |
| Strategic Architecture                    | 10%              | \_\_\_%     | \_\_\_ hrs               |
| **TOTAL**                                 | 100%             | 100%        | 160 hrs                  |

---

### Step 3: Apply Time Savings Multipliers

_Research-backed savings percentages. Use conservative (low) estimates for pilot planning._

| Task Category          | Conservative | Moderate | Aggressive | Your Estimate |
| ---------------------- | ------------ | -------- | ---------- | ------------- |
| IaC Development        | 60%          | 75%      | 85%        | \_\_\_%       |
| Scripting & Automation | 55%          | 70%      | 80%        | \_\_\_%       |
| Troubleshooting        | 50%          | 65%      | 80%        | \_\_\_%       |
| Documentation          | 65%          | 80%      | 90%        | \_\_\_%       |
| Research & Learning    | 40%          | 55%      | 70%        | \_\_\_%       |

**Sources:**

- GitHub Copilot Study (2023): 55% task completion improvement
- Forrester TEI (2024): 88% reduction in repetitive tasks
- MIT Sloan (2024): 80% documentation time saved
- Stanford HAI (2023): 60-70% problem-solving acceleration

---

### Step 4: Calculate Monthly Savings

**Formula:**

```
Hours Saved = (Current Hours × Savings %) for each task category
Monthly Value = Total Hours Saved × Hourly Rate
```

| Task Category          | Current Hrs | Savings % | Hours Saved    | Value Saved |
| ---------------------- | ----------- | --------- | -------------- | ----------- |
| IaC Development        | \_\_\_      | \_\_\_%   | \_\_\_         | $\_\_\_     |
| Scripting & Automation | \_\_\_      | \_\_\_%   | \_\_\_         | $\_\_\_     |
| Troubleshooting        | \_\_\_      | \_\_\_%   | \_\_\_         | $\_\_\_     |
| Documentation          | \_\_\_      | \_\_\_%   | \_\_\_         | $\_\_\_     |
| Research & Learning    | \_\_\_      | \_\_\_%   | \_\_\_         | $\_\_\_     |
| **TOTAL per IT Pro**   |             |           | **\_\_\_ hrs** | **$\_\_\_** |

---

### Step 5: Calculate Team ROI

| Metric                         | Calculation                | Result        |
| ------------------------------ | -------------------------- | ------------- |
| **Monthly savings per IT Pro** | From Step 4                | $\_\_\_       |
| **Team size**                  | From Step 1                | \_\_\_ people |
| **Total monthly savings**      | Savings × Team size        | $\_\_\_       |
| **GitHub Copilot cost**        | $19 × Team size            | $\_\_\_       |
| **Net monthly benefit**        | Savings - Cost             | $\_\_\_       |
| **Monthly ROI**                | (Net benefit ÷ Cost) × 100 | \_\_\_%       |

---

## Pre-Filled Examples

### Example 1: Small Team (5 IT Pros)

| Input                      | Value                      |
| -------------------------- | -------------------------- |
| Team size                  | 5 IT Pros                  |
| Average hourly rate        | $75/hr                     |
| Hours on automatable tasks | 80 hrs/month (50% of time) |
| Average time savings       | 65% (conservative)         |

**Calculation:**

- Hours saved per person: 80 × 0.65 = **52 hours/month**
- Value per person: 52 × $75 = **$3,900/month**
- Team total: $3,900 × 5 = **$19,500/month**
- Copilot cost: $19 × 5 = **$95/month**
- Net benefit: $19,500 - $95 = **$19,405/month**
- **ROI: 20,426%**

---

### Example 2: Medium Team (15 IT Pros)

| Input                      | Value                      |
| -------------------------- | -------------------------- |
| Team size                  | 15 IT Pros                 |
| Average hourly rate        | $85/hr                     |
| Hours on automatable tasks | 70 hrs/month (44% of time) |
| Average time savings       | 70% (moderate)             |

**Calculation:**

- Hours saved per person: 70 × 0.70 = **49 hours/month**
- Value per person: 49 × $85 = **$4,165/month**
- Team total: $4,165 × 15 = **$62,475/month**
- Copilot cost: $19 × 15 = **$285/month**
- Net benefit: $62,475 - $285 = **$62,190/month**
- **ROI: 21,821%**

---

### Example 3: Large Team (50 IT Pros)

| Input                      | Value                      |
| -------------------------- | -------------------------- |
| Team size                  | 50 IT Pros                 |
| Average hourly rate        | $100/hr                    |
| Hours on automatable tasks | 60 hrs/month (38% of time) |
| Average time savings       | 75% (moderate-aggressive)  |

**Calculation:**

- Hours saved per person: 60 × 0.75 = **45 hours/month**
- Value per person: 45 × $100 = **$4,500/month**
- Team total: $4,500 × 50 = **$225,000/month**
- Copilot cost: $19 × 50 = **$950/month**
- Net benefit: $225,000 - $950 = **$224,050/month**
- **ROI: 23,584%**
- **Annual value: $2.7M**

---

## Break-Even Analysis

### How Fast Will You Break Even?

| Scenario                       | Break-Even Point |
| ------------------------------ | ---------------- |
| **Conservative (50% savings)** | < 1 day          |
| **Moderate (70% savings)**     | < 4 hours        |
| **Aggressive (85% savings)**   | < 2 hours        |

**Why so fast?**

At $19/month per user (~$0.12/hour for a full-time employee), even saving 10 minutes per day covers the cost. Most IT Pros report saving 1-2 hours on their first day.

---

## Qualitative Benefits (Not Captured in ROI)

These benefits are real but harder to quantify:

| Benefit                           | Impact                              |
| --------------------------------- | ----------------------------------- |
| **Reduced context-switching**     | Higher focus, better quality        |
| **Faster onboarding**             | New team members productive sooner  |
| **Knowledge democratization**     | Junior staff access senior patterns |
| **Improved documentation**        | Reduced knowledge silos             |
| **Lower frustration**             | Better retention, job satisfaction  |
| **Consistent security practices** | Fewer vulnerabilities in production |
| **Faster incident response**      | Reduced MTTR                        |

---

## Presenting ROI to Leadership

### Key Messages

1. **"Break-even in hours, not months"** - Unlike most software investments, Copilot pays for itself almost immediately.

2. **"Not a productivity tax"** - Learning curve is minimal (1-2 days), and productivity gains are visible from day one.

3. **"Multiplies existing expertise"** - Your senior architects can now implement their own designs. Junior staff learn faster.

4. **"Risk is minimal"** - At $19/user/month with month-to-month billing, you can pilot with zero commitment.

### Suggested Pilot Structure

| Phase        | Duration | Team Size     | Success Criteria                  |
| ------------ | -------- | ------------- | --------------------------------- |
| Pilot        | 4 weeks  | 3-5 IT Pros   | 50%+ time savings on IaC tasks    |
| Expansion    | 4 weeks  | 10-15 IT Pros | Consistent results, team adoption |
| Full Rollout | Ongoing  | All IT Pros   | Standard tooling                  |

---

## Document Info

|                  |                                  |
| ---------------- | -------------------------------- |
| **Created**      | November 2025                    |
| **Purpose**      | Partner/customer ROI discussions |
| **Data Sources** | time-savings-evidence.md         |
| **Maintainer**   | Repository maintainers           |

---

_Download this worksheet, fill in your numbers, and use it to build the business case for your team._
