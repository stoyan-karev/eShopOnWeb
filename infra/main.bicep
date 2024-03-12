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

var abbrs = loadJsonContent('./abbreviations.json')
var tags = { 'azd-env-name': environmentName }

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'eShopOnWeb-${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
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
    location: secondaryLocation
    appName: 'sk-${abbrs.webSitesAppService}api-${environmentName}'
    planName: '${abbrs.webServerFarms}api-${environmentName}'
    allowedOrigins: [
      webPrimary.outputs.url
      webSecondary.outputs.url
      trafficManager.outputs.trafficManagerUrl
    ]
    tags: tags
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
