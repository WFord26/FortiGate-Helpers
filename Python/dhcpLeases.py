import requests
from collections import defaultdict

# Replace with your Fortigate IP, API key, and other necessary details
fortigate_ip = "fgtip_dns"
api_key = "api_key"

url = f"https://{fortigate_ip}/api/v2/monitor/system/dhcp"

headers = {
    "Authorization": f"Bearer {api_key}"
}

response = requests.get(url, headers=headers, verify=False)

if response.status_code == 200:
    dhcp_leases = response.json()
    print(dhcp_leases)
else:
    print(f"Failed to retrieve DHCP leases: {response.status_code} - {response.text}")

# Create a host file with hostname and IP address separated by interface
# Organize leases by interface
leases_by_interface = defaultdict(list)
for lease in dhcp_leases.get("results", []):
    interface = lease.get("interface")
    hostname = lease.get("hostname")
    ip_address = lease.get("ip")
    
    if interface and hostname and ip_address:
        leases_by_interface[interface].append((hostname, ip_address))


# Write sorted leases to file
with open("dhcp_hosts.txt", "w") as file:
    file.write("### Start FortiGate ###\n")
    for interface, leases in sorted(leases_by_interface.items()):
        file.write(f"## {interface} ##\n")
        for hostname, ip_address in sorted(leases):
            file.write(f"{ip_address}\t{hostname} {hostname}.mtnmanit.net\n")
    file.write("### End FortiGate ###\n")