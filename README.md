![Banner](banner.png)

# 🎮 Linux Gaming Toolkit v3.6

<img src="logo.png" width="120" align="right">

> Transform any Linux distribution into a gaming powerhouse

![Version](https://img.shields.io/badge/version-3.6-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## New in v3.6 (2026 Standards)

- **💾 Automated ZRAM Setup**: Optimized compressed RAM swap for systems with ≤16GB RAM.
- **🔋 Intelligent Power Profiles**: Automatic `power-profiles-daemon` configuration (Performance for Desktops, Balanced for Handhelds).
- **🚀 Kernel 6.14+ NTSync Support**: Native NT synchronization for massive FPS boosts in modern titles.
- **⚡ Sched-ext (scx) Integration**: Support for BPF-based CPU schedulers on Kernels 6.12+.
- **🎮 Handheld Optimized**: Auto-detection and installation of **Decky Loader** for Steam Deck, ROG Ally, and Legion Go.
- **🛠️ Refactored Architecture**: Modular bash design for better reliability and faster updates.
- **📦 2026 Package Stack**: Includes `input-remapper`, `obs-vkcapture`, `Heroic Games Launcher`, and `scx-utils`.
- **🧠 Advanced Idempotency**: Smart checks for `vm.max_map_count` (2.1M+), MGLRU, and Arch multilib.

## Features

### 🎯 What This Toolkit Does

1. **Installs Gaming Packages (Checks Before Installing)**
   - Steam with Proton support + **SteamTinkerLaunch**
   - Lutris for unified game management
   - Wine + **Wine Gecko & Mono** + Winetricks
   - **Bottles** - Modern Wine prefix manager
   - **Heroic Games Launcher** (Epic/GOG)
   - **itch.io** - Indie game platform
   - **Discord** - Gaming communication
   - **Prism Launcher** - Minecraft launcher
   - **SOBER** - Roblox on Linux
   - **Waydroid** - Android container for mobile games
   - GameMode performance optimizer
   - MangoHud performance overlay
   - Gamescope micro-compositor
   - vkBasalt for Vulkan post-processing
   - **obs-vkcapture** - High-performance game recording
   - **input-remapper** - Modern controller/input mapping
   - **ProtonUp-Qt** for managing Proton-GE
   - **Complete 32-bit library set** for maximum compatibility

2. **Installs Gaming-Optimized Kernels**
   - XanMod Kernel (recommended for most)
   - Liquorix Kernel (low-latency, Debian/Ubuntu)
   - Zen Kernel (Arch-based)
   - CachyOS Kernel (performance-focused)

3. **GPU Driver Installation (Proprietary, Open & Latest)**
   - **NVIDIA**: Proprietary drivers or **Open kernel modules** (555+ for Wayland Explicit Sync)
   - **AMD**: Mesa RADV (recommended) or AMDGPU-PRO
   - **Intel**: Mesa with Arc GPU / DG2 support
   - Automatic GPU model detection and online version checking

4. **Optimizes System Performance**
   - **ZRAM**: Automated compressed RAM swap
   - **Power Profiles**: Automatic performance tuning
   - **NTSync**: Kernel-level sync for Wine (6.14+)
   - **vm.max_map_count**: Increased to `2147483642` for modern AAA titles
   - **MGLRU**: Multi-Gen LRU enablement
   - Network stack optimized (BBR congestion control)

5. **Handheld Support**
   - Auto-detection of Steam Deck, ROG Ally, Legion Go, GPD, etc.
   - Installation of **Decky Loader**
   - Handheld-specific power management

## Supported Distributions

| Distribution | Support Level |
|-------------|---------------|
| Ubuntu / Linux Mint / Pop!_OS | ⭐⭐⭐ Full |
| Debian | ⭐⭐⭐ Full |
| Fedora / Nobara | ⭐⭐⭐ Full |
| Arch Linux / Manjaro / CachyOS | ⭐⭐⭐ Full |
| openSUSE Tumbleweed | ⭐⭐ Good |

## Quick Start

### 1. Clone or Download

```bash
git clone https://github.com/mohandshamada/Linux_Gaming_toolkit.git
cd Linux_Gaming_toolkit
```

### 2. Run the Script

```bash
chmod +x gamingtoolkit.sh
sudo ./gamingtoolkit.sh
```

### 3. Choose Your Setup

| Option | Description |
|--------|-------------|
| **1** | 🚀 Full Setup (Recommended) - Install everything automatically |
| **2** | 📦 Install Gaming Packages Only |
| **3** | 🐧 Install Gaming Kernel |
| **4** | 🎨 Install GPU Drivers |
| **5** | ⚙️ Apply System Optimizations Only |
| **6** | 💾 Setup ZRAM |
| **7** | 🔋 Setup Power Profiles |
| **8** | 🔥 Configure CPU Governor |
| **9** | ⚠️ Disable CPU Mitigations (Security Risk) |
| **10** | 📊 Configure MangoHud |
| **11** | 🎲 Configure GameMode |
| **12** | 🛠️ Install Additional Tools (Discord, Heroic, itch.io) |
| **13** | 🌐 Check for Latest Drivers Online |
| **14** | 🎮 Install Handheld/Deck Tools |
| **0** | 🚪 Exit |

## Performance Benchmarks (2026)

| Optimization | FPS Improvement | Frame Stability (1% Lows) |
|-------------|-----------------|-------------------|
| NTSync (Kernel 6.14+) | 15-40% | ⭐⭐⭐ Huge |
| Sched-ext (scx) | 5-10% | ⭐⭐ Better |
| Disabled Mitigations | 5-20% | ⭐ Significant |
| GameMode + ZRAM | 2-5% | ⭐ Noticeable |

## Safety & Reliability
- **Safer Bash**: `set -Eeuo pipefail` with error trapping
- **Modular Design**: Separated detection and utility modules
- **Idempotency**: Safe to run multiple times without duplicate configurations
- **Backup system**: All modified files are backed up automatically

## Uninstallation
Revert all changes easily:
```bash
sudo ./uninstall.sh
```

## License
MIT License - See LICENSE file

---
**Happy Gaming on Linux! 🐧🎮**
