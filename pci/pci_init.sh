#!/bin/sh

echo "install dependency..."
sudo pacman -Syy
sudo pacman -S archlinux-keyring
sudo pacman -S qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat dmidecode
sudo pacman -S iptables
sudo pacman -S libguestfs

echo "start daemon..."
sudo systemctl start libvirtd.service
sudo systemctl enable libvirtd.service

echo "add user to group libvirt..."
sudo usermod -a -G libvirt $(whoami)
newgrp libvirt

echo "virtualization enable inside vm..."
sudo modprobe -r kvm_amd
sudo modprobe kvm_amd nested=1

echo "add permanent argument for kernel..."
echo "options kvm_amd nested=1" | sudo tee /etc/modprobe.d/kvm-amd.conf

echo "setup vfio..."
echo "first get the id of your comonent to pcipassthough...[xxxx:xxxx] where 10de:xxxx is nvidia"

shopt -s nullglob
for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;

echo "be careful, when select ALL group need to use vfio-pci driver"
