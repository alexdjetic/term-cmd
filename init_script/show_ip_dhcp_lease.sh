#!/bin/sh
# Author: Djetic Alexandre
# Date: 02/02/2024
# Modified: 02/02/2024
# Description: Display IP lease information in a aligned table format

LEASE_FILE="/var/lib/misc/dnsmasq.leases"

# Display table header
echo "|-----------------|--------------------------------|----------------------|"
printf "| %-15s | %-30s | %-20s |\n" "IP" "Hostname" "MAC Address"
echo "|-----------------|--------------------------------|----------------------|"

while read -r line; do
    # Extracting IP, Hostname, and MAC Address from each line
    ip=$(echo "$line" | awk '{print $3}')
    hostname=$(echo "$line" | awk '{print $4}')
    mac_address=$(echo "$line" | awk '{print $5}')

    # Displaying formatted table row with alignment
    printf "| %-15s | %-30s | %-20s |\n" "$ip" "$hostname" "$mac_address"
done < "$LEASE_FILE"

echo "|-----------------|--------------------------------|----------------------|"

