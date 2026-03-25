# Configuration Examples

This document provides various configuration presets for different gaming scenarios.

## Table of Contents

1. [MangoHud Presets](#mangohud-presets)
2. [GameMode Presets](#gamemode-presets)
3. [Steam Launch Options](#steam-launch-options)
4. [Environment Variables](#environment-variables)

---

## MangoHud Presets

### Minimal (FPS Only)

Create `~/.config/MangoHud/minimal.conf`:

```ini
fps
fps_limit=0
frame_timing=0
font_size=18
position=top-left
background_alpha=0
```

Usage: `MANGOHUD_CONFIGFILE=~/.config/MangoHud/minimal.conf mangohud %command%`

### Detailed (All Stats)

Create `~/.config/MangoHud/detailed.conf`:

```ini
# Position and Style
position=top-left
font_size=20
background_alpha=0.4
alpha=1.0

# GPU Info
gpu_stats
gpu_temp
gpu_power
gpu_name
gpu_fan
gpu_voltage
vulkan_driver

# CPU Info
cpu_stats
cpu_temp
cpu_power
cpu_mhz
cpu_load_change

# System Info
ram
vram
swap
battery
fps
frametime
frame_timing
fps_limit=0

# Extra Info
time
version
wine
gamemode
vkbasalt
hdr
refresh_rate
resolution

# I/O
io_read
io_write

# Toggle
toggle_hud=Shift_R+F12
```

### Esports/Competitive

Create `~/.config/MangoHud/esports.conf`:

```ini
# Minimal but essential info for competitive gaming
fps
frametime
frame_timing
font_size=16
position=top-right
background_alpha=0.3

# Disable anything that might cause stutter
gpu_stats=0
cpu_stats=0
ram=0

# Always visible, no toggle
no_display=0
```

### RTSS Style (MSI Afterburner-like)

Create `~/.config/MangoHud/rtss.conf`:

```ini
# Classic RTSS layout
position=top-left
font_size=16
background_alpha=0.6
alpha=0.9

# Layout in columns
columns=2

# Hardware monitoring
gpu_stats
gpu_temp
cpu_stats
cpu_temp
ram
vram

# FPS and timing
fps
frametime
frame_timing

# Colors
gpu_color=76C900
cpu_color=EB5B00
vram_color=A3D900
ram_color=00A3D9
fps_color=FFD900

# Toggle
toggle_hud=Shift_R+F12
```

---

## GameMode Presets

### Laptop Power Saving

Create `~/.config/gamemode-laptop.ini`:

```ini
[general]
; Lower priority to save battery
renice=5

[cpu]
; Use ondemand governor on battery
governor=ondemand

[gpu]
; Don't apply aggressive GPU settings
apply_gpu_optimisations=0

[supervisor]
priority=5
```

### Desktop Maximum Performance

Create `~/.config/gamemode-performance.ini`:

```ini
[general]
; Highest priority
renice=-5

[cpu]
; Performance governor
governor=performance
; Pin to physical cores only (adjust for your CPU)
pin=0-7

[gpu]
; Apply GPU optimizations
apply_gpu_optimisations=accept-responsibility
; NVIDIA specific
nv_powermizer_mode=1

[supervisor]
priority=-5

[custom]
; Notifications
start=notify-send "🎮 GameMode" "Performance mode activated"
end=notify-send "🎮 GameMode" "Performance mode deactivated"
; Disable compositor (X11)
start=bash -c "if command -v qdbus &> /dev/null; then qdbus org.kde.KWin /Compositor suspend; fi"
end=bash -c "if command -v qdbus &> /dev/null; then qdbus org.kde.KWin /Compositor resume; fi"
```

### Streaming Setup

Create `~/.config/gamemode-streaming.ini`:

```ini
[general]
renice=0

[cpu]
; Keep some headroom for streaming software
governor=performance

[custom]
; Start streaming software when game starts
start=bash -c "pgrep obs || (obs &"
; Optional: Set OBS to lower priority
start=bash -c "sleep 5 && renice +10 $(pgrep obs)"
```

---

## Steam Launch Options

### Basic Setup

```bash
# Just MangoHud
mangohud %command%

# Just GameMode
gamemoderun %command%

# Both
mangohud gamemoderun %command%
```

### AMD GPU Optimizations

```bash
# Enable ACO shader compiler (usually default now)
RADV_PERFTEST=aco mangohud gamemoderun %command%

# Enable all RADV optimizations
RADV_PERFTEST=aco,gpl,nggc mangohud gamemoderun %command%

# Disable DCC for troubleshooting
RADV_DEBUG=nodcc mangohud %command%
```

### NVIDIA GPU Optimizations

```bash
# Disable composition pipeline (reduce latency)
__GL_SYNC_TO_VBLANK=0 mangohud gamemoderun %command%

# Force NVIDIA GPU on Optimus laptops
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia mangohud %command%

# Enable threaded optimizations
__GL_THREADED_OPTIMIZATIONS=1 mangohud %command%
```

### Intel GPU Optimizations

```bash
# Disable render buffer compression for compatibility
INTEL_DEBUG=norbc mangohud %command%

# Enable compute shaders
INTEL_DEBUG=cs mangohud %command%
```

### Proton-Specific Options

```bash
# Use specific Proton version
STEAM_COMPAT_DATA_PATH=/path/to/prefix %command%

# Enable ESYNC (legacy, use FSYNC instead)
PROTON_USE_ESYNC=1 %command%

# Enable FSYNC (recommended)
PROTON_USE_FSYNC=1 %command%

# Disable D3D11 (force DXVK)
PROTON_USE_WINED3D=0 %command%

# Force specific DirectX version
PROTON_NO_D3D11=1 PROTON_NO_D3D10=1 %command%  ; Force DX9

# Disable intro videos
PROTON_NO_ESYNC=1 %command%

# For games with controller issues
PROTON_ENABLE_HIDRAW=1 %command%

# For older games
PROTON_OLD_GL_STRING=1 %command%
```

### Gamescope (Wayland/Steam Deck)

```bash
# 720p scaled to display
gamescope -W 1280 -H 720 -r 60 -- mangohud %command%

# FSR upscaling
gamescope -W 1920 -H 1080 -r 144 -F fsr -- mangohud %command%

# Integer scaling for pixel art games
gamescope -W 1280 -H 720 -r 60 -S integer -- %command%

# With mangoapp (integrated hud)
gamescope -W 1920 -H 1080 -r 60 --mangoapp -- %command%
```

### Combined Example

```bash
# Maximum performance setup for AMD
gamemoderun RADV_PERFTEST=aco,gpl,nggc AMD_VULKAN_ICD=RADV mangohud %command%

# Maximum performance for NVIDIA
__GL_SYNC_TO_VBLANK=0 __GL_THREADED_OPTIMIZATIONS=1 gamemoderun mangohud %command%

# Troubleshooting mode (disable optimizations)
RADV_DEBUG=nohiz,nodcc PROTON_USE_WINED3D=1 %command%
```

---

## Environment Variables

### Gaming Session (.gamingrc)

```bash
# ~/.gamingrc - Source this in your shell profile

# MangoHud
export MANGOHUD=1
export MANGOHUD_CONFIGFILE="$HOME/.config/MangoHud/MangoHud.conf"

# AMD GPU
export AMD_VULKAN_ICD=RADV
export RADV_PERFTEST=aco,gpl,nggc
export mesa_glthread=true

# Intel GPU
export INTEL_DEBUG=norbc
export INTEL_GPU_BOOST=1

# NVIDIA GPU
export __GL_SYNC_TO_VBLANK=0
export __GL_THREADED_OPTIMIZATIONS=1

# Wine/Proton
export WINEESYNC=1
export WINEFSYNC=1
export PROTON_USE_FSYNC=1
export PROTON_NO_ESYNC=0

# Steam
export STEAM_RUNTIME=1

# GameMode
export GAMEMODERUN=1

# Performance
export CPU_PERF_MODE=performance
```

### Per-Game Variables

Create `~/.config/game-envs`:

```bash
# Source this file: source ~/.config/game-envs

# Cyberpunk 2077
export CYBERPUNK_ENV="RADV_PERFTEST=aco mangohud"

# Elden Ring
export ELDENRING_ENV="gamemoderun PROTON_USE_FSYNC=1 mangohud"

# CS2
export CS2_ENV="mangohud -c ~/.config/MangoHud/esports.conf"
```

---

## Desktop Environment Optimizations

### KDE Plasma

```bash
# Disable compositor for gaming
# Add to GameMode start script:
qdbus org.kde.KWin /Compositor suspend

# Re-enable:
qdbus org.kde.KWin /Compositor resume
```

### GNOME

```bash
# Disable animations
gsettings set org.gnome.desktop.interface enable-animations false

# Re-enable
gsettings set org.gnome.desktop.interface enable-animations true
```

### XFCE

```bash
# Disable compositor
xfconf-query -c xfwm4 -p /general/use_compositing -s false

# Re-enable
xfconf-query -c xfwm4 -p /general/use_compositing -s true
```

---

## Troubleshooting Presets

### Maximum Compatibility Mode

```bash
# For problematic games
PROTON_USE_WINED3D=1      # Use OpenGL instead of Vulkan/DXVK
PROTON_NO_ESYNC=1         # Disable ESYNC
PROTON_NO_FSYNC=1         # Disable FSYNC
PROTON_DISABLE_NVAPI=1    # Disable NVAPI
RADV_DEBUG=nohiz,nodcc    # Disable RADV optimizations
%command%
```

### Debug Mode

```bash
# Enable detailed logging
PROTON_LOG=1 DXVK_LOG_LEVEL=info MANGOHUD_LOG_LEVEL=debug %command%
```

### VR Mode

```bash
# For SteamVR games
gamemoderun mangohud %command%
# Ensure MangoHud is disabled in VR - use VR's native overlay
```

---

## Automated Setup Script

Create `~/setup-gaming-env.sh`:

```bash
#!/bin/bash
# Setup optimal gaming environment

# CPU governor
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance > "$cpu" 2>/dev/null || true
done

# Disable NMI watchdog
echo 0 > /proc/sys/kernel/nmi_watchdog 2>/dev/null || true

# Disable transparent huge pages
echo never > /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || true

# Network optimizations
sysctl -w net.ipv4.tcp_congestion_control=bbr 2>/dev/null || true

echo "Gaming environment ready!"
```

Usage:
```bash
sudo ./setup-gaming-env.sh
```
