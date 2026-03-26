#!/bin/bash
#
# Quick test for common issues

set -e

echo "======================================"
echo "Quick Issue Detection Test"
echo "======================================"
echo ""

SCRIPT="/mnt/HC_Volume_104832602/gamingtoolkit/gamingtoolkit.sh"

# 1. Check for common bash issues
echo "--- Checking for common bash issues ---"

# Check for unquoted variables in critical places
echo "Checking for potentially unquoted variables in conditions..."
if grep -n 'if.*\[.*\$[^"]' "$SCRIPT" | grep -v 'grep\|sed\|awk' | head -10; then
    echo "⚠ Found potentially unquoted variables (may be false positives)"
else
    echo "✓ No obvious unquoted variable issues"
fi

echo ""

# 2. Check for package names that differ between distros
echo "--- Checking package name consistency ---"
echo "Packages that might need distro-specific handling:"
grep -oE 'install_packages [a-z0-9-]+' "$SCRIPT" | sort | uniq -c | sort -rn | head -20

echo ""

# 3. Check for functions that might fail without proper error handling
echo "--- Checking error handling ---"
echo "Functions with '|| true' (optional failures allowed):"
grep -c '|| true' "$SCRIPT" && echo "^ These allow failures (good for optional packages)"

echo ""
echo "Functions with proper error messages:"
grep -c 'print_warning.*||' "$SCRIPT" && echo "^ These show warnings on failure"

echo ""

# 4. Check for potential infinite loops or recursion
echo "--- Checking for recursion issues ---"
if grep -n 'install_packages.*install_packages' "$SCRIPT"; then
    echo "⚠ Potential recursion found"
else
    echo "✓ No obvious recursion issues"
fi

echo ""

# 5. Check for required external commands
echo "--- Checking required commands ---"
REQUIRED_CMDS="curl wget git grep sed awk lspci uname"
for cmd in $REQUIRED_CMDS; do
    if command -v "$cmd" > /dev/null 2>&1; then
        echo "✓ $cmd available"
    else
        echo "✗ $cmd NOT available (will be installed by script)"
    fi
done

echo ""

# 6. Check script structure
echo "--- Script structure ---"
echo "Total lines: $(wc -l < "$SCRIPT")"
echo "Functions defined: $(grep -c '^[a-z_]*() {' "$SCRIPT")"
echo "Case statements: $(grep -c 'case ' "$SCRIPT")"
echo "If statements: $(grep -c 'if ' "$SCRIPT")"

echo ""
echo "======================================"
echo "Test complete!"
echo "======================================"
