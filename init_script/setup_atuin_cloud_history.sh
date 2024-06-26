#!/bin/bash
# Author: Djetic Alexandre
# Date: 27/02/2024
# Modified: 27/02/2024
# Description: this script init atuin cloud history

if [ ! $EUID -eq 0 ]; then
  echo "require sudo/root access"
  exit 1
fi

#install req
dnf install cargo rustc -y

# install atuin
/bin/bash -c "$(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)"
atuin login -u alexggh -p wm7ze*2b
atuin import auto
atuin sync
atuin gen-completions --shell bash --out-dir $HOME
exit
