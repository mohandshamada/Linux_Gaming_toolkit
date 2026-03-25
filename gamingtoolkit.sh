#!/bin/bash
#
# Linux Gaming Toolkit - Universal Gaming Setup Script
# This script transforms any Linux distro into a gaming powerhouse
# Compatible with: Debian/Ubuntu, Fedora, Arch Linux, openSUSE
#
# Version: 3.0
# Created: 2025
#

# Safer bash settings (matching Dennis Hilk's approach)
set -Eeuo pipefail

# Error trap - show line number where error occurred
trap 'echo -e "\n\033[0;31m❌ Error on line $LINENO. Check log: $LOG_FILE\033[0m" >&2' ERR

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Logging with /tmp fallback (like Dennis Hilk's approach)
LOG_FILE="/var/log/gamingtoolkit.log"
if ! touch "$LOG_FILE" &>/dev/null; then
    LOG_FILE="/tmp/gamingtoolkit.log"
    touch "$LOG_FILE"
fi

# Global variables
DISTRO=""
DISTRO_FAMILY=""
ARCH=""
GPU_VENDOR=""
USE_WHIPTAIL=false

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log_msg() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Check if a package is installed (distro-specific)
package_installed() {
    local pkg="$1"
    case "$DISTRO_FAMILY" in
        debian)
            dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"
            ;;
        fedora)
            rpm -q "$pkg" &> /dev/null
            ;;
        arch)
            pacman -Q "$pkg" &> /dev/null
            ;;
        suse)
            rpm -q "$pkg" &> /dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Install package only if not already installed
install_package() {
    local pkg="$1"
    if package_installed "$pkg"; then
        print_info "Package '$pkg' is already installed, skipping..."
        return 0
    fi
    
    case "$DISTRO_FAMILY" in
        debian)
            apt install -y "$pkg"
            ;;
        fedora)
            dnf install -y "$pkg"
            ;;
        arch)
            pacman -S --noconfirm "$pkg"
            ;;
        suse)
            zypper install -y "$pkg"
            ;;
    esac
}

# Install multiple packages, checking each
install_packages() {
    local to_install=()
    for pkg in "$@"; do
        if ! package_installed "$pkg"; then
            to_install+=("$pkg")
        else
            print_info "✓ '$pkg' already installed"
        fi
    done
    
    if [ ${#to_install[@]} -eq 0 ]; then
        print_success "All packages already installed"
        return 0
    fi
    
    print_info "Installing: ${to_install[*]}"
    
    case "$DISTRO_FAMILY" in
        debian)
            apt install -y "${to_install[@]}"
            ;;
        fedora)
            dnf install -y "${to_install[@]}"
            ;;
        arch)
            pacman -S --noconfirm "${to_install[@]}"
            ;;
        suse)
            zypper install -y "${to_install[@]}"
            ;;
    esac
}

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

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

command_exists() {
    command -v "$1" &> /dev/null
}

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO="$ID"
        DISTRO_NAME="$NAME"
        
        # Detect distro family
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
    
    # Detect GPU
    if lspci | grep -i nvidia &> /dev/null; then
        GPU_VENDOR="nvidia"
    elif lspci | grep -i amd &> /dev/null; then
        GPU_VENDOR="amd"
    elif lspci | grep -i intel &> /dev/null; then
        GPU_VENDOR="intel"
    else
        GPU_VENDOR="unknown"
    fi
    
    # Check for whiptail (like Dennis Hilk's version)
    if command_exists whiptail; then
        USE_WHIPTAIL=true
    fi
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Backup created: ${file}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# ============================================================================
# SYSTEM UPDATE
# ============================================================================

update_system() {
    print_section "📦 Updating System Packages"
    
    case "$DISTRO_FAMILY" in
        debian)
            apt update && apt upgrade -y
            ;;
        fedora)
            dnf upgrade -y
            ;;
        arch)
            pacman -Syu --noconfirm
            ;;
        suse)
            zypper refresh && zypper update -y
            ;;
    esac
    
    print_success "System updated successfully"
}

# ============================================================================
# ENABLE 32-BIT SUPPORT
# ============================================================================

enable_multilib() {
    print_section "🔧 Enabling 32-bit Support (Multiarch/Multilib)"
    
    case "$DISTRO_FAMILY" in
        debian)
            dpkg --add-architecture i386
            apt update
            ;;
        fedora)
            # Fedora supports multilib by default when installing 32-bit packages
            print_info "Fedora multilib is enabled by default"
            ;;
        arch)
            if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
                echo "[multilib]" >> /etc/pacman.conf
                echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
                pacman -Sy
                print_success "Multilib repository enabled"
            fi
            ;;
        suse)
            # openSUSE has 32-bit packages in separate repositories
            zypper addrepo -f https://download.opensuse.org/repositories/Emulators/openSUSE_Tumbleweed/Emulators.repo 2>/dev/null || true
            ;;
    esac
    
    print_success "32-bit support enabled"
}

# ============================================================================
# GPU DRIVER DETECTION & INSTALLATION
# ============================================================================

get_nvidia_gpu_model() {
    lspci | grep -i nvidia | grep -i vga | sed 's/.*: //' | head -1
}

check_nvidia_driver_version() {
    if command_exists nvidia-smi; then
        nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1
    else
        echo "not-installed"
    fi
}

get_latest_nvidia_driver_info() {
    print_info "Checking for latest NVIDIA driver..."
    
    case "$DISTRO_FAMILY" in
        debian|ubuntu)
            # Check available versions in repository
            apt update &> /dev/null
            local available=$(apt-cache policy nvidia-driver 2>/dev/null | grep Candidate | awk '{print $2}')
            echo "$available"
            ;;
        fedora)
            dnf info akmod-nvidia 2>/dev/null | grep Version | awk '{print $3}'
            ;;
        arch)
            pacman -Si nvidia 2>/dev/null | grep Version | awk '{print $3}'
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

install_gpu_drivers() {
    print_section "🎨 GPU Driver Installation"
    
    print_info "Detected GPU: $GPU_VENDOR"
    
    case "$GPU_VENDOR" in
        nvidia)
            install_nvidia_drivers
            ;;
        amd)
            install_amd_drivers
            ;;
        intel)
            install_intel_drivers
            ;;
        *)
            print_warning "Unknown GPU vendor. Installing generic Mesa drivers."
            install_mesa_fallback
            ;;
    esac
}

install_nvidia_drivers() {
    local gpu_model=$(get_nvidia_gpu_model)
    local current_driver=$(check_nvidia_driver_version)
    local latest_driver=$(get_latest_nvidia_driver_info)
    
    print_section "🎨 NVIDIA Driver Installation"
    print_info "GPU Model: $gpu_model"
    print_info "Current Driver: $current_driver"
    print_info "Latest Available: $latest_driver"
    
    # Check if nouveau is currently being used
    if lsmod | grep -q nouveau; then
        print_warning "Nouveau (open-source) driver detected. Installing proprietary driver..."
    fi
    
    # Determine best driver branch based on GPU generation
    local driver_branch=""
    local driver_pkg=""
    
    # Detect GPU generation and recommend driver
    if echo "$gpu_model" | grep -qi "rtx\|gtx.*16\|quadro.*[tpr]\|tesla.*[tpr]"; then
        print_info "Modern NVIDIA GPU detected (Turing/Ampere/Ada Lovelace)"
        driver_branch="latest"
    elif echo "$gpu_model" | grep -qi "gtx.*10\|quadro.*p\|tesla.*p"; then
        print_info "Pascal generation GPU detected"
        driver_branch="latest"
    elif echo "$gpu_model" | grep -qi "gtx.*9\|gtx.*7\|gtx.*6"; then
        print_info "Legacy GPU detected - checking for legacy driver support..."
        driver_branch="legacy"
    fi
    
    echo ""
    echo "Choose driver option:"
    echo "  1) Install/Update to latest proprietary driver (recommended)"
    echo "  2) Install open-source Nouveau driver (limited performance)"
    echo "  3) Skip driver installation"
    echo ""
    read -p "Enter choice [1-3]: " nvidia_choice
    
    case "$nvidia_choice" in
        1)
            install_nvidia_proprietary "$driver_branch"
            ;;
        2)
            print_info "Keeping Nouveau driver (note: gaming performance will be limited)"
            install_package mesa-vulkan-drivers
            ;;
        3)
            print_info "Skipping NVIDIA driver installation"
            return
            ;;
        *)
            print_warning "Invalid choice, installing proprietary driver..."
            install_nvidia_proprietary "$driver_branch"
            ;;
    esac
}

