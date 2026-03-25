#!/bin/bash
#
# Linux Gaming Toolkit - Utility Functions Module
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Logging with /tmp fallback
LOG_FILE="/var/log/gamingtoolkit.log"
if ! touch "$LOG_FILE" &>/dev/null; then
    LOG_FILE="/tmp/gamingtoolkit.log"
    touch "$LOG_FILE"
fi

# Print functions
print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                    ║"
    echo "║          🎮  LINUX GAMING TOOLKIT - ULTIMATE EDITION              ║"
    echo "║                                                                    ║"
    echo "║     Transform any Linux distro into a Gaming Powerhouse           ║"
    echo "║                                                                    ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${CYAN}ℹ $1${NC}"; }

# Logging
log_msg() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Command checks
command_exists() {
    command -v "$1" &> /dev/null
}

# File backup
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Backup created: ${file}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Package checking
package_installed() {
    local pkg="$1"
    case "$DISTRO_FAMILY" in
        debian) dpkg -l "$pkg" 2>/dev/null | grep -q "^ii" ;;
        fedora) rpm -q "$pkg" &> /dev/null ;;
        arch) pacman -Q "$pkg" &> /dev/null ;;
        suse) rpm -q "$pkg" &> /dev/null ;;
        *) return 1 ;;
    esac
}

# User context functions
get_original_user() {
    if [ -n "${SUDO_USER:-}" ]; then
        echo "$SUDO_USER"
    elif [ -n "${DOAS_USER:-}" ]; then
        echo "$DOAS_USER"
    else
        echo ""
    fi
}

run_as_user() {
    local user=$(get_original_user)
    if [ -n "$user" ]; then
        sudo -u "$user" "$@"
    else
        "$@"
    fi
}

run_winetricks_as_user() {
    local user=$(get_original_user)
    if [ -z "$user" ]; then
        print_warning "Cannot determine original user, skipping winetricks"
        return 1
    fi
    
    local user_home=$(getent passwd "$user" | cut -d: -f6)
    
    sudo -u "$user" \
        HOME="$user_home" \
        WINEARCH=win32 \
        WINEPREFIX="${user_home}/.wine" \
        winetricks --unattended "$@" 2>/dev/null || return 1
    
    return 0
}
