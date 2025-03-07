import os
import sys
import requests

# Replace with your FortiGate details
fortigate_host = "fgtIP_DNS"
fortiswitch_id = ""  # Example serial number
api_key = os.getenv("FORTIGATE_API_KEY")
reset_endpoint = f"https://{fortigate_host}/api/v2/monitor/switch-controller/managed-switch/port-stats-reset"

# Check if API key is set
if not api_key:
    print("API key not found. Please set the FORTIGATE_API_KEY environment variable.")
    sys.exit(1)

# Disable warnings for unverified HTTPS requests
requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)

# Set the request parameters
payload = {
    "mkey": fortiswitch_id
}

# Optionally include ports to reset
ports_to_reset = ["port23", "port24"]  # Modify this list as needed
if ports_to_reset:
    payload["ports"] = ports_to_reset
headers = {
    'Authorization': f"Bearer {api_key}",
}

# Make the POST request to reset port statistics
response = requests.post(reset_endpoint, headers=headers, json=payload, verify=True)
if response.status_code == 200:
    print("Port statistics reset successfully!")
else:
    print(f"Failed to reset port statistics. Status code: {response.status_code}")
    print(f"Response content: {response.text}")
    sys.exit(1)