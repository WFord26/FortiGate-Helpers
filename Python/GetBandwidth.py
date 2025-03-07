import os
import requests
import csv
from datetime import datetime

# FortiGate API configuration
API_URL = ''
API_KEY = ''

def get_wan_bandwidth():
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Content-Type': 'application/json'
    }
    
    try:
        requests.packages.urllib3.disable_warnings()
        response = requests.get(API_URL, headers=headers, verify=False)
        response.raise_for_status()
        
        data = response.json()
        
        # Find WAN1 interface data
        for interface in data.get('results', []):
            if interface.get('name') == 'wan1':
                bytes_rx = int(interface.get('bytes_rx', 0))
                bytes_tx = int(interface.get('bytes_tx', 0))
                
                # Convert to Mbps
                rx_mbps = round((bytes_rx * 8) / 1000000, 2)
                tx_mbps = round((bytes_tx * 8) / 1000000, 2)
                
                return {
                    'time': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                    'in': rx_mbps,
                    'out': tx_mbps
                }
        return None
            
    except requests.exceptions.RequestException as e:
        print(f'API request failed: {str(e)}')
        return None

# Main execution
if __name__ == '__main__':
    if not API_KEY:
        print("Please set FORTIGATE_API_KEY environment variable")
        exit(1)
        
    bandwidth_data = get_wan_bandwidth()
    if bandwidth_data:
        # Write to CSV
        with open('bandwidth_data.csv', 'a', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([
                bandwidth_data['time'],
                bandwidth_data['in'],
                bandwidth_data['out']
            ])
        print(f"Bandwidth data recorded: In: {bandwidth_data['in']} Mbps, Out: {bandwidth_data['out']} Mbps")
    else:
        print("Failed to get bandwidth data")
