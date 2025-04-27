@description('Create a resource group for the project')
param ResourceGroupName string
@description('Location for the resource group')
param Location string
@description('Name of the AKS cluster')
param aksClusterName string
@description('Enable creation of the container registry')
param acrCreate bool
@description('The name of the Azure Container Registry.')
param acrName string
param servicePrincipalClientId string
@description('The name of the webapp to deploy')
param webAppName string 
@description('The name of the container image to deploy')
param webAppContainerImage string
@description('The Azure DevOps project to create an agent pool')
param azdoProject string
@description('The url of the Azure DevOps organization')
param azdoUrl string
param dbUserName string = 'azureuser'
@secure()
param dbPassword string
@description('The list of database names to create in the SQL server.')
param dbNames array = [
  'crud'
  'auth'
]


var appGatewayName = 'appgw-${aksClusterName}'

targetScope = 'subscription'

resource deploymentgroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: ResourceGroupName
  location: Location
}

resource azdoGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${ResourceGroupName}-azdo'
  location: Location
}

module mdp 'modules/mdp.bicep' = {
  name: 'azdo'
  scope: resourceGroup(azdoGroup.name)
  params: {
    projectName: azdoProject
    organizationUrl: azdoUrl
  }
}


module vnet 'modules/network.bicep' = {
  name: 'vnet'
  scope: resourceGroup(deploymentgroup.name)
}

module appgw 'modules/appgw.bicep' = {
  name: 'appgw'
  scope: resourceGroup(deploymentgroup.name)
  params: {
    applicationGatewayName: appGatewayName
    applicationGatewaySubnetId: vnet.outputs.publicsubnetID
  }
}

module aks 'modules/aks.bicep' = {
  name: 'aks'
  scope: resourceGroup(deploymentgroup.name)
  params: {
    appGatewayId: appgw.outputs.appGatewayId
    aksSubnetId: vnet.outputs.akssubnetID
    aksClusterName: aksClusterName
    acrCreate: acrCreate
    acrName: acrName
    servicePrincipalClientId: servicePrincipalClientId
  }
}

module webapp 'modules/appservice.bicep' = {
  scope: resourceGroup(deploymentgroup.name)
  name: 'webapp'
  params: {
    appServicePlanName: '${aksClusterName}-appserviceplan'
    appSubnetID: vnet.outputs.webAppSubnetID
    appServicePlanSku: {
      name: 'P1v3'
      tier: 'PremiumV3'
      size: 'P1v3'
      capacity: 1
    }
    containerImage: webAppContainerImage
    registryId: aks.outputs.acrId
    registry: aks.outputs.acrUrl
    webAppName: webAppName
  }
}

module sql 'modules/sqlserver.bicep' = {
  name: 'sqlserver'
  scope: resourceGroup(deploymentgroup.name)
  params: {
    dbPassword: dbPassword
    dbUserName: dbUserName
    dbNames: dbNames
  }
}
