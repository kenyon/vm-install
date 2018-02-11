#!/bin/bash
# A modified variant of Dmitri Popov's script to be a little more flexible.
# https://github.com/pin/debian-vm-install
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

if [ $# -lt 1 ]
then
    cat <<EOF
Usage: $0 -n <Name> -r <RAM> -c <CPU> -d <DISK> -mac <MAC>
  -n       Sets the guest, VM, and disk name. ${BOLD}Required.${NORM}
  -r       Sets the amount of memory to allocate in MB
  -c       Sets the number of vCPUs to assign
  -d       Sets the size of the disk in GB
  -t       Sets the type of server this will be. Uses default-postinst.sh
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

# Load our configuration
if [ ! -f ./config.sh ]; then
  echo "Configuration file missing!"
  return
else
  source ./config.sh
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
    -t)
    BUILD_TYPE="$2"
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
# If we only have two args, use the name and go. If our name is not set or empty, fail.
if [[ $# -eq 1 ]]; then
    echo "Setting name ${1}"
    NAME=${1}
elif [[ ! -n "${NAME+set}" || -z "$NAME" ]]; then
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
if [[ ! -n "${BUILD_TYPE+set}" || -z "$BUILD_TYPE" ]]; then
    echo "Setting build type from configuration..."
    BUILD_TYPE=${CONFIG[VM_TYPE]}
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
  MAC:   ${MAC}
  Type:  ${BUILD_TYPE}\n
Using the following settings from the configuration:
  Dist:    ${CONFIG[DIST_URL]}
  Variant: ${CONFIG[DIST_VARIANT]}\n"

# Figure out where we want to get our key from, and pull it.
case "${CONFIG[PS_SSHKEY_SOURCE]}" in
    github)
        # Get our key from github
        if [[ -n "${CONFIG[PS_SSHKEY_GITHUB]}" ]]; then
            echo "Grabbing SSH key from Github at: ${CONFIG[PS_SSHKEY_GITHUB]}"
            wget -q ${CONFIG[PS_SSHKEY_GITHUB]} -O postinst/authorized_keys || { echo "Failed to download file. Check your URL." ; exit 1; }
        else
            echo "${BOLD}Told to use key source ${CONFIG[PS_SSHKEY_SOURCE]}, but the variable is not set.${NORM}"
            exit 1
        fi
        ;;
    config)
        # Get our key from the configuration
        if [[ -n "${CONFIG[PS_SSHKEY_HARDSET]}" ]]; then
            echo ${CONFIG[PS_SSHKEY_HARDSET]} > postinst/authorized_keys
        fi
        ;;
    user)
        # Pull the user's pubkey
        if [ -f ~/.ssh/id_rsa.pub ]; then
            cat ~/.ssh/id_rsa.pub > postinst/authorized_keys
        else
            echo "${BOLD}Told to grab user key, but cannot find it at ~/.ssh/id_rsa.pub${NORM}"
            exit 1
        fi
        ;;
    *)
        # Invalid entries
        echo "${BOLD}Key source '${CONFIG[PS_SSHKEY_SOURCE]}' invalid. Must be github, config, or user${NORM}"
        exit 1
esac

echo "${BOLD}Starting process...${NORM}"
# Create tarball with some stuff we would like to install into the system.
echo "Creating postinst tarball..."
tar cvfz postinst.tar.gz postinst

# Set our temporary filenames and remove the leading ./
TEMP_POSTINST=$(tempfile -d . -p post -s .sh | cut -c 3-)
# Set up preseed
echo "Setting parameters on preseed from configuration..."
TEMP_PRESEED="preseed.cfg"
cat default-preseed.cfg > ${TEMP_PRESEED}
# Use sed to replace placeholders from our configuration.
sed -i "s/PS_POSTINST_FILENAME/${TEMP_POSTINST}/g" ${TEMP_PRESEED}
for REPL in ${PRESEED_REPLACE[@]};
do echo "Setting ${REPL} -> ${CONFIG[$REPL]}"
   sed -i "s/${REPL}/${CONFIG[$REPL]}/g" ${TEMP_PRESEED}
done

echo "Setting parameters on postinst.sh from configuration..."
cat default-postinst.sh > ${TEMP_POSTINST}
sed -i "s/VM_TYPE/${BUILD_TYPE}/g" ${TEMP_POSTINST}
for REPL in ${POSTINST_REPLACE[@]};
do echo "Setting ${REPL} -> ${CONFIG[$REPL]}"
   sed -i "s/${REPL}/${CONFIG[$REPL]}/g" ${TEMP_POSTINST}
done
echo "${BOLD}Initiating VM creation.${NORM}"
virt-install \
--connect=qemu:///system \
--name=${NAME} \
--ram=${RAM} \
--vcpus=${CPU} \
--disk size=${DISK},path=${CONFIG[VM_DISKLOC]}${NAME}.img,bus=virtio,cache=none \
--initrd-inject=${TEMP_PRESEED} \
--initrd-inject=${TEMP_POSTINST} \
--initrd-inject=postinst.tar.gz \
--location ${CONFIG[DIST_URL]} \
--os-type linux \
--os-variant ${CONFIG[DIST_VARIANT]} \
--virt-type=kvm \
--controller usb,model=none \
--graphics none \
--noautoconsole \
--network bridge=${CONFIG[VM_INTERFACE]},mac=${MAC},model=virtio \
--extra-args="auto=true hostname="${NAME}" domain="${CONFIG[DOMAIN]}" console=tty0 console=ttyS0,115200n8 serial"

echo "Cleaning up..."
rm -v postinst.tar.gz ${TEMP_PRESEED} ${TEMP_POSTINST}
echo "Done! Connect to the system using ${BOLD}virsh console ${NAME}${NORM}.

Enjoy!"
