function Write-IpAddressObjects {
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