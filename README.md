# arch-simple-installer

#### An extremely basic Arch Linux installer, configuring Arch, GRUB, NetworkManager. ⚠️ No GUI

# Features
- Consistently reproducible
- Installs GRUBv2 portable
- Follows the Arch Wiki verbatim
- AMD and Intel microcode install
- NetworkManager enabled out of the box
- Supports SSH out of the box
- Bare minimum universal installation

# Comparing Alternatives
- [archfi](https://github.com/MatMoul/archfi): Bloated, large final install, lots of steps.
- [aui](https://github.com/helmuthdu/aui): Manual partitioning, over complicated, requires `unzip` package.
- [alis](https://picodotdev.github.io/alis/): Massive configuration file, does far more than the bare minimum.
- arch-simple-installer: minimal configs, bare minimum install.

# Usage
1. Boot Arch Linux live image
2. Connect to the internet
3. check [Usage](./USAGE.md) for more Details

```console
$ wget -O installer bit.ly/3ODSLx4
$ bash installer`
```
