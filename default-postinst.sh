#!/bin/sh
# -*- coding: utf-8 -*-
# This script is run by debian installer using preseed/late_command
# directive, see preseed.cfg
BUILD_TYPE="VM_TYPE"

# Setup console, remove timeout on boot.
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0"/g; s/TIMEOUT=5/TIMEOUT=0/g' /etc/default/grub
update-grub

# Members of `sudo` group are not asked for password.
sed -i 's/%sudo\tALL=(ALL:ALL) ALL/%sudo\tALL=(ALL:ALL) NOPASSWD:ALL/g' /etc/sudoers

# Empty message of the day.
echo -n > /etc/motd

# Unpack postinst tarball.
tar -x -v -z -C/tmp -f /tmp/postinst.tar.gz

# Install SSH key for PS_USERNAME.
mkdir -m700 /home/PS_USERNAME/.ssh
cat /tmp/postinst/authorized_keys > /home/PS_USERNAME/.ssh/authorized_keys
chown -R PS_USERNAME:PS_USERNAME /home/PS_USERNAME/.ssh

# Remove some non-essential packages.
DEBIAN_FRONTEND=noninteractive apt-get purge -y nano laptop-detect tasksel dictionaries-common emacsen-common iamerican ibritish ienglish-common ispell
# Install basic tools
apt-get update && apt-get install net-tools git vim screen curl -yy
# Install services based off the type.
case "$BUILD_TYPE" in
    nginx)
        apt-get install nginx -yy
        ;;
    apache)
        apt-get install apache2 -yy
        ;;
esac
