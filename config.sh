#!/bin/bash
typeset -A CONFIG # Create our array
CONFIG=( # Set some values
  # Domain can be pulled from the host FQDN or hard set.
  [DOMAIN]="burnham.io"
  #[DOMAIN]=$(/bin/hostname -d)
  # Distribution settings
  # Use the global CDN
  [DIST_URL]="https://deb.debian.org/debian/dists/stretch/main/installer-amd64/"
  [DIST_VARIANT]="debian9"
  # Default sizing settings if not passed.
  [VM_MEM]="1024"
  [VM_CPU]="2"
  [VM_DISK]="25" # GB
  # Location to store the images
  [VM_DISKLOC]=/opt/libvirt/images/
  # Preseed Settings
  [PS_USER_FULLNAME]="Taylor Burnham"
  [PS_USERNAME]="taylor"
  [PS_LOCALE]="en_US"
  [PS_KEYBOARD]="us"
  [PS_DEB_MIRROR]="ftp.us.debian.org"
  [PS_TZ]="America/New_York"
  [PS_GITHUB]="https://github.com/TaylorBurnham.keys"
)
