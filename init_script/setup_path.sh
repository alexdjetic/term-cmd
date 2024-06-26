#!/bin/bash
# Author: Djetic Alexandre
# Date: 22/01/2024
# Modified: 22/01/2024
# Description: this script will setup the path for custom command

paths=$(cat list_path.txt)

echo "# custom PATH from $PWD/setup_path.sh" >> ~/.bashrc

for path in $paths
do
    echo "chmod +x $path" >> ~/.bashrc
    echo "export PATH=\$PATH:$path" >> ~/.bashrc
done

