#!/bin/bash
# A modified variant of Dmitri Popov's script to be a little more flexible.
# Make sure to update the config.sh with your settings.

# I wouldn't modify anything below this unless you know what you are doing.
# Pretty up our command
BOLD=$(tput bold)
NORM=$(tput sgr0)
# Some functions
generate_mac() {
  # Create a random MAC address
  MACCHARS="0123456789abcdef"
  MACPART="0a:0b:0c"
  MACGEN=$(for i in {1..6};
             do
               echo -n ${MACCHARS:$(( $RANDOM % 16 )):1};
             done | sed -e 's/\(..\)/:\1/g')
  echo ${MACPART}${MACGEN}
}


# Load our configuration
if [ ! -f ./config.sh ]; then
  echo "Configuration file missing!"
  return
else
  source ./config.sh
fi

if [ $# -lt 1 ]
then
    cat <<EOF
Usage: $0 -n <Name> -r <RAM> -c <CPU> -d <DISK> -mac <MAC>
  -n       Sets the guest, VM, and disk name. ${BOLD}Required.${NORM}
  -r       Sets the amount of memory to allocate in MB
  -c       Sets the number of vCPUs to assign
  -d       Sets the size of the disk in GB
  -mac     Sets the MAC address. Leave blank for random.

Examples:
  This will create a guest named "webserver" with 512mb
  RAM, 2 vCPUs, 25GB disk, and an assigned MAC address.

  ${BOLD}$0 webserver -r 512 -c 2 -d 25 -mac 52:54:00:bf:b3:80${NORM}

  This will create a guest using the defaults inherited from
  config.sh named "vmtest" with a random MAC.

  ${BOLD}$0 vmtest${NORM}
EOF
    exit 1
fi

# Parse arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -n)
    NAME="$2"
    shift
    shift
    ;;
    -r)
    RAM="$2"
    shift
    shift
    ;;
    -c)
    CPU="$2"
    shift
    shift
    ;;
    -d)
    DISK="$2"
    shift
    shift
    ;;
    -mac)
    MAC="$2"
    shift
    shift
    ;;
    *)
    POSITIONAL+=("$1")
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}"
# Check our variables are set from the arguments, otherwise use defaults
# If our name is not set or empty, fail.
if [[ ! -n "${NAME+set}" || -z "$NAME" ]]; then
    echo "${BOLD}No name passed. Failing.${NORM}"
    exit 1
fi
# Check optional parameters, use defaults if not set or no value passed.
if [[ ! -n "${RAM+set}" || -z "$RAM" ]]; then
    echo "Setting RAM from configuration..."
    RAM=${CONFIG[VM_MEM]}
fi
if [[ ! -n "${CPU+set}" || -z "$CPU" ]]; then
    echo "Setting vCPU count from configuration..."
    CPU=${CONFIG[VM_CPU]}
fi
if [[ ! -n "${DISK+set}" || -z "$DISK" ]]; then
    echo "Setting disk size from configuration..."
    DISK=${CONFIG[VM_DISK]}
fi
# MAC address verification.
if [[ -n  "${MAC+set}" ]]; then
    if [[ ! ${MAC} =~ ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$ ]]; then
        echo -ne "${BOLD}Invalid MAC address '${MAC}'${NORM}, must be like $(generate_mac)\n\n"
        exit 1
    else
        echo "Using MAC address '${MAC}'"
    fi
else
    echo "Generating random MAC address..."
    MAC=$(generate_mac)
fi

# Print our plans
echo -ne "${BOLD}Provisioning VM with parameters:${NORM}
  Name:  ${NAME}.${CONFIG[DOMAIN]}
  RAM:   ${RAM}mb
  vCPUs: ${CPU}
  Disk:  ${DISK}gb
  MAC:   ${MAC}\n
Using the following settings from the configuration:
  Dist:    ${CONFIG[DIST_URL]}
  Variant: ${CONFIG[DIST_VARIANT]}\n"

# Commented out until we're done with parameters
# Fetch SSH key from github.
#wget -q https://github.com/pin.keys -O postinst/authorized_keys

# Create tarball with some stuff we would like to install into the system.
#tar cvfz postinst.tar.gz postinst
 
#virt-install \
#--connect=qemu:///system \
#--name=${NAME} \
#--ram=${RAM} \
#--vcpus=${CPU} \
#--disk size=${DISK},path=${CONFIG[VM_DISKLOC]}${NAME}.img,bus=virtio,cache=none \
#--initrd-inject=preseed.cfg \
#--initrd-inject=postinst.sh \
#--initrd-inject=postinst.tar.gz \
#--location ${CONFIG[DIST_URL]} \
#--os-type linux \
#--os-variant ${CONFIG[DIST_VARIANT]} \
#--virt-type=kvm \
#--controller usb,model=none \
#--graphics none \
#--noautoconsole \
#--network bridge=br0,mac=${MAC},model=virtio \
#--extra-args="auto=true hostname="${NAME}" domain="${CONFIG[DOMAIN]}" console=tty0 console=ttyS0,115200n8 serial"

#rm postinst.tar.gz
