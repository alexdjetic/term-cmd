#!/bin/bash
# Author: Djetic Alexandre
# Date: 27/02/2024
# Modified: 27/02/2024
# Description: this script init atuin cloud history

if [ ! $EUID -eq 0 ]; then
  echo "require sudo/root access"
  exit 1
fi

#fzf: fuzysearch
#tldr: an easy documentation
#eza: upgrade version of ls
#bat: better version of cat
dnf install fzf tldr eza bat -y
