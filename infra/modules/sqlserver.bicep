param dbUserName string = 'azureuser'
@secure()
param dbPassword string
@description('The list of database names to create in the SQL server.')
param dbNames array


resource sqlserver 'Microsoft.Sql/servers@2024-05-01-preview' = {
  location: resourceGroup().location
  name: 'sqlsrv-${uniqueString(resourceGroup().id)}'
  properties: {
    administratorLogin: dbUserName
    administratorLoginPassword: dbPassword
  }
}

resource symbolicname 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: sqlserver
  name: 'AllowAllIps'
  properties: {
    endIpAddress: '255.255.255.255'
    startIpAddress: '0.0.0.0'
  }
}

resource database 'Microsoft.Sql/servers/databases@2024-05-01-preview' = [for dbName in dbNames: {
  name: dbName
  parent: sqlserver
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
}]

output sqlServerurl string = sqlserver.properties.fullyQualifiedDomainName
