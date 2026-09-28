# Gaming OS 🎮

A bleeding-edge, performance-tuned Arch Linux distribution engineered from the ground up for high-performance PC gaming. Features an optimized `linux-zen` kernel, universal multi-GPU support with Wayland explicit synchronization, a turnkey gaming launcher suite, and automatic snapshot rollbacks via Btrfs & Snapper.

---

## ⚡ Key Highlights

- **KDE Plasma 6 on Wayland**: Native support for High Dynamic Range (HDR), Variable Refresh Rate (VRR / FreeSync / G-Sync), fractional scaling, and color management.
- **Gaming-Optimized Kernel**: `linux-zen` kernel with Fsync/Futex2 low-latency synchronization and interactive process scheduling.
- **Universal Multi-GPU Stack**:
  - **AMD Radeon**: Open-source Mesa RADV Vulkan driver with Graphics Pipeline Library (GPL) caching.
  - **Intel Arc / Xe**: Open-source ANV Vulkan driver and media runtimes.
  - **NVIDIA GeForce**: Proprietary DKMS drivers (560+ series) pre-configured with Wayland explicit sync to eliminate stuttering and tearing.
  - **Dual-GPU Laptops**: Automated GPU offloading via `switcheroo-control`.
- **System-Level Latency & Stability Tweaks**:
  - `vm.max_map_count = 2147483642`: Prevents out-of-memory crashes in massive games (Star Citizen, Counter-Strike 2, UE5 titles).
  - `kernel.split_lock_mitigate = 0`: Eliminates bus-lock micro-stutters in Wine and Proton games.
  - **ZRAM Compressed Swap**: High-speed compressed in-memory swap utilizing `zstd`.
  - **Feral GameMode & Ananicy**: Automatic CPU governor boost and process priority tuning when games launch.
- **Turnkey Gaming Suite Pre-installed**:
  - **Steam** (Native + Proton GE readiness)
  - **Heroic Games Launcher** (Epic Games Store, GOG, Amazon Prime Games)
  - **Lutris & Bottles** (EA App, Battle.net, Ubisoft Connect, custom Wine prefixes)
  - **ProtonUp-Qt** (One-click Proton-GE and Wine-GE installer)
  - **MangoHud & Goverlay** (In-game FPS, frametime, GPU/CPU metrics and configuration GUI)
  - **Plug-and-Play Controller Support**: Udev rules for DualSense (PS5), DualShock 4, Xbox One / Series X, Nintendo Switch Pro, and Steam Deck controllers.
- **Calamares GUI Installer & Btrfs Snapper**:
  - Graphical installer supporting Windows dual-booting.
  - Default Btrfs layout with subvolumes (`@`, `@home`, `@snapshots`).
  - Automatic pre/post package upgrade snapshots for instant rollback.

---

## 📁 Repository Blueprint

```
.
├── .github/workflows/
│   └── build-iso.yml                 # Automated Cloud build & GitHub Releases
├── airootfs/                         # Rootfs overlay injected into the live system
│   ├── etc/
│   │   ├── calamares/                # Calamares GUI installer configuration
│   │   │   ├── modules/              # Subvolume, partitioning, and boot modules
│   │   │   └── settings.conf         # Installer module sequence
│   │   ├── security/limits.d/        # Memlock and file descriptor limits for Fsync
│   │   ├── sysctl.d/                 # Gaming sysctl performance tuning
│   │   ├── systemd/                  # ZRAM generator configuration
│   │   ├── udev/rules.d/             # Gamepad and NVIDIA power management rules
│   │   └── skel/                     # Live desktop shortcuts & autostart
│   └── usr/local/bin/
│       ├── gpu-driver-detect         # Automatic GPU detector & driver activator
│       ├── gaming-system-check       # System health & performance diagnostics TUI
│       └── launch-installer          # Calamares graphical launcher wrapper
├── efiboot/                          # UEFI systemd-boot configuration
├── syslinux/                         # Legacy BIOS bootloader configuration
├── packages.x86_64                   # Complete list of packages and drivers
├── pacman.conf                       # Pacman config with multilib & chaotic mirrors
├── profiledef.sh                     # Archiso profile metadata and permissions
├── Dockerfile                        # Containerized reproducible build environment
├── build.sh                          # Universal local build orchestration script
└── README.md
```

---

## 🛠️ How to Build the ISO

You have two simple options to compile your ISO:

### Option 1: Cloud Build via GitHub Actions (Zero Local Setup)
1. Push this repository to a GitHub repository:
   ```bash
   git init
   git add .
   git commit -m "feat: initial gaming os profile"
   git remote add origin https://github.com/<your-username>/<repo-name>.git
   git push -u origin main
   ```
2. In GitHub, navigate to **Actions** -> **Build Gaming OS ISO** -> Click **Run workflow**.
3. When the build finishes, download the generated `.iso` and `sha256sum.txt` from the GitHub Release or Workflow Artifacts.

---

### Option 2: Local Build using Docker (Windows, macOS, or Linux)
Requires Docker Desktop (with Linux containers) or Docker on Linux:

```bash
# Make the build script executable (on Linux/WSL2)
chmod +x build.sh

# Run containerized build
./build.sh docker
```
The finished ISO image will be placed into the `./out/` directory.

---

### Option 3: Native Build on Arch Linux / Arch WSL2
If you are already running an Arch-based distribution:

```bash
sudo pacman -S --needed archiso
sudo ./build.sh native
```

---

## 🧪 Testing the ISO in a Virtual Machine

Before flashing to a physical USB drive, test the ISO in QEMU:

```bash
qemu-system-x86_64 \
    -enable-kvm \
    -m 4G \
    -smp 4 \
    -vga virtio \
    -display sdl,gl=on \
    -cdrom out/gaming-os-*.iso
```

---

## 💾 Flashing to a USB Drive

### Recommended: Ventoy
1. Install [Ventoy](https://www.ventoy.net) onto a USB drive.
2. Drag and drop the generated `gaming-os-*.iso` file directly onto the USB drive partition.
3. Boot your PC and select the ISO from the Ventoy menu.

### Rufus (Windows)
1. Open Rufus and select your USB flash drive.
2. Select the `gaming-os-*.iso` file.
3. When prompted, select **Write in DD Image mode**.

### dd (Linux CLI)
```bash
sudo dd if=out/gaming-os-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```
*(Replace `/dev/sdX` with your USB drive identifier — do not write to your internal drive!)*

---

## 🎮 Post-Installation & Gaming Quickstart

### Verify Gaming Optimizations
Open a terminal or click the **Gaming Diagnostics** icon on your desktop to run:
```bash
gaming-system-check
```
This confirms that:
- Fsync & futex2 kernel support are active.
- `vm.max_map_count` is set to `2147483642`.
- ZRAM compressed swap is enabled.
- Connected gamepads are detected without root permissions.

### In-Game Performance HUD (MangoHud)
MangoHud is pre-installed. To display FPS, GPU/CPU temperatures, and frametimes in any game:
- **Steam games**: In game Properties -> Launch Options, add:
  ```text
  mangohud %command%
  ```
- **Heroic / Lutris**: Enable the MangoHud toggle switch in the game settings menu.
- **Customization GUI**: Launch `Goverlay` from the application launcher to customize HUD appearance, metrics, and keybindings.

### System Rollback with Snapper
If an update ever causes an issue with a driver or game:
1. Open the application launcher and start **Btrfs Assistant**.
2. Select **Snapper** -> View snapshots created before system updates.
3. Click **Restore** to revert your system state in seconds without losing files in your `/home` folder.
