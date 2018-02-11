# Debian `stretch` Unattended VM Guest Installer

This is an automated script that will make use of **virt-install** to
configure and deploy a Debian system without any user interaction. Just
set it and let it go. Utilizes the **preseed** config to run unattended.

This script is based off one written by [Dmitri Popov](https://github.com/pin) 
located here: [debian-vm-install](https://github.com/pin/debian-vm-install). Dmitri's 
intent was for the script he wrote to be used by someone to write their own, and this
is the result spending a morning working on it.

```
Usage: ./install.sh -n <Name> -r <RAM> -c <CPU> -d <DISK> -mac <MAC>
  -n       Sets the guest, VM, and disk name. Required.
  -r       Sets the amount of memory to allocate in MB
  -c       Sets the number of vCPUs to assign
  -d       Sets the size of the disk in GB
  -t       Sets the type of server this will be. Uses default-postinst.sh
  -mac     Sets the MAC address. Leave blank for random.

Examples:
  This will create a guest named "webserver" with 512mb
  RAM, 2 vCPUs, 25GB disk, and an assigned MAC address.

  ./install.sh webserver -r 512 -c 2 -d 25 -mac 52:54:00:bf:b3:80

  This will create a guest using the defaults inherited from
  config.sh named "vmtest" with a random MAC.

  ./install.sh vmtest
```

Guest OS out of the box is minimal with no GUI and serial console support so you can 
Guest OS is minimal no-GUI Debian installation configured with serial console
for ability to `virsh console <GUEST_NAME>`, and OpenSSH server with your SSH
key or/and password pre-configured.

Prerequisites
-------------
I was able to run this out of the box after installing the following on a fresh
Debian 9.x host.

 * `apt-get install qemu-kvm libvirt-clients libvirt-daemon-system virtinst`

Things to do before you run
-------------------------------------
Update `config.sh` with the following values:

 * `DOMAIN`: Sets the domain. You can also use `/bin/hostname -d` to use what DHCP 
 assigned the host.
 * `DIST_URL`: Sets the URL for your distribution. By default this is using the 
 CDN mirror by Debian, but depending on your country you may want to change this
 to reflect somewhere closer/faster. `netselect` is a utility that can help with
 selecting a good low latency mirror, along with a `wget` or `curl` throughput test.
 * `VM_MEM`: Default memory (in MB) to assign.
 * `VM_CPU`: Default number of vCPUs to assign.
 * `VM_DISK`: Default size (in GB) to allocate.
 * `VM_TYPE`: The type of default VM. You will need to update `default-postinst.sh`
 to contain the type you specify if it does not already exist.
 * `VM_DISKLOC`: Location to create the disk image.
 * `PS_USER_FULLNAME`: Your full name.
 * `PS_USERNAME`: The user name to set the default user to.
 * `PS_LOCALE`: The system locale.
 * `PS_KEYBOARD`: The type of keyboard.
 * `PS_DEB_MIRROR`: The mirror to use for downloading packages. See `DIST_URL` 
 for more selection information. 
 * `PS_TZ`: The timezone to use. Take care to escape the forward slash. 
 Example: `America\/New_York`.
 * `PS_SSHKEY_SOURCE`: The source of the SSH key. Options: `github`, `config`, `user`.
 * `PS_SSHKEY_GITHUB`: The URL to your public key on your git profile. 
 Example: `https://github.com/TaylorBurnham.keys`.
 * `PS_SSHKEY_SET`: If you set `config` for the `PS_SSHKEY_SOURCE` you will need 
 to paste the full contents of the `ssh-rsa` string in this variable. This is
 handy if you use different keys for your lab vs. production.
 
 
Some considerations from Dmitri's original README:
 * It's worth considering to enable password authentication in `preseed.cfg`
   at least during first run so you could `virsh console <GUEST_NAME>` in case
   network connection in guest does not comes up with DHCP or IP of the guest
   is unclear.

Network configuration
---------------------
The script works best with a bridged network where guests are able to use
the local DHCP server. There's other more advanced options you can work with
if you are using completely private networking, but that is not part of my
needed use case. 

You may update `VM_INTERFACE` in the `config.sh` to specify a different
interface.

Below is an example of my network configuration from my test system.

Location: `/etc/network/interfaces`
```
# Loopback
auto lo
iface lo inet loopback

# Primary interface
auto enp6s0
iface enp6s0 inet manual
iface enp6s0 inet6 manual

# br0 for guests
auto br0
iface br0 inet dhcp
  bridge_ports enp6s0 # bridge_ports must point to your primary interface
  bridge_stp off
  bridge_fd 0
  bridge_maxwait 0
```

More Info and References
---------
* https://www.debian.org/releases/stable/example-preseed.txt
* https://github.com/pin/debian-vm-install
* https://wiki.debian.org/Keyboard
* https://wiki.debian.org/Locale