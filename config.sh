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
  [VM_INTERFACE]="br0"
  # Default build type - leave as basic unless you design it otherwise
  [VM_TYPE]="basic"
  # Location to store the images
  [VM_DISKLOC]=/opt/libvirt/images/
  # Preseed Settings
  [PS_USER_FULLNAME]="Taylor Burnham"
  [PS_USERNAME]="taylor"
  [PS_LOCALE]="en_US"
  [PS_KEYBOARD]="us"
  [PS_DEB_MIRROR]="ftp.us.debian.org"
  # Be sure to escape the forward slash in the TZ setting.
  [PS_TZ]="America\/New_York"
  # Set the source of the key. github, config, or user.
  [PS_SSHKEY_SOURCE]="config"
  [PS_SSHKEY_GITHUB]="https://github.com/TaylorBurnham.keys"
  [PS_SSHKEY_SET]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDyzTwXgyKuc7jA604jtytWzVTxLhUHVVjQXXiD7sV+kf3+CY9K1Lbgh5SK2VYATR3fmkKAhSJE+PmGscq5VpU75+NjSWhWGI6i18wqa4hHPKJGtx1UMrdVtExnenN6odNxkNcVmZKqAwpy8RP7pwQcWVO/+ghF/tGA6lpxPy5LWBrjjYoVoQiGK6FwIcskxFN3gDSvHOQmI5isin/1wDpb/DXrPn0Fe0l9Csc/AAB1jiZKS2FgS5cNUT0QBr72HGQmI2ztugQmN2z5pvRWP9iuL7TXbSuht9RN18iQvp+oi18YMYtSL10L4Kq0lUeEKSr4ukXeeCGH/xg4KfofB++D"
)
# Don't change these or the configuration will not merge correctly on provision
declare -a PRESEED_REPLACE=('PS_USER_FULLNAME' 'PS_USERNAME' 'PS_LOCALE' 'PS_KEYBOARD' 'PS_DEB_MIRROR' 'PS_TZ')
declare -a POSTINST_REPLACE=('PS_USERNAME')

