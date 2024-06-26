#!/bin/bash
# Author: Djetic Alexandre
# Date: 19/03/2024
# Modified: 19/03/2024
# Description: this script put a 

if [ $EUID -ne 0 ]; then
  echo "require sudo/root access..."
  exit 1
fi

function update_dns {
    # Setup the DNS server to use
    echo "search alexgghnetwork.local" > /etc/resolv.conf
    echo "nameserver 192.168.50.254" >> /etc/resolv.conf
}

#Initial update
update_dns

# Monitor network changes and update DNS accordingly
nmcli monitor | while read -r event; do
    if [[ $event == *"dns"* ]]; then
        update_dns
    fi
done
