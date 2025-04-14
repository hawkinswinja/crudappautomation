param VnetName string = '${resourceGroup().name}-vnet-${resourceGroup().location}'
param VnetAddressPrefix string = '10.0.0.0/16'
param subnets object = {
  privatesubnet: {
    addressprefix: '10.0.4.0/24'
    public: false
  }
  publicsubnet: {
    addressprefix: '10.0.5.0/24'
    public: true
  }
}

var location = resourceGroup().location


resource privateNSG 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'private-${VnetName}-nsg'
  location: location
  properties: {
    securityRules: []
  }
}

resource publicNSG 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'public-${VnetName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowInternetInbound'
        properties: {
          priority: 300
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: VnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        VnetAddressPrefix
      ]
    }
    subnets: [for subnet in items(subnets): {
        name: subnet.key
        properties: {
          addressPrefix: subnet.value.addressprefix
          networkSecurityGroup: subnet.value.public ? {
            id: publicNSG.id
          } : {
            id: privateNSG.id
          }
        }
      }
    ]
  }
}


output publicsubnetID string = vnet.properties.subnets[1].id
output privatesubnetID string = vnet.properties.subnets[0].id
output nsgID string = publicNSG.id
