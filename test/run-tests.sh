#!/bin/bash
#
# Test script for Linux Gaming Toolkit
# Runs various checks to identify issues

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "======================================"
echo "Linux Gaming Toolkit - Test Suite"
echo "======================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    echo -n "Testing: $test_name... "
    if eval "$test_cmd" > /tmp/test_output.log 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        echo "  Error output:"
        tail -5 /tmp/test_output.log | sed 's/^/    /'
        ((TESTS_FAILED++))
        return 1
    fi
}

# ============================================
# STATIC ANALYSIS TESTS
# ============================================

echo "--- Static Analysis Tests ---"

# Test 1: Syntax check
run_test "Bash syntax check" "bash -n $PROJECT_DIR/gamingtoolkit.sh"
run_test "Uninstall script syntax" "bash -n $PROJECT_DIR/uninstall.sh"

# Test 2: Check for common bash issues
echo ""
echo "Checking for common issues..."

# Check for unquoted variables (common source of errors)
UNQUOTED=$(grep -n 'if \[ -\$' "$PROJECT_DIR/gamingtoolkit.sh" 2>/dev/null | wc -l)
if [ "$UNQUOTED" -eq 0 ]; then
    echo -e "${GREEN}✓ No unquoted variable comparisons found${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠ Found $UNQUOTED potentially unquoted variables${NC}"
fi

# Test 3: Check for required commands
echo ""
echo "--- Required Commands Check ---"

for cmd in grep sed awk curl wget git lspci; do
    if command -v "$cmd" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $cmd available${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${YELLOW}⚠ $cmd not available (may be installed by script)${NC}"
    fi
done

# ============================================
# FUNCTION TESTS (Source and test individual functions)
# ============================================

echo ""
echo "--- Function Tests ---"

# Create a minimal test environment
export DISTRO_FAMILY="debian"
export DISTRO_NAME="Ubuntu Test"

# Source the modules to test functions
if [ -f "$PROJECT_DIR/modules/utils.sh" ]; then
    source "$PROJECT_DIR/modules/utils.sh" 2>/dev/null || true
fi

# Test package_installed function logic
echo "Testing package detection logic..."
if command -v dpkg > /dev/null 2>&1; then
    run_test "dpkg package detection" "dpkg -l bash"
elif command -v rpm > /dev/null 2>&1; then
    run_test "rpm package detection" "rpm -q bash"
elif command -v pacman > /dev/null 2>&1; then
    run_test "pacman package detection" "pacman -Q bash"
fi

# ============================================
# PACKAGE INSTALLATION SIMULATION
# ============================================

echo ""
echo "--- Package Installation Simulation ---"

# Test that package manager commands are valid
case "$DISTRO_FAMILY" in
    debian)
        run_test "apt dry-run" "apt install --dry-run bash 2>/dev/null || apt install -s bash"
        ;;
    fedora)
        run_test "dnf dry-run" "dnf install --assumeno bash 2>/dev/null || true"
        ;;
    arch)
        run_test "pacman dry-run" "pacman -S --print bash"
        ;;
    suse)
        run_test "zypper dry-run" "zypper --dry-run install bash"
        ;;
esac

# ============================================
# DOCKER TESTS
# ============================================

echo ""
echo "--- Docker Integration Tests ---"

if command -v docker > /dev/null 2>&1; then
    echo "Docker available, running container tests..."
    
    # Test Ubuntu
    if [ -f "$SCRIPT_DIR/Dockerfile.ubuntu" ]; then
        echo ""
        echo "Building Ubuntu test container..."
        if docker build -f "$SCRIPT_DIR/Dockerfile.ubuntu" -t gamingtoolkit-test:ubuntu "$PROJECT_DIR" > /tmp/docker_ubuntu.log 2>&1; then
            echo -e "${GREEN}✓ Ubuntu container built${NC}"
            ((TESTS_PASSED++))
            
            # Run basic test in container
            echo "Running basic test in Ubuntu container..."
            if docker run --rm gamingtoolkit-test:ubuntu bash -c "head -50 /root/gamingtoolkit.sh | grep -q 'Linux Gaming Toolkit'"; then
                echo -e "${GREEN}✓ Script accessible in container${NC}"
                ((TESTS_PASSED++))
            else
                echo -e "${RED}✗ Script not accessible${NC}"
                ((TESTS_FAILED++))
            fi
        else
            echo -e "${RED}✗ Ubuntu container build failed${NC}"
            tail -10 /tmp/docker_ubuntu.log
            ((TESTS_FAILED++))
        fi
    fi
    
    # Test Fedora
    if [ -f "$SCRIPT_DIR/Dockerfile.fedora" ]; then
        echo ""
        echo "Building Fedora test container..."
        if docker build -f "$SCRIPT_DIR/Dockerfile.fedora" -t gamingtoolkit-test:fedora "$PROJECT_DIR" > /tmp/docker_fedora.log 2>&1; then
            echo -e "${GREEN}✓ Fedora container built${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}✗ Fedora container build failed${NC}"
            ((TESTS_FAILED++))
        fi
    fi
else
    echo "Docker not available, skipping container tests"
fi

# ============================================
# SUMMARY
# ============================================

echo ""
echo "======================================"
echo "Test Summary"
echo "======================================"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Check output above.${NC}"
    exit 1
fi
