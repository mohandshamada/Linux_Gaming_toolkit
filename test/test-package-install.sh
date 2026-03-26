#!/bin/bash
#
# Test package installation with dependencies
# Runs inside Docker containers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "======================================"
echo "Package Installation Test"
echo "======================================"
echo ""

# Test packages commonly installed by the script
TEST_PACKAGES_DEBIAN="curl wget git pciutils vulkan-tools"
TEST_PACKAGES_FEDORA="curl wget git pciutils vulkan-tools"
TEST_PACKAGES_ARCH="curl wget git pciutils vulkan-tools"

test_debian() {
    echo "--- Testing Debian/Ubuntu Package Installation ---"
    
    # Simulate what the script does
    apt-get update
    
    # Test installing packages with dependencies
    for pkg in $TEST_PACKAGES_DEBIAN; do
        echo -n "Installing $pkg... "
        if apt-get install -y --no-install-recommends "$pkg" > /tmp/apt_$pkg.log 2>&1; then
            echo "OK"
            # Check dependencies were installed
            deps=$(apt-cache depends "$pkg" 2>/dev/null | grep "Depends:" | head -3)
            echo "  Dependencies: $deps"
        else
            echo "FAILED"
            cat /tmp/apt_$pkg.log
        fi
    done
    
    # Test package detection
    echo ""
    echo "Testing package_installed function simulation..."
    for pkg in curl wget git; do
        if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            echo "✓ $pkg detected as installed"
        else
            echo "✗ $pkg NOT detected"
        fi
    done
}

test_fedora() {
    echo "--- Testing Fedora Package Installation ---"
    
    # Test installing packages
    for pkg in $TEST_PACKAGES_FEDORA; do
        echo -n "Installing $pkg... "
        if dnf install -y "$pkg" > /tmp/dnf_$pkg.log 2>&1; then
            echo "OK"
        else
            echo "FAILED (or already installed)"
        fi
    done
    
    # Test package detection
    echo ""
    echo "Testing package detection..."
    for pkg in curl wget git; do
        if rpm -q "$pkg" > /dev/null 2>&1; then
            echo "✓ $pkg detected as installed"
        else
            echo "✗ $pkg NOT detected"
        fi
    done
}

test_arch() {
    echo "--- Testing Arch Package Installation ---"
    
    pacman -Sy --noconfirm
    
    # Test installing packages
    for pkg in $TEST_PACKAGES_ARCH; do
        echo -n "Installing $pkg... "
        if pacman -S --noconfirm "$pkg" > /tmp/pacman_$pkg.log 2>&1; then
            echo "OK"
        else
            echo "FAILED"
        fi
    done
    
    # Test package detection
    echo ""
    echo "Testing package detection..."
    for pkg in curl wget git; do
        if pacman -Q "$pkg" > /dev/null 2>&1; then
            echo "✓ $pkg detected as installed"
        else
            echo "✗ $pkg NOT detected"
        fi
    done
}

# Detect distro and run appropriate test
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|debian)
            test_debian
            ;;
        fedora)
            test_fedora
            ;;
        arch)
            test_arch
            ;;
        *)
            echo "Unknown distro: $ID"
            exit 1
            ;;
    esac
else
    echo "Cannot detect distro"
    exit 1
fi

echo ""
echo "Package installation test complete!"
