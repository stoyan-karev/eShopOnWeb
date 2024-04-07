param location string = resourceGroup().location
param name string
param tags object
param serverName string

resource server 'Microsoft.Sql/servers@2023-08-01-preview' existing = {
  name: serverName

  resource database 'databases' = {
    name: name
    location: location
    tags: tags
    sku: {
      name: 'Basic'
      tier: 'Basic'
    }
    properties: {
      collation: 'SQL_Latin1_General_CP1_CI_AS'
    }
  }
}

output name string = server::database.name
