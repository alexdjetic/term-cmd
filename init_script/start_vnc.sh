#!/bin/bash

##################################################################################################################
##### Author: Djetic Alexandre                                                                               #####
##### Date: 11/06/2024                                                                                       #####
##### Modified: 11/06/2024                                                                                   #####
##### Description: this script init a tigervnc server and xfce4 desktop on almalinux docker/podman container #####
##################################################################################################################

################################
#####        Color         #####
################################

Color_Off='\033[0m'
Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
White='\033[0;37m'

################################
#####   Useful function    #####
################################

function check_return_code {
  # This function check that an comand give the right return code
  if [ $? -eq 0 ]; then
    logger -e "> ${Green}OK !${Color_Off}"
  else
    logger -e "> ${Red}NOK !${Color_Off}"
  fi
}

function check_file_exist {
    # This function checks if a file exists
    if [ -e "$1" ]; then
        return 0
    else
        return 1
    fi
}

function check_file_readable {
    # This function checks if the current user can read the file given
    if [ -r "$1" ]; then
        return 0
    else
        return 1
    fi
}

function check_file_writeable {
    # This function checks if the current user can write the file given
    if [ -w "$1" ]; then
        return 0
    else
        return 1
    fi
}

function check_file {
    # This function checks if the file can be read by the current user and exists
    if check_file_exist "$1" && check_file_readable "$1"; then
        return 0
    else
        return 1
    fi
}

function check_env_variable_exist {
  # This function checks if the env variable exist and set
  if [ ! -z $1 ]; then
    return 0
  else
    return 1
  fi
}

function help {
  logger -e "$0: "
  logger -e "${Red}Author${Color_Off}: Djetic Alexandre"
  logger -e "${Red}Description${Color_Off}: This script install xfce4, xorg server and tigervnc server using dnf"
  logger -e "${Red}Arguments${Color_Off}:"
  logger -e "\t< application list file>(${Red}require${Color_Off}): this file contian all application to install on this device. It need to be a list package no text before or after the package name, each package need to be space out by a next line"
  exit 1
}

##################################
##### Check Script Condition #####
##################################

# Check Password to Connect Using Vnc
if check_env_variable_exist "$PASSWORD"; then
  logger -e "- the envirronement variable ${Green}PASSWORD${Color_Off} is ${Green}define${Color_Off} !"
else
  logger -e "- the envirronement variable ${Red}PASSWORD${Color_Off} is ${Red}not define${Color_Off} !"
  logger "exiting..."
  exit 1
fi

# Check Remote Resolution
if check_env_variable_exist "$FORMAT"; then
  logger -e "- the envirronement variable ${Green}FORMAT${Color_Off} is ${Green}define${Color_Off} !\n"
else
  logger -e "- the envirronement variable ${Red}FORMAT${Color_Off} is ${Red}not define${Color_Off} !\nExample of value: (1920x1080)"
  logger "exiting..."
  exit 1
fi

# Check Vnc Port
if check_env_variable_exist "$VNC_PORT"; then
  logger -e "- the envirronement variable ${Green}VNC_PORT${Color_Off} is ${Green}define${Color_Off} !"
else
  logger -e "- the envirronement variable ${Red}VNC_PORT${Color_Off} is ${Red}not define${Color_Off} !"
  logger "exiting..."
  exit 1
fi

# Check that the application list file to install is readable and exist
if check_file "$1"; then
  # set the envirronement variable of the list file
  $APP_LIST_FILE="$1"
else
  # Check that the file exist on the system
  if check_file_exist "$1"; then
    logger -e "(debug)> The file ${Green}$1 exist !${Color_Off}"
  else
    logger -e "(debug)> The file ${Red}$1 does not exist !${Color_Off}"
  fi

  # Check that the file is reable by current user
  if check_file_readable "$1"; then
    logger -e "(debug)> The file ${Green}$1 is readeable !${Color_Off}"
  else
    logger -e "(debug)> The file ${Red}$1 is not readeable !${Color_Off}"
  fi

  logger "exiting..."
  exit 1
fi

# display variable
DISPLAY=:0

#################################
#####  Install Application  #####
#################################
logger "- installing application"

for app in $(cat "$APP_LIST_FILE")
do
  logger "- installing ${app}"
  dnf install "${app}"
  check_return_code
done
#################################
##### Install Group upgrade #####
#################################
logger "- installing group package"
dnf install -y epel-release
check_return_code

#################################
##### Install xorg desktop  #####
#################################
logger "- installing xorg server"
dnf install -y xorg-x11-server-Xorg xorg-x11-server-utils xorg-x11-xauth xorg-x11-fonts-* xorg-x11-drv-dummy
check_return_code

#################################
##### Install xfce4 desktop #####
#################################
logger "- installing xfce"
dnf groupinstall -y "xfce"
check_return_code

#################################
#####   Install tigerVNC    #####
#################################
logger "- installing tigervnc"
dnf install -y tigervnc-server
check_return_code

###################################
##### Install network package #####
###################################
logger "- installing necessary network package: iproute2"
dnf install iproute2
check_return_code

####################################
#####   Configuration tigerVNC #####
####################################
logger "- Creating password dir for tigerVNC: (for current user)"
mkdir -p ~/.vnc && chmod 700 ~/.vnc
check_return_code

logger "- Creating password file for tigerVNC: (for current user)"
logger "$PASSWORD" | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd\n
check_return_code

#################################
#####     Configure Xorg    #####
#################################
logger "- Configuring Xorg"
echo 'Section "Device"' > /etc/X11/xorg.conf && \
echo '    Identifier "dummy"' >> /etc/X11/xorg.conf && \
echo '    Driver "dummy"' >> /etc/X11/xorg.conf && \
echo '    Option "NoDDC" "true"' >> /etc/X11/xorg.conf && \
echo '    Option "HWCursor" "false"' >> /etc/X11/xorg.conf && \
echo '    VideoRam 256000' >> /etc/X11/xorg.conf && \
echo 'EndSection' >> /etc/X11/xorg.conf
check_return_code

#################################
#####      Start xfce       #####
#################################
logger "- Start xfce"
startxfce4 >> xfce4.log &> xfce4.log &
check_return_code

#################################
#####      Start vnc        #####
#################################
logger "- Start tigerVNC Server"
vncserver ":${DISPLAY}" -rfbport "${VNC_PORT}" -geometry "${FORMAT}" -localhost no
check_return_code

#################################
#####   Check stuff start   #####
#################################

if [ -z $(ss -lunpt | grep "5900") ]; then
  logger -e "(debug)> ${Green}tigerVNC is running !${Color_Off}"
else
  logger -e "(debug)> ${Red}tigerVNC is not running !${Color_Off}"
fi

if systemctl is-active --quiet graphical.target; then
  logger -e "(debug)> ${Green}Xorg is running !${Color_Off}"
else
  logger -e "(debug)> ${Red}Xorg is not running !${Color_Off}"
fi

######################################
##### Exporting require variable #####
######################################
logger "- exporting display variable"
export DISPLAY=:0
check_return_code
