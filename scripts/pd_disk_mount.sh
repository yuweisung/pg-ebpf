#!/bin/bash
set -euxo pipefail

MNT_DIR1=/pgsrc
MNT_DIR2=/pgdata

if [[ -d "$MNT_DIR1" ]]; then
        exit
else 
        sudo mkfs.xfs /dev/sdb; \
        sudo mkdir -p $MNT_DIR1
        sudo mount -o nofail,noatime,nodev,defaults /dev/sdb $MNT_DIR1
        sudo mount -a

        # Add fstab entry
        echo UUID=`sudo blkid -s UUID -o value /dev/sdb` $MNT_DIR1 xfs nofail,noatime,nodev,defaults 0 2 | sudo tee -a /etc/fstab
fi
if [[ -d "$MNT_DIR2" ]]; then
        exit
else 
        sudo mkfs.xfs /dev/sdc; \
        sudo mkdir -p $MNT_DIR2
        sudo mount -o nofail,noatime,nodev,defaults /dev/sdc $MNT_DIR2
        sudo mount -a

        # Add fstab entry
        echo UUID=`sudo blkid -s UUID -o value /dev/sdc` $MNT_DIR2 xfs nofail,noatime,nodev,defaults 0 2 | sudo tee -a /etc/
fi