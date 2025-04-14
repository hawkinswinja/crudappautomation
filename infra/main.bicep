@description('Create a resource group for the project')
param ResourceGroupName string
@description('Location for the resource group')
param Location string = 'westus'
@description('admin username of the virtual machine')
param vmUsername string = 'azureuser'
@description('admin password of the virtual machine')
@secure()
param vmPassword string
@description('name of the virtual machine')
param vmName string
@description('size of the virtual machine')
param vmSize string = 'Standard_B2s'

targetScope = 'subscription'

resource deploymentgroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: ResourceGroupName
  location: Location
}


module vnet 'modules/network.bicep' = {
  name: 'vnet'
  scope: resourceGroup(deploymentgroup.name)
  params: {
    VnetName: 'vnet'
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
