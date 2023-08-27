#!/bin/sh

echo "install my nvchad for neovim"

if command -v apt &> /dev/null; then
    echo "Using APT package manager:"
    sudo apt update && sudo apt install neovim
# Check if YUM is available
elif command -v yum &> /dev/null; then
    echo "Using YUM package manager:"
    sudo yum install neovim
# Check if DNF is available
elif command -v dnf &> /dev/null; then
    echo "Using DNF package manager:"
    sudo dnf install neovim
# Check if Pacman is available
elif command -v pacman &> /dev/null; then
    echo "Using Pacman package manager:"
    sudo pacman -S neovim
else
    echo "No supported package manager found."
fi

echo "add to config: ~/.config/nvim/"
nvim "check if all work"