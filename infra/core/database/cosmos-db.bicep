param accountName string
param databaseName string
param tags object

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' existing = {
  name: accountName

  resource database 'sqlDatabases' = {
    name: databaseName
    tags: tags
    properties: {
      resource: {
        id: databaseName
      }
      options: {
        throughput: 1000
      }
    }
  }
}

// TODO: Store connection string in KeyVault
#disable-next-line outputs-should-not-contain-secrets
output connectionString string = cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString
