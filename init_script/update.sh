#!/bin/bash
# Author: Djetic Alexandre
# Date: 13/03/2024
# Modified: 13/02/2024
# Description: This updates various package managers on Linux systems

if [ $EUID -ne 0 ]; then
  echo "This script requires sudo/root access"
  exit 1
fi

# Red Hat based distributions (CentOS, Fedora, RHEL)
if command -v dnf &>/dev/null; then
  echo "Updating Red Hat based system using dnf..."
  dnf check-update
  dnf update -y
elif command -v yum &>/dev/null; then
  echo "Updating Red Hat based system using yum..."
  yum check-update
  yum update -y
fi

# Debian and Ubuntu based distributions
if command -v apt &>/dev/null; then
  echo "Updating Debian/Ubuntu based system..."
  apt update -y && apt upgrade -y
fi

# Arch Linux
if command -v pacman &>/dev/null; then
  echo "Updating Arch Linux system..."
  pacman -Syu --noconfirm
fi

# Gentoo
if [ -f "/etc/gentoo-release" ]; then
  echo "Updating Gentoo system..."
  emerge --sync && emerge -auDN @world
fi

# Flatpak
if command -v flatpak &>/dev/null; then
  echo "Updating Flatpak..."
  flatpak update -y
fi

# Snap
if command -v snap &>/dev/null; then
  echo "Updating Snap..."
  snap refresh
fi

