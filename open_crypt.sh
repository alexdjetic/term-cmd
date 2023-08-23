#!/bin/sh

if [ $# -lt 3 ]; then
    echo "Usage: $0 <luks_name> <mount_point> <number_of_partitions>"
    exit 1
fi

luks_name="$1"
mount_point="$2"
number_of_partitions="$3"

echo "Uncipher the luks partitions, starting with name: $luks_name ..."
for ((i=1; i<=number_of_partitions; i++)); do
    sudo cryptsetup luksOpen "/dev/sdb$i" "${luks_name}$i"
done

echo "Mount the partitions to endpoint: $mount_point ..."
for ((i=1; i<=number_of_partitions; i++)); do
    partition_path="/dev/mapper/${luks_name}$i"
    mount_path="$mount_point/${luks_name}$i"

    # Check if the mount directory exists, and create it if not
    if [ ! -d "$mount_path" ]; then
        echo "Creating directory: $mount_path"
        sudo mkdir -p "$mount_path"
    fi

    sudo mount "$partition_path" "$mount_path"
done

