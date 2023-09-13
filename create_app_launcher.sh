#!/bin/bash

# Check if the required arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <command> <icon_path>"
    exit 1
fi

# Assign the provided arguments to variables
command="$1"
icon_path="$2"

# Define the .desktop file content
desktop_file_content="[Desktop Entry]
Version=1.0
Type=Application
Name=Anaconda Navigator
GenericName=Anaconda Navigator
Comment=Graphical user interface for Anaconda
Exec=$command
Icon=$icon_path
Terminal=false
Categories=Development;Science;Education;
StartupNotify=true
"

# Create the .desktop file
echo "$desktop_file_content" > anaconda-navigator.desktop

# Move the .desktop file to the right location
mv anaconda-navigator.desktop ~/.local/share/applications/

# Update the application menu
xdg-desktop-menu forceupdate

echo "$command has been created and added to the application menu."