install_nvidia_proprietary() {
    local branch="${1:-latest}"
    
    print_info "Installing NVIDIA proprietary drivers..."
    
    case "$DISTRO_FAMILY" in
        debian)
            # Update repositories first
            apt update
            
            # Install prerequisites
            install_packages linux-headers-$(uname -r) dkms
            
            # Detect Debian version for repository setup
            . /etc/os-release
            local debian_version=${VERSION_CODENAME:-bookworm}
            
            # Add non-free repositories for NVIDIA
            if ! grep -q "non-free" /etc/apt/sources.list; then
                print_info "Adding non-free repositories..."
                sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list
                apt update
            fi
            
            # Install NVIDIA driver
            if [ "$branch" == "legacy" ]; then
                # For older GPUs (Kepler/Maxwell)
                install_packages nvidia-legacy-470xx-driver nvidia-settings
            else
                # Latest driver
                install_packages nvidia-driver nvidia-settings nvidia-xconfig
            fi
            
            # Install 32-bit libraries
            install_packages libnvidia-eglcore:i386 libnvidia-glcore:i386 || true
            install_packages nvidia-driver-libs:i386 || true
            
            # Install CUDA support (optional but useful for some games/apps)
            install_packages nvidia-cuda-toolkit || print_warning "CUDA installation failed, continuing..."
            ;;
            
        fedora)
            # Enable RPM Fusion if not already
            if ! rpm -qa | grep -q rpmfusion; then
                print_info "Enabling RPM Fusion repositories..."
                dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
                dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
            fi
            
            # Install kernel headers and akmods
            install_packages kernel-devel kernel-headers akmods
            
            # Install NVIDIA driver
            install_packages akmod-nvidia
            
            # Install 32-bit libraries
            install_packages xorg-x11-drv-nvidia-libs.i686 || true
            
            # Install CUDA
            install_packages xorg-x11-drv-nvidia-cuda || print_warning "CUDA installation skipped"
            
            # Wait for akmod to build the kernel module
            print_info "Building kernel module (this may take a few minutes)..."
            akmods --force 2>/dev/null || true
            ;;
            
        arch)
            # Update system first
            pacman -Sy
            
            # Detect if using dkms or standard package
            local kernel=$(uname -r)
            if echo "$kernel" | grep -q "zen\|lts\|hardened"; then
                print_info "Non-standard kernel detected, using nvidia-dkms"
                install_packages nvidia-dkms nvidia-utils lib32-nvidia-utils
            else
                install_packages nvidia nvidia-utils lib32-nvidia-utils
            fi
            
            install_packages nvidia-settings
            ;;
            
        suse)
            # Add NVIDIA repository
            if ! zypper repos | grep -q nvidia; then
                zypper addrepo -f https://download.nvidia.com/opensuse/tumbleweed NVIDIA
                zypper refresh
            fi
            
            install_packages nvidia-driver nvidia-settings nvidia-utils
            install_packages nvidia-gl-G06-32bit || true
            ;;
    esac
    
    # Blacklist nouveau
    if [ ! -f /etc/modprobe.d/blacklist-nouveau.conf ]; then
        print_info "Blacklisting nouveau driver..."
        cat > /etc/modprobe.d/blacklist-nouveau.conf << 'EOF'
blacklist nouveau
options nouveau modeset=0
EOF
    fi
    
    # Update initramfs
    case "$DISTRO_FAMILY" in
        debian)
            update-initramfs -u
            ;;
        fedora)
            dracut --force
            ;;
        arch)
            mkinitcpio -P
            ;;
        suse)
            mkinitrd
            ;;
    esac
    
    local new_version=$(check_nvidia_driver_version)
    print_success "NVIDIA proprietary driver installed/updated"
    print_info "Driver version: $new_version"
    print_warning "Please REBOOT to load the NVIDIA driver"
}

install_mesa_fallback() {
    print_info "Installing generic Mesa drivers..."
    
    case "$DISTRO_FAMILY" in
        debian)
            install_packages mesa-vulkan-drivers mesa-opencl-icd vulkan-tools
            ;;
        fedora)
            install_packages mesa-dri-drivers mesa-vulkan-drivers vulkan-tools
            ;;
        arch)
            install_packages mesa vulkan-icd-loader vulkan-tools
            ;;
        suse)
            install_packages Mesa vulkan-tools
            ;;
    esac
}

install_nvidia_drivers() {
    print_info "Installing NVIDIA drivers..."
    
    case "$DISTRO_FAMILY" in
        debian)
            apt install -y linux-headers-$(uname -r) dkms
            apt install -y nvidia-driver nvidia-settings nvidia-xconfig
            apt install -y libnvidia-encode1:i386 nvidia-driver-libs:i386 || true
            ;;
        fedora)
            dnf install -y akmod-nvidia
            dnf install -y xorg-x11-drv-nvidia-cuda
            dnf install -y xorg-x11-drv-nvidia-libs.i686 || true
            ;;
        arch)
            pacman -S --noconfirm nvidia nvidia-utils lib32-nvidia-utils nvidia-settings
            ;;
        suse)
            zypper install -y nvidia-driver nvidia-settings nvidia-utils
            ;;
    esac
    
    print_success "NVIDIA drivers installed"
}

install_amd_drivers() {
    print_section "🎨 AMD Driver Installation"
    
    local gpu_model=$(lspci | grep -i amd | grep -i vga | sed 's/.*: //' | head -1)
    print_info "Detected AMD GPU: $gpu_model"
    
    # Check for proprietary AMD driver (AMDGPU-PRO)
    local has_proprietary=false
    if command_exists amdgpu-pro-uninstall || [ -d /opt/amdgpu-pro ]; then
        has_proprietary=true
        print_info "AMDGPU-PRO proprietary driver detected"
    fi
    
    echo ""
    echo "Choose driver option:"
    echo "  1) Mesa open-source drivers (recommended for gaming)"
    if [ "$has_proprietary" = true ]; then
        echo "  2) Keep/update AMDGPU-PRO proprietary driver"
    else
        echo "  2) Install AMDGPU-PRO proprietary driver (workstation/pro apps)"
    fi
    echo "  3) Skip driver installation"
    echo ""
    read -p "Enter choice [1-3]: " amd_choice
    
    case "$amd_choice" in
        1)
            install_amd_mesa
            ;;
        2)
            if [ "$has_proprietary" = true ]; then
                update_amd_proprietary
            else
                install_amd_proprietary
            fi
            ;;
        3)
            print_info "Skipping AMD driver installation"
            return
            ;;
        *)
            print_warning "Invalid choice, installing Mesa drivers..."
            install_amd_mesa
            ;;
    esac
}

