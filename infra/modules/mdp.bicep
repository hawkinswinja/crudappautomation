@description('Azure DevOps Organization URL')
param organizationUrl string
@description('Azure DevOps Project Name')
param projectName string
@description('Name of the Dev Center')
param devCenterName string = '${projectName}-devcenter'
@description('Name of the Azure DevOps agent pool')
param agentPoolName string = '${projectName}-agentpool'
param fabricSkuName string = 'Standard_B2ms'
param location string = 'australiaeast'

resource devcenter 'Microsoft.DevCenter/devcenters@2025-02-01' = {
  identity: {
    type: 'SystemAssigned'
  }

  location: location
  name: devCenterName
  properties: {
    devBoxProvisioningSettings: {
      installAzureMonitorAgentEnableStatus: 'Enabled'
    }
    displayName: devCenterName
    networkSettings: {
      microsoftHostedNetworkEnableStatus: 'Enabled'
    }
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: 'Enabled'
    }
  }
}

resource devProject 'Microsoft.DevCenter/projects@2025-02-01' = {
  location: location
  name: projectName
  properties: {

    description: 'project for agent pools'
    devCenterId: devcenter.id
    displayName: projectName
  }

}

resource azdoIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: '${devCenterName}-identity'
  location: location
}

resource azdopool 'Microsoft.DevOpsInfrastructure/pools@2025-01-21' = {
  name: agentPoolName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${azdoIdentity.id}': {}
    }
  }
  properties: {
    agentProfile: {
      resourcePredictionsProfile: {
        kind: 'Automatic'
        predictionPreference: 'Balanced'
      }
      kind: 'Stateless'
      // For remaining properties, see AgentProfile objects
    }
    devCenterProjectResourceId: devProject.id
    fabricProfile: {
      kind: 'Vmss'
      sku: {
        name: fabricSkuName
      }
      images: [
        {
          wellKnownImageName: 'ubuntu-24.04'
        }
      ]
      osProfile: {logonType: 'Service'}
      storageProfile: {osDiskStorageAccountType: 'StandardSSD'}
    }
    maximumConcurrency: 2
    organizationProfile: {
      kind: 'AzureDevOps'
      organizations: [
        {
          openAccess: true
          parallelism: 2
          projects: [
            projectName
          ]
          url: organizationUrl
        }
      ]
      permissionProfile: {
        kind: 'Inherit'
      }
    }
    provisioningState: 'Succeeded'
  }
}

output agentPool string = azdopool.name
