#!/usr/bin/env bash
# Written by Draco (tytydraco @ GitHub)

# Exit on any error
set -e
clear

err() {
	echo -e " \e[91m*\e[39m $*"
	exit 1
}

prompt() {
	echo -ne " \e[92m*\e[39m $*"
}

# Check internet Connection
if ! ping -c1 archlinux.org ;then
err "Connect to Internet & try again!";fi

# Configuration
lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS

prompt "Boot [/dev/sda#]: "
read BOOT_EFI
[[ ! -b "$BOOT_EFI" ]] && err "Partition does not exist. Exiting."

prompt "Root [/dev/sda#]: "
read ROOT
[[ ! -b "$ROOT" ]] && err "Partition does not exist. Exiting."

# Home Partition setup
prompt "Seprate Home Partition [y/N]: "
if [[ "$HOME_REQUIRED" = "y" ]];then

	prompt "Format Home Partition [y/N]: "
	read FORMAT_HOME
	[[ "$FORMAT_HOME" = "y" ]] && FORMAT_HOME=Yes || FORMAT_HOME=No

	prompt "Home [/dev/sda#]: "
	read HOMEO
	[[ ! -b "$HOMEO" ]] && err "Partition does not exist. Exiting."
fi

prompt "Filesystem [ext4]: "
read FILESYSTEM
FILESYSTEM=${FILESYSTEM:-ext4}
! command -v mkfs."$FILESYSTEM" &> /dev/null && err "Filesystem type does not exist. Exiting."

prompt "Timezone [Asia/Kolkata]: "
read TIMEZONE
TIMEZONE=${TIMEZONE:-Asia/Kolkata}
[[ ! -f "/usr/share/zoneinfo/$TIMEZONE" ]] && err "/usr/share/zoneinfo/$TIMEZONE does not exist. Exiting."

prompt "Mirror Country [India]: "
read COUNTRY
COUNTRY=${COUNTRY:-India}

prompt "Hostname [archlinux]: "
read HOSTNAME
HOSTNAME=${HOSTNAME:-archlinux}

prompt "SSH [no]: "
read SSH
SSH=${SSH:-no}

prompt "Password [root]: "
read -s PASSWORD
PASSWORD=${PASSWORD:-root}

echo ""
echo ""
printf "%-16s\t%-16s\n" "CONFIGURATION" "VALUE"
printf "%-16s\t%-16s\n" "Root & Home Filesystem:" "$FILESYSTEM"
printf "%-16s\t%-16s\n" "Boot Partition [EFI]:" "$BOOT_EFI"
printf "%-16s\t%-16s\n" "Root Partition:" "$ROOT"
printf "%-16s\t%-16s\n" "Home Partition:" "$HOMEO"
printf "%-16s\t%-16s\n" "Format Home Partition:" "$FORMAT_HOME"
printf "%-16s\t%-16s\n" "Timezone:" "$TIMEZONE"
printf "%-16s\t%-16s\n" "Mirror Country:" "$COUNTRY"
printf "%-16s\t%-16s\n" "Hostname:" "$HOSTNAME"
printf "%-16s\t%-16s\n" "Password:" "$(echo "$PASSWORD" | sed 's/./*/g')"
printf "%-16s\t%-16s\n" "SSH:" "$SSH"
echo ""
prompt "Proceed? [y/N]: "
read PROCEED
[[ "$PROCEED" != "y" ]] && err "User chose not to proceed. Exiting."

# Unmount for safety
umount "$BOOT_EFI" 2> /dev/null || true
umount "$ROOT" 2> /dev/null || true
if [ "$HOME_REQUIRED" = "Yes" ];then
	umount "$HOMEO" 2> /dev/null || true ;fi

# Timezone
timedatectl set-ntp true

# Formatting partitions
if [[ $(blkid "$BOOT_EFI" | grep -o 'TYPE="[^"]*"' | awk -F '"' '{print $2}') != "vfat" ]];then
	err "Unsupported Boot Partition: $BOOT_EFI. Exiting";fi

echo "Formating Root Partition: $ROOT"
yes | mkfs."$FILESYSTEM" "$ROOT"

if [ "$FORMAT_HOME" = "Yes" ];then
	echo "Formating Home Partition: $HOMEO"
	yes | mkfs."$FILESYSTEM" "$HOMEO";fi

# Mount our new partition
mount --mkdir "$BOOT_EFI" /mnt/boot && sleep 3 # Delay to avoid race condition
mount "$ROOT" /mnt && sleep 3
if [ "$HOME_REQUIRED" = "y" ];then
  mount --mkdir "$HOMEO" /mnt/home;fi

# Update Mirrors
echo "Backup Current Mirrorlist"
cp -v /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

echo "Updating Mirrors"
reflector --save /etc/pacman.d/mirrorlist --country "$COUNTRY" --sort rate --latest 10 --verbose

# Enable Parallel downloading
sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 4/" /etc/pacman.conf
sed -i "s/#Color/Color/" /etc/pacman.conf

# Initialize base system, kernel, and firmware
pacstrap -K /mnt base linux linux-firmware

# Setup fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot commands
(
	# Time and date configuration
	echo "ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime"
	echo "hwclock --systohc"

	# Setup locales
	echo "sed -i \"s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/\" /etc/locale.gen"
	echo "locale-gen"
	echo "echo \"LANG=en_US.UTF-8\" > /etc/locale.conf"

	# Setup hostname and hosts file
	echo "echo \"$HOSTNAME\" > /etc/hostname"
	echo "echo -e \"127.0.0.1\tlocalhost\" >> /etc/hosts"
	echo "echo -e \"::1\t\tlocalhost\" >> /etc/hosts"
	echo "echo -e \"127.0.1.1\t$HOSTNAME\" >> /etc/hosts"
	echo "echo -e \"$PASSWORD\n$PASSWORD\" | passwd"

	# Install microcode
	echo "pacman -Sy --noconfirm --needed amd-ucode intel-ucode"

	# Install GRUBv2
	echo "pacman -Sy --noconfirm --needed grub efibootmgr"
	echo "grub-install --target=x86_64-efi --efi-directory=/boot --recheck"
	echo "grub-mkconfig -o /boot/grub/grub.cfg"

	# Install and enable NetworkManager on boot
	echo "pacman -Sy --noconfirm --needed networkmanager"
	echo "systemctl enable NetworkManager"

	# Launch Bluetoothd on boot
	echo "pacman -Sy --noconfirm --needed bluez"
	echo "systemctl enable bluetooth"

	# Enable SSH server out of the box
	if [[ "$SSH" == "yes" ]]
	then
		echo "pacman -Sy --noconfirm --needed openssh"
		echo "sed -i \"s/#PermitRootLogin prohibit-password/PermitRootLogin yes/\" /etc/ssh/sshd_config"
		echo "systemctl enable sshd"
	fi
) | arch-chroot /mnt

echo "Basic ArchLinux Install completed."
