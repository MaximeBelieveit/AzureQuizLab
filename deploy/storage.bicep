@description('Localisation des ressources')
param location string = resourceGroup().location

@description('Tags à appliquer sur les ressources')
param tags object = {
  env: 'formation'
  owner: 'msublet'
}

@description('SQL Server admin username')
param sqlAdminUsername string = 'dbserveradmin'

@description('SQL Server admin password')
@minLength(8)
@secure()
param sqlAdminPassword string

@description('SQL Database name')
param sqlDatabaseName string = 'azurequizlab-db'

@description('SQL Server edition')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sqlEdition string = 'Basic'

// Variables
var sqlServerName = 'sqlsrv-${sqlDatabaseName}'

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-08-01' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

// Firewall rule - Allow Azure Services
resource sqlFirewallAzure 'Microsoft.Sql/servers/firewallRules@2023-08-01' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  tags: tags
  sku: {
    name: sqlEdition
    tier: sqlEdition
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: sqlEdition == 'Basic' ? 2147483648 : sqlEdition == 'Standard' ? 268435456000 : 1099511627776
  }
}

// Outputs
output sqlServerName string = sqlServer.name
output sqlServerFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
output sqlDatabaseName string = sqlDatabase.name
