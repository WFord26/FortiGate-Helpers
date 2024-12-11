<#
.SYNOPSIS
    This script downloads the Microsoft IP and URL address ranges JSON file and generates FortiGate CLI commands to create address objects.
.DESCRIPTION
    This script downloads the Microsoft IP and URL address ranges JSON file and generates FortiGate CLI commands to create address objects.
    The script uses the Invoke-WebRequest cmdlet to download the JSON file from the Microsoft site.
    The script then reads the JSON file and loops through each service area to create IP and URL address objects.
    The script uses the Out-File cmdlet to output the FortiGate CLI commands to a file.
    The script requires the site parameter to specify the Microsoft site to download the address ranges from.
    The available options are:
    - USGovGCCHigh
    - China
    - Worldwide
    - USGovDoD
    - Germany
    The script also includes functions to create IP and URL address objects for FortiGate.
    The Create-IP-AddressObjects function creates IP address objects with the specified IP addresses.
    The Create-URL-AddressObjects function creates URL address objects with the specified URLs.
    The Get-MicrosoftAddressListForFortiGate function downloads the Microsoft IP and URL address ranges JSON file and generates FortiGate CLI commands to create address objects.
    The function takes the site parameter as input to specify the Microsoft site to download the address ranges from.
    The function outputs the FortiGate CLI commands to a file and displays a success message.

.PARAMETER site
    The Microsoft site to download the address ranges from. The available options are:
    - USGovGCCHigh
    - China
    - Worldwide
    - USGovDoD
    - Germany
.EXAMPLE
    Get-MicrosoftAddressListForFortigate -site "Worldwide"
    This example downloads the Microsoft IP and URL address ranges JSON file for the Worldwide site and generates FortiGate CLI commands to create address objects.
    The FortiGate CLI commands are output to a file and a success message is displayed.
.NOTES
    File Name      : Set-MicrosoftAddressObjects.ps1
    Author         : William Ford
    Prerequisite   : PowerShell V2
#>
function Create-IP-AddressObjects {
    param (
        [string]$serviceName,
        [array]$ips
    )
    $commands = @()
    foreach ($ip in $ips) {
        $addressName = "$serviceName`_$ip"
        $command = @"
config firewall address
edit 'IP - $addressName'
set subnet $ip
set color 3
next
end
"@
        $commands += $command
    }
    return $commands
}

# Function to create address objects for URLs
function Create-URL-AddressObjects {
    param (
        [string]$serviceName,
        [array]$urls
    )
    $commands = @()
    foreach ($url in $urls) {
        $addressName = "$serviceName`_$url"
        $command = @"
config firewall address
edit 'FQDN - $addressName'
set type fqdn
set fqdn $url
set color 3
next
end
"@
        $commands += $command
    }
    return $commands
}
# Function to create address groups for IPs and URLs
function Create-AddressGroups {
    param (
        [string]$serviceName,
        [array]$ipAddresses,
        [array]$urls
    )
    $commands = @()

    # Create IP address group
    if ($ipAddresses.Count -gt 0) {
        $ipGroupName = "$serviceName`_IP_Group"
        $ipGroupMembers = $ipAddresses | ForEach-Object { "$serviceName`_$_" }
        $ipGroupMembersString = $ipGroupMembers -join ' '
        $command = @"
config firewall addrgrp
edit '$ipGroupName'
set member $ipGroupMembersString
next
end
"@
        $commands += $command
    }

    # Create URL address group
    if ($urls.Count -gt 0) {
        $urlGroupName = "$serviceName`_URL_Group"
        $urlGroupMembers = $urls | ForEach-Object { "$serviceName`_$_" }
        $urlGroupMembersString = $urlGroupMembers -join ' '
        $command = @"
config firewall addrgrp
edit '$urlGroupName'
set member $urlGroupMembersString
next
end
"@
        $commands += $command
    }

    return $commands
}
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
    $fortiGateCommands += Create-IP-AddressObjects -serviceName $serviceName -ips $service.ips
    $fortiGateCommands += Create-URL-AddressObjects -serviceName $serviceName -urls $service.urls
    $fortiGateCommands += Create-AddressGroups -serviceName $serviceName -ipAddresses $service.ips -urls $service.urls
}

# Output the FortiGate CLI commands to a file
$outputFilePath = "C:\temp\"+"$site - Microsoft Address Objects.conf"
$fortiGateCommands | Out-File -FilePath $outputFilePath -Encoding ASCII

# Output the result
Write-Output "FortiGate CLI commands have been generated successfully."
Write-Output "The commands have been saved to $outputFilePath."
}