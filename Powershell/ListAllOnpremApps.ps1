# Import the Business Central Administration Shell module
Import-Module "C:\Program Files\Microsoft Dynamics 365 Business Central\140\Service\NavAdminTool.ps1"

# Set the Business Central Server instance details
$ServerInstance = "BC230"
$ServerName = "http://localhost"
$ServerPort = 1046

# Connect to the Business Central Server instance using Windows authentication
Connect-BCInstance -ServerInstance $ServerInstance -Server $ServerName -Port $ServerPort -Credential  -UseWindowsAuthentication

# Get information on installed apps and their dependencies
$appsInfo = Get-NAVAppInfo

# Output the information
foreach ($app in $appsInfo) {
    Write-Host "App Name: $($app.Name)"
    Write-Host "Publisher: $($app.Publisher)"
    Write-Host "Version: $($app.Version)"
    Write-Host "Dependencies: $($app.Dependencies)"
    Write-Host ""
}

# Disconnect from the Business Central Server instance
#Disconnect-BCInstance
