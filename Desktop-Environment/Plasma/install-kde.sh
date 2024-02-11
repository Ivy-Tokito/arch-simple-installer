#!/usr/bin/env bash

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

# check you Superuser Permissions
if [[  $EUID -ne 0 ]]; then
	echo "Run as Root User"
	exit 0;fi

# Chech Internet Connection
if ! ping -c1 archlinux.org ;then
	err "Connect to Internet & try again!";fi

# Configuration
prompt "Standard Username [user]: "
read USERNAME
USERNAME=${USERNAME:-user}

prompt "User Password [pass]: "
read -s USER_PASSWORD
USER_PASSWORD=${USER_PASSWORD:-pass} && echo

prompt "User as Root $USERNAME [y/N]: "
read USER_AS_ROOT
[[ "$USER_AS_ROOT" = "y" ]] && USER_AS_ROOT=Yes || USER_AS_ROOT=No

# Configuration
echo ""
echo ""
printf "%-16s\t%-16s\n" "CONFIGURATION" "VALUE"
printf "%-16s\t%-16s\n" "Username:" "$USERNAME"
printf "%-16s\t%-16s\n" "User Password:" "$(echo "$USER_PASSWORD" | sed 's/./*/g')"
printf "%-16s\t%-16s\n" "User as Root:" "$USER_AS_ROOT"

echo ""
prompt "Proceed? [y/N]: "
read PROCEED
[[ "$PROCEED" != "y" ]] && err "User chose not to proceed. Exiting."

# Instal and Setup sudo
pacman -Sy --noconfirm --needed sudo
groupadd sudo

# Setup user
useradd -m "$USERNAME"
echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USERNAME
if [ "$USER_AS_ROOT" = "Yes" ];then
	usermod -aG sudo "$USERNAME";fi

# Don't ask passwd for sudo # only for $USERNAME
echo "## Allow $USERNAME to execute any root command
%$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Pacman Configuration
sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 4/" "/etc/pacman.conf"
sed -i "s/#Color/Color/" "/etc/pacman.conf"

#Install KDE Plasma Desktop Environment
pacman -Sy --noconfirm --needed plasma-meta
systemctl enable sddm.service

#Install Additional Utils
pacman -Sy --noconfirm --needed dolphin ark konsole

# Remove discover it doesn't work out of the box without flatpak
pacman -Rdd --noconfirm discover
sed -i "s/#IgnorePkg   =/IgnorePkg   = discover/" "/etc/pacman.conf"
