#!/bin/bash
# Create a square logo for the project

OUTPUT="logo.png"
SIZE=512

echo "Creating Linux Gaming Toolkit logo..."

# Create base with gradient
convert -size ${SIZE}x${SIZE} \
    gradient:'#1a1a2e-#16213e' \
    "$OUTPUT"

# Add outer circle border
convert "$OUTPUT" \
    -fill '#e94560' -draw "circle 256,256 256,50" \
    -fill '#1a1a2e' -draw "circle 256,256 256,60" \
    "$OUTPUT"

# Add Tux penguin body
convert "$OUTPUT" \
    -fill '#0f3460' -draw "circle 256,280 256,150" \
    -fill '#1a1a2e' -draw "circle 256,280 256,170" \
    "$OUTPUT"

# Add eyes
convert "$OUTPUT" \
    -fill '#ffffff' -draw "circle 220,220 220,200" \
    -fill '#ffffff' -draw "circle 292,220 292,200" \
    -fill '#1a1a2e' -draw "circle 220,220 220,210" \
    -fill '#1a1a2e' -draw "circle 292,220 292,210" \
    "$OUTPUT"

# Add beak
convert "$OUTPUT" \
    -fill '#e94560' -draw "polygon 256,240 230,270 282,270" \
    "$OUTPUT"

# Add gaming controller elements
convert "$OUTPUT" \
    -fill '#e94560' -draw "roundrectangle 180,350 332,420 15,15" \
    -fill '#1a1a2e' -draw "circle 220,385 220,365" \
    -fill '#1a1a2e' -draw "circle 292,385 292,365" \
    "$OUTPUT"

# Add controller buttons
convert "$OUTPUT" \
    -fill '#533483' -draw "circle 256,360 256,350" \
    -fill '#533483' -draw "circle 256,410 256,400" \
    -fill '#533483' -draw "circle 231,385 231,375" \
    -fill '#533483' -draw "circle 281,385 281,375" \
    "$OUTPUT"

echo "✅ Logo created: $OUTPUT"
echo "Size: $(identify -format '%wx%h' $OUTPUT)"
