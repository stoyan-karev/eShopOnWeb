param location string = resourceGroup().location
param name string
param tags object
param serverName string
param keyVaultName string

@secure()
param adminLogin string
@secure()
param adminPassword string

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

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName

  resource secret 'secrets' = {
    name: '${name}-connection-string'
    properties: {
      value: 'Server=${server.properties.fullyQualifiedDomainName}; Database=${server::database.name}; User=${adminLogin}; Password=${adminPassword};'
    }
  }
}

// resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
//   name: '${name}-connection-string'
//   parent: keyVault
//   properties: {
//     value: 'Server=${server.properties.fullyQualifiedDomainName}; Database=${server::database.name}; User=${adminLogin}; Password=${adminPassword};'
//   }
// }

output name string = server::database.name
output connectionStringKeyVaultRef string = '@Microsoft.KeyVault(SecretUri=${keyVault::secret.properties.secretUriWithVersion})'
