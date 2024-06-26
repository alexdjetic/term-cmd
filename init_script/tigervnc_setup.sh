#!/bin/bash

# Set default port
VNC_PORT=${1:-5900}

# Set default display number (port number minus 5900)
DISPLAY_NUM=$((VNC_PORT - 5900))

# Create the necessary directories and set permissions
mkdir -p ~/.vnc
chmod 700 ~/.vnc

# Set a VNC password (this is a simple way, for more secure options see TigerVNC documentation)
echo "yourpassword" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Start the VNC server
vncserver :${DISPLAY_NUM} -rfbport ${VNC_PORT} -localhost no

# Keep the container running
tail -f /dev/null

