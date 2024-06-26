#!/bin/bash
# Author: Djetic Alexandre
# Date: 04/04/2024
# Modified: 04/04/2024
# Description: This script tests a domain name and retrieves its IPv4, IPv6, and PTR records.

# Environment variables
NAME="$1"

# Resolve IP addresses
IP_V4=$(dig -t A "$NAME" @1.1.1.1 +short)
IP_V6=$(dig -t AAAA "$NAME" @1.1.1.1 +short)

# Retrieve PTR records
PTR_RECORD_V4=$(dig -x "$IP_V4" @1.1.1.1 +short)
PTR_RECORD_V6=$(dig -x "$IP_V6" @1.1.1.1 +short)

# Print values
echo "IPv4 records:"
echo "$IP_V4"
echo "IPv6 records:"
echo "$IP_V6"
echo "PTR records (v4):"
echo "$PTR_RECORD_V4"
echo "PTR records (v6):"
echo "$PTR_RECORD_V6"
