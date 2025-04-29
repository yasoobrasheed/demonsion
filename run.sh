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

# 7. Resize windows from a single display with this ratio
osascript resize.scpt $widthRatio $heightRatio