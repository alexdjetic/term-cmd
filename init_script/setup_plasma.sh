#!/bin/sh
# Author: Djetic Alexandre
# Date: 25/02/2024
# Modified: 25/02/2024
# Description: this script setup plasma

if [ ! $EUID -eq 0 ]; then
  echo "require sudo/root access"
  exit 1
fi

# install plasma
dnf update -y
dnf install @kde-desktop -y

# set graphical default
systemctl set-default graphical.target

# disable gdm
systemctl disable gdm
systemctl enable sddm

# clone rofi repo 
git clone --depth=1 https://github.com/adi1090x/rofi.git

### export and alias
current_pwd=$(echo ~)

# add to bashrc
echo "#### launcher shortcut" >> $current_pwd/.bashrc
echo "export app_launcher=$current_pwd/.config/rofi/scripts/launcher_t7" >> $current_pwd/.bashrc
echo "export quit_menu=$current_pwd/.config/rofi/scripts/powermenu_t5" >> $current_pwd/.bashrc
echo "alias app_launcher=$current_pwd/.config/rofi/scripts/launcher_t7" >> $current_pwd/.bashrc
echo "alias quit_menu=$current_pwd/.config/rofi/scripts/powermenu_t5" >> $current_pwd/.bashrc
