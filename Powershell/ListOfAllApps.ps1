# Define your Microsoft Graph API credentials
$clientId = "YOUR_CLIENT_ID"
$clientSecret = "YOUR_CLIENT_SECRET"
$tenantId = "YOUR_TENANT_ID"

# Define the endpoint for Microsoft Graph API
$tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$graphApiUrl = "https://graph.microsoft.com/v1.0"

# Define the scope for accessing Business Central data
$scope = "https://graph.microsoft.com/.default"

# Define the app ID of Business Central
$appId = "YOUR_BUSINESS_CENTRAL_APP_ID"

# Define the function to acquire access token
function Get-AccessToken {
    $body = @{
        client_id     = $clientId
        scope         = $scope
        client_secret = $clientSecret
        grant_type    = "client_credentials"
    }

    $response = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body
    return $response.access_token
}

# Function to get installed apps and their dependencies
function Get-InstalledAppsAndDependencies {
    $accessToken = Get-AccessToken
    $headers = @{
        Authorization = "Bearer $accessToken"
    }

    # Get installed apps in Business Central
    $appsUrl = "$graphApiUrl/applications?$filter=appId eq '$appId'"
    $installedAppsResponse = Invoke-RestMethod -Uri $appsUrl -Headers $headers -Method Get

    # Loop through each installed app
    foreach ($app in $installedAppsResponse.value) {
        Write-Host "Installed App Name: $($app.displayName)"
        Write-Host "App ID: $($app.appId)"
        Write-Host "Publisher: $($app.publisherDisplayName)"

        # Get dependencies of each installed app
        $dependenciesUrl = "$graphApiUrl/applications/$($app.id)/dependencies"
        $dependenciesResponse = Invoke-RestMethod -Uri $dependenciesUrl -Headers $headers -Method Get

        # Loop through dependencies and display their information
        foreach ($dependency in $dependenciesResponse.value) {
            Write-Host "`tDependency Name: $($dependency.displayName)"
            Write-Host "`tDependency ID: $($dependency.appId)"
            Write-Host "`tPublisher: $($dependency.publisherDisplayName)"
        }
        Write-Host ""
    }
}

# Call the function to get installed apps and their dependencies
Get-InstalledAppsAndDependencies
