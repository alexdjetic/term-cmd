#!/bin/bash
# Author: Djetic Alexandre
# Date: 18/02/2024
# Modified: 18/02/2024
# Description: This script installs and sets up KVM on Arch Linux.

# Check if the script is run with root privileges
if [ ! $EUID -eq 0 ]; then
  echo "Error: This script requires sudo/root access"
  exit 1
fi

# Install necessary packages for KVM
pacman -S --noconfirm qemu-full libvirt virt-manager ovmf swtpm virt-viewer libguestfs || { echo "Error: Failed to install required packages"; exit 1; }

# Start and enable libvirt service
systemctl enable --now libvirtd || { echo "Error: Failed to enable and start libvirtd service"; exit 1; }

# Start and enable the virtlogd service
systemctl enable --now virtlogd.socket || { echo "Error: Failed to enable and start virtlogd.socket"; exit 1; }

# Start and enable the virtlockd service
systemctl enable --now virtlockd.socket || { echo "Error: Failed to enable and start virtlockd.socket"; exit 1; }

# Check the host system for virtualization support
if ! grep -E '(vmx|svm)' /proc/cpuinfo >/dev/null; then
  echo "Error: Host system does not support virtualization"
  exit 1
fi

# Enable nested virtualization if supported
modprobe -r kvm_intel 2>/dev/null
modprobe -r kvm_amd 2>/dev/null
modprobe kvm_intel nested=1 || modprobe kvm_amd nested=1 || echo "Warning: Nested virtualization is not supported on this system"

# Reload GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg || { echo "Error: Failed to reload GRUB configuration"; exit 1; }

# Prompt to add user to libvirt group
read -p "Add current user to libvirt group? (y/n): " user_choice
case "$user_choice" in
  y|Y ) usermod -aG libvirt $USER;;
  * ) echo "Skipping adding user to libvirt group";;
esac

# Prompt to reboot the system to apply changes
read -p "System configuration updated. Reboot now? (y/n): " reboot_choice
case "$reboot_choice" in
  y|Y ) reboot;;
  * ) echo "Reboot manually later to apply changes";;
esac

exit 0

