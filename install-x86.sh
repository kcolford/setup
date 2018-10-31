#!/bin/bash
set -euo pipefail

case "$0" in
    sh|bash)
	echo "Do not run this script through a pipe." >&2
	exit 1
	;;
esac

if ! [ -b "$1" ]; then
    echo "First argument, OS disk, must be a block device to install to." >&2
    exit 1
fi
disk="$1"
if [ -d /sys/firmware/efi/efivars/ ]; then
    parted "$disk" mklabel gpt
    parted "$disk" mkpart primary 0 1000
    parted "$disk" name 1 BOOT
    parted "$disk" set 1 esp on
    parted "$disk" mkpart primary 1000 100%
    parted "$disk" name 2 ROOT
else
    parted "$disk" mklabel gpt
    parted "$disk" mkpart primary 0 1
    parted "$disk" set 1 bios_grub on
    parted "$disk" mkpart primary 1 1000
    parted "$disk" name 2 BOOT
    parted "$disk" mkpart primary 1000 100%
    parted "$disk" name 3 ROOT
fi

# setup root volume group, either on a luks device or something else
case "$2" in
    none)
	vgcreate rootvol /dev/disk/by-partlabel/ROOT
	;;
    disk)
	cp -a /etc/keyfile /tmp/ || head -c 4096 /dev/urandom > /tmp/keyfile
	if ! cryptsetup isLuks /dev/disk/by-partlabel/ROOT; then
	    cryptsetup luksFormat /dev/disk/by-partlabel/ROOT /tmp/keyfile -q
	    # cryptsetup luksAddKey /dev/disk/by-partlabel/ROOT --key-file /tmp/keyfile
	fi
	if ! dmsetup ls | grep -q '^root\s'; then
	    cryptsetup open /dev/disk/by-partlabel/ROOT root --key-file /tmp/keyfile
	fi
	echo root /dev/disk/by-partlabel/ROOT none discard > /tmp/crypttab.initramfs
	vgcreate rootvol /dev/mapper/root
	;;
    *)
	echo "Second argument, encryption, must be one of 'none' or 'disk'." >&2
	exit 1
	;;
esac

# create logical volumes based on system factors
lvcreate -L "$(awk '$1=="MemTotal:"{print $2}' /proc/meminfo)"k rootvol -n swap
lvcreate -l 100%FREE rootvol -n root

# create root partition
mkfs -t ext4 -n ROOT /dev/rootvol/root
mount /dev/disk/by-label/ROOT /mnt
mkdir -m000 /mnt/boot
mkfs -t vfat -n BOOT /dev/disk/by-partlabel/BOOT
mount /dev/disk/by-label/BOOT /mnt/boot

# setup hibernation swap space
case "$2" in
    disk)
	mkswap -L SWAP /dev/rootvol/swap
	swapon /dev/rootvol/swap
	;;
esac

# final install step
pacstrap /mnt base ansible
genfstab -U /mnt > /mnt/etc/fstab
cp -aT /tmp/keyfile /mnt/etc/keyfile || true
cp -aT /tmp/crypttab.initramfs /mnt/etc/crypttab.initramfs || true
