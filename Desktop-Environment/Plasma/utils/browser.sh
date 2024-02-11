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
if ! ping -c1 archlinux.org ;then
	err "Connect to Internet & try again!";fi

prompt "Browser [waterfox-g-kde]: "
read BROWSER
BROWSER=${BROWSER:-waterfox-g-kde}

# Configuration
echo ""
echo ""
printf "%-16s\t%-16s\n" "CONFIGURATION" "VALUE"
printf "%-16s\t%-16s\n" "Browser:" "$BROWSER"

# Install Browser
case $BROWSER in
	waterfox-g-kde)
   # Install Waterfox-G-Kde
   echo '
   ## Prebuilt Waterfox Repo
   [home_hawkeye116477_waterfox_Arch]
   Server = https://downloadcontent.opensuse.org/repositories/home:/hawkeye116477:/waterfox/Arch/$arch
   Server = https://download.opensuse.org/repositories/home:/hawkeye116477:/waterfox/Arch/$arch' >> /etc/pacman.conf
   #Install Keyring
   key=$(curl -fsSL https://download.opensuse.org/repositories/home:hawkeye116477:waterfox/Arch/$(uname -m)/home_hawkeye116477_waterfox_Arch.key)
   fingerprint=$(gpg --quiet --with-colons --import-options show-only --import --fingerprint <<< "${key}" | awk -F: '$1 == "fpr" { print $10 }')

   pacman-key --init
   pacman-key --add - <<< "${key}"
   pacman-key --lsign-key "${fingerprint}"
   pacman -Sy --noconfirm --needed waterfox-g-kde
	 echo "waterfox-g-kde Install Completed!"
	;;

 firefox)
   pacman -Sy --noconfirm --needed firefox
	 echo "firefox Install Completed!"
	;;

 chromium)
   pacman -Sy --noconfirm --neded chromium
	 echo "chromium Install Completed!"
	;;

 falkon)
   pacman -Sy --noconfirm --neded falkon
	 echo "falkon Install Completed!"
	;;

 *)
   err "Browser Not found"
	;;
esac
