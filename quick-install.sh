#!/bin/bash
#
# Linux Gaming Toolkit - Quick Install Script
# Non-interactive installation for automated setups
#
# Usage: sudo ./quick-install.sh [options]
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default options
INSTALL_KERNEL=""
DISABLE_MITIGATIONS=false
INSTALL_NVIDIA=false
INSTALL_AMD=false
INSTALL_INTEL=false
SKIP_PACKAGES=false
CHECK_DRIVERS=false

# Show help
show_help() {
    echo "Linux Gaming Toolkit - Quick Install"
    echo ""
    echo "Usage: sudo $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --kernel=TYPE     Install gaming kernel (xanmod, liquorix, zen, cachyos)"
    echo "  --mitigations     Disable CPU mitigations (security risk)"
    echo "  --nvidia          Force NVIDIA driver installation"
    echo "  --amd             Force AMD driver installation"
    echo "  --intel           Force Intel driver installation"
    echo "  --check-drivers   Check for latest drivers online only"
    echo "  --skip-packages   Skip package installation (drivers/optimization only)"
    echo "  --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  sudo $0 --kernel=xanmod"
    echo "  sudo $0 --kernel=zen --mitigations"
    echo "  sudo $0 --nvidia"
    echo "  sudo $0 --check-drivers"
    echo ""
}

# Parse arguments
for arg in "$@"; do
    case $arg in
        --kernel=*)
            INSTALL_KERNEL="${arg#*=}"
            shift
            ;;
        --mitigations)
            DISABLE_MITIGATIONS=true
            shift
            ;;
        --nvidia)
            INSTALL_NVIDIA=true
            shift
            ;;
        --amd)
            INSTALL_AMD=true
            shift
            ;;
        --intel)
            INSTALL_INTEL=true
            shift
            ;;
        --check-drivers)
            CHECK_DRIVERS=true
            shift
            ;;
        --skip-packages)
            SKIP_PACKAGES=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Check root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}     Linux Gaming Toolkit - Quick Install${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""

# Run the main script with automated options
export AUTO_INSTALL=1
export AUTO_KERNEL="$INSTALL_KERNEL"
export AUTO_MITIGATIONS="$DISABLE_MITIGATIONS"
export AUTO_GPU_NVIDIA="$INSTALL_NVIDIA"
export AUTO_GPU_AMD="$INSTALL_AMD"
export AUTO_GPU_INTEL="$INSTALL_INTEL"
export AUTO_SKIP_PACKAGES="$SKIP_PACKAGES"
export AUTO_CHECK_DRIVERS="$CHECK_DRIVERS"

# Source and run main installer
cd "$(dirname "$0")"
exec ./gamingtoolkit.sh
