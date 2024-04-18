param location string
param appName string
param planName string
param allowedOrigins array
param tags object
param appInsightsConnectionString string
@secure()
param identityDbConnectionString string
@secure()
param catalogDbConnectionString string

param keyVaultName string

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: planName
  location: location
  kind: 'linux'
  tags: tags
  sku: {
    name: 'S1'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    reserved: true
  }
}

resource scaleOutRule 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: '${appServicePlan.name}-scale-out'
  location: location
  tags: tags
  properties: {
    targetResourceUri: appServicePlan.id
    enabled: true
    profiles: [
      {
        name: 'Scale In/Out'
        capacity: {
          minimum: '1'
          maximum: '3'
          default: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: appServicePlan.id
              operator: 'GreaterThan'
              threshold: 70
              timeAggregation: 'Average'
              statistic: 'Average'
              timeGrain: 'PT1M'
              timeWindow: 'PT10M'
              dimensions: []
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT10M'
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: appServicePlan.id
              operator: 'LessThan'
              threshold: 30
              timeAggregation: 'Average'
              statistic: 'Average'
              timeGrain: 'PT1M'
              timeWindow: 'PT10M'
              dimensions: []
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT10M'
            }
          }
        ]
      }
    ]
  }
}

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: appName
  location: location
  kind: 'app,linux'
  tags: union(tags, { 'azd-service-name': 'api' })
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      cors: {
        allowedOrigins: allowedOrigins
      }
    }
    httpsOnly: true
  }

  resource appSettings 'config' = {
    name: 'appsettings'
    properties: {
      UseOnlyInMemoryDatabase: 'false'
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
      ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
    }
  }

  resource connectionStrings 'config' = {
    name: 'connectionstrings'
    dependsOn: [keyVault::accessPolicy]
    properties: {
      IdentityConnection: {
        value: identityDbConnectionString
        type: 'SQLAzure'
      }
      CatalogConnection: {
        value: catalogDbConnectionString
        type: 'SQLAzure'
      }
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName

  resource accessPolicy 'accessPolicies' = {
    name: 'add'
    properties: {
      accessPolicies: [
        {
          tenantId: subscription().tenantId
          objectId: appService.identity.principalId
          permissions: {
            secrets: ['get']
          }
        }
      ]
    }
  }
}

output url string = 'https://${appService.properties.defaultHostName}'
output appServiceId string = appService.id
output appServiceName string = appService.name
