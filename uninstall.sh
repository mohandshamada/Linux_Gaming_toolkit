#!/bin/bash
#
# Linux Gaming Toolkit - Uninstall Script
# Reverts changes made by the gaming toolkit
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}     Linux Gaming Toolkit - Uninstall${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}⚠️  This will remove:${NC}"
echo "   • Gaming packages (Steam, Lutris, Wine, etc.)"
echo "   • Gaming kernel (if installed)"
echo "   • System optimizations"
echo "   • Configuration files"
echo ""
echo -e "${YELLOW}Note: Backup files will be preserved${NC}"
echo ""

read -p "Are you sure you want to continue? [y/N]: " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo "Select what to remove:"
echo "  1) Everything (full uninstall)"
echo "  2) Gaming packages only"
echo "  3) System optimizations only"
echo "  4) Gaming kernel only"
echo "  5) Cancel"
echo ""
read -p "Enter choice [1-5]: " choice

# Detect distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|debian|linuxmint|pop|elementary|zorin|kubuntu|xubuntu|lubuntu|neon)
            DISTRO_FAMILY="debian"
            ;;
        fedora|rhel|centos|rocky|almalinux|nobara)
            DISTRO_FAMILY="fedora"
            ;;
        arch|manjaro|endeavouros|garuda|cachyos|artix)
            DISTRO_FAMILY="arch"
            ;;
        opensuse*|suse*)
            DISTRO_FAMILY="suse"
            ;;
    esac
fi

remove_packages() {
    echo -e "${BLUE}Removing gaming packages...${NC}"
    
    case "$DISTRO_FAMILY" in
        debian)
            apt remove -y steam-installer steam-devices lutris wine64 wine32 winetricks \
                gamemode mangohud vulkan-tools gamescope corectrl || true
            ;;
        fedora)
            dnf remove -y steam lutris wine winetricks gamemode mangohud \
                vulkan-tools gamescope corectrl || true
            ;;
        arch)
            pacman -R --noconfirm steam lutris wine winetricks gamemode mangemode \
                mangohud vulkan-tools gamescope corectrl 2>/dev/null || true
            ;;
        suse)
            zypper remove -y steam lutris wine winetricks gamemode mangohud \
                vulkan-tools gamescope 2>/dev/null || true
            ;;
    esac
    
    echo -e "${GREEN}✓ Packages removed${NC}"
}

remove_optimizations() {
    echo -e "${BLUE}Reverting system optimizations...${NC}"
    
    # Remove sysctl config
    rm -f /etc/sysctl.d/99-gaming.conf
    
    # Remove udev rules
    rm -f /etc/udev/rules.d/60-ioschedulers.rules
    rm -f /etc/udev/rules.d/99-steam-controller.rules
    
    # Remove systemd services
    systemctl disable cpu-performance.service 2>/dev/null || true
    rm -f /etc/systemd/system/cpu-performance.service
    systemctl daemon-reload
    
    # Reset sysctl to defaults
    sysctl --system
    
    # Restore CPU governor
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "schedutil" > "$cpu" 2>/dev/null || echo "ondemand" > "$cpu" 2>/dev/null || true
        done
    fi
    
    echo -e "${GREEN}✓ Optimizations reverted${NC}"
}

remove_kernel() {
    echo -e "${BLUE}Removing gaming kernel...${NC}"
    echo -e "${YELLOW}⚠️  Please manually remove the kernel package:${NC}"
    
    case "$DISTRO_FAMILY" in
        debian)
            echo "   Run: apt remove linux-xanmod*"
            echo "   Or:  apt remove linux-image-liquorix*"
            ;;
        fedora)
            echo "   Run: dnf remove kernel-xanmod*"
            ;;
        arch)
            echo "   Run: pacman -R linux-zen linux-zen-headers"
            echo "   Or:  pacman -R linux-cachyos linux-cachyos-headers"
            ;;
    esac
    
    echo "   Then reboot to complete the removal"
}

remove_configs() {
    echo -e "${BLUE}Removing configuration files...${NC}"
    
    # Remove global configs
    rm -rf /usr/share/gamemode
    rm -rf /usr/share/MangoHud
    rm -rf /usr/share/doc/linux-gaming-toolkit
    
    # Remove helper scripts
    rm -f /usr/local/bin/steam-gaming
    rm -f /usr/local/bin/gamescope-session
    rm -f /usr/local/bin/game-launch
    rm -f /usr/local/bin/gaming-perf
    rm -f /opt/gaming-tools/ProtonUp-Qt.AppImage
    
    # Remove desktop entries
    rm -f /usr/share/applications/protonup-qt.desktop
    
    echo -e "${YELLOW}⚠️  User configs in ~/.config/ were not removed${NC}"
    echo "   Remove manually if desired:"
    echo "   rm -rf ~/.config/gamemode"
    echo "   rm -rf ~/.config/MangoHud"
    echo "   rm -f ~/.gamingrc"
}

case "$choice" in
    1)
        remove_packages
        remove_optimizations
        remove_configs
        echo ""
        echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}     Full uninstall completed!${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
        echo ""
        echo "To complete removal:"
        echo "  1. Reboot your system"
        echo "  2. Manually remove gaming kernel if installed"
        echo "  3. Restore CPU mitigations in GRUB if disabled"
        echo ""
        ;;
    2)
        remove_packages
        ;;
    3)
        remove_optimizations
        ;;
    4)
        remove_kernel
        ;;
    5)
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
