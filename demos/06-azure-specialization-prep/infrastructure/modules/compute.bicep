// compute.bicep - Compute Infrastructure Module
// Purpose: Deploys Windows Server VMs with IIS and monitoring extensions

targetScope = 'resourceGroup'

// ============================================
// PARAMETERS
// ============================================

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Environment name (dev, staging, prod)')
@allowed([
  'dev'
  'staging'
  'prod'
])
param environment string = 'prod'

@description('Administrator username for VMs')
param adminUsername string

@description('Administrator password for VMs')
@secure()
param adminPassword string

@description('VM size for web servers')
param vmSize string = 'Standard_D2s_v3'

@description('Number of VMs to deploy')
@minValue(2)
@maxValue(4)
param vmCount int = 2

@description('Web subnet resource ID')
param subnetId string

@description('Log Analytics workspace resource ID for monitoring')
param logAnalyticsWorkspaceId string

@description('Common tags applied to all resources')
param tags object

// ============================================
// VARIABLES
// ============================================

var availabilitySetName = 'avail-web-${environment}'
var vmNamePrefix = 'vm-web'
var nicNamePrefix = 'nic-web'
var osDiskPrefix = 'osdisk-web'

// IIS Installation Script
var customScriptContent = '''
# Install IIS with ASP.NET
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Install-WindowsFeature -Name Web-Asp-Net45
Install-WindowsFeature -Name Web-Mgmt-Console

# Create Application Pool
Import-Module WebAdministration
New-WebAppPool -Name 'TaskManagerPool'
Set-ItemProperty IIS:\AppPools\TaskManagerPool -name processModel.identityType -value 2

# Create Application Directory
New-Item -Path 'C:\inetpub\wwwroot\TaskManager' -ItemType Directory -Force

# Create a simple default page
$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Task Manager - Server $env:COMPUTERNAME</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
        .container { background: rgba(255,255,255,0.1); padding: 40px; border-radius: 10px; backdrop-filter: blur(10px); }
        h1 { font-size: 48px; margin-bottom: 20px; }
        .status { background: rgba(0,255,0,0.2); padding: 20px; border-radius: 5px; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Task Manager Application</h1>
        <p>Server: <strong>$env:COMPUTERNAME</strong></p>
        <p>IIS is running successfully!</p>
        <div class="status">
            <p>✓ Application Ready for Deployment</p>
            <p>Deploy the TaskManager.Web application to this directory</p>
        </div>
    </div>
</body>
</html>
"@

$html | Out-File -FilePath 'C:\inetpub\wwwroot\TaskManager\index.html' -Encoding UTF8

# Configure IIS Site
Remove-WebSite -Name 'Default Web Site' -ErrorAction SilentlyContinue
New-WebSite -Name 'TaskManager' -PhysicalPath 'C:\inetpub\wwwroot\TaskManager' -ApplicationPool 'TaskManagerPool' -Port 80

# Enable detailed logging
Set-WebConfigurationProperty -PSPath 'IIS:\Sites\TaskManager' -Filter 'system.webServer/httpLogging' -Name 'dontLog' -Value $false

# Configure Windows Firewall
New-NetFirewallRule -DisplayName "Allow HTTP" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow HTTPS" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow

Write-Host "IIS configuration completed successfully on $env:COMPUTERNAME"
'''

// ============================================
// RESOURCES
// ============================================

// Availability Set for VMs (99.95% SLA)
resource availabilitySet 'Microsoft.Compute/availabilitySets@2023-03-01' = {
  name: availabilitySetName
  location: location
  tags: tags
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 5
  }
}

// Network Interfaces (loop for multiple VMs)
resource networkInterfaces 'Microsoft.Network/networkInterfaces@2023-05-01' = [for i in range(0, vmCount): {
  name: '${nicNamePrefix}${padLeft(i + 1, 2, '0')}-${environment}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}]

// Virtual Machines (loop for multiple VMs)
resource virtualMachines 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, vmCount): {
  name: '${vmNamePrefix}${padLeft(i + 1, 2, '0')}-${environment}'
  location: location
  tags: tags
  properties: {
    availabilitySet: {
      id: availabilitySet.id
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${osDiskPrefix}${padLeft(i + 1, 2, '0')}-${environment}'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        diskSizeGB: 128
        caching: 'ReadWrite'
      }
    }
    osProfile: {
      computerName: 'TASKWEB${padLeft(i + 1, 2, '0')}'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
        }
        timeZone: 'Eastern Standard Time'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces[i].id
          properties: {
            primary: true
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    licenseType: 'Windows_Server'
  }
}]

// Custom Script Extension for IIS Installation
resource iisExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = [for i in range(0, vmCount): {
  name: 'InstallIIS'
  parent: virtualMachines[i]
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -Command "${customScriptContent}"'
    }
  }
}]

// Azure Monitor Agent Extension
resource monitoringExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = [for i in range(0, vmCount): {
  name: 'AzureMonitorWindowsAgent'
  parent: virtualMachines[i]
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
  dependsOn: [
    iisExtension[i]
  ]
}]

// ============================================
// OUTPUTS
// ============================================

@description('Array of VM resource IDs')
output vmIds array = [for i in range(0, vmCount): virtualMachines[i].id]

@description('Array of VM names')
output vmNames array = [for i in range(0, vmCount): virtualMachines[i].name]

@description('Array of private IP addresses')
output privateIpAddresses array = [for i in range(0, vmCount): networkInterfaces[i].properties.ipConfigurations[0].properties.privateIPAddress]

@description('Availability set resource ID')
output availabilitySetId string = availabilitySet.id

@description('Array of network interface resource IDs')
output networkInterfaceIds array = [for i in range(0, vmCount): networkInterfaces[i].id]
