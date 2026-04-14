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

@description('SQL Server admin password')
@minLength(8)
param sqlAdminPassword string

@description('Aad Admin Login')
param aadAdminLogin string

@description('Aad Admin Object Id')
param aadAdminObjectId string

// Naming convention
var sqlDatabaseName = '${appName}-db-${environment}'
var sqlAdminUsername = 'dbserveradmin'

// Storage module (SQL Server and Database)
module storage 'storage.bicep' = {
  name: 'storage-deployment'
  params: {
    location: 'francecentral' //location
    tags: tags
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPassword: sqlAdminPassword
    sqlDatabaseName: sqlDatabaseName
    aadAdminLogin: aadAdminLogin
    aadAdminObjectId: aadAdminObjectId
    sqlEdition: 'Basic'
  }
}

// Web App module
module webApp 'webApp.bicep' = {
  name: 'webApp-deployment'
  params: {
    location: location
    environment: environment
    appName: appName
    appServicePlanName: appServicePlanName
    skuName: skuName
    linuxFxVersion: linuxFxVersion
    instanceCount: instanceCount
    tags: tags
    connectionString: 'Server=tcp:${storage.outputs.sqlServerFullyQualifiedDomainName},1433;Initial Catalog=${storage.outputs.sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdminUsername};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
  }
}

// Outputs
output webAppUrl string = webApp.outputs.webAppUrl
output webAppName string = webApp.outputs.webAppName
output appServicePlanName string = webApp.outputs.appServicePlanName
output sqlServerName string = storage.outputs.sqlServerName
output sqlServerFqdn string = storage.outputs.sqlServerFullyQualifiedDomainName
output sqlDatabaseName string = storage.outputs.sqlDatabaseName
