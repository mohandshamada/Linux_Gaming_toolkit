#!/bin/bash
# High-quality banner and logo generation for Linux Gaming Toolkit
# Uses ImageMagick

set -e

# Configuration
BANNER_OUTPUT="banner.png"
LOGO_OUTPUT="logo.png"
BANNER_WIDTH=1200
BANNER_HEIGHT=400
LOGO_SIZE=512

# Colors
DARK="#0f0f1b"
ACCENT="#00d2ff"      # Cyan
ACCENT_DARK="#3a7bd5" # Blue
TEXT_COLOR="#ffffff"

echo "🎨 Generating new project media..."

# 1. Create Banner
echo "  - Creating banner..."
convert -size ${BANNER_WIDTH}x${BANNER_HEIGHT} \
    gradient:"${DARK}-${ACCENT_DARK}" \
    -fill none -stroke "${ACCENT}" -strokewidth 2 -draw "line 0,0 ${BANNER_WIDTH},0" \
    -fill none -stroke "${ACCENT}" -strokewidth 2 -draw "line 0,${BANNER_HEIGHT} ${BANNER_WIDTH},${BANNER_HEIGHT}" \
    \( -size ${BANNER_WIDTH}x${BANNER_HEIGHT} canvas:transparent \
       -fill "${TEXT_COLOR}" -font "DejaVu-Sans-Bold" -pointsize 80 -gravity center \
       -annotate +0-40 "LINUX GAMING" \
       -fill "${ACCENT}" -font "DejaVu-Sans-Bold" -pointsize 60 -gravity center \
       -annotate +0+40 "TOOLKIT" \
    \) -composite \
    "$BANNER_OUTPUT"

# 2. Create Logo (Simplified version of the banner style)
echo "  - Creating logo..."
convert -size ${LOGO_SIZE}x${LOGO_SIZE} \
    gradient:"${DARK}-${ACCENT_DARK}" \
    -fill none -stroke "${ACCENT}" -strokewidth 10 -draw "circle 256,256 256,40" \
    \( -size ${LOGO_SIZE}x${LOGO_SIZE} canvas:transparent \
       -fill "${TEXT_COLOR}" -font "DejaVu-Sans-Bold" -pointsize 180 -gravity center \
       -annotate +0+0 "LGT" \
    \) -composite \
    "$LOGO_OUTPUT"

echo "✅ Media generation complete!"
echo "Banner: $BANNER_OUTPUT ($(identify -format '%wx%h' $BANNER_OUTPUT))"
echo "Logo: $LOGO_OUTPUT ($(identify -format '%wx%h' $LOGO_OUTPUT))"
