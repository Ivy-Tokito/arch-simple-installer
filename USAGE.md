## Arch-Simple-Installer Usage Guide

#### An extremely basic Arch Linux installer, configuring Arch, GRUB, NetworkManager. ⚠️ No GUI | No Desktop Environment.

## Boot ArchLinux Live Image
   * Download ISO image from [ArchLinux](https://archlinux.org/download/)
   * Flash ISO to pendrive using tools like [Rufus](https://rufus.ie/en/), [Etcher](https://etcher.balena.io/#download-etcher), [EtchDroid](https://github.com/EtchDroid/EtchDroid/releases) (Android)
     * Directly Boot ISO using tools like [Ventoy](https://www.ventoy.net/en/download.html), [DriveDroid](https://www.apkmirror.com/apk/softwarebakery/drivedroid/) (Android)-Requires Root
   * Connect Flashed USB to Desktop|Laptop & boot to BIOS
   * Search for Boot options & Change Boot Priority to your USB. Save & Reboot

## Partition the disks
[Check Archlinux Guide on Partition](https://wiki.archlinux.org/title/Installation_guide?Nobodycanhelpyouifyoudon%27tspecifyyouractualissue#Partition_the_disks)
* Check All Avilable Disk and Partition Using `lsblk`
* Partition it Using cfdisk /dev/sdX (where sdX is your Disk NAME from lsblk)
   * Create 3 Partitions for Boot, Root and Home (optional)
      * Boot patition: Set it's Size to 1G, Type to `EFI System`
      * Root Partition: Set Size Accordingly,Type to `Linux`
      * (optional) Home Partition: Set it's Size Accordingly,Type to `Linux`
* Format your Boot Partition (Not included in install Script)

```shell
mkfs.fat -F 32 /dev/efi_system_partition
```

## Example Partition Layout
| Mount Point    | Partition                 | Partition Type      | Filesystem Type       | Recomended Size |
| :--------------| :-------------------------| :-------------------| :---------------------|:----------------|
| /boot          | /dev/efi_system_partition | EFI system partition|vfat (fat32)           | 512M-1G         |
| /root          | /dev/root_partition       | linux               |ext4 or btrfs & others | 28-32G          |
|(optional) /home| /dev/home_partition       | linux               |ext4 or btrfs & others | 100-200G        |


## Connecting To Internet
#### check all Avilable network interface using `ip link`
<details><summary><b>Using <a href="https://wiki.archlinux.org/title/Iwd">IDW</a></b></summary>
<ul>
<li> iwctl to enter interactive mode</li>
   <ul>
   <li> <b>device list</b> to get list of all avilable wireless network device (usually wlan0)</li>
   <li> <b>station wlan0 scan</b> to scan for networks</li>
   <li> <b>station wlan0 get-networks</b> to list all avilable wifi networks</li>
   <li> <b>station connect "$NETWORK NAME"</b> to connect</li>
   <li> Passphrase will be asked interactively (if required)</li>
  </ul>
</ul>
Note: replace <b>wlan0</b> with your wireless device name from (device list)

<ul> if you know ssid(Network Name) & Passphrase</ul>
</details>

```shell
iwctl --passphrase $PHASSPHRASE station device connect SSID
```

<details><summary><b>Using <a href="https://wiki.archlinux.org/title/NetworkManager">NetworkManager</a></b></summary>
<ul>
 <li> nmcli device wifi list to list all avilable wifi networks</li>
</ul>
</details>

 ```shell
nmcli device wifi connect "$SSID" password "$PASSWORD"
```

**Check your Internet Connection**

```shell
ping -c1 archlinux.org
```

## Installation
#### Download the script & Run it

```console
$ wget -O installer bit.ly/3ODSLx4
$ bash installer
```

**Configs**
```shell
Boot [/dev/sda#]: #/dev/boot_partition
Root [/dev/sda#]: #/dev/root_partition
Seprate Home Partition [y/N]: #chose to have an Home partition (should already be Partitioned)
Format Home Partition [y/N]: #if you are new partitioned disk then select y #N to Keep the data
Home [/dev/sda#]: #/dev/home_partition
Filesystem [ext4]: #choice of Filesystem #Default:ext4
#Note: Both Root & Home Partition will use this filesystem
Timezone [Asia/Kolkata]: #Enter your Timezone for System Time #Default: Asia/Kolkata
Mirror Country [India]: #ArchLinux Package Mirror ranked based on country #check Usefull links #Default: India
Hostname [archlinux]: #System Hostname #Can be changed later in /etc/hostname
SSH [no]: #Install & enable ssh out of box if yes
Password [root]: #root user password #Default: root
```

* For entire list of Timezones
```shell
timedatectl list-timezones > zones
```
## os-prober
* To Detect other os in disk **(Dual-Boot)** Install os-prober
```console
$ wget -o osprober https://bit.ly/3OD8wnP
$ bash osprober
```

## Usefull Links
* [Reflector](https://wiki.archlinux.org/title/Reflector)
* [ArchLinux Mirrors](https://archlinux.org/mirrorlist)

## Example
```shell
NAME        TYPE   SIZE FSTYPE MOUNTPOINTS
nvme1n1     disk 931.5G        
|-nvme1n1p1 part   100M vfat   
|-nvme1n1p2 part    16M        
|-nvme1n1p3 part    65G ntfs   
|-nvme1n1p4 part   512G ntfs
|-nvme1n1p5 part     1G vfat
|-nvme1n1p6 part    32G    
|-nvme1n1p7 part   200G    
nvme0n1     disk 476.9G        
|-nvme0n1p1 part 476.9G ext4

CONFIGURATION           VALUE           
Root & Home Filesystem: ext4            
Boot Partition [EFI]:   /dev/nvme1n1p5  
Root Partition:         /dev/nvme1n1p6  
Home Partition:         /dev/nvme1n1p7
Format Home Partition:  Yes            
Timezone:               Asia/Kolkata    
Mirror Country:         India           
Hostname:               archlinux       
Password:               ****            
SSH:                    no  
```
