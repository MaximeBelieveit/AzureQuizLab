@description('Localisation des ressources')
param location string = resourceGroup().location

@allowed([
  'Development'
  'PreProduction'
  'Production'
])
param environment string = 'Development'

@description('Nom de l\'application')
param appName string = 'azurequizlab'

@description('Nom du service plan')
param appServicePlanName string = 'asp-${appName}'

@description('SKU du service plan')
@allowed([
  'F1' // Free
  'B1' // Basic
  'B2'
  'B3'
  'S1' // Standard
  'S2'
  'S3'
  'P1v2' // Premium V2
  'P2v2'
  'P3v2'
])
param skuName string = 'F1'

@description('Runtime stack de l\'application')
@allowed([
  'DOTNETCORE|10.0'
  'DOTNETCORE|8.0'
])
param linuxFxVersion string = 'DOTNETCORE|10.0'

@allowed([1])
param instanceCount int = 1

@description('Tags à appliquer sur les ressources')
param tags object = {
  env: 'formation'
  owner: 'msublet'
}

@description('Connection string pour la base de données')
param connectionString string

// Naming convention
var webAppName = '${appName}-${environment}'
var appServicePlanNameFinalName = '${appServicePlanName}-${environment}'

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: appServicePlanNameFinalName
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: skuName
    capacity: instanceCount
  }
  tags: tags
}

// Web App
resource webApp 'Microsoft.Web/sites@2024-11-01' = {
  name: webAppName
  location: location
  tags: tags
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: appServicePlan.id
    reserved: true
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: skuName != 'F1'
      http20Enabled: false
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: environment
        }
        {
          name: 'ConnectionStrings__DefaultConnection'
          value: connectionString
        }
      ]
    }
    httpsOnly: true
    clientCertMode: 'Required'
    ipMode: 'IPv4'
  }
}

// Outputs
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output webAppName string = webApp.name
output appServicePlanName string = appServicePlan.name
