# FortiGate get all address objects using API
# Version 1.0
# Date: 2024-12-07

import requests
import json
import sys
import os

# API key
api_key = os.getenv("FORTIGATE_API_KEY")
if not api_key:
    print("API key not found. Please set the FORTIGATE_API_KEY environment variable.")
    sys.exit(1)

# Set the request parameters
url = 'https://fgtip_dns/api/v2/cmdb/firewall/address'
payload = {}
headers = {
    'Authorization': f"Bearer {api_key}",
    'Content-Type': 'application/json'
}

# Do the HTTP request
response = requests.get(url, headers=headers, data=payload, verify=True)   # Set verify to False if using self-signed certificate

# Check for HTTP codes other than 200
if response.status_code != 200:
    print('Status:', response.status_code, 'Problem with the request. Exiting.')
    exit()

# Decode the JSON response into a dictionary and use the data
data = response.json()
# print(json.dumps(data, indent=2))

# Check for Specific Address Object
address_object = "pfSense - CASA"
for address in data.get("results", []):
    if address.get("name") == address_object:
        print(f"Found address object {address_object}")
        # Print the Address Object details
        print(json.dumps(address, indent=2))
        break   # Stop the loop once the address object is found
else:
    print(f"Address object {address_object} not found")
    sys.exit(1)
