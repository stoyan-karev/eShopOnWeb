param location string
param appName string
param planName string
param serviceName string
param tags object
param useStagingSlot bool = false

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: planName
  location: location
  kind: 'linux'
  tags: tags
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: appName
  location: location
  kind: 'app,linux'
  tags: union(tags, { 'azd-service-name': serviceName })
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
    }
    httpsOnly: true
  }
  
  resource appSettings 'config' = {
    name: 'appsettings'
    properties: {
      UseOnlyInMemoryDatabase: 'true'
    }
  }

  resource stagingSlot 'slots' = if (useStagingSlot) {
    name: 'staging'
    location: location
    tags: tags
    properties: {
      serverFarmId: appServicePlan.id
      siteConfig: {
        linuxFxVersion: 'DOTNETCORE|8.0'
      }
      httpsOnly: true
    }
  }
}

output url string = 'https://${appService.properties.defaultHostName}'
output appServiceId string = appService.id
output appServiceName string = appService.name
