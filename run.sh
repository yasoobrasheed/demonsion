#!/bin/bash

# Make the script executable
chmod +x run.sh

# 1. Ask user for the names of the displays
read -p "Enter the name of your first display: " displayNameA
read -p "Enter the name of your second display: " displayNameB

# 2. Get the dimensions for both displays from their respective settings files
SETTINGS_DIR="$HOME/.config/demonsion"

# 3. Check if the settings files exist
if [ ! -f "$SETTINGS_DIR/$displayNameA.json" ] || [ ! -f "$SETTINGS_DIR/$displayNameB.json" ]; then
    echo "Error: One or both display settings files not found."
    echo "Please run set-dimensions.sh first to create the settings files."
    exit 1
fi

# 4. Read dimensions from the settings files
dimensionsA=$(cat "$SETTINGS_DIR/$displayNameA.json")
dimensionsB=$(cat "$SETTINGS_DIR/$displayNameB.json")

# 5. Extract width and height values
widthA=$(echo "$dimensionsA" | jq '.width')
heightA=$(echo "$dimensionsA" | jq '.height')
widthB=$(echo "$dimensionsB" | jq '.width')
heightB=$(echo "$dimensionsB" | jq '.height')

# echo "Display $displayNameA dimensions: $widthA x $heightA"
# echo "Display $displayNameB dimensions: $widthB x $heightB"

# 6. Divide display A width and height by display B width and height
widthRatio=$(echo "scale=10; $widthB / $widthA" | bc)
heightRatio=$(echo "scale=10; $heightB / $heightA" | bc)

# echo "Width ratio: $widthRatio"
# echo "Height ratio: $heightRatio"

# 7. Run the yabai command to get all dimensions for all windows across all spaces
spacesJson=$(yabai -m query --spaces)

echo "$spacesJson" | jq -c '.[]' | while read -r space; do
  index=$(echo "$space" | jq '.index')
  windows=$(echo "$space" | jq '.windows[]?')

  if [[ -n "$windows" ]]; then
    echo "Desktop $index:"
    
    for window in $windows; do
      echo "  - Window ID: $window"
      windowInfo=$(yabai -m query --windows --window $window)
      x=$(echo "$windowInfo" | jq '.frame.x')
      y=$(echo "$windowInfo" | jq '.frame.y')
      w=$(echo "$windowInfo" | jq '.frame.w')
      h=$(echo "$windowInfo" | jq '.frame.h')
      
      # Apply the width and height ratios
      newX=$(echo "scale=4; $x * $widthRatio" | bc)
      newY=$(echo "scale=4; $y * $heightRatio" | bc)
      newW=$(echo "scale=4; $w * $widthRatio" | bc)
      newH=$(echo "scale=4; $h * $heightRatio" | bc)
      
      # dimensions=$(echo "{\"x\": $newX, \"y\": $newY, \"w\": $newW, \"h\": $newH}")
      echo "  - Original Dimensions: $x $y $w $h"
      echo "  - New Dimensions: $newX $newY $newW $newH"
    done
  fi
done