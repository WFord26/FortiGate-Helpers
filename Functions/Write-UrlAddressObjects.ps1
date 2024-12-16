function Write-UrlAddressObjects {
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