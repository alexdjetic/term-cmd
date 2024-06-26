#!/bin/bash
# Author: 26/02/2024
# Date: 26/02/2024
# Modified: 26/02/2024
# Description: this script add a resolver to /etc/resolv.conf

if [ ! $EUID -eq 0 ]; then
  echo "require sudo/root access"
  exit 1
fi

echo "" > /etc/resolv.conf
echo "nameserver 192.168.50.254" >> /etc/resolv.conf
