# Azure Deployment - AzureQuizLab

Ce dossier contient les fichiers Bicep pour déployer la Web API AzureQuizLab sur Azure.

## Fichiers

- **main.bicep** : Fichier principal de déploiement Bicep
- **parameters.json** : Fichiers de paramètres pour le déploiement

## Architecture

Le déploiement crée les ressources suivantes :

- **App Service Plan** : Plan d'hébergement Linux
- **Web App** : Application Web pour héberger l'API
- **Application Insights** : Monitoring et telemetry
- **Log Analytics Workspace** : Stockage des logs

## Prérequis

- Azure CLI installé
- Un groupe de ressources Azure existant
- Accès au groupe de ressources

## Déploiement

### Option 1 : Avec Azure CLI

```bash
# Se connecter à Azure
az login

# Vérifier le déploiement (optionnel)
az deployment group validate \
  --resource-group <nom-du-groupe> \
  --template-file main.bicep \
  --parameters parameters.json

# Déployer
az deployment group create \
  --resource-group <nom-du-groupe> \
  --template-file main.bicep \
  --parameters parameters.json
```

### Option 2 : Avec PowerShell

```powershell
# Se connecter à Azure
Connect-AzAccount

# Vérifier le déploiement (optionnel)
Test-AzResourceGroupDeployment `
  -ResourceGroupName "<nom-du-groupe>" `
  -TemplateFile "main.bicep" `
  -TemplateParameterFile "parameters.json"

# Déployer
New-AzResourceGroupDeployment `
  -ResourceGroupName "<nom-du-groupe>" `
  -TemplateFile "main.bicep" `
  -TemplateParameterFile "parameters.json"
```

## Paramètres

- **location** : Région Azure (par défaut : location du groupe de ressources)
- **environment** : Environnement de déploiement (dev, staging, prod)
- **appName** : Nom de base pour les ressources
- **skuName** : SKU de l'App Service Plan (B1, B2, B3, S1, etc.)
- **instanceCount** : Nombre d'instances (1 par défaut)

## Sorties

Après un déploiement réussi, vous obtenez :

- **webAppUrl** : URL de la Web API
- **webAppName** : Nom de la Web App
- **appServicePlanName** : Nom du plan d'hébergement
- **appInsightsInstrumentationKey** : Clé Application Insights
- **appInsightsConnectionString** : Chaîne de connexion Application Insights

## Configuration de l'Application

Après le déploiement, configurez les paramètres suivants dans votre application :

1. Mettre à jour `appsettings.json` avec la chaîne de connexion Application Insights
2. Configurer les secrets et variables d'environnement nécessaires
3. Déployer le code de l'application (via GitHub Actions, Azure DevOps, etc.)