install_amd_mesa() {
    print_info "Installing latest Mesa RADV drivers..."
    
    # Add bleeding-edge Mesa repositories for some distros
    case "$DISTRO_FAMILY" in
        debian)
            # Add kisak-mesa PPA for newer Mesa on Ubuntu
            if command_exists add-apt-repository; then
                print_info "Checking for newer Mesa drivers..."
                add-apt-repository -y ppa:kisak/kisak-mesa 2>/dev/null || true
                apt update
            fi
            
            install_packages \
                mesa-vulkan-drivers \
                mesa-vulkan-drivers:i386 \
                mesa-opencl-icd \
                vulkan-tools
            ;;
            
        fedora)
            # Fedora usually has recent Mesa
            install_packages \
                mesa-dri-drivers \
                mesa-vulkan-drivers \
                mesa-va-drivers \
                vulkan-tools \
                vulkan-loader \
                vulkan-validation-layers
            
            # Install 32-bit libraries
            install_packages mesa-vulkan-drivers.i686 || true
            ;;
            
        arch)
            # Arch has bleeding edge Mesa
            pacman -Sy
            install_packages \
                mesa \
                lib32-mesa \
                vulkan-radeon \
                lib32-vulkan-radeon \
                vulkan-tools \
                vulkan-icd-loader \
                lib32-vulkan-icd-loader \
                mesa-vdpau \
                lib32-mesa-vdpau \
                libva-mesa-driver \
                lib32-libva-mesa-driver
            ;;
            
        suse)
            install_packages \
                Mesa \
                Mesa-libVulkan-devel \
                Mesa-dri \
                libvulkan_radeon \
                vulkan-tools
            ;;
    esac
    
    # Verify RADV is available
    if command_exists vulkaninfo; then
        print_info "Vulkan drivers installed. Verifying RADV..."
        vulkaninfo --summary 2>/dev/null | grep -i "radv\|amd" | head -5 || true
    fi
    
    print_success "AMD Mesa (RADV) drivers installed"
}

install_amd_proprietary() {
    print_info "Installing AMDGPU-PRO proprietary driver..."
    print_warning "Note: AMDGPU-PRO is primarily for workstation use. Mesa is usually better for gaming."
    
    case "$DISTRO_FAMILY" in
        debian|ubuntu)
            # Download latest AMDGPU-PRO installer
            local amdurl="https://www.amd.com/en/support/linux-drivers"
            print_info "Please download AMDGPU-PRO from: $amdurl"
            print_info "Then run the amdgpu-pro-install script manually"
            read -p "Press Enter to continue..."
            ;;
        fedora)
            print_error "AMDGPU-PRO is not officially supported on Fedora"
            print_info "Installing Mesa instead..."
            install_amd_mesa
            ;;
        *)
            print_error "Automatic AMDGPU-PRO installation not supported on this distro"
            ;;
    esac
}

update_amd_proprietary() {
    print_info "Updating AMDGPU-PRO driver..."
    print_info "Please check AMD website for latest version"
    # This would require downloading and running AMD's installer
}

install_intel_drivers() {
    print_section "🎨 Intel Driver Installation"
    
    local gpu_model=$(lspci | grep -i intel | grep -i vga | sed 's/.*: //' | head -1)
    print_info "Detected Intel GPU: $gpu_model"
    
    # Check for Arc/Alchemist (DG2) - needs newer drivers
    local is_arc=false
    if echo "$gpu_model" | grep -qi "arc\|dg2\|alchemist"; then
        is_arc=true
        print_info "Intel Arc GPU detected - ensuring latest drivers..."
    fi
    
    # Check current Mesa version
    if command_exists glxinfo; then
        local mesa_version=$(glxinfo | grep "OpenGL version string" | head -1 | sed 's/.*Mesa //' | awk '{print $1}')
        print_info "Current Mesa version: $mesa_version"
    fi
    
    case "$DISTRO_FAMILY" in
        debian)
            # Add repositories for newer Mesa if needed
            if [ "$is_arc" = true ]; then
                print_info "Adding repositories for Intel Arc support..."
                add-apt-repository -y ppa:kisak/kisak-mesa 2>/dev/null || true
                apt update
            fi
            
            # Non-free media driver for better video decode
            install_packages \
                intel-media-va-driver-non-free \
                mesa-vulkan-drivers \
                mesa-vulkan-drivers:i386 \
                vulkan-tools \
                intel-gpu-tools
            
            # Compute runtime for OpenCL
            install_packages intel-opencl-icd || true
            ;;
            
        fedora)
            install_packages \
                intel-media-driver \
                mesa-vulkan-drivers \
                mesa-dri-drivers \
                vulkan-tools \
                intel-gpu-tools
            
            # 32-bit support
            install_packages mesa-vulkan-drivers.i686 || true
            
            # Compute runtime
            install_packages intel-compute-runtime || true
            ;;
            
        arch)
            pacman -Sy
            install_packages \
                mesa \
                lib32-mesa \
                vulkan-intel \
                lib32-vulkan-intel \
                intel-media-driver \
                vulkan-tools \
                vulkan-icd-loader \
                lib32-vulkan-icd-loader \
                intel-gpu-tools \
                intel-compute-runtime
            ;;
            
        suse)
            install_packages \
                Mesa \
                Mesa-libVulkan-devel \
                intel-media-driver \
                vulkan-tools \
                intel-gpu-tools
            ;;
    esac
    
    # Check for Arc-specific firmware
    if [ "$is_arc" = true ]; then
        print_info "Checking for Intel Arc firmware..."
        if [ -d /lib/firmware/i915 ]; then
            print_success "Intel GPU firmware found"
        else
            print_warning "Intel GPU firmware may need to be updated for Arc support"
        fi
    fi
    
    print_success "Intel drivers installed"
}

# ============================================================================
# GAMING PACKAGES INSTALLATION
# ============================================================================

install_gaming_packages() {
    print_section "🎮 Installing Gaming Packages"
    
    case "$DISTRO_FAMILY" in
        debian)
            install_debian_gaming_packages
            ;;
        fedora)
            install_fedora_gaming_packages
            ;;
        arch)
            install_arch_gaming_packages
            ;;
        suse)
            install_suse_gaming_packages
            ;;
    esac
    
    print_success "Gaming packages installed"
}

