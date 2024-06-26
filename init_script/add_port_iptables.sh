#!/bin/sh
# Author: Djetic Alexandre
# Date: 01/02/2024
# Modified: 01/02/2024
# Description: this script add a port to iptables rule

iptables -A INPUT -p tcp --dport $1 -j ACCEPT
iptables -A INPUT -p udp --dport $1 -j ACCEPT
ip6tables -A INPUT -p tcp --dport $1 -j ACCEPT
ip6tables -A INPUT -p udp --dport $1 -j ACCEPT

