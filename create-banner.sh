#!/bin/bash
#
# Create a professional banner for Linux Gaming Toolkit
# Uses ImageMagick

set -e

OUTPUT="banner.png"
WIDTH=1280
HEIGHT=640

echo "Creating Linux Gaming Toolkit banner..."

# Create base gradient background
convert -size ${WIDTH}x${HEIGHT} \
    gradient:'#1a1a2e-#16213e' \
    -pointsize 30 \
    "$OUTPUT"

# Add Tux penguin silhouette (simplified representation using circle/text)
convert "$OUTPUT" \
    -fill '#0f3460' -draw "circle 200,320 200,180" \
    -fill '#1a1a2e' -draw "circle 200,320 200,200" \
    -fill '#e94560' -draw "circle 170,280 170,270" \
    -fill '#e94560' -draw "circle 230,280 230,270" \
    -fill '#ffffff' -draw "circle 170,280 170,275" \
    -fill '#ffffff' -draw "circle 230,280 230,275" \
    -fill '#1a1a2e' -draw "circle 170,280 170,278" \
    -fill '#1a1a2e' -draw "circle 230,280 230,278" \
    -fill '#e94560' -draw "ellipse 200,350 30,20 0,360" \
    "$OUTPUT"

# Add gaming controller icon
convert "$OUTPUT" \
    -fill '#e94560' -draw "roundrectangle 900,280 1100,400 20,20" \
    -fill '#1a1a2e' -draw "circle 950,340 950,320" \
    -fill '#1a1a2e' -draw "circle 1050,340 1050,320" \
    -fill '#1a1a2e' -draw "circle 1000,300 1000,290" \
    -fill '#1a1a2e' -draw "circle 1000,380 1000,370" \
    "$OUTPUT"

# Add main title
convert "$OUTPUT" \
    -fill '#ffffff' \
    -font 'DejaVu-Sans-Bold' \
    -pointsize 60 \
    -gravity center \
    -annotate +200+0 'LINUX GAMING' \
    "$OUTPUT"

convert "$OUTPUT" \
    -fill '#e94560' \
    -font 'DejaVu-Sans-Bold' \
    -pointsize 60 \
    -gravity center \
    -annotate +200+70 'TOOLKIT' \
    "$OUTPUT"

# Add subtitle
convert "$OUTPUT" \
    -fill '#aaaaaa' \
    -font 'DejaVu-Sans' \
    -pointsize 24 \
    -gravity center \
    -annotate +200+130 'Transform any Linux distro into a gaming powerhouse' \
    "$OUTPUT"

# Add decorative RGB lines
convert "$OUTPUT" \
    -stroke '#e94560' -strokewidth 3 \
    -draw "line 100,500 400,500" \
    -stroke '#0f3460' -strokewidth 3 \
    -draw "line 100,510 400,510" \
    -stroke '#533483' -strokewidth 3 \
    -draw "line 100,520 400,520" \
    "$OUTPUT"

# Add version badge area
convert "$OUTPUT" \
    -fill '#0f3460' -draw "roundrectangle 1000,100 1200,160 10,10" \
    -fill '#ffffff' \
    -font 'DejaVu-Sans-Bold' \
    -pointsize 30 \
    -gravity center \
    -annotate +500+-220 'v3.0' \
    "$OUTPUT"

# Add Linux icon (penguin beak)
convert "$OUTPUT" \
    -fill '#e94560' \
    -draw "polygon 200,300 180,320 220,320" \
    "$OUTPUT"

echo "✅ Banner created: $OUTPUT"
echo "Size: $(identify -format '%wx%h' $OUTPUT)"
