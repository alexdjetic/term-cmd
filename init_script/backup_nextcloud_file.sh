#!/bin/bash
# Author: Djetic Alexandre
# Date: 29/02/2024
# Modified: 29/02/2024
# Description: This script makes a backup of all Nextcloud files

# Check for sudo/root access
if [ ! $EUID -eq 0 ]; then
  echo "Require sudo/root access"
  exit 1
fi

# Define source and backup directories
SOURCE_DIR="/home/oem/Nextcloud"
BACKUP_DIR=$1
TIME=$(date +"%Y%m%d_%H%M%S")

# Compress the source directory
tar -zcvf "${BACKUP_DIR}/Nextcloud_backup_${TIME}.tgz" "${SOURCE_DIR}"
echo "Backup completed at ${BACKUP_DIR}/Nextcloud_backup_${TIME}.tgz"