install_debian_gaming_packages() {
    print_section "📦 Installing Gaming Packages (Debian/Ubuntu)"
    
    # Add repositories
    install_packages software-properties-common wget curl git
    
    # Add WineHQ repository
    if ! grep -q "winehq" /etc/apt/sources.list.d/*.list 2>/dev/null; then
        print_info "Adding WineHQ repository..."
        dpkg --add-architecture i386
        mkdir -pm755 /etc/apt/keyrings
        wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key 2>/dev/null || true
        
        . /etc/os-release
        if echo "$ID" | grep -q "ubuntu"; then
            wget -NP /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/ubuntu/dists/$VERSION_CODENAME/winehq-$VERSION_CODENAME.sources" 2>/dev/null || true
        fi
        apt update 2>/dev/null || true
    fi
    
    # Core gaming packages
    install_packages gamemode libgamemode0
    
    # Wine (try different package names)
    if ! package_installed wine && ! package_installed wine64; then
        print_info "Installing Wine..."
        apt install -y wine64 wine32 winetricks 2>/dev/null || apt install -y wine winetricks || true
    else
        print_info "Wine already installed"
    fi
    
    install_packages \
        mangohud \
        steam-installer \
        steam-devices \
        lutris \
        vulkan-tools \
        vulkan-validationlayers \
        mesa-utils
    
    # Optional packages
    install_packages corectrl || print_info "corectrl not available, skipping"
    install_packages goverlay || print_info "goverlay not available, skipping"
    install_packages gamescope || print_info "gamescope not available, skipping"
    
    # Install ProtonUp-Qt
    install_protonupqt
}

install_fedora_gaming_packages() {
    print_section "📦 Installing Gaming Packages (Fedora)"
    
    # Enable RPM Fusion if not already
    if ! rpm -qa | grep -q rpmfusion-free-release; then
        print_info "Enabling RPM Fusion repositories..."
        dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    fi
    if ! rpm -qa | grep -q rpmfusion-nonfree-release; then
        dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    fi
    
    dnf config-manager --enable fedora-cisco-openh264 2>/dev/null || true
    
    # Core gaming packages
    install_packages \
        wine \
        winetricks \
        gamemode \
        mangohud \
        steam \
        lutris \
        vulkan-tools \
        vulkan-loader \
        mesa-demos \
        corectrl \
        goverlay \
        gamescope
    
    # Optional packages
    install_packages vkBasalt || print_info "vkBasalt not available, skipping"
    install_packages obs-studio || print_info "obs-studio not available, skipping"
    
    # Install ProtonUp-Qt
    install_protonupqt
}

install_arch_gaming_packages() {
    print_section "📦 Installing Gaming Packages (Arch Linux)"
    
    # Update system first to get latest packages
    pacman -Sy
    
    # Core gaming packages
    install_packages \
        wine \
        winetricks \
        gamemode \
        lib32-gamemode \
        mangohud \
        lib32-mangohud \
        steam \
        lutris \
        vulkan-tools \
        vulkan-icd-loader \
        lib32-vulkan-icd-loader \
        mesa-demos \
        corectrl \
        goverlay \
        gamescope \
        vkBasalt \
        lib32-vkBasalt \
        obs-studio \
        discord
    
    # Install from AUR if helper available
    if command_exists yay || command_exists paru; then
        local aur_helper=$(command_exists yay && echo "yay" || echo "paru")
        print_info "Installing AUR packages with $aur_helper..."
        
        if ! package_installed protonup-qt; then
            $aur_helper -S --noconfirm protonup-qt || install_protonupqt
        else
            print_info "protonup-qt already installed"
        fi
    else
        install_protonupqt
    fi
}

install_suse_gaming_packages() {
    print_section "📦 Installing Gaming Packages (openSUSE)"
    
    # Enable Packman repository if not already
    if ! zypper repos | grep -q packman; then
        print_info "Adding Packman repository..."
        zypper addrepo -f https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman
    fi
    
    print_info "Refreshing repositories and checking for updates..."
    zypper refresh
    zypper dup --from packman --allow-vendor-change -y 2>/dev/null || true
    
    # Core gaming packages
    install_packages \
        wine \
        winetricks \
        gamemode \
        mangohud \
        steam \
        lutris \
        vulkan-tools \
        Mesa-demo-x
    
    # Optional packages
    install_packages corectrl || print_info "corectrl not available, skipping"
    install_packages gamescope || print_info "gamescope not available, skipping"
    
    install_protonupqt
}

install_protonupqt() {
    print_info "Checking ProtonUp-Qt..."
    
    # Check if already installed via flatpak
    if command_exists flatpak; then
        if flatpak list | grep -q protonup-qt 2>/dev/null || flatpak list | grep -q pupgui2 2>/dev/null; then
            print_info "ProtonUp-Qt already installed via Flatpak"
            return
        fi
        
        print_info "Installing ProtonUp-Qt via Flatpak..."
        flatpak install -y flathub net.davidotek.pupgui2 2>/dev/null || true
        if [ $? -eq 0 ]; then
            print_success "ProtonUp-Qt installed via Flatpak"
            return
        fi
    fi
    
    # Check if AppImage already exists
    if [ -f /opt/gaming-tools/ProtonUp-Qt.AppImage ]; then
        print_info "ProtonUp-Qt AppImage already exists"
        return
    fi
    
    # Download AppImage
    print_info "Downloading ProtonUp-Qt AppImage..."
    local protonup_url=$(curl -s https://api.github.com/repos/DavidoTek/ProtonUp-Qt/releases/latest | grep "browser_download_url.*AppImage" | cut -d '"' -f 4)
    
    if [ -n "$protonup_url" ]; then
        mkdir -p /opt/gaming-tools
        wget -O /opt/gaming-tools/ProtonUp-Qt.AppImage "$protonup_url"
        chmod +x /opt/gaming-tools/ProtonUp-Qt.AppImage
        
        # Create desktop entry
        cat > /usr/share/applications/protonup-qt.desktop << 'EOF'
[Desktop Entry]
Name=ProtonUp-Qt
Comment=Install and manage Proton-GE
Exec=/opt/gaming-tools/ProtonUp-Qt.AppImage
Icon=wine
Type=Application
Categories=Game;Utility;
EOF
        print_success "ProtonUp-Qt installed"
    else
        print_warning "Could not download ProtonUp-Qt"
    fi
}

# ============================================================================
# GAMING KERNEL INSTALLATION
# ============================================================================

install_gaming_kernel() {
    print_section "🐧 Installing Gaming-Optimized Kernel"
    
    echo ""
    echo "Choose a gaming kernel:"
    echo "  1) XanMod Kernel (Recommended for most systems)"
    echo "  2) Liquorix Kernel (Low-latency, Debian/Ubuntu only)"
    echo "  3) Zen Kernel (Balanced, Arch-based)"
    echo "  4) CachyOS Kernel (Performance-focused, Arch only)"
    echo "  5) TKG Kernel (Custom builds, advanced users)"
    echo "  6) Skip kernel installation"
    echo ""
    read -p "Enter your choice [1-6]: " kernel_choice
    
    case "$kernel_choice" in
        1)
            install_xanmod_kernel
            ;;
        2)
            if [ "$DISTRO_FAMILY" != "debian" ]; then
                print_error "Liquorix kernel is only available for Debian/Ubuntu"
                return
            fi
            install_liquorix_kernel
            ;;
        3)
            if [ "$DISTRO_FAMILY" != "arch" ]; then
                print_error "Zen kernel is best supported on Arch-based distros"
                return
            fi
            install_zen_kernel
            ;;
        4)
            if [ "$DISTRO_FAMILY" != "arch" ]; then
                print_error "CachyOS kernel is only available for Arch-based distros"
                return
            fi
            install_cachyos_kernel
            ;;
        5)
            print_warning "TKG kernel requires manual compilation"
            print_info "Visit: https://github.com/Frogging-Family/linux-tkg"
            ;;
        6)
            print_info "Skipping kernel installation"
            return
            ;;
        *)
            print_warning "Invalid choice. Skipping kernel installation."
            return
            ;;
    esac
}

install_xanmod_kernel() {
    print_info "Installing XanMod Kernel..."
    
    case "$DISTRO_FAMILY" in
        debian)
            # Add XanMod repository
            wget -qO - https://dl.xanmod.org/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg
            echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list
            apt update
            
            # Detect CPU variant and install appropriate kernel
            local cpu_flags=$(grep -m1 'flags' /proc/cpuinfo)
            if echo "$cpu_flags" | grep -q 'avx512'; then
                apt install -y linux-xanmod-x64v4 || apt install -y linux-xanmod
            elif echo "$cpu_flags" | grep -q 'avx2'; then
                apt install -y linux-xanmod-x64v3 || apt install -y linux-xanmod
            else
                apt install -y linux-xanmod
            fi
            ;;
        fedora)
            # XanMod for Fedora
            dnf copr enable -y rmnscnce/kernel-xanmod
            dnf install -y kernel-xanmod
            ;;
        arch)
            # XanMod is in AUR
            if command_exists yay; then
                yay -S --noconfirm linux-xanmod linux-xanmod-headers || true
            else
                print_warning "Please install yay to install XanMod kernel"
                return
            fi
            ;;
        *)
            print_error "XanMod kernel not available for this distro"
            return
            ;;
    esac
    
    print_success "XanMod kernel installed. Reboot required."
}

install_liquorix_kernel() {
    print_info "Installing Liquorix Kernel..."
    
    # Liquorix is Debian/Ubuntu specific
    apt install -y curl
    curl -s 'https://liquorix.net/install-liquorix.sh' | bash
    
    print_success "Liquorix kernel installed. Reboot required."
}

install_zen_kernel() {
    print_info "Installing Zen Kernel..."
    
    pacman -S --noconfirm linux-zen linux-zen-headers
    
    # Update bootloader
    if command_exists grub-mkconfig; then
        grub-mkconfig -o /boot/grub/grub.cfg
    elif command_exists systemd-boot; then
        print_info "Systemd-boot detected. Kernel installed."
    fi
    
    print_success "Zen kernel installed. Reboot required."
}

install_cachyos_kernel() {
    print_info "Installing CachyOS Kernel..."
    
    # Add CachyOS repository
    pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
    pacman-key --lsign-key F3B607488DB35A47
    
    cat >> /etc/pacman.conf << 'EOF'

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
EOF
    
    # Download mirrorlist
    curl -o /etc/pacman.d/cachyos-mirrorlist https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/cachyos-mirrorlist/cachyos-mirrorlist
    
    pacman -Sy
    
    # Detect CPU variant
    local cpu_flags=$(grep -m1 'flags' /proc/cpuinfo)
    if echo "$cpu_flags" | grep -q 'avx512'; then
        pacman -S --noconfirm linux-cachyos linux-cachyos-headers
    else
        pacman -S --noconfirm linux-cachyos linux-cachyos-headers
    fi
    
    print_success "CachyOS kernel installed. Reboot required."
}

# ============================================================================
# SYSTEM OPTIMIZATIONS
# ============================================================================

apply_sysctl_optimizations() {
    print_section "⚙️ Applying Kernel System Optimizations"
    
    backup_file /etc/sysctl.conf
    
    # Create gaming optimization file
    cat > /etc/sysctl.d/99-gaming.conf << 'EOF'
# Linux Gaming Toolkit - System Optimizations
# ============================================

# Virtual Memory Optimizations
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=10
vm.dirty_background_ratio=5
vm.page-cluster=3
vm.zone_reclaim_mode=0

# Network Optimizations for Gaming
net.core.rmem_max=134217728
net.core.wmem_max=134217728
net.ipv4.tcp_rmem=4096 87380 67108864
net.ipv4.tcp_wmem=4096 65536 67108864
net.core.netdev_max_backlog=65536
net.ipv4.tcp_congestion_control=bbr
net.core.default_qdisc=fq
net.ipv4.tcp_low_latency=1
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15

# File System Optimizations
fs.file-max=2097152
fs.inotify.max_user_watches=524288

# Kernel Scheduler Optimizations
kernel.sched_min_granularity_ns=10000000
kernel.sched_wakeup_granularity_ns=15000000
kernel.sched_migration_cost_ns=5000000
kernel.sched_autogroup_enabled=0

# Disable NMI watchdog for lower latency
kernel.nmi_watchdog=0

# Intel GPU specific optimization (if applicable)
kernel.split_lock_mitigate=0
EOF
    
    # Apply settings
    sysctl -p /etc/sysctl.d/99-gaming.conf
    
    print_success "System optimizations applied"
}

configure_cpu_governor() {
    print_section "🔥 Configuring CPU Governor for Performance"
    
    # Install cpufrequtils or equivalent
    case "$DISTRO_FAMILY" in
        debian)
            apt install -y cpufrequtils
            ;;
        fedora)
            dnf install -y kernel-tools
            ;;
        arch)
            pacman -S --noconfirm cpupower
            ;;
    esac
    
    # Set governor to performance
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        echo 'GOVERNOR="performance"' > /etc/default/cpufrequtils
        systemctl enable cpufrequtils 2>/dev/null || true
        
        # Apply immediately
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo performance > "$cpu" 2>/dev/null || true
        done
        
        print_success "CPU governor set to performance"
    else
        print_warning "CPU frequency scaling not available"
    fi
    
    # Create systemd service for persistent performance mode
    cat > /etc/systemd/system/cpu-performance.service << 'EOF'
[Unit]
Description=Set CPU Governor to Performance
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > "$cpu" 2>/dev/null || true; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable cpu-performance.service
}

disable_cpu_mitigations() {
    print_section "⚠️ CPU Mitigations Configuration"
    
    print_warning "Disabling CPU mitigations improves performance but reduces security"
    print_info "This makes your system vulnerable to Spectre, Meltdown, and similar attacks"
    echo ""
    read -p "Do you want to disable CPU mitigations? [y/N]: " disable_mitigations
    
    if [[ "$disable_mitigations" =~ ^[Yy]$ ]]; then
        backup_file /etc/default/grub
        
        case "$DISTRO_FAMILY" in
            fedora)
                grubby --update-kernel=ALL --args="mitigations=off"
                ;;
            *)
                # For GRUB-based systems
                if grep -q "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub; then
                    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 mitigations=off"/' /etc/default/grub
                    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=" *\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1"/' /etc/default/grub
                    update-grub 2>/dev/null || grub-mkconfig -o /boot/grub/grub.cfg
                fi
                ;;
        esac
        
        print_success "CPU mitigations disabled. Reboot required."
        print_warning "Run 'grep . /sys/devices/system/cpu/vulnerabilities/*' after reboot to verify"
    else
        print_info "CPU mitigations kept enabled"
    fi
}

optimize_io_scheduler() {
    print_section "💾 Optimizing I/O Scheduler"
    
    # Create udev rule for I/O scheduler
    cat > /etc/udev/rules.d/60-ioschedulers.rules << 'EOF'
# Set I/O scheduler for SSDs and NVMe to none/mq-deadline
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"

# Set I/O scheduler for HDDs to bfq
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF
    
    # Reload udev rules
    udevadm control --reload-rules
    udevadm trigger
    
    print_success "I/O scheduler optimized"
}

# ============================================================================
# GAMEMODE CONFIGURATION
# ============================================================================

configure_gamemode() {
    print_section "🎲 Configuring GameMode"
    
    # Create gamemode configuration
    mkdir -p /usr/share/gamemode
    
    cat > /usr/share/gamemode/gamemode.ini << 'EOF'
; GameMode Configuration
; ======================

[general]
; Run with the highest priority
renice=10

[cpu]
; CPU governor to use during gaming
governor=performance
; Pin game to specific cores (optional)
;pin=0-7

[gpu]
; GPU optimizations
; NVIDIA GPU settings
apply_gpu_optimisations=accept-responsibility
; AMD GPU settings
amdgpu_powersave=0

[supervisor]
; Priority boost for game processes
priority=10

[custom]
; Start commands
start=notify-send "GameMode" "GameMode activated"

; End commands  
end=notify-send "GameMode" "GameMode deactivated"
EOF
    
    # Create user config template
    mkdir -p /etc/skel/.config/gamemode
    cp /usr/share/gamemode/gamemode.ini /etc/skel/.config/gamemode/
    
    print_success "GameMode configured"
}

# ============================================================================
# MANGOHUD CONFIGURATION
# ============================================================================

configure_mangohud() {
    print_section "📊 Configuring MangoHud"
    
    # Create MangoHud configuration
    mkdir -p /usr/share/doc/mangohud
    
    cat > /usr/share/doc/mangohud/MangoHud.conf << 'EOF'
# MangoHud Configuration
# ======================

# Position
position=top-left

# Font
font_size=24
font_scale=1.0

# Display Settings
gpu_stats
cpu_stats
ram
vram
fps
frametime=0
frame_timing

# GPU Details
gpu_name
gpu_temp
gpu_power
vulkan_driver

# CPU Details
cpu_temp
cpu_power
cpu_mhz

# System Info
time
version

# Additional Features
io_read io_write
engine_version
wine
gamemode
vkbasalt
hdr
refresh_rate
resolution

# HUD Style
background_alpha=0.5
alpha=1.0
text_color=FFFFFF
background_color=000000

# Toggle Key
toggle_hud=Shift_R+F12
toggle_fps_limit=Shift_L+F1
EOF
    
    # Create user config template
    mkdir -p /etc/skel/.config/MangoHud
    cp /usr/share/doc/mangohud/MangoHud.conf /etc/skel/.config/MangoHud/
    
    # Create global config
    mkdir -p /usr/share/MangoHud
    cp /usr/share/doc/mangohud/MangoHud.conf /usr/share/MangoHud/
    
    print_success "MangoHud configured"
}

# ============================================================================
# STEAM CONFIGURATION
# ============================================================================

configure_steam() {
    print_section "🎯 Configuring Steam for Optimal Gaming"
    
    # Create Steam udev rules for controller support
    cat > /etc/udev/rules.d/99-steam-controller.rules << 'EOF'
# Steam Controller and Steam Link udev rules

# Valve USB devices (Steam Controller, Steam Link, etc.)
SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"

# Steam Controller udev
KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
SUBSYSTEM=="input", ATTRS{name}=="Steam Controller", MODE="0666"

# DualShock 4 over USB
SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0666"
# DualShock 4 wireless adapter
SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ba0", MODE="0666"
# DualShock 4 Slim/Pro
SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0666"

# DualSense (PS5)
SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0666"

# Xbox Controllers
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028f", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02d1", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02dd", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02e3", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ea", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02fd", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b12", MODE="0666"

# Nintendo Switch Pro Controller
SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0666"
EOF
    
    udevadm control --reload-rules
    udevadm trigger
    
    print_success "Steam controller udev rules configured"
    
    # Create Steam launch helper script
    cat > /usr/local/bin/steam-gaming << 'EOF'
#!/bin/bash
# Steam launcher with gaming optimizations

# Enable MangoHud by default
export MANGOHUD=1

# Enable GameMode
export GAMEMODERUN=1

# AMD GPU optimizations
export AMD_VULKAN_ICD=RADV
export RADV_PERFTEST=aco

# Launch Steam with gamemode
gamemoderun steam "$@"
EOF
    chmod +x /usr/local/bin/steam-gaming
    
    print_success "Steam gaming helper created: steam-gaming"
}

# ============================================================================
# GAMESCOPE CONFIGURATION
# ============================================================================

configure_gamescope() {
    print_section "🖥️ Configuring Gamescope"
    
    # Gamescope is primarily for Steam Deck / handhelds but useful for desktops too
    cat > /usr/local/bin/gamescope-session << 'EOF'
#!/bin/bash
# Gamescope session launcher for desktop gaming

# Default settings
GAMESCOPE_WIDTH=${GAMESCOPE_WIDTH:-1920}
GAMESCOPE_HEIGHT=${GAMESCOPE_HEIGHT:-1080}
GAMESCOPE_REFRESH=${GAMESCOPE_REFRESH:-60}

# Launch gamescope with optimized settings
gamescope -W $GAMESCOPE_WIDTH -H $GAMESCOPE_HEIGHT -r $GAMESCOPE_REFRESH \
    --adaptive-sync \
    --mangoapp \
    -- "$@"
EOF
    chmod +x /usr/local/bin/gamescope-session
    
    print_success "Gamescope session helper created"
}

# ============================================================================
# ADDITIONAL TOOLS
# ============================================================================

check_latest_drivers_online() {
    print_section "🌐 Checking for Latest Drivers Online"
    
    print_info "Fetching latest driver information..."
    
    # Check NVIDIA
    if [ "$GPU_VENDOR" = "nvidia" ]; then
        print_info "Checking latest NVIDIA driver..."
        local nvidia_latest=$(curl -s "https://download.nvidia.com/XFree86/Linux-x86_64/latest.txt" 2>/dev/null | head -1 | awk '{print $2}')
        if [ -n "$nvidia_latest" ]; then
            print_info "Latest NVIDIA driver available: $nvidia_latest"
            
            local current=$(check_nvidia_driver_version)
            if [ "$current" != "not-installed" ]; then
                print_info "Current driver: $current"
                # Simple version comparison
                if [ "$nvidia_latest" != "$current" ]; then
                    print_warning "A newer NVIDIA driver is available!"
                    read -p "Update to latest driver? [y/N]: " update_driver
                    if [[ "$update_driver" =~ ^[Yy]$ ]]; then
                        install_nvidia_proprietary
                    fi
                else
                    print_success "NVIDIA driver is up to date"
                fi
            fi
        fi
    fi
    
    # Check Mesa (for AMD/Intel)
    if [ "$GPU_VENDOR" = "amd" ] || [ "$GPU_VENDOR" = "intel" ]; then
        print_info "Checking latest Mesa version..."
        local mesa_latest=$(curl -s "https://gitlab.freedesktop.org/api/v4/projects/176/repository/tags" 2>/dev/null | grep -o '"name":"[^"]*"' | head -1 | sed 's/"name":"//;s/"$//')
        if [ -n "$mesa_latest" ]; then
            print_info "Latest Mesa version: $mesa_latest"
            
            if command_exists glxinfo; then
                local current=$(glxinfo | grep "OpenGL version string" | grep -o "Mesa [0-9.]*" | awk '{print $2}')
                print_info "Current Mesa: $current"
            fi
        fi
    fi
    
    # Check Wine
    print_info "Checking latest Wine version..."
    local wine_latest=$(curl -s "https://raw.githubusercontent.com/wine-mirror/wine/master/VERSION" 2>/dev/null | grep -o '"[0-9.]*"' | tr -d '"')
    if [ -n "$wine_latest" ]; then
        print_info "Latest Wine development: $wine_latest"
        if command_exists wine; then
            local wine_current=$(wine --version 2>/dev/null | grep -o '[0-9.]*')
            print_info "Current Wine: $wine_current"
        fi
    fi
}

install_discord() {
    print_info "Installing Discord..."
    
    # Try native packages first
    case "$DISTRO_FAMILY" in
        debian)
            # Discord is not in official repos, use flatpak or download
            if ! command_exists flatpak; then
                install_packages flatpak
            fi
            ;;
        fedora)
            # Try RPM Fusion or flatpak
            install_packages discord || true
            ;;
        arch)
            if command_exists yay; then
                yay -S --noconfirm discord 2>/dev/null || true
            elif command_exists paru; then
                paru -S --noconfirm discord 2>/dev/null || true
            fi
            ;;
    esac
    
    # Fallback to Flatpak
    if command_exists flatpak; then
        if ! flatpak list | grep -q discord 2>/dev/null; then
            print_info "Installing Discord via Flatpak..."
            flatpak install -y flathub com.discordapp.Discord
        fi
    fi
}

install_itch_io() {
    print_section "🎮 Installing itch.io Client"
    
    # itch.io has an official Linux client
    local itch_url="https://itch.io/app/download?platform=linux"
    
    print_info "Downloading itch.io client..."
    mkdir -p /opt/gaming-tools
    
    # Download latest itch-setup
    local setup_url=$(curl -sL "https://api.github.com/repos/itchio/itch/releases/latest" | grep "browser_download_url.*linux-amd64" | cut -d '"' -f 4)
    
    if [ -n "$setup_url" ]; then
        wget -O /opt/gaming-tools/itch-setup "$setup_url" 2>/dev/null || true
        chmod +x /opt/gaming-tools/itch-setup
        
        # Create desktop entry
        cat > /usr/share/applications/itch.desktop << 'EOF'
[Desktop Entry]
Name=itch.io
Comment=itch.io game client
Exec=/opt/gaming-tools/itch-setup
Icon=applications-games
Type=Application
Categories=Game;
Terminal=false
EOF
        print_success "itch.io client installed to /opt/gaming-tools/"
        print_info "Run 'itch-setup' to complete installation"
    else
        print_warning "Could not download itch.io automatically"
        print_info "Please download manually from: https://itch.io/app"
    fi
}

install_vkd3d_proton() {
    print_section "🎯 Installing VKD3D-Proton"
    
    # VKD3D-Proton is the DirectX 12 implementation for Vulkan
    # Usually comes with Proton, but we can install standalone for Lutris
    
    case "$DISTRO_FAMILY" in
        arch)
            # Available in AUR
            if command_exists yay; then
                yay -S --noconfirm vkd3d-proton 2>/dev/null || print_info "vkd3d-proton not in AUR or already installed"
            elif command_exists paru; then
                paru -S --noconfirm vkd3d-proton 2>/dev/null || print_info "vkd3d-proton not in AUR or already installed"
            fi
            ;;
        debian|fedora|suse)
            print_info "VKD3D-Proton is included with Proton/Steam"
            print_info "For Lutris, it will be downloaded automatically when needed"
            ;;
    esac
    
    # Download latest release for manual installation
    local vkd3d_url=$(curl -sL "https://api.github.com/repos/HansKristian-Work/vkd3d-proton/releases/latest" | grep "browser_download_url.*tar.gz" | cut -d '"' -f 4)
    
    if [ -n "$vkd3d_url" ]; then
        print_info "Downloading VKD3D-Proton for Lutris..."
        mkdir -p /opt/gaming-tools/vkd3d-proton
        wget -O /tmp/vkd3d-proton.tar.gz "$vkd3d_url" 2>/dev/null || true
        if [ -f /tmp/vkd3d-proton.tar.gz ]; then
            tar -xzf /tmp/vkd3d-proton.tar.gz -C /opt/gaming-tools/vkd3d-proton/ 2>/dev/null || true
            rm /tmp/vkd3d-proton.tar.gz
            print_success "VKD3D-Proton downloaded to /opt/gaming-tools/vkd3d-proton/"
        fi
    fi
}

install_additional_tools() {
    print_section "🛠️ Installing Additional Gaming Tools"
    
    # Install Discord
    install_discord
    
    # Install itch.io
    install_itch_io
    
    # Install VKD3D-Proton
    install_vkd3d_proton
    
    case "$DISTRO_FAMILY" in
        debian)
            install_packages vkbasalt || true
            install_packages obs-studio || true
            install_packages flatpak
            ;;
        fedora)
            install_packages vkBasalt || true
            install_packages obs-studio
            install_packages flatpak
            ;;
        arch)
            install_packages vkbasalt
            install_packages obs-studio
            install_packages obs-vkcapture
            install_packages flatpak
            ;;
        suse)
            install_packages vkBasalt || true
            install_packages obs-studio
            install_packages flatpak
            ;;
    esac
    
    # Setup Flatpak
    if command_exists flatpak; then
        print_info "Setting up Flatpak..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        
        # Install common gaming flatpaks (check first)
        if ! flatpak list | grep -q discord 2>/dev/null; then
            flatpak install -y flathub com.discordapp.Discord 2>/dev/null || true
        fi
        
        if ! flatpak list | grep -q spotify 2>/dev/null; then
            flatpak install -y flathub com.spotify.Client 2>/dev/null || true
        fi
        
        if ! flatpak list | grep -q lutris 2>/dev/null; then
            flatpak install -y flathub net.lutris.Lutris 2>/dev/null || true
        fi
        
        if ! flatpak list | grep -q heroic 2>/dev/null; then
            flatpak install -y flathub com.heroicgameslauncher.hgl 2>/dev/null || true
        fi
    fi
    
    print_success "Additional tools installed"
}

# ============================================================================
# CREATE USER HELPERS
# ============================================================================

create_user_helpers() {
    print_section "📝 Creating User Helper Scripts"
    
    # Create gaming environment setup script for users
    cat > /etc/skel/.gamingrc << 'EOF'
# Gaming Environment Settings
# Source this in your .bashrc or .zshrc: source ~/.gamingrc

# Enable MangoHud globally for Vulkan
export MANGOHUD=1

# MangoHud configuration path
export MANGOHUD_CONFIGFILE="$HOME/.config/MangoHud/MangoHud.conf"

# AMD GPU optimizations
export AMD_VULKAN_ICD=RADV
export RADV_PERFTEST=aco,gpl,nggc
export mesa_glthread=true

# Intel GPU optimizations
export INTEL_DEBUG=norbc

# Wine/Proton optimizations
export WINEESYNC=1
export WINEFSYNC=1
export PROTON_USE_FSYNC=1
export PROTON_NO_ESYNC=1

# Disable composition pipeline for lower latency (NVIDIA)
export __GL_SYNC_TO_VBLANK=0

# Steam optimizations
export STEAM_RUNTIME=1

# GameMode
export GAMEMODERUN=1
EOF
    
    # Create quick game launcher
    cat > /usr/local/bin/game-launch << 'EOF'
#!/bin/bash
# Quick game launcher with optimizations

if [ -z "$1" ]; then
    echo "Usage: game-launch <game_executable>"
    echo "Launches games with MangoHud and GameMode enabled"
    exit 1
fi

# Source gaming environment
[ -f "$HOME/.gamingrc" ] && source "$HOME/.gamingrc"

echo "🎮 Launching game with optimizations..."
mangohud gamemoderun "$@"
EOF
    chmod +x /usr/local/bin/game-launch
    
    # Create performance monitoring script
    cat > /usr/local/bin/gaming-perf << 'EOF'
#!/bin/bash
# Gaming Performance Monitor

echo "═══════════════════════════════════════════"
echo "         GAMING PERFORMANCE STATS          "
echo "═══════════════════════════════════════════"
echo ""

# CPU Info
echo "🔥 CPU Governor:"
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "N/A"
echo ""

# Current CPU frequency
echo "⚡ CPU Frequencies:"
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
    freq=$(cat "$cpu" 2>/dev/null)
    if [ -n "$freq" ]; then
        echo "  $(basename $(dirname $cpu)): $((freq / 1000)) MHz"
    fi
done
echo ""

# Memory Info
echo "💾 Memory:"
free -h | grep -E "Mem|Swap"
echo ""

# GPU Info (if available)
if [ -f /sys/class/drm/card0/device/gpu_busy_percent ]; then
    echo "🎨 GPU Usage:"
    cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null
    echo "%"
fi

# Check GameMode status
if command -v gamemoded &> /dev/null; then
    echo ""
    echo "🎲 GameMode:"
    gamemoded -s 2>/dev/null || echo "  Status unknown"
fi

echo ""
echo "═══════════════════════════════════════════"
EOF
    chmod +x /usr/local/bin/gaming-perf
    
    # Copy templates to existing users
    for userdir in /home/*; do
        if [ -d "$userdir" ]; then
            username=$(basename "$userdir")
            if id "$username" &>/dev/null; then
                cp /etc/skel/.gamingrc "$userdir/" 2>/dev/null || true
                chown "$username:$username" "$userdir/.gamingrc" 2>/dev/null || true
            fi
        fi
    done
    
    print_success "User helper scripts created"
}

# ============================================================================
# DOCUMENTATION
# ============================================================================

create_documentation() {
    print_section "📚 Creating Documentation"
    
    mkdir -p /usr/share/doc/linux-gaming-toolkit
    
    cat > /usr/share/doc/linux-gaming-toolkit/README.md << 'EOF'
# Linux Gaming Toolkit

Thank you for installing the Linux Gaming Toolkit!

## What's Installed

### Gaming Platforms
- **Steam** - The ultimate gaming platform with Proton compatibility
- **Lutris** - Unified game launcher for all your games
- **Heroic Games Launcher** - Epic Games and GOG support

### Performance Tools
- **GameMode** - System optimizer that boosts game performance
- **MangoHud** - In-game performance overlay
- **Gamescope** - Micro-compositor for gaming
- **vkBasalt** - Vulkan post-processing (reshade-like effects)
- **CoreCtrl** - GPU control utility

### Compatibility Layers
- **Wine** - Run Windows applications
- **Winetricks** - Helper for Wine configuration
- **Proton-GE** - Enhanced Proton via ProtonUp-Qt

## Quick Start

### Launch Games with Optimizations
```bash
# Use the game-launch helper
game-launch /path/to/game

# Or manually with MangoHud and GameMode
mangohud gamemoderun ./game

# Steam with optimizations
steam-gaming
```

### Check Performance
```bash
gaming-perf
```

### Enable MangoHud in Steam
Add to Steam launch options:
```
mangohud %command%
```

### Enable GameMode in Steam
Add to Steam launch options:
```
gamemoderun %command%
```

### Combined
```
mangohud gamemoderun %command%
```

## Configuration Files

- GameMode: `~/.config/gamemode.ini`
- MangoHud: `~/.config/MangoHud/MangoHud.conf`
- Environment: `~/.gamingrc` (source this in your shell rc file)

## Gaming Kernel

If you installed a gaming kernel (XanMod, Liquorix, Zen, or CachyOS),
you need to reboot to activate it.

## CPU Mitigations

If you chose to disable CPU mitigations, your system is now optimized
for maximum performance but may be vulnerable to certain CPU exploits.
This is similar to the default behavior on Windows.

## Additional Resources

- ProtonDB: https://www.protondb.com/
- Gaming on Linux: https://www.gamingonlinux.com/
- Lutris: https://lutris.net/
EOF
    
    print_success "Documentation created at /usr/share/doc/linux-gaming-toolkit/"
}

# ============================================================================
# MAIN MENU
# ============================================================================

# Whiptail GUI menu (like Dennis Hilk's version)
show_whiptail_menu() {
    if ! $USE_WHIPTAIL; then
        return 1
    fi
    
    local choice
    choice=$(whiptail --title "Linux Gaming Toolkit v3" --menu "Select action 🕹️" 22 72 12 \
        "1" "🚀 Full Gaming Setup (Recommended)" \
        "2" "📦 Install Gaming Packages Only" \
        "3" "🐧 Install Gaming Kernel" \
        "4" "🎨 Install GPU Drivers" \
        "5" "⚙️ Apply System Optimizations Only" \
        "6" "🔥 Configure CPU Governor" \
        "7" "⚠️ Disable CPU Mitigations (Security Risk)" \
        "8" "📊 Configure MangoHud" \
        "9" "🎲 Configure GameMode" \
        "10" "🛠️ Install Additional Tools (Discord, itch.io)" \
        "11" "🌐 Check for Latest Drivers Online" \
        "0" "🚪 Exit" 3>&1 1>&2 2>&3)
    
    echo "$choice"
}

# Text-based menu (fallback)
show_menu() {
    print_header
    
    echo "Detected: $DISTRO_NAME ($DISTRO_FAMILY)"
    echo "Architecture: $ARCH"
    echo "GPU: $GPU_VENDOR"
    if $USE_WHIPTAIL; then
        echo "UI: Whiptail GUI available"
    else
        echo "UI: Text mode (install 'whiptail' for GUI)"
    fi
    echo ""
    
    echo "═══════════════════════════════════════════════════════════════════"
    echo "                    MAIN MENU                                      "
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
    echo "  1) 🚀 Full Setup (Recommended) - Install everything"
    echo "  2) 📦 Install Gaming Packages Only"
    echo "  3) 🐧 Install Gaming Kernel"
    echo "  4) 🎨 Install GPU Drivers"
    echo "  5) ⚙️ Apply System Optimizations Only"
    echo "  6) 🔥 Configure CPU Governor"
    echo "  7) ⚠️ Disable CPU Mitigations (Security Risk)"
    echo "  8) 📊 Configure MangoHud"
    echo "  9) 🎲 Configure GameMode"
    echo " 10) 🛠️ Install Additional Tools (Discord, itch.io, VKD3D)"
    echo " 11) 🌐 Check for Latest Drivers Online"
    echo "  0) 🚪 Exit"
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
}

full_setup() {
    print_section "🚀 Starting Full Gaming Setup"
    
    update_system
    enable_multilib
    install_gpu_drivers
    install_gaming_packages
    
    # Ask about kernel
    echo ""
    read -p "Install gaming kernel? [Y/n]: " install_kernel
    if [[ ! "$install_kernel" =~ ^[Nn]$ ]]; then
        install_gaming_kernel
    fi
    
    apply_sysctl_optimizations
    configure_cpu_governor
    optimize_io_scheduler
    configure_gamemode
    configure_mangohud
    configure_steam
    configure_gamescope
    install_additional_tools
    create_user_helpers
    create_documentation
    
    # Ask about mitigations
    disable_cpu_mitigations
    
    print_section "✅ Setup Complete!"
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo "                    INSTALLATION SUMMARY                           "
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
    echo "🎮 Gaming packages installed:"
    echo "   • Steam with controller support"
    echo "   • Lutris for all game launchers"
    echo "   • Wine and Winetricks"
    echo "   • GameMode performance optimizer"
    echo "   • MangoHud performance overlay"
    echo "   • Gamescope compositor"
    echo ""
    echo "⚙️ System optimizations applied:"
    echo "   • Kernel parameters tuned"
    echo "   • CPU governor set to performance"
    echo "   • I/O scheduler optimized"
    echo ""
    echo "📚 Documentation: /usr/share/doc/linux-gaming-toolkit/README.md"
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
    echo -e "${YELLOW}⚠️ IMPORTANT: Reboot your system to apply all changes!${NC}"
    echo ""
    echo "After reboot:"
    echo "  • Run 'gaming-perf' to check system status"
    echo "  • Add 'mangohud %command%' to Steam launch options"
    echo "  • Add 'gamemoderun %command%' for game mode"
    echo ""
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    check_root
    detect_distro
    
    # Create log file
    touch "$LOG_FILE"
    
    # Install whiptail if not present (optional)
    if ! $USE_WHIPTAIL && [ "$DISTRO_FAMILY" = "debian" ]; then
        print_info "Installing whiptail for better UI..."
        apt install -y whiptail 2>/dev/null && USE_WHIPTAIL=true || true
    fi
    
    while true; do
        local choice=""
        
        # Try whiptail first, fallback to text menu
        if $USE_WHIPTAIL; then
            choice=$(show_whiptail_menu)
            if [ $? -ne 0 ]; then
                # User cancelled whiptail
                choice="0"
            fi
        else
            show_menu
            read -p "Enter your choice [0-11]: " choice
        fi
        
        case "$choice" in
            1)
                full_setup
                read -p "Press Enter to continue..." </dev/tty
                ;;
            2)
                install_gaming_packages
                read -p "Press Enter to continue..." </dev/tty
                ;;
            3)
                install_gaming_kernel
                read -p "Press Enter to continue..." </dev/tty
                ;;
            4)
                install_gpu_drivers
                read -p "Press Enter to continue..." </dev/tty
                ;;
            5)
                apply_sysctl_optimizations
                configure_cpu_governor
                optimize_io_scheduler
                read -p "Press Enter to continue..." </dev/tty
                ;;
            6)
                configure_cpu_governor
                read -p "Press Enter to continue..." </dev/tty
                ;;
            7)
                disable_cpu_mitigations
                read -p "Press Enter to continue..." </dev/tty
                ;;
            8)
                configure_mangohud
                read -p "Press Enter to continue..." </dev/tty
                ;;
            9)
                configure_gamemode
                read -p "Press Enter to continue..." </dev/tty
                ;;
            10)
                install_additional_tools
                read -p "Press Enter to continue..." </dev/tty
                ;;
            11)
                check_latest_drivers_online
                read -p "Press Enter to continue..." </dev/tty
                ;;
            0|""|*)
                echo ""
                print_success "Thank you for using Linux Gaming Toolkit!"
                echo ""
                exit 0
                ;;
        esac
    done
}

# Run main function
main "$@"
