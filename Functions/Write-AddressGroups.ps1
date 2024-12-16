function Write-AddressGroups {
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