#!/bin/bash
#
# Linux Gaming Toolkit - Enhanced Uninstall Script
# Reverts changes made by the gaming toolkit
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging
LOG_FILE="/var/log/gamingtoolkit-uninstall.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

# Check root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}     Linux Gaming Toolkit - Enhanced Uninstall${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}⚠️  This will remove:${NC}"
echo "   • Gaming packages (Steam, Lutris, Wine, etc.)"
echo "   • Gaming kernel (if installed)"
echo "   • System optimizations"
echo "   • Configuration files"
echo "   • Added repositories"
echo "   • Custom scripts and tools"
echo ""
echo -e "${CYAN}📋 Log file: $LOG_FILE${NC}"
echo ""

read -p "Are you sure you want to continue? [y/N]: " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo "Select what to remove:"
echo "  1) Everything (full uninstall with repository cleanup)"
echo "  2) Gaming packages only"
echo "  3) System optimizations only"
echo "  4) Gaming kernel only"
echo "  5) Restore backups only"
echo "  6) Cancel"
echo ""
read -p "Enter choice [1-6]: " choice

# Detect distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|debian|linuxmint|pop|elementary|zorin|kubuntu|xubuntu|lubuntu|neon)
            DISTRO_FAMILY="debian"
            DISTRO_NAME="$NAME"
            ;;
        fedora|rhel|centos|rocky|almalinux|nobara)
            DISTRO_FAMILY="fedora"
            DISTRO_NAME="$NAME"
            ;;
        arch|manjaro|endeavouros|garuda|cachyos|artix)
            DISTRO_FAMILY="arch"
            DISTRO_NAME="$NAME"
            ;;
        opensuse*|suse*)
            DISTRO_FAMILY="suse"
            DISTRO_NAME="$NAME"
            ;;
    esac
fi

# Track what was removed
REMOVED_ITEMS=()

log_removal() {
    REMOVED_ITEMS+=("$1")
    echo -e "${GREEN}✓ $1${NC}"
}

# ============================================
# RESTORE BACKUPS
# ============================================

