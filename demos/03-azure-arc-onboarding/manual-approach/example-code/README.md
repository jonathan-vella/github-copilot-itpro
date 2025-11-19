# Manual Approach - Example Code

This folder contains examples of **manually-written scripts** for Azure Arc onboarding, representing the traditional approach before using GitHub Copilot.

## What's in This Folder

These scripts demonstrate the typical characteristics of manually-written automation:

1. **Create-ServicePrincipal.ps1** - Basic Service Principal creation
2. **Install-ArcAgent.ps1** - Sequential agent installation across servers
3. **Configure-ArcPolicy.ps1** - Simple policy assignment
4. **Setup-Monitoring.ps1** - Basic monitoring configuration
5. **Test-ArcConnectivity.ps1** - Simple connectivity checks

## Characteristics of Manual Approach

### ❌ Limited Features
- Minimal error handling
- Basic parameter validation
- No retry logic
- Sequential processing only
- Hard-coded values
- No progress indicators

### ❌ Poor Documentation
- Minimal inline comments
- Basic or missing help text
- No usage examples
- No parameter descriptions
- Limited troubleshooting guidance

### ❌ Security Issues
- Over-privileged roles (Contributor instead of least-privilege)
- Secrets displayed in console
- No secure credential storage
- Plain-text parameter passing
- No certificate support

### ❌ Operational Challenges
- Manual tracking required
- No automated validation
- Limited logging
- No health checks
- Difficult to troubleshoot
- No reporting capabilities

### ❌ Scalability Problems
- Sequential processing (slow for 500 servers)
- No parallel execution
- No batching
- Manual intervention required
- Hard to maintain
- Poor code reusability

## Time Investment

Creating these basic scripts manually typically takes:

- **Create-ServicePrincipal.ps1**: 3-4 hours
- **Install-ArcAgent.ps1**: 6-8 hours
- **Configure-ArcPolicy.ps1**: 3-4 hours
- **Setup-Monitoring.ps1**: 4-5 hours
- **Test-ArcConnectivity.ps1**: 2-3 hours

**Total**: 18-24 hours for basic functionality

Compare this to the Copilot-assisted versions in `../with-copilot/` which took **2 hours** total and include:
- ✅ Comprehensive error handling
- ✅ Full documentation
- ✅ Security best practices
- ✅ Parallel processing
- ✅ Advanced features
- ✅ Production-ready quality

## Usage (Not Recommended)

⚠️ **These scripts are for demonstration purposes only** to show the contrast between manual and Copilot-assisted development.

For production use, refer to the scripts in `../with-copilot/` which provide:
- 10x better error handling
- 5x faster execution (parallel processing)
- Enterprise-grade security
- Complete documentation
- Production-ready quality

## Key Takeaway

The manual approach requires significantly more time to produce lower-quality results. GitHub Copilot enables IT Pros to:

1. **Write better code faster** - 90% time reduction
2. **Follow best practices automatically** - Security, error handling, documentation
3. **Scale efficiently** - Parallel processing, retry logic, health checks
4. **Deliver production-ready solutions** - First time, every time

See `../with-copilot/` for the GitHub Copilot-assisted versions that demonstrate the efficiency multiplier effect.
