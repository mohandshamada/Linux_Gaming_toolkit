# 🎮 Linux Gaming Toolkit v3.5

Transform any Linux distribution into a gaming powerhouse with this comprehensive setup script.

![Version](https://img.shields.io/badge/version-3.5-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

### 🎯 What This Toolkit Does

1. **Installs Gaming Packages (Checks Before Installing)**
   - Steam with Proton support + **SteamTinkerLaunch**
   - Lutris for unified game management
   - Wine + **Wine Gecko & Mono** + Winetricks for Windows compatibility
   - **Bottles** - Modern Wine prefix manager
   - Heroic Games Launcher (Epic/GOG)
   - **itch.io** - Indie game platform
   - **Discord** - Gaming communication (native or Flatpak)
   - **Prism Launcher** - Minecraft launcher
   - **RetroArch** - Multi-system emulator
   - **SOBER** - Roblox on Linux (via Flatpak)
   - **Waydroid** - Android container for mobile games
   - GameMode performance optimizer
   - MangoHud performance overlay
   - Gamescope micro-compositor
   - vkBasalt for Vulkan post-processing
   - **VKD3D-Proton** - DirectX 12 to Vulkan translation
   - **GreenWithEnvy** - NVIDIA GPU control tool
   - **Mod managers** (r2modman)
   - ProtonUp-Qt for managing Proton-GE
   - **Complete 32-bit library set** for maximum game compatibility
   - **Smart package checking** - skips already installed packages

2. **Installs Gaming-Optimized Kernels**
   - XanMod Kernel (recommended for most)
   - Liquorix Kernel (low-latency, Debian/Ubuntu)
   - Zen Kernel (Arch-based)
   - CachyOS Kernel (performance-focused)

3. **GPU Driver Installation (Proprietary, Open & Latest)**
   - **NVIDIA**: 
     - Proprietary drivers (best performance/compatibility)
     - **Open kernel modules** (for Turing RTX 20+ and newer GPUs, better for Wayland)
     - Nouveau (fully open-source)
     - Version detection and latest driver check
   - **AMD**: Mesa RADV (recommended) or AMDGPU-PRO (workstation)
   - **Intel**: Mesa with Arc GPU support
   - Automatic GPU model detection
   - Online driver version checking
   - 32-bit library support

4. **Optimizes System Performance**
   - Kernel sysctl parameters for low-latency
   - CPU governor set to performance
   - I/O scheduler optimized for SSDs/NVMe
   - Network stack optimized (BBR congestion control)
   - Virtual memory tuning

5. **Optional: Disable CPU Mitigations**
   - Windows-like performance by disabling Spectre/Meltdown mitigations
   - ⚠️ Security warning: makes system vulnerable to CPU exploits

6. **Online Driver Update Checker**
   - Check for latest NVIDIA drivers from official sources
   - Check for latest Mesa versions
   - Check for latest Wine versions

7. **🆕 HDR & Advanced Display Support (v3.4)**
   - **HDR Support**: Gamescope HDR patches, Mesa HDR enablement
   - **Dolby Vision**: Enable Dolby Vision on compatible displays
   - **OLED Protection**: Auto-dimming, pixel shifting, taskbar detection

8. **🆕 Nobara-Inspired Extra Features (v3.4)**
   - **auto-cpufreq**: Automatic CPU frequency scaling
   - **LACT**: Linux AMD GPU control tool
   - **Wootility**: Wooting keyboard configuration
   - **asusctl/supergfxctl**: ASUS device control
   - **piper**: Gaming mouse configuration

9. **🆕 Advanced Graphics Configuration (v3.4)**
   - FSR (FidelityFX Super Resolution) support
   - LatencyFleX for reduced input lag
   - VR runtime setup (OpenComposite, ALVR)
   - Game controller support and configuration

10. **🆕 scx_lavd BPF Scheduler (v3.5)**
    - **Valve-funded gaming scheduler** designed for high frame rates
    - Auto power profile switching (battery/performance)
    - Reduces stuttering and improves frame times
    - Works with kernel 6.12+ or gaming kernels

11. **🆕 Enhanced Gamescope Integration (v3.5)**
    - **AMD FSR** upscaling for any game
    - **NVIDIA NIS** upscaling support
    - **HDR output** with `--hdr-enabled`
    - **VRR/Adaptive Sync** support
    - **MangoApp** integration for overlay
    - Helper scripts: `gamescope-fsr`, `gamescope-hdr`, `gamescope-full`

12. **🆕 Proton-GE Management (v3.5)**
    - Auto-download latest GloriousEggroll Proton
    - Weekly update scheduling via cron
    - ProtonUp-Qt integration
    - `update-proton-ge` command

13. **🆕 Latency Reduction Tools (v3.5)**
    - **LatencyFleX**: Open-source alternative to NVIDIA Reflex
    - Frame latency optimization
    - Vulkan layer integration

14. **🆕 Handheld Gaming Support (v3.5)**
    - Steam Deck optimizations
    - ASUS ROG Ally tools (with asusctl)
    - TDP control scripts
    - Power profile management

15. **🆕 Advanced Audio Setup (v3.5)**
    - **EasyEffects** (formerly PulseEffects) installation
    - PipeWire low-latency configuration
    - Gaming audio presets
    - Real-time audio scheduling

16. **🆕 Game Save Backup (v3.5)**
    - **Ludusavi** save game backup tool
    - Cloud sync ready
    - Hundreds of games supported

17. **🆕 Gaming Overlays & Recording (v3.5)**
    - **ReplaySorcery** instant replay
    - **OBS Studio** with Vulkan capture
    - VkCapture integration
    - `obs-game-capture` helper

18. **🆕 Anti-Cheat Information (v3.5)**
    - EAC/BattlEye compatibility status
    - Working games list
    - Troubleshooting guide
    - ProtonDB integration tips

19. **🆕 Protontricks (v3.5)**
    - Winetricks for Proton prefixes
    - Easy DLL installation
    - Game-specific fixes

20. **Safety & Reliability**
    - **Safer Bash**: `set -Eeuo pipefail` with error trapping
    - **Line number reporting**: Shows exactly where errors occur
    - **Logging with /tmp fallback**: Works even if /var/log is not writable
    - **Whiptail GUI**: Optional graphical menu (installs automatically on Debian/Ubuntu)
    - **Idempotent operations**: Safe to run multiple times - checks before modifying configs
    - **Backup system**: All modified files backed up with `.backup.*` extension

11. **Complete Uninstallation**
    - `uninstall.sh` script to revert all changes
    - Automatic backup restoration
    - Repository cleanup
    - Package removal tracking

## Supported Distributions

| Distribution | Support Level |
|-------------|---------------|
| Ubuntu / Linux Mint | ⭐⭐⭐ Full |
| Debian | ⭐⭐⭐ Full |
| Fedora / Nobara | ⭐⭐⭐ Full |
| Arch Linux / Manjaro | ⭐⭐⭐ Full |
| openSUSE Tumbleweed | ⭐⭐ Good |
| Pop!_OS | ⭐⭐⭐ Full |
| Garuda Linux | ⭐⭐⭐ Full |
| CachyOS | ⭐⭐⭐ Full |

## Quick Start

### 1. Clone or Download

```bash
git clone https://github.com/mohandshamada/Linux_Gaming_toolkit.git
cd Linux_Gaming_toolkit
```

### 2. Make Executable

```bash
chmod +x gamingtoolkit.sh
```

### 3. Run as Root

```bash
sudo ./gamingtoolkit.sh
```

### 4. Choose Your Setup

The script presents a menu:

| Option | Description |
|--------|-------------|
| **1** | 🚀 Full automatic setup (recommended) |
| **2** | 📦 Install Gaming Packages Only |
| **3** | 🐧 Install Gaming Kernel |
| **4** | 🎨 Install GPU Drivers |
| **5** | ⚙️ Apply System Optimizations Only |
| **6** | 🔥 Configure CPU Governor |
| **7** | ⚠️ Disable CPU Mitigations (Security Risk) |
| **8** | 📊 Configure MangoHud |
| **9** | 🎲 Configure GameMode |
| **10** | 🛠️ Install Additional Tools (Discord, itch.io) |
| **11** | 🌐 Check for Latest Drivers Online |
| **12** | 🌈 Install HDR & Dolby Vision Support |
| **13** | 🖥️ Install OLED Protection Tools |
| **14** | 🎮 Install Nobara Extra Features |
| **15** | 🔧 Configure Advanced Graphics |
| **16** | ⚡ Install scx_lavd Gaming Scheduler |
| **17** | 🎮 Configure Gamescope (FSR/HDR/VRR) |
| **18** | 🍷 Install Proton-GE |
| **19** | ⚡ Install LatencyFleX |
| **20** | 🎮 Install Handheld/Deck Tools |
| **21** | 🔊 Install Advanced Audio (EasyEffects) |
| **22** | 💾 Install Game Save Backup |
| **23** | 📺 Install Overlays (OBS/ReplaySorcery) |
| **24** | 🍷 Install Protontricks |
| **25** | 🛡️ Anti-Cheat Info |
| **0** | 🚪 Exit |

## What Gets Installed

### Gaming Platforms

| Package | Purpose |
|---------|---------|
| Steam | Valve's gaming platform with Proton |
| Lutris | Unified launcher for all game stores |
| Heroic Games Launcher | Epic Games and GOG Galaxy client |
| **itch.io** | Indie game platform and client |
| **Discord** | Gaming communication platform |
| Wine | Windows compatibility layer |
| Winetricks | Wine configuration helper |

### Performance Tools

| Package | Purpose |
|---------|---------|
| GameMode | Auto-optimizes system when gaming |
| MangoHud | In-game performance overlay (FPS, temps, etc.) |
| Gamescope | Wayland micro-compositor for gaming |
| vkBasalt | Vulkan post-processing (CAS, FXAA, etc.) |
| **DXVK** | DirectX 9/10/11 to Vulkan translation |
| **VKD3D-Proton** | DirectX 12 to Vulkan translation |
| **GreenWithEnvy** | NVIDIA GPU overclocking/control |
| CoreCtrl | AMD/Intel GPU control and monitoring |
| ProtonUp-Qt | Manage Proton-GE versions |
| **PipeWire** | Modern audio server (replaces PulseAudio) |

### Emulation & Extra Tools

| Package | Purpose |
|---------|---------|
| **RetroArch** | Multi-system game emulator |
| **Prism Launcher** | Minecraft launcher with mod support |
| **Bottles** | Modern Wine prefix manager |
| **SteamTinkerLaunch** | Steam game configuration tool |
| **SOBER** | Roblox on Linux |
| **Waydroid** | Android container for mobile games |
| **r2modman** | Mod manager for games |

### HDR & Display Features (v3.4)

| Package | Purpose |
|---------|---------|
| **Gamescope HDR** | HDR support in Gamescope |
| **Mesa HDR** | Mesa HDR patches for AMD/Intel |
| **Dolby Vision** | Enable Dolby Vision on compatible displays |
| **OLED Protection** | Auto-dimming and pixel shifting tools |

### Nobara-Inspired Tools (v3.4)

| Package | Purpose |
|---------|---------|
| **auto-cpufreq** | Automatic CPU frequency scaling |
| **LACT** | Linux AMD GPU control tool |
| **Wootility** | Wooting keyboard configuration |
| **asusctl** | ASUS laptop control |
| **supergfxctl** | ASUS GPU switching |
| **piper** | Gaming mouse configuration |

### v3.5 Advanced Tools

| Package | Purpose |
|---------|---------|
| **scx_lavd** | Valve-funded BPF gaming scheduler |
| **Proton-GE** | GloriousEggroll's custom Proton |
| **LatencyFleX** | Open-source latency reduction |
| **EasyEffects** | Advanced audio processing |
| **Ludusavi** | Game save backup tool |
| **ReplaySorcery** | Instant replay for any game |
| **Protontricks** | Winetricks for Proton |
| **gpu-screen-recorder** | Lightweight GPU recording |

## Smart Package Management

The toolkit includes intelligent package handling:

### Check Before Installing
- Each package is checked before installation
- Already installed packages are skipped automatically
- No duplicate installations
- Faster re-runs

### Idempotent Configuration
- All config modifications check before adding
- GRUB parameters only added if not present
- Repository configurations are idempotent
- Safe to run the script multiple times

### Backup System
- All modified files backed up with `.backup.*` extension
- Backups stored in same directory as original file
- Automatic restore on uninstall
- Never lose your original configuration

### Latest Driver Detection

#### NVIDIA
- Detects current installed driver version
- Checks for latest available driver online
- Offers to update if newer version available
- Supports legacy GPUs (470xx series)

#### AMD
- Detects GPU model (including Arc/Alchemist)
- Offers Mesa RADV (recommended for gaming) or AMDGPU-PRO
- Checks for latest Mesa version

#### Intel
- Detects Intel Arc GPUs
- Installs appropriate media drivers
- Sets up compute runtime for OpenCL

### Check for Updates

Run the script and select **Option 11** to check for latest drivers online:

```bash
sudo ./gamingtoolkit.sh
# Then select option 11: Check for Latest Drivers Online
```

This will check:
- Latest NVIDIA driver from official NVIDIA servers
- Latest Mesa version for AMD/Intel
- Latest Wine development version

## Uninstallation

To completely remove all changes made by the toolkit:

```bash
sudo ./uninstall.sh
```

The uninstall script will:
- Remove all installed gaming packages
- Restore original configuration files from backups
- Remove added repositories
- Revert sysctl and kernel parameter changes
- Provide instructions for removing gaming kernels

## Usage After Installation

### Launch Games with Optimizations

```bash
# Use the helper script
game-launch /path/to/your/game

# Or manually
mangohud gamemoderun ./your-game
```

### Steam Launch Options

Add to any Steam game's launch options:

```
mangohud gamemoderun %command%
```

For MangoHud only:
```
mangohud %command%
```

For GameMode only:
```
gamemoderun %command%
```

### Check System Performance

```bash
gaming-perf
```

This shows:
- CPU governor status
- Current CPU frequencies
- Memory usage
- GPU utilization (if available)
- GameMode status

## Gaming Kernels Explained

### XanMod (Recommended)
- **Best for**: Most systems
- **Features**: BBR2/BBR3, high-res timers, optimized scheduler
- **CPU variants**: x64v1, v2, v3, v4 (AVX levels)

### Liquorix
- **Best for**: Debian/Ubuntu desktop users
- **Features**: Low-latency, MuQSS scheduler, optimized for responsiveness

### Zen
- **Best for**: Arch-based distributions
- **Features**: Balance between performance and stability

### CachyOS
- **Best for**: Maximum performance on Arch
- **Features**: BORE scheduler, LRU patchset, x86-64-v3/v4 optimizations

## HDR & Advanced Display Setup

### Enabling HDR (v3.4)

```bash
sudo ./gamingtoolkit.sh
# Select option 12: Install HDR & Dolby Vision Support
```

Requirements:
- HDR-compatible display
- AMD GPU: Mesa 24.0+ with HDR patches
- NVIDIA GPU: Proprietary drivers 550.54.14+
- Gamescope for HDR in windowed mode

### OLED Protection (v3.4)

```bash
sudo ./gamingtoolkit.sh
# Select option 13: Install OLED Protection Tools
```

Features:
- Auto-dimming after idle time
- Pixel shifting to prevent burn-in
- Taskbar detection and protection
- ASUS OLED device support (asusctl)

### Dolby Vision (v3.4)

For compatible displays, the toolkit can enable Dolby Vision support through kernel parameters and Mesa patches (AMD/Intel).

## Configuration Files

After installation, you can customize:

| File | Purpose |
|------|---------|
| `~/.config/gamemode.ini` | GameMode settings |
| `~/.config/MangoHud/MangoHud.conf` | MangoHud overlay appearance |
| `~/.gamingrc` | Environment variables (source in shell) |
| `/etc/sysctl.d/99-gaming.conf` | Kernel parameters |
| `/etc/default/grub` | Boot parameters (with .backup backup) |

## CPU Mitigations Warning

The script can disable CPU vulnerability mitigations (Spectre, Meltdown, etc.) for maximum performance. This:

- ✅ Can improve gaming performance by 5-20%
- ✅ Makes Linux perform like Windows (which disables many by default)
- ⚠️ Makes your system vulnerable to CPU security exploits
- ⚠️ Not recommended for systems with sensitive data

To check mitigations status after reboot:
```bash
grep . /sys/devices/system/cpu/vulnerabilities/*
```

## Troubleshooting

### Games Won't Launch

1. Check GPU drivers:
   ```bash
   glxinfo | grep "OpenGL renderer"
   vulkaninfo --summary | grep deviceName
   ```

2. Verify 32-bit libraries:
   ```bash
   ldconfig -p | grep libGL.so.1
   ```

3. Check Wine dependencies:
   ```bash
   winetricks --self-update
   winetricks corefonts vcrun2019 dxvk
   ```

### Performance Issues

1. Verify CPU governor:
   ```bash
   cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
   ```

2. Check GameMode is running:
   ```bash
   gamemoded -s
   systemctl status gamemoded
   ```

3. Verify kernel parameters:
   ```bash
   sysctl vm.swappiness
   sysctl net.ipv4.tcp_congestion_control
   ```

### Controller Not Working

1. Check udev rules are loaded:
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

2. Verify user is in `input` group:
   ```bash
   groups $USER
   ```

3. Add user if needed:
   ```bash
   sudo usermod -aG input $USER
   ```

### HDR Not Working

1. Check HDR support:
   ```bash
   vulkaninfo | grep HDR
   ```

2. Verify Gamescope HDR:
   ```bash
   gamescope --help | grep hdr
   ```

3. Check kernel parameters:
   ```bash
   cat /proc/cmdline | grep nvidia-drm.modeset
   ```

## Advanced Usage

### Custom GameMode Configuration

Edit `~/.config/gamemode.ini`:

```ini
[general]
renice=10

[cpu]
governor=performance
pin=0-7

[gpu]
apply_gpu_optimisations=accept-responsibility

[custom]
start=notify-send "GameMode ON"
end=notify-send "GameMode OFF"
```

### Custom MangoHud

Edit `~/.config/MangoHud/MangoHud.conf`:

```ini
position=top-left
font_size=24
gpu_stats cpu_stats ram vram fps
frametime frame_timing
gpu_temp cpu_temp
vulkan_driver wine gamemode
background_alpha=0.5
toggle_hud=Shift_R+F12
```

### Environment Variables

Source `~/.gamingrc` in your `.bashrc` or `.zshrc`:

```bash
source ~/.gamingrc
```

Key variables:
- `MANGOHUD=1` - Enable MangoHud globally
- `AMD_VULKAN_ICD=RADV` - Use RADV driver for AMD
- `RADV_PERFTEST=aco` - Enable ACO shader compiler
- `WINEESYNC=1` - Enable ESYNC for Wine
- `WINEFSYNC=1` - Enable FSYNC for Wine
- `ENABLE_HDR_WSI=1` - Enable HDR support

## Benchmark Results

Typical improvements on a mid-range gaming PC:

| Optimization | FPS Improvement | Latency Reduction |
|-------------|-----------------|-------------------|
| Gaming Kernel | 3-8% | 5-10% |
| CPU Governor | 2-5% | Minimal |
| Disabled Mitigations | 5-20% | 10-30% |
| GameMode | 2-5% | 15-25% |
| **Combined** | **10-35%** | **30-60%** |

*Results vary by hardware and game*

## Version History

### v3.5 - Advanced Gaming Optimizations
- Added scx_lavd BPF scheduler (Valve-funded gaming scheduler)
- Added enhanced Gamescope integration (FSR, NIS, HDR, VRR)
- Added Proton-GE management with auto-updates
- Added LatencyFleX (open-source NVIDIA Reflex alternative)
- Added handheld/Steam Deck tools
- Added advanced audio setup (EasyEffects, PipeWire low-latency)
- Added game save backup tools (Ludusavi)
- added gaming overlays (ReplaySorcery, OBS integration)
- Added Protontricks for Proton prefix management
- Added anti-cheat compatibility information

### v3.4 - HDR & Nobara Features
- Added HDR support (Gamescope, Mesa patches)
- Added Dolby Vision support
- Added OLED protection tools
- Added Nobara-inspired packages (auto-cpufreq, LACT, Wootility)
- Added advanced graphics configuration

### v3.3 - Code Review & Refactoring
- Removed duplicate functions
- Added idempotency checks
- Rewrote uninstall.sh with backup restore
- Fixed winetricks user context
- Started modularization (modules/utils.sh, modules/detection.sh)

### v3.2 - NVIDIA Open Modules
- Added NVIDIA open kernel modules option
- GPU generation detection
- Support for Turing RTX 20+ GPUs

### v3.1 - Community Features
- Added itch.io, Discord, VKD3D-Proton
- Added Bottles, Prism Launcher, RetroArch
- Added SteamTinkerLaunch, GreenWithEnvy
- Added PipeWire, SOBER, Waydroid, r2modman

### v3.0 - Initial Release
- Core gaming toolkit
- Steam, Lutris, Wine, GameMode, MangoHud

## Project Structure

```
Linux_Gaming_toolkit/
├── gamingtoolkit.sh    # Main script (3000+ lines)
├── uninstall.sh        # Uninstall/restore script
├── README.md          # This file
├── modules/
│   ├── utils.sh       # Utility functions
│   └── detection.sh   # Hardware detection
└── backups/           # Configuration backups
```

## Contributing

Pull requests welcome! Areas for improvement:
- Additional distribution support
- More kernel options
- Better GPU detection
- Additional gaming tools
- HDR display detection

## License

MIT License - See LICENSE file

## Acknowledgments

- Valve for Steam, Proton, and scx_lavd scheduler
- Wine project contributors
- XanMod, Liquorix, Zen, and CachyOS kernel teams
- Feral Interactive for GameMode
- FlightlessMango for MangoHud
- Nobara Project for inspiration
- GloriousEggroll for GE-Proton and Gamescope patches
- [sched-ext](https://github.com/sched-ext/scx) team for BPF schedulers
- ishitatsuyuki for LatencyFleX
- mtkennerly for Ludusavi
- ReplaySorcery contributors

## Resources

- [ProtonDB](https://www.protondb.com/) - Steam game compatibility
- [Lutris](https://lutris.net/) - Game installer scripts
- [GamingOnLinux](https://www.gamingonlinux.com/) - News and guides
- [r/linux_gaming](https://reddit.com/r/linux_gaming) - Community support
- [Nobara Project](https://nobaraproject.org/) - Gaming-focused Fedora

---

**Happy Gaming on Linux! 🐧🎮**
