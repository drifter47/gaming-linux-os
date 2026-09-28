#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="gaming-os"
iso_label="GAMING_OS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Gaming OS Project <https://github.com/gaming-os>"
iso_application="Gaming OS Live/Installation Media (Optimized for Gaming)"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
build_modes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/usr/local/bin/gpu-driver-detect"]="0:0:755"
  ["/usr/local/bin/gaming-system-check"]="0:0:755"
  ["/usr/local/bin/launch-installer"]="0:0:755"
)
