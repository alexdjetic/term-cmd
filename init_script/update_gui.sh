#!/bin/bash
# Author: Djetic Alexandre
# Date: 14/03/2003
# Modified: 14/03/2003
# Description: This script gets all packages of a Linux system

# This function tests whether a package manager exists
function test_package_exist {
  # $1 : package manager name
  local package_manager="$1"
  
  "$package_manager" -v > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    return 0
  else
    return 1
  fi
}

# This function updates the system with 1 package manager
function update {
  # $1 : package manager
  case $1 in
    "dnf")
      dnf update -y
      ;;
    "yum")
      yum update -y
      ;;
    "apt")
      apt update && apt upgrade -y
      ;;
    "apk")
      apk update -y
      ;;
    "pacman")
      pacman -Syu
      ;;
    "yay")
      yay -Syu
      ;;
    "flatpak")
      flatpak update -y
      ;;
    "snap")
      snap refresh
      ;;
    *)
      ;;
  esac
}

if [ $EUID -ne 0 ]; then
  echo "require sudo/root access..."
  exit 1
fi

# env var
list_all_package="dnf yum apt apk pacman yay flatpak snap"
list_available_package=""

# Get all available packages
for package in $list_all_package
do
  if test_package_exist "$package"; then
    list_available_package="${list_available_package} ${package} off"
  fi
done

# TUI: Choose the package to update
selected_packages=$(whiptail --title "Select package manager to update" --checklist --separate-output "Select package manager to update" 20 60 7 $list_available_package 3>&1 1>&2 2>&3)

# Update selected package managers
for selected_package in $selected_packages
do
  update "$selected_package"
done
