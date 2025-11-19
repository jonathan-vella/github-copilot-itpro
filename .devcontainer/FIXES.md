# Devcontainer Configuration Fixes

## Issues Fixed

### 1. **Removed Problematic Mount Configuration**
**Problem:** The original configuration tried to mount `.terraform-cache` directory that didn't exist yet, causing container startup to fail with exit code 1.

**Fix:**
- Removed `mounts` array from `devcontainer.json`
- Changed Terraform cache location to `/home/vscode/.terraform-cache` (inside container)
- Post-create script now creates this directory automatically

### 2. **Eliminated Duplicate postCreateCommand**
**Problem:** Had `postCreateCommand` declared twice in different locations.

**Fix:** Consolidated to single `postCreateCommand` declaration at the end of the configuration.

### 3. **Removed updateContentCommand**
**Problem:** `updateContentCommand` was referencing `update-tools.sh` which could slow down container restarts.

**Fix:** Removed automatic update on content changes. Users can manually run `bash .devcontainer/update-tools.sh` when needed.

### 4. **Made Post-Create Script More Robust**
**Improvements:**
- Added logging to `~/.devcontainer-install.log` for debugging
- Added error handling with `|| true` and `|| echo "Warning..."` patterns
- Made PowerShell module installation more resilient with try-catch
- Added fallback messages for non-critical tool failures

### 5. **Fixed Terraform Formatter Configuration**
**Problem:** Terraform extension formatter was set to `hashicorp.terraform` which wasn't in the allowed list.

**Fix:** Removed explicit formatter, kept `editor.formatOnSave: true` which uses the extension's default formatter.

## Files Modified

1. **`.devcontainer/devcontainer.json`**
   - Removed `mounts` array
   - Fixed `TF_PLUGIN_CACHE_DIR` path
   - Consolidated `postCreateCommand`
   - Fixed Terraform formatter settings

2. **`.devcontainer/post-create.sh`**
   - Added logging to file
   - Added error handling for all installations
   - Fixed Terraform cache directory path
   - Made PowerShell module installation more robust

3. **`README.md`**
   - Added devcontainer as recommended quick start option
   - Added link to troubleshooting guide
   - Updated repository structure to show `.devcontainer/` folder

## Files Added

1. **`.devcontainer/TROUBLESHOOTING.md`**
   - Common errors and fixes
   - Verification commands
   - Minimal configuration fallback
   - Manual installation instructions for host machine

## Testing Recommendations

### Before Retrying Container Build

1. **Clear Docker cache:**
   ```powershell
   docker system prune -a --volumes
   ```

2. **Ensure Docker Desktop is running and has sufficient resources:**
   - Memory: 4GB minimum
   - Disk space: 20GB available

3. **Test base image pull:**
   ```powershell
   docker pull mcr.microsoft.com/devcontainers/base:ubuntu-24.04
   ```

### After Container Starts

Run verification commands inside the container:

```bash
# Check installation log
cat ~/.devcontainer-install.log

# Verify tools
terraform version
az version
bicep --version
pwsh --version
tfsec --version
checkov --version

# Test Terraform cache directory
ls -la /home/vscode/.terraform-cache
```

## Fallback Options

If the full configuration still fails:

### Option 1: Minimal Configuration
Use the simplified config in `TROUBLESHOOTING.md` that only includes:
- Azure CLI
- Terraform
- PowerShell
- Essential VS Code extensions

### Option 2: Host Machine Installation
Install tools directly on Windows/macOS/Linux using package managers (Chocolatey, Homebrew, apt).

## Expected Build Time

- **First build**: 3-5 minutes (downloading images + installing tools)
- **Subsequent builds**: 30-60 seconds (cached)
- **Rebuild without cache**: 3-5 minutes

## Known Limitations

1. **Windows file path issues**: Some Docker Desktop for Windows configurations may have issues with line endings or paths
2. **Network restrictions**: Corporate firewalls may block container image downloads
3. **Resource constraints**: Low memory allocation to Docker Desktop can cause failures

## Next Steps

1. Try rebuilding the container: `F1` → `Dev Containers: Rebuild Container`
2. If it fails again, check `~/.devcontainer-install.log` for specific error
3. Report issues with log contents and Docker/OS versions
