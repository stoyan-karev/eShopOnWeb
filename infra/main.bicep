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
    tags: tags
    appInsightsConnectionString: appInsights.outputs.connectionString
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
