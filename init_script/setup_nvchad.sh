#!/bin/bash
# Author: Djetic Alexandre
# Date: 22/01/2024
# Modified: 22/01/2024
# Description: this script install nvchad and nvim

if [ ! $EUID -eq 0 ]; then
  echo "require sudo/root access"
  exit 1
fi

echo "installing neovim..."
dnf install neovim git -y

echo "installing nvchad..."*
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim

echo "finish"
