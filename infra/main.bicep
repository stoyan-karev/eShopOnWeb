targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@minLength(1)
@description('Secondary location for all resources')
param secondaryLocation string

@description('Enable web staging slot for the primary web app')
param useWebStagingSlot bool = false

@secure()
param sqlAdminLogin string

@secure()
param sqlAdminPassword string

param principalId string

var abbrs = loadJsonContent('./abbreviations.json')
var tags = { 'azd-env-name': environmentName }

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'eShopOnWeb-${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

module logWorkspace 'core/monitoring/log-workspace.bicep' = {
  name: 'logWorkspace'
  scope: rg
  params: {
    location: location
    name: 'sk-${abbrs.operationalInsightsWorkspaces}${environmentName}'
    tags: tags
  }
}

module keyVault 'core/security/keyvault.bicep' = {
  name: 'keyVault'
  scope: rg
  params: {
    location: location
    name: 'sk-${abbrs.keyVaultVaults}${environmentName}'
    tags: tags
    principalId: principalId
  }
}

module appInsights 'core/monitoring/application-insights.bicep' = {
  name: 'appInsights'
  scope: rg
  params: {
    location: location
    name: 'sk-${abbrs.insightsComponents}${environmentName}'
    tags: tags
    workspaceId: logWorkspace.outputs.workspaceId
  }
}

module storage 'core/storage/storage-account.bicep' = {
  name: 'storage'
  scope: rg
  params: {
    location: location
    name: 'sk${abbrs.storageStorageAccounts}${environmentName}'
    tags: tags
  }
}

module cosmosAccount 'core/database/cosmos-account.bicep' = {
  name: 'cosmosDbAccount'
  scope: rg
  params: {
    location: location
    name: 'sk-${abbrs.documentDBDatabaseAccounts}${environmentName}'
    tags: tags
  }
}

module deliveryOrdersDb 'core/database/cosmos-db.bicep' = {
  name: 'deliveryOrdersDb'
  scope: rg
  params: {
    accountName: cosmosAccount.outputs.name
    databaseName: 'DeliveryOrders'
    tags: tags
  }
}

module functionApp 'core/host/functions.bicep' = {
  name: 'functionApp'
  scope: rg
  params: {
    location: location
    serviceName: 'functions'
    name: 'sk-${abbrs.webSitesFunctions}${environmentName}'
    keyVaultName: keyVault.outputs.name
    applicationInsightsConnection: appInsights.outputs.connectionString
    storageAccountConnection: storage.outputs.connectionString
    deliveryOrdersDbConnectionString: deliveryOrdersDb.outputs.connectionString
    orderItemsQueueConnection: orderItemsQueue.outputs.listenConnectionString
    tags: tags
  }
}

module sqlServer 'core/database/sql-server.bicep' = {
  name: 'sqlServer'
  scope: rg
  params: {
    location: location
    name: 'sk-${abbrs.sqlServers}${environmentName}'
    adminLogin: sqlAdminLogin
    adminPassword: sqlAdminPassword
    tags: tags
  }
}

module catalogDb 'core/database/sql-database.bicep' = {
  name: 'catalogDb'
  scope: rg
  params: {
    location: location
    serverName: sqlServer.outputs.name
    name: 'Catalog'
    tags: tags
    adminLogin: sqlAdminLogin
    adminPassword: sqlAdminPassword
    keyVaultName: keyVault.outputs.name
  }
}

module identityDb 'core/database/sql-database.bicep' = {
  name: 'identityDb'
  scope: rg
  params: {
    location: location
    serverName: sqlServer.outputs.name
    name: 'Identity'
    tags: tags
    adminLogin: sqlAdminLogin
    adminPassword: sqlAdminPassword
    keyVaultName: keyVault.outputs.name
  }
}

module serviceBusNamespace 'core/service-bus/namespace.bicep' = {
  name: 'serviceBusNamespace'
  scope: rg
  params: {
    location: location
    name: 'sk-${abbrs.serviceBusNamespaces}${environmentName}'
    tags: tags
  }
}

module orderItemsQueue 'core/service-bus/order-items-queue.bicep' = {
  name: 'orderItemsQueue'
  scope: rg
  params: {
    serviceBusNamespace: serviceBusNamespace.outputs.name
    name: 'order-items'
    keyVaultName: keyVault.outputs.name
  }
}

module webPrimary 'core/host/web.bicep' = {
  name: 'webPrimary'
  scope: rg
  params: {
    location: location
    appName: 'sk-${abbrs.webSitesAppService}web-primary-${environmentName}'
    planName: '${abbrs.webServerFarms}web-primary-${environmentName}'
    serviceName: 'web'
    tags: tags
    useStagingSlot: useWebStagingSlot
    orderItemsQueueConnection: orderItemsQueue.outputs.sendConnectionString
    orderItemsQueueName: orderItemsQueue.outputs.name
    deliveryOrderProcessorUrl: functionApp.outputs.url
    deliveryOrderProcessorApiCode: functionApp.outputs.accessKey
    applicationInsightsConnection: appInsights.outputs.connectionString
    identityDbConnectionString: identityDb.outputs.connectionStringKeyVaultRef
    catalogDbConnectionString: catalogDb.outputs.connectionStringKeyVaultRef
    keyVaultName: keyVault.outputs.name
  }
}

module webSecondary 'core/host/web.bicep' = {
  name: 'webSecondary'
  scope: rg
  params: {
    location: secondaryLocation
    appName: 'sk-${abbrs.webSitesAppService}web-secondary-${environmentName}'
    planName: '${abbrs.webServerFarms}secondary-${environmentName}'
    serviceName: 'webSecondary'
    tags: tags
    orderItemsQueueConnection: orderItemsQueue.outputs.sendConnectionString
    orderItemsQueueName: orderItemsQueue.outputs.name
    deliveryOrderProcessorUrl: functionApp.outputs.url
    deliveryOrderProcessorApiCode: functionApp.outputs.accessKey
    applicationInsightsConnection: appInsights.outputs.connectionString
    identityDbConnectionString: identityDb.outputs.connectionStringKeyVaultRef
    catalogDbConnectionString: catalogDb.outputs.connectionStringKeyVaultRef
    keyVaultName: keyVault.outputs.name
  }
}

module api 'core/host/api.bicep' = {
  name: 'api'
  scope: rg
  params: {
    location: location
    appName: 'sk-${abbrs.webSitesAppService}api-${environmentName}'
    planName: '${abbrs.webServerFarms}api-${environmentName}'
    allowedOrigins: [
      webPrimary.outputs.url
      webSecondary.outputs.url
      trafficManager.outputs.trafficManagerUrl
    ]
    identityDbConnectionString: identityDb.outputs.connectionStringKeyVaultRef
    catalogDbConnectionString: catalogDb.outputs.connectionStringKeyVaultRef
    tags: tags
    appInsightsConnectionString: appInsights.outputs.connectionString
    keyVaultName: keyVault.outputs.name
  }
}

module trafficManager 'core/network/traffic-manager.bicep' = {
  name: 'trafficManager'
  scope: rg
  params: {
    name: 'sk-${abbrs.networkTrafficManagerProfiles}${environmentName}'
    endpointResourceIds: [
      webPrimary.outputs.appServiceId
      webSecondary.outputs.appServiceId
    ]
    tags: tags
  }
}

output trafficManagerUrl string = trafficManager.outputs.trafficManagerUrl
output apiUrl string = api.outputs.url