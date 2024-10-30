param projectName string = 'weatherapi'       // Base name for your resources
param location string = 'eastus'              // Azure region
param skuName string = 'F1'                   // F1 is free tier
param skuTier string = 'Free'                 // Free tier for testing

// App Service Plan (this is your server)
resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${projectName}-plan'                 // This will be weatherapi-plan
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    reserved: false                           // False for Windows, True for Linux
  }
}

// Application Insights (for monitoring)
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${projectName}-insights'             // This will be weatherapi-insights
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    DisableIpMasking: false
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Web App (this hosts your API)
resource webApp 'Microsoft.Web/sites@2021-03-01' = {
  name: '${projectName}-app'                  // This will be weatherapi-app
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      netFrameworkVersion: 'v7.0'            // Matches your local .NET version
      appSettings: [
        {
          // Connects Application Insights to your Web App
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          // Ensures proper logging
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
      ]
    }
  }
}

// Outputs - these will be displayed after deployment
output webappName string = webApp.name
output webappUrl string = 'https://${webApp.properties.defaultHostName}'
output appInsightsKey string = appInsights.properties.InstrumentationKey
