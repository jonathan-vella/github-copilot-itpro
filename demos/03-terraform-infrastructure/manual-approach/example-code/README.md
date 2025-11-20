# Manual Approach - Example Terraform Code

This folder contains **manually-written Terraform code**, representing the traditional approach before using GitHub Copilot.

## What's in This Folder

`main.tf` - A basic monolithic Terraform configuration for a 3-tier web application.

## Characteristics of Manual Approach

### ❌ Poor Structure

- Monolithic file (all resources in one file)
- No modules or code reusability
- Hard-coded values throughout
- No separation of environments

### ❌ Security Issues

- 🔴 Hard-coded password in code (`P@ssw0rd1234!`)
- 🔴 SQL Server publicly accessible
- 🔴 App Service publicly accessible (no private endpoint)
- 🔴 NSG rules too permissive (`*` source)
- 🔴 No encryption enforcement
- 🔴 No TLS minimum version
- 🔴 No managed identity (credentials needed)
- 🔴 No Azure AD authentication

### ❌ Missing Features

- No variable definitions (hard to customize)
- No outputs (how do you get connection strings?)
- No tagging (cost allocation impossible)
- No Key Vault integration
- No monitoring or logging
- No backup configuration
- No threat detection

### ❌ Operational Problems

- **Not reusable**: Can't deploy to staging/prod without duplication
- **Not testable**: No variables to inject test values
- **Not maintainable**: Everything in one file
- **Resource naming**: Hope for globally unique names
- **No state management**: Local state only (team conflicts)

### ❌ Scalability Issues

- Standard tier App Service (no zone redundancy)
- Basic SQL Database (poor performance)
- No autoscaling
- No geo-redundancy

## Time Investment

Creating this basic configuration manually:

- **Research Azure resources**: 4-6 hours
- **Write Terraform code**: 6-8 hours  
- **Debug errors**: 4-6 hours (hard-coded values cause many issues)
- **Test deployment**: 2-3 hours
- **Fix security issues**: 4-6 hours (post-deployment discovery)

**Total**: 20-29 hours for basic (insecure) infrastructure

## Problems Found in Security Audit

If you deployed this manually-written code, a security audit would find:

- ❌ 8 critical findings (public endpoints, hard-coded secrets)
- ❌ 12 high findings (no encryption, no threat detection)
- ❌ 15 medium findings (missing tags, no monitoring)
- ❌ 20+ informational (best practices not followed)

**Remediation cost**: 20-30 additional hours

---

## Comparison with Copilot Version

| Aspect | Manual Code (This Folder) | Copilot Code (`../with-copilot/`) |
|--------|--------------------------|----------------------------------|
| **Lines of Code** | ~120 lines | ~800+ lines (modular) |
| **Security Findings** | 35+ issues | 0 critical issues |
| **Modules** | None (monolithic) | 4 reusable modules |
| **Variables** | None | 30+ with validation |
| **Outputs** | None | 15+ outputs |
| **Time to Create** | 20-29 hours | 2-3 hours |
| **Production-Ready** | ❌ No | ✅ Yes |

---

## Why This Approach Fails

### 1. **Knowledge Gap**

Manually writing Terraform requires deep expertise in:

- HCL syntax
- Azure resource dependencies
- Security best practices
- Network architecture
- State management

Most engineers don't have all this knowledge, leading to trial-and-error development.

### 2. **Copy-Paste from Internet**

Engineers often:

- Copy code from StackOverflow (outdated, insecure)
- Use examples from blog posts (not production-ready)
- Adapt code without understanding implications

### 3. **No Security Validation**

Without tools like Checkov/tfsec integrated, security issues aren't discovered until:

- Security audit (costly remediation)
- Production deployment (security incident)
- Compliance review (project delays)

### 4. **Time Pressure**

Under pressure to deliver quickly, engineers skip:

- Proper module design
- Comprehensive testing
- Security hardening
- Documentation

---

## Key Takeaway

The manual approach produces insecure, non-reusable code in 20-30 hours. GitHub Copilot produces production-ready, modular code with security best practices in 2-3 hours - a **90% time reduction** with **10x better quality**.

See `../with-copilot/example-code/` for the Copilot-assisted version that addresses all these issues.

---

## ⚠️ DO NOT USE THIS CODE IN PRODUCTION

This code is intentionally basic and insecure for demonstration purposes. It illustrates common mistakes in manually-written Terraform code.

For production use, see the Copilot-generated version in `../with-copilot/example-code/`.
