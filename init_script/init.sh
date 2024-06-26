#!/bin/sh

sysctl -w net.ipv4.ip_forward=1
echo "ip forward: "
cat /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

echo "settings up IP address"
ip link set eth0 up
ip a add 192.168.50.254/24 dev eth0

echo "test connectivity"
ping -c 2 www.google.com > /dev/null

if [ $? -eq 0 ]; then
	echo "OK"
	exit 0
else
	echo "NOK"
	exit 1
fi
