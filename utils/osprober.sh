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
# Chech Internet Connection
if ! ping -c1 archlinux.org ;then
	err "Connect to Internet & try again!";fi

# check you Superuser Permissions
if [[  $EUID -ne 0 ]]; then
	err "Run as Root User"
	exit 0;fi

echo ""
echo ""
prompt "Customize Grub Bootmenu [Yes]: "
read PATCH
PATCH=${PATCH:-Yes}

echo ""
echo ""
printf "%-16s\t%-16s\n" "CONFIGURATION" "VALUE"
printf "%-16s\t%-16s\n" "Customize Grub" "$PATCH"
echo ""

# Installing os-prober
pacman -Sy --noconfirm --needed os-prober grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --recheck

# Customization & config
if [ "$PATCH" = "Yes" ];then
	sed -i "/#GRUB_DISABLE_OS_PROBER/"'s/^#//' /etc/default/grub #Enable os-prober
	sed -i "s/\(GRUB_DISTRIBUTOR=\"\)[^\"]*\"/\1Archlinux\"/" /etc/default/grub #set Distro name in grub to ArchLinux
	sed -i "s/OS=\"\${GRUB_DISTRIBUTOR} Linux\"/OS=\"\${GRUB_DISTRIBUTOR}\"/" /etc/grub.d/10_linux #bootmenu display only Distro name
	sed -i "s/Loading Linux/Loading \${OS}/" /etc/grub.d/10_linux #display distro name instead of Linux on boot load screen

	echo "Adding Restart To Bootmenu Entry"
	echo '
	menuentry "Restart" {
		echo "Rebooting System..."
		reboot
	}' >> /etc/grub.d/40_custom

	echo "Adding Shutdown To Bootmenu Entry"
	echo '
	menuentry "Shutdown" {
		echo "System Shutting Down..."
		halt
	}' >> /etc/grub.d/40_custom

	grub-mkconfig -o /boot/grub/grub.cfg
else
	sed -i "/#GRUB_DISABLE_OS_PROBER/"'s/^#//' /etc/default/grub #Enable os-prober
	grub-mkconfig -o /boot/grub/grub.cfg
fi
