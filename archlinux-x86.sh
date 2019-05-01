#!/bin/bash
set -euo pipefail

cmdline="quiet"
rootfs=ext4

case "$0" in
    sh|bash)
	echo "Do not run this script through a pipe." >&2
	exit 1
	;;
esac

curl https://www.archlinux.org/mirrorlist/\?country=CA | sed s/#// > /etc/pacman.d/mirrorlist || true

# get rid of artifacts from previous run
umount -R /mnt || true
swapoff -a || true
vgremove -ff rootvol || true
killall lvmetad || true
cryptsetup close root || true
: > /tmp/fstab
rm -f /tmp/fstab /tmp/keyfile /tmp/crypttab.initramfs

set +u
disk="$1"
set -u
if ! [ -b "$disk" ]; then
    echo "First argument, OS disk, must be a block device to install to." >&2
    exit 1
fi
parted="parted -s -a optimal $disk"
if [ -d /sys/firmware/efi/efivars/ ]; then
    $parted mklabel gpt
    $parted mkpart primary 0 1024
    $parted name 1 BOOT
    $parted set 1 esp on
    $parted mkpart primary 1024 100%
    $parted name 2 ROOT
else
    $parted mklabel gpt
    $parted mkpart primary 0 1
    $parted set 1 bios_grub on
    $parted mkpart primary 1 1024
    $parted name 2 BOOT
    $parted mkpart primary 1024 100%
    $parted name 3 ROOT
fi

# sleep to prevent race condition
sleep 1

# setup root volume group, either on a luks device or something else
set +u
enc="$2"
set -u
case "$enc" in
    none)
	vgcreate -f rootvol /dev/disk/by-partlabel/ROOT
	;;
    disk)
	head -c 4096 /dev/urandom > /tmp/keyfile
	cryptsetup luksFormat /dev/disk/by-partlabel/ROOT /tmp/keyfile -q # format with keyfile
	cryptsetup luksAddKey /dev/disk/by-partlabel/ROOT # add password boot
	uuid="$(cryptsetup luksUUID /dev/disk/by-partlabel/ROOT)"
	cryptsetup open /dev/disk/by-partlabel/ROOT root --key-file /tmp/keyfile
	echo root UUID="$uuid" none discard >> /tmp/crypttab.initramfs
	vgcreate -f rootvol /dev/mapper/root
	;;
    *)
	echo "Second argument, encryption, must be one of 'none' or 'disk'." >&2
	exit 1
	;;
esac

# create logical volumes based on system factors
memk="$(awk '$1=="MemTotal:"{print $2}' /proc/meminfo)"
lvcreate -L "$memk"k rootvol -n swap
lvcreate -l 100%FREE rootvol -n root

# create root partition
mkfs -t $rootfs -L ROOT /dev/rootvol/root
mount /dev/rootvol/root /mnt
echo LABEL=ROOT / auto defaults 0 0 >> /tmp/fstab
mkdir -m000 /mnt/boot
mkfs.vfat -n BOOT /dev/disk/by-partlabel/BOOT
mount /dev/disk/by-partlabel/BOOT /mnt/boot
echo LABEL=BOOT /boot auto defaults 0 0 >> /tmp/fstab

# setup hibernation swap space
case "$enc" in
    disk)
	mkswap -L SWAP /dev/rootvol/swap
	swapon /dev/rootvol/swap
	echo LABEL=SWAP none swap nofail 0 0 >> /tmp/fstab
	cmdline="$cmdline resume=/dev/rootvol/swap"
	;;
esac

# install basic archlinux
pacstrap /mnt base grub efibootmgr ansible git lastpass-cli

# copy configuration files in
cp /tmp/fstab /mnt/etc/
mkdir /mnt/etc/ansible/facts.d/
if [ -f /tmp/keyfile ]; then
    cp /tmp/crypttab.initramfs /mnt/etc/
    install -D -m000 /tmp/keyfile /mnt/etc/keyfiles/"$uuid"
    echo "\"$uuid\"" > /mnt/etc/ansible/facts.d/encrypted_disk.fact
fi

# configure grub
sed -i "/GRUB_CMDLINE_LINUX_DEFAULT=/s|\".*\"|\"$cmdline\"|" /mnt/etc/default/grub
sed -i "/^GRUB_TIMEOUT=/s/=.*/=2/" /mnt/etc/default/grub
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# install grub
if [ -d /sys/firmware/efi/efivars/ ]; then
    arch-chroot /mnt grub-install --efi-directory /boot
else
    arch-chroot /mnt grub-install --force "$disk"
fi

# configure initcpio
boothooks="systemd autodetect sd-vconsole sd-encrypt sd-lvm2 modconf block keyboard filesystems fsck"
sed -i "/^HOOKS/s/.*/HOOKS=($boothooks)/" /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -P

# chroot and open a shell
systemd-nspawn -D /mnt -a
