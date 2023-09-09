#!/bin/sh

echo "auto lo"
echo "iface lo inet loopback"

echo "iface $1 inet static"
echo "address $2"
echo "netmask $3"
echo "gateway $4"
