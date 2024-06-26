#!/bin/bash
# Author: Djetic Alexandre
# Date: 18/02/2024
# Modified: 18/02/2024
# Description: This script installs and sets up KVM on Fedora.

# Check if the script is run with root privileges
if [ ! $EUID -eq 0 ]; then
  echo "Error: This script requires sudo/root access"
  exit 1
fi

# Install necessary packages for KVM
dnf install qemu-kvm libvirt virt-install virt-manager virt-viewer \
    edk2-ovmf swtpm qemu-img guestfs-tools libosinfo tuned -y || { echo "Error: Failed to install required packages"; exit 1; }

# Start all services required for qemu and kvm
for drv in qemu interface network nodedev nwfilter secret storage; do \
  systemctl enable virt${drv}d.service || { echo "Error: Failed to enable virt${drv}d.service"; exit 1; }; \
  systemctl enable virt${drv}d{,-ro,-admin}.socket || { echo "Error: Failed to enable virt${drv}d{,-ro,-admin}.socket"; exit 1; }; \
done

# Check the host system for virtualization support
virt-host-validate qemu || { echo "Error: Host system does not support virtualization"; exit 1; }

# Reload GRUB configuration
grub2-mkconfig -o /boot/grub2/grub.cfg || { echo "Error: Failed to reload GRUB configuration"; exit 1; }

# Enable and start the tuned service
systemctl enable --now tuned || { echo "Error: Failed to enable and start the tuned service"; exit 1; }

# Display the currently active tuned profile
tuned-adm active || { echo "Error: Failed to display the currently active tuned profile"; exit 1; }

# List all available tuned profiles
tuned-adm list || { echo "Error: Failed to list all available tuned profiles"; exit 1; }

# Set the virtual-host profile as the active profile
tuned-adm profile virtual-host || { echo "Error: Failed to set the virtual-host profile"; exit 1; }

# Display the currently active tuned profile
tuned-adm active || { echo "Error: Failed to display the currently active tuned profile"; exit 1; }

# Verify the tuned profile
tuned-adm verify || { echo "Error: Failed to verify the tuned profile"; exit 1; }

# add user to livbirt group
sudo usermod -aG libvirt $USER
echo "export LIBVIRT_DEFAULT_URI='qemu:///system'" >> ~/.bashrc
source ~/.bashrc

# get current uri
virsh uri

# Prompt for a system reboot to apply changes
read -p "System configuration updated. Reboot now? (y/n): " choice
case "$choice" in
  y|Y ) reboot;;
  * ) echo "Reboot manually later to apply changes";;
esac

exit 0
