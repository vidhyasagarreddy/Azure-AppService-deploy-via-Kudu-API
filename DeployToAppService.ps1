# Username and Password to deploy ZIP - you can use FTP credentials
$username = "<username>"
$password = "<password>"

# Convert credentials to Base64
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))

$userAgent = "powershell/1.0"

# Kudu endpoint to deploy ZIP Package
# <app-service-scm-path> - Kudu/SCM path of AppService; eg: sagar.scm(.azurewebsites.net)
$apiUrl = "https://<app-service-scm-path>.azurewebsites.net/api/zipdeploy?isAsync=true"

# Search for Deployment package (.zip) 
# <path/folder-to-search-for-zip> - Folder to search for ZIP package; eg: C:\Users\Sagar(\Deployment\Packages\sagar.zip)
$deploymentFiles = Get-ChildItem -Path "<path/folder-to-search-for-zip>" -Include "*.zip" -Recurse

# Select appropriate ZIP package; assumption here is, I have only one package
$deploymentFile = $deploymentFiles[0].FullName

# Call the Endpoint Above with all parameters to deploy the package
# ContentType is: "content/zip" and not "multipart/form-data" as there's an issue with Kudu services of AppService for Linux(https://github.com/Azure-App-Service/KuduLite/issues/70), which doesn't work with "multipart/form-data". You can use latter one for AppService for Windows
Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -UserAgent $userAgent -Method "POST" -InFile $deploymentFile -ContentType "content/zip"