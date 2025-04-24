@description('Create a resource group for the project')
param ResourceGroupName string
@description('Location for the resource group')
param Location string
@description('Name of the AKS cluster')
param aksClusterName string
@description('Enable creation of the container registry')
param acrCreate bool
@description('The name of the Application Gateway')
param appGatewayName string
@description('The name of the Azure Container Registry.')
param acrName string
param servicePrincipalClientId string
@description('The name of the webapp to deploy')
param webAppName string 
@description('The name of the container image to deploy')
param webAppContainerImage string
@description('admin username of the virtual machine')
param vmUsername string = 'azureuser'
@description('admin password of the virtual machine')
@secure()
param vmPassword string
@description('name of the virtual machine')
param vmName string
@description('size of the virtual machine')
param vmSize string = 'Standard_D2s_v3'



targetScope = 'subscription'

resource deploymentgroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: ResourceGroupName
  location: Location
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
    appGatewayId:''
    // appGatewayId: appgw.outputs.appGatewayId
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

module vm 'modules/vm.bicep' = {
  name: vmName
  scope: resourceGroup(deploymentgroup.name)
  params: {
    adminPassword: vmPassword 
    adminUsername: vmUsername
    nsgID: vnet.outputs.nsgID
    subnetID: vnet.outputs.publicsubnetID
    vmName: vmName
    vmSize: vmSize
  }
}

output vmPublicIp string = vm.outputs.publicIp
output KeyvaultProfileClientId string = aks.outputs.addonKeyvaultClientId
