#!/bin/bash
set -euo pipefail

cmdline="quiet"

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
if [ -d /sys/firmware/efi/efivars/ ]; then
    parted "$1" mklabel gpt
    parted "$1" mkpart primary 0 1000
    parted "$1" name 1 BOOT
    parted "$1" set 1 esp on
    parted "$1" mkpart primary 1000 100%
    parted "$1" name 2 ROOT
else
    parted "$1" mklabel gpt
    parted "$1" mkpart primary 0 1
    parted "$1" set 1 bios_grub on
    parted "$1" mkpart primary 1 1000
    parted "$1" name 2 BOOT
    parted "$1" mkpart primary 1000 100%
    parted "$1" name 3 ROOT
fi

# setup root volume group, either on a luks device or something else
case "$2" in
    none)
	vgcreate rootvol /dev/disk/by-partlabel/ROOT
	;;
    disk)
	head -c 4096 /dev/urandom > /tmp/keyfile
	if ! cryptsetup isLuks /dev/disk/by-partlabel/ROOT; then
	    cryptsetup luksFormat /dev/disk/by-partlabel/ROOT /tmp/keyfile -q
	fi
	if ! dmsetup ls | grep -q '^root\s'; then
	    cryptsetup open /dev/disk/by-partlabel/ROOT root --key-file /tmp/keyfile
	fi
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
rootfs=ext4
mkfs -t $rootfs -n ROOT /dev/rootvol/root
mount /dev/disk/by-label/ROOT /mnt
mkdir -m000 /mnt/boot
mkfs -t vfat -n BOOT /dev/disk/by-partlabel/BOOT
mount /dev/disk/by-label/BOOT /mnt/boot

# setup hibernation swap space
case "$2" in
    disk)
	mkswap -L SWAP /dev/rootvol/swap
	swapon /dev/rootvol/swap
	cmdline="$cmdline resume=/dev/rootvol/swap"
	;;
esac

# final install step
pacstrap /mnt base grub efibootmgr ansible
genfstab -U /mnt > /mnt/etc/fstab
if [ -f /tmp/keyfile ]; then
    uuid="$(cryptsetup luksUUID /dev/disk/by-partlabel/ROOT)"
    install -D -m000 /tmp/keyfile /mnt/etc/keyfiles/"$uuid"
    echo root UUID="$uuid" none discard > /mnt/etc/crypttab.initramfs
fi
sed -i "/GRUB_CMDLINE_LINUX_DEFAULT=/s/\".*\"/\"$cmdline\"/" /mnt/etc/default/grub
arch-chroot /mnt mkinitcpio -P
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
if [ -d /sys/firmware/efi/efivars/ ]; then
    arch-chroot /mnt grub-install --efi-directory /boot
else
    arch-chroot /mnt grub-install "$1"
fi
