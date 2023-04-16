#!/bin/sh

echo "auto lo"
echo "iface lo inet loopback"

echo "iface eth inet static"
echo "address $1"
echo "netmask $2"
echo "gateway $3"
