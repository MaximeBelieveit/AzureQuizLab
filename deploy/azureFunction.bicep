@description('Location for Azure resources')
param location string = resourceGroup().location

@description('Environment name')
param environment string

@description('Application name')
param functionName string

@description('Tags for resources')
param tags object = {}

@description('SQL Server connection string')
param sqlConnectionString string

// Variables
var functionAppName = 'func-${functionName}-${environment}'
var storageAccountName = 'st${replace(functionName, '-', '')}${environment}'
var functionAppServicePlanName = 'asp-func-${functionName}'

// Storage Account for Function App runtime
resource storageAccount 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: toLower(take(storageAccountName, 24))
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Enabled'
  }
  tags: tags
}

var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'

// App Service Plan for Function App
resource appServicePlan 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: functionAppServicePlanName
  location: location
  tags: tags
   sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  kind: 'functionapp'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
    asyncScalingEnabled: false
  }
}

// Function App
resource functionApp 'Microsoft.Web/sites@2024-11-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      use32BitWorkerProcess: false
      linuxFxVersion: 'DOTNETCORE|10.0'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageConnectionString
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: storageConnectionString
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'SqlConnectionString'
          value: sqlConnectionString
        }
      ]
    }
    httpsOnly: true
  }
  tags: tags
}

// Outputs
output functionAppId string = functionApp.id
output functionAppName string = functionApp.name
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output appServicePlanId string = appServicePlan.id
