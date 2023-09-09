#!/bin/sh

echo "install theme for zsh shell"
git clone https://aur.archlinux.org/zsh-theme-powerlevel10k-git.zsh-theme-powerlevel10k-git
cd zsh-theme-powerlevel10k-git/
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

echo "open a new shell emulator to check and finish the install then in prompt"
zsh 
