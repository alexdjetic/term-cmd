#!/bin/bash
# Author: Djetic Alexandre
# Date: 23/01/2024
# Modified: 23/01/2024
# Description: this script change the default PS1

echo "export PS1='\[\033[01;31m\]>\[\033[00m\]\[\033[01;32m\]\u\[\033[00m\]@\[\033[01;34m\]\h \[\033[00;37m\]$(date +"%Y-%m-%d %H:%M:%S") \[\033[01;33m\]$(pwd)\[\033[00m\] \[\033[01;31m\]$(user_type)\[\033[00m\]\$ '" >> ~/.bashrc

# Function to determine user type
user_type() {
  if [ "$EUID" -eq 0 ]; then
    echo "# admin"
  else
    echo "$USER"
  fi
}
