@description('Localisation des ressources')
param location string = resourceGroup().location
param environment string = 'dev'

@description('Nom du service plan')
param appServicePlanName string = 'asp-${uniqueString(resourceGroup().id)}'

@description('Nom du service plan')
param appName string = 'azurequizlab'
@description('SKU du service plan')
@allowed([
  'F1'  // Free
  'B1'  // Basic
  'B2'
  'B3'
  'S1'  // Standard
  'S2'
  'S3'
  'P1v2'  // Premium V2
  'P2v2'
  'P3v2'
])
param skuName string = 'F1'

@description('Runtime stack de l\'application')
@allowed([
  'DOTNET|10.0'
  'DOTNET|8.0'
  'DOTNET|6.0'
])
param linuxFxVersion string = 'DOTNET|10.0'
param instanceCount int = 1

// Naming convention
var webAppName = '${appName}-api-${environment}'


// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: skuName
    capacity: instanceCount
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: skuName != 'F1'
      http20Enabled: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ENVIRONMENT'
          value: environment
        }
      ]
    }
    httpsOnly: true
  }
}
// Web App diagnostic settings

output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output webAppName string = webApp.name
output appServicePlanName string = appServicePlan.name
