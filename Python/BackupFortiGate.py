import requests
from datetime import datetime
import os

# Replace with your FortiGate details
fortigate_ip = "fgtip_dns"
api_key = 'api_key'
if not api_key:
    print("API key not found. Please set the FORTIGATE_API_KEY environment variable.")
    sys.exit(1)

# Disable warnings for unverified HTTPS requests
requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)

# Get hostname of the FortiGate
hostname_endpoint = f"https://{fortigate_ip}/api/v2/monitor/system/status"
hostname_response = requests.get(hostname_endpoint, headers={"Authorization": f"Bearer {api_key}"})

# Get the current date
current_date = datetime.now().strftime("%Y%m%d")

if hostname_response.status_code == 200:
    hostname = hostname_response.json().get("results", {}).get("hostname", "unknown")
else:
    hostname = "unknown"

# Create the backup file name
backup_filename = f"fortigate_backup_{hostname}_{current_date}.conf"

# Define the backup endpoint
backup_endpoint = f"https://{fortigate_ip}/api/v2/monitor/system/config/backup?scope=global"

# Make the GET request to the FortiGate API
response = requests.get(backup_endpoint, headers={"Authorization": f"Bearer {api_key}"}, verify=False)

# Check if the request was successful
if response.status_code == 200:
    # Save the backup to a file
    with open(backup_filename, "wb") as backup_file:
        backup_file.write(response.content)
    print("Backup successful!")
else:
    print(f"Failed to backup FortiGate from {backup_endpoint}. Status code: {response.status_code}")
    print(response.text)