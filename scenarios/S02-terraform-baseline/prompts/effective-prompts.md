# S02: Effective Prompts for Terraform Learning

This guide shows how to use **discovery questions** rather than generation commands when learning
Terraform with GitHub Copilot. The goal is to build understanding, not just produce HCL.

---

## Prompt Philosophy

### ❌ Code Generation (What to Avoid)

```
Generate a Terraform module for Azure VNet with 3 subnets
```

This produces code you can't maintain or troubleshoot.

### ✅ Conversation-Based Learning (Recommended)

```
I'm an AWS engineer learning Terraform for Azure. In CloudFormation, I create VPCs
with nested stacks. Can you explain how Terraform modules work and help me build
one while understanding each part?
```

This builds transferable knowledge.

---

## Phase 1: Understanding Terraform & HCL

### Starting from CloudFormation Background

**If you know CloudFormation**:
```
I've used AWS CloudFormation for years - nested stacks, change sets, cross-stack
references. I'm learning Terraform for Azure. Can you explain how Terraform concepts
map to what I already know?
```

**If you know ARM templates**:
```
I've written Azure ARM templates but they're verbose and hard to read. I've heard
Bicep and Terraform are better. How does Terraform compare, and when would I choose
it over Bicep?
```

**If you know Ansible/Chef/Puppet**:
```
I've used Ansible for configuration management but never proper IaC for cloud
resources. How is Terraform different from Ansible, and what does it do better?
```

### Understanding HCL

**Syntax questions**:
```
What does HCL syntax look like compared to CloudFormation YAML? Can you show me the
same simple resource in both formats?
```

**Block types**:
```
I see 'resource', 'variable', 'output', 'locals' blocks. What does each one do and
when would I use each?
```

**References**:
```
In CloudFormation, I use !Ref and !GetAtt. How do I reference resources and attributes
in Terraform?
```

---

## Phase 2: Provider & Backend Setup

### Azure Provider Questions

**Authentication**:
```
How do I configure Terraform to talk to Azure? In AWS, I set environment variables
or use instance profiles. What are the options for Azure?
```

**Local development**:
```
What's the simplest way to authenticate when developing locally? I don't want to
manage service principals just for testing.
```

**CI/CD pipelines**:
```
For production CI/CD, what's the recommended authentication method? I've used AWS
IAM roles for GitHub Actions - is there an Azure equivalent?
```

### State Management

**Understanding state**:
```
You mentioned Terraform state. In CloudFormation, AWS manages stack state automatically.
Why does Terraform require me to manage state, and what could go wrong if I don't?
```

**Remote backends**:
```
How do I set up Azure Storage as a remote backend? I want locking like DynamoDB
provides for S3-based state in AWS.
```

**State security**:
```
State files contain sensitive data. How do I secure the Azure Storage backend?
What encryption and access controls should I configure?
```

**State recovery**:
```
What happens if state gets corrupted? How do I recover? Should I enable versioning
on the storage container?
```

---

## Phase 3: Building Network Foundation

### Module Structure Questions

**Understanding modules**:
```
In CloudFormation, I use nested stacks for reusability. How do Terraform modules
work? What files do I need and how are they organized?
```

**Module design**:
```
What makes a good Terraform module? What should be variables vs hardcoded? How
granular should modules be?
```

**Module sources**:
```
Can I use modules from a registry like NPM packages? What's the Terraform Registry
and how do I find Azure-specific modules?
```

### Virtual Network Questions

**VNet basics**:
```
I'm building my first Azure VNet in Terraform. Can you show me the resource and
explain each property? How does it compare to AWS VPC?
```

**Subnet design**:
```
I need three subnets for a three-tier app. In AWS, I'd consider availability zones.
What should I think about for Azure subnets?
```

**Subnet delegation**:
```
I see 'delegation' in some subnet examples. What is subnet delegation and when do
I need it?
```

### NSG Questions

**NSG vs Security Groups**:
```
How do Azure NSGs compare to AWS Security Groups? What's different about how they
work and where they attach?
```

**Rule design**:
```
What's the best practice for NSG rules? Should I start with allow-all or deny-all?
How do priorities work?
```

**Tier isolation**:
```
Web tier should talk to app tier, app to database, but web shouldn't reach database
directly. How do I configure NSG rules for this pattern?
```

---

## Phase 4: App & Data Modules

### App Service Questions

**Understanding App Service**:
```
How does Azure App Service compare to AWS Elastic Beanstalk or ECS? When would I
choose App Service vs containers?
```

**Security configuration**:
```
What security settings should I configure on App Service? Things like HTTPS, TLS
versions, network access?
```

