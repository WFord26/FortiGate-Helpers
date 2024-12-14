# Get-MicrosoftAddressListForFortiGate

This PowerShell script contains a function `Get-MicrosoftAddressListForFortiGate` that retrieves Microsoft service area information and generates FortiGate CLI commands to create address objects for the specified IP addresses and URLs.

## Prerequisites

- PowerShell 5.1 or later
- JSON file containing Microsoft service area information

## Usage

### Function: `Get-MicrosoftAddressListForFortiGate`

This function retrieves Microsoft service area information based on the specified site and generates FortiGate CLI commands to create address objects.

### Parameters

- `site`: Specifies the Microsoft service area. Valid values are:
  - `USGovGCCHigh`
  - `China`
  - `Worldwide`
  - `USGovDoD`
  - `Germany`

### Example

```powershell
# Import the script containing the function
. .\Set-MicrosoftAddressObjects.ps1

# Call the function with the desired site
Get-MicrosoftAddressListForFortiGate -site "Worldwide"
```

### Output

The script generates a FortiGate configuration file containing the CLI commands to create address objects. The file is saved to the specified output path.

#### Example
```
config firewall address
edit "Exchange_Online_13.107.6.152/31"
set subnet 13.107.6.152/31
next
end
config firewall address
edit "Exchange_Online_outlook.office365.com"
set fqdn outlook.office365.com
next
end
```
