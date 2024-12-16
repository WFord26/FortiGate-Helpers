function Get-MicrosoftAddressListForFortiGate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("USGovGCCHigh", "China", "Worldwide", "USGovDoD", "Germany")]
        [string]$site
    )
    $site = $site.ToLower()
    # Path to download location
    $downloadPath = "C:\temp"
    $fileName = "MSAddresses-$site.json"
    
    # Get Client Request ID
    $clientRequestID = New-Guid
    
    # Download the Microsoft IP and URL address ranges JSON file
    $uri = "https://endpoints.office.com/endpoints/$site"+"?clientrequestid=$clientRequestID"
    Invoke-WebRequest -Uri $uri -OutFile "$downloadPath\$fileName"
    
    # Read the JSON file
    $jsonFilePath = "$downloadPath\$fileName"
    $jsonContent = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json
    
    # Initialize an array to store the FortiGate CLI commands
    $fortiGateCommands = @()
    
    
    
    # Loop through each service area in the JSON
    foreach ($service in $jsonContent) {
        $serviceName = $service.serviceAreaDisplayName -replace ' ', '_'
        $fortiGateCommands += Write-IpAddressObjects -serviceName $serviceName -ips $service.ips
        $fortiGateCommands += Write-UrlAddressObjects -serviceName $serviceName -urls $service.urls
        $fortiGateCommands += Write-AddressGroups -serviceName $serviceName -ipAddresses $service.ips -urls $service.urls
    }
    
    # Output the FortiGate CLI commands to a file
    $outputFilePath = "C:\temp\"+"$site - Microsoft Address Objects.conf"
    $fortiGateCommands | Out-File -FilePath $outputFilePath -Encoding ASCII
    
    # Output the result
    Write-Output "FortiGate CLI commands have been generated successfully."
    Write-Output "The commands have been saved to $outputFilePath."
}