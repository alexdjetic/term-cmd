#!/bin/sh

echo "iface eth inet static"
echo "address $1"
echo "netmask $2"
echo "gateway $3"
