#!/bin/bash
#
# Linux Gaming Toolkit - Detection Module
# Detects distro, GPU, and system info
#

# Global variables
DISTRO=""
DISTRO_FAMILY=""
DISTRO_NAME=""
ARCH=""
GPU_VENDOR=""
GPU_MODEL=""
USE_WHIPTAIL=false
IS_HANDHELD=false
KERNEL_VERSION=""

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO="$ID"
        DISTRO_NAME="$NAME"
        
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
            *)
                DISTRO_FAMILY="unknown"
                ;;
        esac
    else
        print_error "Cannot detect Linux distribution"
        exit 1
    fi
    
    ARCH=$(uname -m)
    KERNEL_VERSION=$(uname -r)
    
    # Check for whiptail
    if command_exists whiptail; then
        USE_WHIPTAIL=true
    fi
}

detect_gpu() {
    local lspci_output=$(lspci 2>/dev/null)
    
    if echo "$lspci_output" | grep -qi nvidia; then
        GPU_VENDOR="nvidia"
        GPU_MODEL=$(echo "$lspci_output" | grep -i nvidia | grep -i vga | sed 's/.*: //' | head -1)
    elif echo "$lspci_output" | grep -qi amd; then
        GPU_VENDOR="amd"
        GPU_MODEL=$(echo "$lspci_output" | grep -i amd | grep -i vga | sed 's/.*: //' | head -1)
    elif echo "$lspci_output" | grep -qi intel; then
        GPU_VENDOR="intel"
        GPU_MODEL=$(echo "$lspci_output" | grep -i intel | grep -i vga | sed 's/.*: //' | head -1)
    else
        GPU_VENDOR="unknown"
        GPU_MODEL="Unknown"
    fi
}

detect_handheld() {
    local product_name=""
    if [ -f /sys/class/dmi/id/product_name ]; then
        product_name=$(cat /sys/class/dmi/id/product_name)
    fi
    
    local board_name=""
    if [ -f /sys/class/dmi/id/board_name ]; then
        board_name=$(cat /sys/class/dmi/id/board_name)
    fi

    if echo "$product_name $board_name" | grep -qiE "Jupiter|Galileo|Steam Deck|ROG Ally|Legion Go|GPD|AYANEO"; then
        IS_HANDHELD=true
        print_info "Handheld device detected: ${product_name}"
    fi
}

check_nvidia_driver_version() {
    if command_exists nvidia-smi; then
        nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1
    else
        echo "not-installed"
    fi
}

check_mesa_version() {
    if command_exists glxinfo; then
        glxinfo | grep "OpenGL version string" | grep -o "Mesa [0-9.]*" | awk '{print $2}'
    else
        echo "unknown"
    fi
}

print_system_info() {
    echo "Detected: $DISTRO_NAME ($DISTRO_FAMILY)"
    echo "Architecture: $ARCH"
    echo "Kernel: $KERNEL_VERSION"
    echo "GPU: $GPU_VENDOR (${GPU_MODEL:-Unknown})"
    if $IS_HANDHELD; then
        echo "Device Type: Handheld"
    fi
    if $USE_WHIPTAIL; then
        echo "UI: Whiptail GUI available"
    else
        echo "UI: Text mode (install 'whiptail' for GUI)"
    fi
    echo ""
}