restore_backups() {
    echo -e "${BLUE}Restoring backup files...${NC}"
    
    local backup_found=false
    
    # Restore GRUB backups
    for backup in /etc/default/grub.backup.*; do
        if [ -f "$backup" ]; then
            echo "  Restoring: $backup → /etc/default/grub"
            cp "$backup" /etc/default/grub
            update-grub 2>/dev/null || grub-mkconfig -o /boot/grub/grub.cfg
            backup_found=true
            log_removal "Restored GRUB config from backup"
            break
        fi
    done
    
    # Restore pacman.conf backups (Arch)
    if [ "$DISTRO_FAMILY" == "arch" ]; then
        for backup in /etc/pacman.conf.backup.*; do
            if [ -f "$backup" ]; then
                echo "  Restoring: $backup → /etc/pacman.conf"
                cp "$backup" /etc/pacman.conf
                backup_found=true
                log_removal "Restored pacman.conf from backup"
                break
            fi
        done
    fi
    
    # Restore sysctl backups
    for backup in /etc/sysctl.conf.backup.*; do
        if [ -f "$backup" ]; then
            echo "  Restoring: $backup → /etc/sysctl.conf"
            cp "$backup" /etc/sysctl.conf
            backup_found=true
            log_removal "Restored sysctl.conf from backup"
            break
        fi
    done
    
    # Restore modprobe backups
    for backup in /etc/modprobe.d/*.backup.*; do
        if [ -f "$backup" ]; then
            local original="${backup%.backup.*}"
            echo "  Restoring: $backup → $original"
            cp "$backup" "$original"
            backup_found=true
            log_removal "Restored $(basename "$original") from backup"
        fi
    done
    
    if [ "$backup_found" = false ]; then
        echo -e "${YELLOW}  No backup files found to restore${NC}"
    fi
}

# ============================================
# REMOVE REPOSITORIES
# ============================================

remove_repositories() {
    echo -e "${BLUE}Removing added repositories...${NC}"
    
    case "$DISTRO_FAMILY" in
        debian)
            # Function to remove a repo by searching for its URL pattern
            remove_debian_repo() {
                local pattern="$1"
                local name="$2"
                local keyfile="$3"
                local found_files=$(grep -l "$pattern" /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources 2>/dev/null || true)
                
                if [ -n "$found_files" ]; then
                    for file in $found_files; do
                        rm -f "$file"
                    done
                    if [ -n "$keyfile" ]; then
                        rm -f "$keyfile"
                    fi
                    log_removal "$name"
                fi
            }

            remove_debian_repo "dl.winehq.org" "WineHQ repository" "/etc/apt/keyrings/winehq-archive.key"
            remove_debian_repo "ppa:kisak/kisak-mesa" "kisak-mesa PPA" "/usr/share/keyrings/kisak-*.gpg"
            remove_debian_repo "proget.makedeb.org" "Prism Launcher repository" "/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg"
            remove_debian_repo "repo.waydro.id" "Waydroid repository" "/usr/share/keyrings/waydroid.gpg"
            remove_debian_repo "deb.xanmod.org" "XanMod repository" "/usr/share/keyrings/xanmod-archive-keyring.gpg"
            
            apt update
            ;;
            
        fedora)
            # Remove RPM Fusion (optional - ask user)
            echo -e "${YELLOW}Note: RPM Fusion provides many useful packages beyond gaming${NC}"
            read -p "Remove RPM Fusion repositories? [y/N]: " remove_rpmfusion
            if [[ "$remove_rpmfusion" =~ ^[Yy]$ ]]; then
                dnf remove -y rpmfusion-free-release rpmfusion-nonfree-release 2>/dev/null || true
                log_removal "RPM Fusion repositories"
            fi
            
            # Remove Prism Launcher COPR
            if dnf repolist | grep -q "prismlauncher"; then
                dnf copr remove -y g3tchoo/prismlauncher 2>/dev/null || true
                log_removal "Prism Launcher COPR"
            fi
            
            # Remove XanMod COPR
            if dnf repolist | grep -q "kernel-xanmod"; then
                dnf copr remove -y rmnscnce/kernel-xanmod 2>/dev/null || true
                log_removal "XanMod COPR"
            fi
            ;;
            
        arch)
            # Remove CachyOS repository if present
            if grep -q "^\[cachyos\]" /etc/pacman.conf; then
                # Remove the cachyos repo section
                sed -i '/^\[cachyos\]/,/^$/d' /etc/pacman.conf
                rm -f /etc/pacman.d/cachyos-mirrorlist
                log_removal "CachyOS repository"
            fi
            ;;
            
        suse)
            # Remove Packman repository
            if zypper repos | grep -q packman; then
                zypper removerepo -f packman 2>/dev/null || true
                log_removal "Packman repository"
            fi
            
            # Remove NVIDIA repository
            if zypper repos | grep -q NVIDIA; then
                zypper removerepo -f NVIDIA 2>/dev/null || true
                log_removal "NVIDIA repository"
            fi
            ;;
    esac
}

# ============================================
# REMOVE PACKAGES
# ============================================

remove_packages() {
    echo -e "${BLUE}Removing gaming packages...${NC}"
    
    case "$DISTRO_FAMILY" in
        debian)
            # Remove gaming packages
            apt remove -y --purge \
                steam-installer steam-devices steam-launcher \
                lutris lutris-db \
                wine wine64 wine32 winetricks wine-gecko wine-mono \
                gamemode gamemode-daemon libgamemode0 \
                mangohud mangohud-common \
                vulkan-tools vulkan-validationlayers \
                gamescope \
                corectrl \
                goverlay \
                vkbasalt \
                obs-studio obs-plugins \
                prismlauncher \
                retroarch \
                bottles \
                flatpak \
                waydroid \
                pipewire pipewire-pulse wireplumber \
                easyeffects pulseeffects \
                protontricks 2>/dev/null || true
            
            # Remove NVIDIA drivers if present
            apt remove -y --purge \
                nvidia-driver nvidia-settings nvidia-xconfig nvidia-cuda-toolkit \
                nvidia-open-driver 2>/dev/null || true
                
            # Autoremove dependencies
            apt autoremove -y
            ;;
            
        fedora)
            dnf remove -y \
                steam \
                lutris \
                wine winetricks \
                gamemode \
                mangohud \
                vulkan-tools \
                gamescope \
                corectrl \
                vkBasalt \
                obs-studio \
                prismlauncher \
                retroarch \
                pipewire wireplumber \
                easyeffects \
                protontricks \
                lact asusctl supergfxctl \
                powertop tlp 2>/dev/null || true
            
            # Remove NVIDIA drivers
            dnf remove -y akmod-nvidia akmod-nvidia-open 2>/dev/null || true
            
            dnf autoremove -y
            ;;
            
        arch)
            pacman -Rns --noconfirm \
                steam \
                lutris \
                wine wine-gecko wine-mono winetricks \
                gamemode lib32-gamemode \
                mangohud lib32-mangohud \
                vulkan-tools vulkan-icd-loader lib32-vulkan-icd-loader \
                gamescope \
                corectrl \
                goverlay \
                vkBasalt lib32-vkBasalt \
                obs-studio obs-vkcapture \
                prismlauncher \
                retroarch libretro-core-info \
                steamtinkerlaunch \
                gwe \
                pipewire wireplumber \
                waydroid \
                easyeffects \
                protontricks \
                lact asusctl supergfxctl \
                scx-scheds \
                powertop tlp \
                replaysorcery gpu-screen-recorder \
                protonup-qt protonup 2>/dev/null || true
            
            # Remove NVIDIA drivers
            pacman -Rns --noconfirm nvidia nvidia-open nvidia-dkms nvidia-open-dkms nvidia-utils 2>/dev/null || true
            ;;
            
        suse)
            zypper remove -y \
                steam \
                lutris \
                wine winetricks \
                gamemode \
                mangohud \
                vulkan-tools \
                gamescope \
                obs-studio \
                pipewire wireplumber \
                powertop tlp 2>/dev/null || true
            
            # Remove NVIDIA drivers
            zypper remove -y nvidia-driver nvidia-open-driver 2>/dev/null || true
            ;;
    esac
    
    log_removal "Gaming packages"
}

# ============================================
# REMOVE OPTIMIZATIONS
# ============================================

remove_optimizations() {
    echo -e "${BLUE}Reverting system optimizations...${NC}"
    
    # Remove sysctl config
    if [ -f /etc/sysctl.d/99-gaming.conf ]; then
        rm -f /etc/sysctl.d/99-gaming.conf
        log_removal "Gaming sysctl config"
    fi
    
    # Remove udev rules
    if [ -f /etc/udev/rules.d/60-ioschedulers.rules ]; then
        rm -f /etc/udev/rules.d/60-ioschedulers.rules
        log_removal "I/O scheduler udev rules"
    fi
    
    if [ -f /etc/udev/rules.d/99-steam-controller.rules ]; then
        rm -f /etc/udev/rules.d/99-steam-controller.rules
        log_removal "Steam controller udev rules"
    fi
    
    # Remove systemd services
    if [ -f /etc/systemd/system/cpu-performance.service ]; then
        systemctl stop cpu-performance.service 2>/dev/null || true
        systemctl disable cpu-performance.service 2>/dev/null || true
        rm -f /etc/systemd/system/cpu-performance.service
        systemctl daemon-reload
        log_removal "CPU performance service"
    fi
    
    # Reset sysctl to defaults
    sysctl --system 2>/dev/null || true
    
    # Restore CPU governor
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "schedutil" > "$cpu" 2>/dev/null || echo "ondemand" > "$cpu" 2>/dev/null || true
        done
        log_removal "CPU governor reset to default"
    fi
    
    # Remove modprobe configs
    if [ -f /etc/modprobe.d/blacklist-nouveau.conf ]; then
        rm -f /etc/modprobe.d/blacklist-nouveau.conf
        log_removal "Nouveau blacklist"
    fi
    
    if [ -f /etc/modprobe.d/nvidia-open.conf ]; then
        rm -f /etc/modprobe.d/nvidia-open.conf
        log_removal "NVIDIA open module config"
    fi
    
    if [ -f /etc/modprobe.d/nvidia-performance.conf ]; then
        rm -f /etc/modprobe.d/nvidia-performance.conf
        log_removal "NVIDIA performance config"
    fi
    
    if [ -f /etc/modprobe.d/amdgpu-performance.conf ]; then
        rm -f /etc/modprobe.d/amdgpu-performance.conf
        log_removal "AMDGPU performance config"
    fi
    
    if [ -f /etc/modprobe.d/nvidia-modeset.conf ]; then
        rm -f /etc/modprobe.d/nvidia-modeset.conf
        log_removal "NVIDIA modeset config"
    fi
}

# ============================================
# REMOVE KERNEL
# ============================================

remove_kernel() {
    echo -e "${BLUE}Gaming kernel removal instructions:${NC}"
    echo ""
    
    case "$DISTRO_FAMILY" in
        debian)
            echo "To remove gaming kernels, run:"
            echo -e "${CYAN}  apt remove linux-xanmod*${NC}"
            echo -e "${CYAN}  apt remove linux-image-liquorix*${NC}"
            ;;
        fedora)
            echo "To remove gaming kernels, run:"
            echo -e "${CYAN}  dnf remove kernel-xanmod*${NC}"
            ;;
        arch)
            echo "To remove gaming kernels, run:"
            echo -e "${CYAN}  pacman -R linux-zen linux-zen-headers${NC}"
            echo -e "${CYAN}  pacman -R linux-cachyos linux-cachyos-headers${NC}"
            echo -e "${CYAN}  pacman -R linux-xanmod linux-xanmod-headers${NC}"
            ;;
    esac
    
    echo ""
    echo "Then reboot to complete the removal."
}

# ============================================
# REMOVE V3.5 FEATURES
# ============================================

remove_v34_features() {
    echo -e "${BLUE}Removing v3.4 HDR & Nobara features...${NC}"
    
    # Remove HDR/OLED related services
    systemctl stop oled-protection.service 2>/dev/null || true
    systemctl disable oled-protection.service 2>/dev/null || true
    rm -f /etc/systemd/system/oled-protection.service
    
    # Remove HDR modprobe configs
    rm -f /etc/modprobe.d/amdgpu-hdr.conf
    rm -f /etc/modprobe.d/nvidia-hdr.conf
    
    # Remove Nobara packages
    case "$DISTRO_FAMILY" in
        arch)
            pacman -Rns --noconfirm lact asusctl supergfxctl 2>/dev/null || true
            pacman -Rns --noconfirm auto-cpufreq wootility piper 2>/dev/null || true
            pacman -Rns --noconfirm sunshine umu-launcher v4l2loopback-dkms 2>/dev/null || true
            ;;
        fedora)
            dnf remove -y lact asusctl supergfxctl 2>/dev/null || true
            dnf remove -y auto-cpufreq wootility piper 2>/dev/null || true
            dnf remove -y sunshine umu-launcher v4l2loopback 2>/dev/null || true
            dnf copr remove -y lizardbyte/beta 2>/dev/null || true
            ;;
        debian|ubuntu)
            apt remove -y --purge lact asusctl supergfxctl 2>/dev/null || true
            apt remove -y --purge auto-cpufreq wootility piper 2>/dev/null || true
            ;;
    esac
    
    log_removal "v3.4 HDR & Nobara features"
}

remove_v35_features() {
    echo -e "${BLUE}Removing v3.5 advanced features...${NC}"
    
    # Remove scx_lavd scheduler
    echo "  Removing scx_lavd scheduler..."
    systemctl stop scx.service 2>/dev/null || true
    systemctl disable scx.service 2>/dev/null || true
    rm -f /etc/systemd/system/scx.service
    rm -f /etc/default/scx
    
    case "$DISTRO_FAMILY" in
        arch)
            pacman -Rns --noconfirm scx-scheds 2>/dev/null || true
            ;;
        fedora)
            dnf remove -y scx-scheds 2>/dev/null || true
            ;;
        debian|ubuntu)
            apt remove -y --purge scx-scheds 2>/dev/null || true
            ;;
    esac
    log_removal "scx_lavd scheduler"
    
    # Remove Gamescope helper scripts
    echo "  Removing Gamescope helper scripts..."
    rm -f /usr/local/bin/gamescope-fsr
    rm -f /usr/local/bin/gamescope-nis
    rm -f /usr/local/bin/gamescope-hdr
    rm -f /usr/local/bin/gamescope-mango
    rm -f /usr/local/bin/gamescope-full
    log_removal "Gamescope helper scripts"
    
    # Remove Proton-GE updater
    rm -f /usr/local/bin/update-proton-ge
    log_removal "Proton-GE update script"
    
    # Remove LatencyFleX
    echo "  Removing LatencyFleX..."
    rm -f /usr/share/vulkan/implicit_layer.d/latencyflex.json
    rm -f /usr/lib/liblatencyflex.so
    rm -f /usr/lib32/liblatencyflex.so
    log_removal "LatencyFleX"
    
    # Remove handheld tools
    echo "  Removing handheld tools..."
    rm -f /usr/local/bin/tdp-control
    case "$DISTRO_FAMILY" in
        arch)
            pacman -Rns --noconfirm steamdeck-dsp jupiter-hw-support powertop tlp 2>/dev/null || true
            ;;
        fedora|debian|ubuntu)
            dnf remove -y powertop tlp 2>/dev/null || true
            apt remove -y --purge powertop tlp 2>/dev/null || true
            ;;
    esac
    log_removal "Handheld tools"
    
    # Remove advanced audio configs
    echo "  Removing advanced audio configuration..."
    rm -f /etc/pipewire/pipewire.conf.d/10-lowlatency.conf
    rm -f /etc/pipewire/client.conf.d/10-lowlatency.conf
    
    case "$DISTRO_FAMILY" in
        arch)
            pacman -Rns --noconfirm easyeffects pipewire-pulse pipewire-jack 2>/dev/null || true
            ;;
        fedora)
            dnf remove -y easyeffects 2>/dev/null || true
            ;;
        debian|ubuntu)
            apt remove -y --purge easyeffects pulseeffects 2>/dev/null || true
            ;;
    esac
    log_removal "Advanced audio tools"
    
    # Remove Ludusavi
    rm -f /usr/local/bin/ludusavi
    log_removal "Ludusavi save backup tool"
    
    # Remove gaming overlays
    echo "  Removing gaming overlays..."
    rm -f /usr/local/bin/obs-game-capture
    rm -f /etc/replaysorcery.conf
    
    case "$DISTRO_FAMILY" in
        arch)
            pacman -Rns --noconfirm obs-vkcapture replaysorcery gpu-screen-recorder 2>/dev/null || true
            ;;
        fedora)
            dnf remove -y obs-vkcapture 2>/dev/null || true
            ;;
    esac
    log_removal "Gaming overlays"
    
    # Remove Protontricks
    case "$DISTRO_FAMILY" in
        arch)
            pacman -Rns --noconfirm protontricks 2>/dev/null || true
            ;;
        fedora|debian|ubuntu)
            pip3 uninstall -y protontricks 2>/dev/null || true
            ;;
    esac
    log_removal "Protontricks"
    
    # Remove v3.5 documentation
    rm -f /usr/share/doc/linux-gaming-toolkit/GAMESCOPE.md
    rm -f /usr/share/doc/linux-gaming-toolkit/ANTICHEAT.md
    
    # Remove Proton-GE (ask user)
    echo ""
    echo -e "${YELLOW}Proton-GE is installed per-user in ~/.steam/root/compatibilitytools.d/${NC}"
    read -p "Remove all Proton-GE versions? [y/N]: " remove_proton_ge
    if [[ "$remove_proton_ge" =~ ^[Yy]$ ]]; then
        # Find all user home directories
        for user_home in /home/*; do
            if [ -d "$user_home/.steam/root/compatibilitytools.d" ]; then
                rm -rf "$user_home/.steam/root/compatibilitytools.d"/GE-Proton* 2>/dev/null || true
                rm -rf "$user_home/.steam/root/compatibilitytools.d"/proton-ge* 2>/dev/null || true
            fi
        done
        # Also check root
        rm -rf /root/.steam/root/compatibilitytools.d/GE-Proton* 2>/dev/null || true
        log_removal "Proton-GE versions"
    fi
    
    # Remove cron jobs for Proton-GE updates
    echo "  Checking for Proton-GE update cron jobs..."
    for user_crontab in /var/spool/cron/*; do
        if [ -f "$user_crontab" ]; then
            if grep -q "update-proton-ge" "$user_crontab" 2>/dev/null; then
                sed -i '/update-proton-ge/d' "$user_crontab"
                log_removal "Proton-GE update cron job"
            fi
        fi
    done
    
    # Remove user-specific files
    echo ""
    echo -e "${YELLOW}The following user-specific files need manual removal:${NC}"
    echo "  ~/.config/easyeffects/       (EasyEffects presets)"
    echo "  ~/.local/share/latencyflex/  (LatencyFleX Wine integration)"
    echo "  ~/.local/share/ludusavi/     (Ludusavi config)"
    echo "  ~/.steam/root/compatibilitytools.d/GE-Proton*"
}

# ============================================
# REMOVE CONFIGS
# ============================================

remove_configs() {
    echo -e "${BLUE}Removing configuration files...${NC}"
    
    # Remove v3.4 and v3.5 features
    remove_v34_features
    remove_v35_features
    
    # Remove global configs
    rm -rf /usr/share/gamemode 2>/dev/null || true
    rm -rf /usr/share/MangoHud 2>/dev/null || true
    rm -rf /usr/share/doc/linux-gaming-toolkit 2>/dev/null || true
    
    # Remove helper scripts
    rm -f /usr/local/bin/steam-gaming 2>/dev/null || true
    rm -f /usr/local/bin/gamescope-session 2>/dev/null || true
    rm -f /usr/local/bin/game-launch 2>/dev/null || true
    rm -f /usr/local/bin/gaming-perf 2>/dev/null || true
    rm -f /usr/local/bin/itch-setup 2>/dev/null || true
    
    # Remove tools directory
    rm -rf /opt/gaming-tools 2>/dev/null || true
    
    # Remove desktop entries
    rm -f /usr/share/applications/protonup-qt.desktop 2>/dev/null || true
    rm -f /usr/share/applications/itch.desktop 2>/dev/null || true
    
    log_removal "Configuration files and helper scripts"
    
    # User configs notice
    echo ""
    echo -e "${YELLOW}⚠️  User configs in home directories were not removed${NC}"
    echo "To remove them manually, run as each user:"
    echo "  rm -rf ~/.config/gamemode"
    echo "  rm -rf ~/.config/MangoHud"
    echo "  rm -rf ~/.config/steamtinkerlaunch"
    echo "  rm -f ~/.gamingrc"
    echo "  rm -f ~/.local/share/applications/*gaming*.desktop"
}

# ============================================
# MAIN MENU HANDLER
# ============================================

case "$choice" in
    1)
        echo -e "${BLUE}Performing full uninstall...${NC}"
        echo ""
        restore_backups
        remove_repositories
        remove_packages
        remove_optimizations
        remove_configs
        
        echo ""
        echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}     Full uninstall completed!${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
        echo ""
        echo "Summary of removed items:"
        for item in "${REMOVED_ITEMS[@]}"; do
            echo "  ✓ $item"
        done
        echo ""
        echo "Next steps:"
        echo "  1. Reboot your system"
        echo "  2. Manually remove gaming kernel if installed"
        echo "  3. Check /etc/default/grub for any remaining changes"
        echo ""
        ;;
    2)
        remove_packages
        ;;
    3)
        restore_backups
        remove_optimizations
        ;;
    4)
        remove_kernel
        ;;
    5)
        restore_backups
        ;;
    6)
        echo "Uninstall cancelled."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Done!${NC}"
echo "Log saved to: $LOG_FILE"