**Managed Identity**:
```
What's a Managed Identity? Is it like an AWS IAM instance role? How does App Service
use it to access other Azure resources?
```

**Private endpoint**:
```
I want App Service accessible only from my VNet, not the public internet. How do
private endpoints work?
```

### Database Questions

**Azure SQL setup**:
```
I'm setting up Azure SQL Database. What's the equivalent to RDS IAM authentication?
How do I avoid storing SQL passwords?
```

**Security hardening**:
```
What security settings should I enable on Azure SQL? Things like encryption, threat
detection, network access?
```

**Backup configuration**:
```
How do I configure backups for Azure SQL? What's the difference between short-term
and long-term retention?
```

**Private access**:
```
How do I make SQL Server accessible only via private endpoint? I don't want a
public IP at all.
```

---

## Phase 5: Module Composition & Best Practices

### Root Module Questions

**Wiring modules together**:
```
I have networking, app-service, and database modules. How do I call them from a
root module and pass values between them?
```

**Dependencies**:
```
My database needs the subnet ID from networking. How do I express that dependency?
Is it automatic or do I need explicit depends_on?
```

**Outputs**:
```
What outputs should I define? How do I use them for downstream automation or to
display important values after deployment?
```

### Environment Management

**Multiple environments**:
```
I need dev, staging, and prod environments with different settings. What's the
Terraform pattern for this? Workspaces? Separate directories?
```

**Variable files**:
```
How do terraform.tfvars files work? Can I have different files per environment?
```

**Conditional logic**:
```
Dev should use smaller SKUs than prod. How do I write conditional logic based on
environment?
```

### Testing Questions

**Validation**:
```
How do I validate Terraform code before deploying? What's the equivalent of
cfn-lint for CloudFormation?
```

**Security scanning**:
```
How do I scan Terraform for security issues? I've heard of tfsec and Checkov -
what do they check for?
```

**Integration testing**:
```
How do I write automated tests for Terraform? I've heard of Terratest - how does
it work?
```

---

## Troubleshooting Questions

### When Deployment Fails

**Understanding errors**:
```
I'm getting this error: [paste error]. Can you explain what it means and how to
fix it?
```

**Provider issues**:
```
Terraform says "Error building AzureRM Client". What does this mean and how do I
debug authentication?
```

**Resource conflicts**:
```
Deployment failed because a resource with this name already exists. How do I handle
naming conflicts in Terraform?
```

### State Issues

**State lock**:
```
I'm getting "Error acquiring the state lock". What causes this and how do I fix it?
```

**State drift**:
```
Someone made changes in the Azure portal. Now terraform plan shows unexpected changes.
How do I handle drift?
```

**Import existing**:
```
There are existing resources I want Terraform to manage. How do I import them into
state?
```

---

## Advanced Discovery Questions

### For Deep Understanding

**Lifecycle rules**:
```
What are lifecycle blocks in Terraform? When would I use prevent_destroy or
ignore_changes?
```

**Dynamic blocks**:
```
I have 10 NSG rules. Is there a way to loop over them instead of writing each one
out?
```

**Data sources**:
```
What are data sources vs resources? When would I use a data source to look up
existing infrastructure?
```

**Provisioners**:
```
What are provisioners in Terraform? I've heard they're discouraged - when would
I use them and what are the alternatives?
```

### For Team Scenarios

**Code organization**:
```
Multiple engineers will work on this Terraform. How should we organize code and
avoid merge conflicts?
```

**Module versioning**:
```
How do I version modules so changes don't break consumers? Is there a pattern like
semantic versioning?
```

**Policy enforcement**:
```
How do I enforce standards across Terraform code? I've heard of Sentinel and OPA -
what do they do?
```

---

## Prompt Patterns Reference

### The CloudFormation Mapping Pattern
```
In CloudFormation, I do [thing]. What's the Terraform equivalent for Azure?
```

### The Why Pattern
```
I see [configuration]. Why is it done this way? What would happen if I changed it?
```

### The Compare Pattern
```
What's the difference between [option A] and [option B]? When would I use each?
```

### The Security Pattern
```
What security settings should I configure for [resource]? What attacks do they
prevent?
```

### The Troubleshooting Pattern
```
I'm getting [error]. Here's my code: [paste]. What's wrong and how do I fix it?
```

---

## Key Principle

**Transfer knowledge, don't start over.**

If you already know CloudFormation, ARM templates, or other IaC tools, map that
knowledge to Terraform. Ask Copilot to explain concepts in terms you understand.

---

*These prompts guide conversation-based learning for Terraform on Azure. Focus on
understanding and knowledge transfer, not just code generation.*
