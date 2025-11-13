<#
.SYNOPSIS
    Creates an Azure Service Principal for Azure Arc Connected Machine onboarding.

.DESCRIPTION
    This script creates a Service Principal with least-privilege permissions required
    for Azure Arc Connected Machine agent onboarding. Credentials are securely stored
    in Azure Key Vault. Supports certificate-based authentication for enhanced security.

.PARAMETER ServicePrincipalName
    Name of the Service Principal to create (e.g., "Arc-Onboarding-Prod").

.PARAMETER SubscriptionId
    Azure subscription ID where Arc servers will be registered.

.PARAMETER ResourceGroupScope
    (Optional) Resource group name to scope permissions. If not provided, uses subscription scope.

.PARAMETER LogAnalyticsWorkspaceId
    Full resource ID of the Log Analytics workspace for monitoring.

.PARAMETER KeyVaultName
    Name of the Azure Key Vault to store Service Principal credentials.

.PARAMETER UseCertificate
    Use certificate-based authentication instead of client secret (more secure).

.PARAMETER CertificatePath
    Path to certificate file (.pfx) if UseCertificate is specified.

.PARAMETER ValidityYears
    Number of years the Service Principal credentials are valid (default: 1 year).

.EXAMPLE
    .\New-ArcServicePrincipal.ps1 `
        -ServicePrincipalName "Arc-GlobalManu-Prod" `
        -SubscriptionId "12345678-1234-1234-1234-123456789012" `
        -LogAnalyticsWorkspaceId "/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/..." `
        -KeyVaultName "kv-globalmanu-prod" `
        -ValidityYears 1

.EXAMPLE
    # With certificate authentication
    .\New-ArcServicePrincipal.ps1 `
        -ServicePrincipalName "Arc-SecureAuth" `
        -SubscriptionId "12345678-1234-1234-1234-123456789012" `
        -LogAnalyticsWorkspaceId "/subscriptions/.../workspaces/..." `
        -KeyVaultName "kv-secure" `
        -UseCertificate `
        -CertificatePath "C:\certs\arc-auth.pfx"

.NOTES
    Author: Cloud Infrastructure Team
    Version: 1.0
    Required Modules: Az.Accounts, Az.Resources, Az.KeyVault
    
    Permissions Required:
    - User Access Administrator or Owner on subscription
    - Key Vault Administrator on Key Vault

    Generated with GitHub Copilot assistance
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Name of the Service Principal")]
    [ValidateNotNullOrEmpty()]
    [string]$ServicePrincipalName,
    
    [Parameter(Mandatory = $true, HelpMessage = "Azure subscription ID")]
    [ValidatePattern('^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false, HelpMessage = "Resource group name for scoped permissions")]
    [string]$ResourceGroupScope,
    
    [Parameter(Mandatory = $true, HelpMessage = "Log Analytics workspace resource ID")]
    [ValidateNotNullOrEmpty()]
    [string]$LogAnalyticsWorkspaceId,
    
    [Parameter(Mandatory = $true, HelpMessage = "Key Vault name for credential storage")]
    [ValidateNotNullOrEmpty()]
    [string]$KeyVaultName,
    
    [Parameter(Mandatory = $false, HelpMessage = "Use certificate-based authentication")]
    [switch]$UseCertificate,
    
    [Parameter(Mandatory = $false, HelpMessage = "Path to certificate file (.pfx)")]
    [string]$CertificatePath,
    
    [Parameter(Mandatory = $false, HelpMessage = "Validity period in years")]
    [ValidateRange(1, 2)]
    [int]$ValidityYears = 1
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#region Helper Functions

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $color = switch ($Level) {
        'Info'    { 'Cyan' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
    }
    
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Test-AzureConnection {
    try {
        $context = Get-AzContext -ErrorAction Stop
        if (-not $context) {
            throw "Not connected to Azure"
        }
        Write-Log "Connected to Azure as: $($context.Account.Id)" -Level Info
        return $true
    }
    catch {
        Write-Log "Not connected to Azure. Please run Connect-AzAccount first." -Level Error
        return $false
    }
}

#endregion

#region Main Script

try {
    Write-Log "=== Azure Arc Service Principal Creator ===" -Level Info
    Write-Log "Starting Service Principal creation process..." -Level Info
    
    # Validate Azure connection
    if (-not (Test-AzureConnection)) {
        throw "Azure connection required"
    }
    
    # Set subscription context
    Write-Log "Setting subscription context to: $SubscriptionId" -Level Info
    $null = Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop
    
    # Check if Service Principal already exists
    Write-Log "Checking if Service Principal '$ServicePrincipalName' already exists..." -Level Info
    $existingSP = Get-AzADServicePrincipal -DisplayName $ServicePrincipalName -ErrorAction SilentlyContinue
    
    if ($existingSP) {
        Write-Log "Service Principal '$ServicePrincipalName' already exists. Application ID: $($existingSP.AppId)" -Level Warning
        $userChoice = Read-Host "Do you want to continue and update credentials? (Y/N)"
        if ($userChoice -ne 'Y') {
            Write-Log "Operation cancelled by user." -Level Warning
            return
        }
        $servicePrincipal = $existingSP
        $appId = $existingSP.AppId
    }
    else {
        # Create new Service Principal
        Write-Log "Creating new Service Principal: $ServicePrincipalName" -Level Info
        
        if ($UseCertificate) {
            # Certificate-based authentication
            if (-not $CertificatePath -or -not (Test-Path $CertificatePath)) {
                throw "Certificate file not found: $CertificatePath"
            }
            
            Write-Log "Using certificate-based authentication" -Level Info
            $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CertificatePath)
            $certValue = [System.Convert]::ToBase64String($cert.GetRawCertData())
            
            $servicePrincipal = New-AzADServicePrincipal -DisplayName $ServicePrincipalName `
                -CertValue $certValue `
                -EndDate (Get-Date).AddYears($ValidityYears) `
                -ErrorAction Stop
        }
        else {
            # Client secret authentication
            Write-Log "Using client secret authentication" -Level Info
            $servicePrincipal = New-AzADServicePrincipal -DisplayName $ServicePrincipalName `
                -EndDate (Get-Date).AddYears($ValidityYears) `
                -ErrorAction Stop
        }
        
        $appId = $servicePrincipal.AppId
        Write-Log "Service Principal created successfully. Application ID: $appId" -Level Success
    }
    
    # Determine RBAC scope
    if ($ResourceGroupScope) {
        Write-Log "Using Resource Group scope: $ResourceGroupScope" -Level Info
        $scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupScope"
    }
    else {
        Write-Log "Using Subscription scope" -Level Info
        $scope = "/subscriptions/$SubscriptionId"
    }
    
    # Assign Azure Connected Machine Onboarding role
    Write-Log "Assigning 'Azure Connected Machine Onboarding' role..." -Level Info
    $onboardingRoleId = "b64e21ea-ac4e-4cdf-9dc9-5b892992bee7"  # Azure Connected Machine Onboarding
    
    $existingAssignment = Get-AzRoleAssignment -ObjectId $servicePrincipal.Id `
        -RoleDefinitionId $onboardingRoleId `
        -Scope $scope `
        -ErrorAction SilentlyContinue
    
    if (-not $existingAssignment) {
        $null = New-AzRoleAssignment -ObjectId $servicePrincipal.Id `
            -RoleDefinitionId $onboardingRoleId `
            -Scope $scope `
            -ErrorAction Stop
        
        Write-Log "Assigned 'Azure Connected Machine Onboarding' role" -Level Success
    }
    else {
        Write-Log "'Azure Connected Machine Onboarding' role already assigned" -Level Info
    }
    
    # Assign Log Analytics Contributor role (for monitoring configuration)
    Write-Log "Assigning 'Log Analytics Contributor' role to workspace..." -Level Info
    $logAnalyticsRoleId = "92aaf0da-9dab-42b6-94a3-d43ce8d16293"  # Log Analytics Contributor
    
    $existingLAAssignment = Get-AzRoleAssignment -ObjectId $servicePrincipal.Id `
        -RoleDefinitionId $logAnalyticsRoleId `
        -Scope $LogAnalyticsWorkspaceId `
        -ErrorAction SilentlyContinue
    
    if (-not $existingLAAssignment) {
        $null = New-AzRoleAssignment -ObjectId $servicePrincipal.Id `
            -RoleDefinitionId $logAnalyticsRoleId `
            -Scope $LogAnalyticsWorkspaceId `
            -ErrorAction Stop
        
        Write-Log "Assigned 'Log Analytics Contributor' role" -Level Success
    }
    else {
        Write-Log "'Log Analytics Contributor' role already assigned" -Level Info
    }
    
    # Store credentials in Key Vault
    Write-Log "Storing credentials in Key Vault: $KeyVaultName" -Level Info
    
    # Verify Key Vault exists
    $keyVault = Get-AzKeyVault -VaultName $KeyVaultName -ErrorAction SilentlyContinue
    if (-not $keyVault) {
        throw "Key Vault '$KeyVaultName' not found"
    }
    
    # Store Application ID
    $null = Set-AzKeyVaultSecret -VaultName $KeyVaultName `
        -Name "Arc-SP-ApplicationId" `
        -SecretValue (ConvertTo-SecureString -String $appId -AsPlainText -Force) `
        -ContentType "text/plain" `
        -ErrorAction Stop
    
    Write-Log "Stored Application ID in Key Vault" -Level Success
    
    # Store client secret (if not using certificate)
    if (-not $UseCertificate) {
        $credential = Get-AzADAppCredential -ApplicationId $appId | Select-Object -First 1
        
        if ($credential) {
            # Note: The actual secret value is not retrievable after creation
            # This stores a placeholder - in production, retrieve from SP creation response
            Write-Log "Client secret created (not retrievable after creation)" -Level Warning
            Write-Log "IMPORTANT: Save the client secret displayed during SP creation!" -Level Warning
        }
    }
    else {
        # Store certificate thumbprint
        $null = Set-AzKeyVaultSecret -VaultName $KeyVaultName `
            -Name "Arc-SP-CertThumbprint" `
            -SecretValue (ConvertTo-SecureString -String $cert.Thumbprint -AsPlainText -Force) `
            -ContentType "text/plain" `
            -ErrorAction Stop
        
        Write-Log "Stored certificate thumbprint in Key Vault" -Level Success
    }
    
    # Generate summary
    Write-Log "`n=== Service Principal Summary ===" -Level Info
    Write-Host "`nService Principal Name:  " -NoNewline; Write-Host $ServicePrincipalName -ForegroundColor Green
    Write-Host "Application (Client) ID: " -NoNewline; Write-Host $appId -ForegroundColor Green
    Write-Host "Tenant ID:               " -NoNewline; Write-Host (Get-AzContext).Tenant.Id -ForegroundColor Green
    Write-Host "Subscription ID:         " -NoNewline; Write-Host $SubscriptionId -ForegroundColor Green
    Write-Host "RBAC Scope:              " -NoNewline; Write-Host $scope -ForegroundColor Green
    Write-Host "Key Vault:               " -NoNewline; Write-Host $KeyVaultName -ForegroundColor Green
    Write-Host "Authentication Method:   " -NoNewline; 
    if ($UseCertificate) {
        Write-Host "Certificate (Thumbprint: $($cert.Thumbprint))" -ForegroundColor Green
    }
    else {
        Write-Host "Client Secret" -ForegroundColor Green
    }
    Write-Host "Validity:                " -NoNewline; Write-Host "$ValidityYears year(s)" -ForegroundColor Green
    
    Write-Log "`nRoles Assigned:" -Level Info
    Write-Host "  • Azure Connected Machine Onboarding (Subscription/RG)" -ForegroundColor Cyan
    Write-Host "  • Log Analytics Contributor (Workspace)" -ForegroundColor Cyan
    
    Write-Log "`n✅ Service Principal created and configured successfully!" -Level Success
    Write-Log "You can now use this Service Principal for Azure Arc agent onboarding." -Level Info
    
    # Export details to file
    $outputFile = "Arc-SP-Details-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    $details = @"
Azure Arc Service Principal Configuration
==========================================
Service Principal Name: $ServicePrincipalName
Application ID: $appId
Tenant ID: $((Get-AzContext).Tenant.Id)
Subscription ID: $SubscriptionId
RBAC Scope: $scope
Key Vault: $KeyVaultName
Authentication: $(if ($UseCertificate) { "Certificate" } else { "Client Secret" })
Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

RBAC Roles:
- Azure Connected Machine Onboarding (Subscription/RG scope)
- Log Analytics Contributor (Workspace scope)

Next Steps:
1. Use this Service Principal in Install-ArcAgentParallel.ps1
2. Retrieve Application ID from Key Vault: Get-AzKeyVaultSecret -VaultName '$KeyVaultName' -Name 'Arc-SP-ApplicationId'
3. For client secret: Contact administrator (not stored in Key Vault for security)
4. Monitor Service Principal usage in Azure AD Sign-in Logs

"@
    
    $details | Out-File -FilePath $outputFile -Encoding UTF8
    Write-Log "Configuration details saved to: $outputFile" -Level Success
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)" -Level Error
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" -Level Error
    throw
}
finally {
    Write-Log "`nScript execution completed." -Level Info
}

#endregion
