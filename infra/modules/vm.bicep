@description('Location for all resources')
param location string = resourceGroup().location

@description('Name of the virtual machine')
param vmName string = 'AZDO-VM'

@description('Admin username for the VM')
param adminUsername string = 'azureuser'

@secure()
@description('Admin password for the VM')
param adminPassword string

@description('VM size')
param vmSize string

@description('Ubuntu Image version')
param VmImage object = {
  publisher: 'Canonical'
  offer: 'ubuntu-24_04-lts'
  sku: 'server'
  version: 'latest'
}
@description('subnet id to place the vm')
param subnetID string
@description('NSG id to attach to the vm')
param nsgID string

var nicName = '${vmName}-nic'
var publicIpName = '${vmName}-pip'


resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetID
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgID
    }
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: VmImage.publisher
        offer: VmImage.offer
        sku: VmImage.sku
        version: VmImage.version
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}


output publicIp string = publicIP.properties.ipAddress
