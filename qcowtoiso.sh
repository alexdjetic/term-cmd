#!/bin/bash

if [ $# -lt 2 ]: then
  echo "Usage: $0 </mnt/sdb,/mnt/sdc,...> <path/to/file.iso>"
  exit 1
fi

create_bootable_iso() {
  local usb_device=$1
  local image=$2
  local temp_dir=$(mktemp -d)

  # Unmount the USB drive if it is already mounted
  if mount | grep $usb_device > /dev/null; then
    umount $usb_device
  fi

  # Copy the image to the USB drive
  dd if=$image of=$usb_device bs=4M

  # Mount the USB drive
  mount $usb_device $temp_dir

  # Copy the bootloader files to the USB drive
  cp /usr/lib/syslinux/bios/{ldlinux.c32,libcom32.c32,libutil.c32,menu.c32,memdisk,chain.c32} $temp_dir/syslinux

  # Create the syslinux configuration file
  cat > $temp_dir/syslinux/syslinux.cfg << EOL
DEFAULT vesamenu.c32
PROMPT 0
TIMEOUT 50

LABEL arch
  MENU LABEL Arch Linux
  LINUX ../vmlinuz-linux
  APPEND root=PARTUUID=$(blkid -s PARTUUID -o value $usb_device-part1) rw
  INITRD ../initramfs-linux.img
EOL

  # Install the syslinux bootloader
  syslinux $usb_device-part1

  # Unmount the USB drive
  umount $usb_device

  # Remove the temporary directory
  rm -rf $temp_dir
}

# Example usage:
# create_bootable_iso /dev/sdc archlinux.iso
