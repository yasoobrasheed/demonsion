#!/bin/bash

# Ask user for the name of the display
read -p "Enter the name of the display: " displayName

# Get current display information
displayJson=$(yabai -m query --displays)

# Get the active window information
activeWindowJson=$(yabai -m query --windows --window)

# Get the focused display (the one with the cursor/active window)
if [ -n "$activeWindowJson" ]; then
    # Get the active window's position
    windowX=$(echo "$activeWindowJson" | jq '.frame.x')
    windowY=$(echo "$activeWindowJson" | jq '.frame.y')
    
    # Find the display that contains the active window
    currentDisplay=$(echo "$displayJson" | jq --arg x "$windowX" --arg y "$windowY" \
        '.[] | select(.frame.x <= ($x|tonumber) and 
                     .frame.y <= ($y|tonumber) and 
                     .frame.x + .frame.w >= ($x|tonumber) and 
                     .frame.y + .frame.h >= ($y|tonumber))')
fi

# Extract display dimensions
displayWidth=$(echo "$currentDisplay" | jq '.frame.w')
displayHeight=$(echo "$currentDisplay" | jq '.frame.h')

# Get the current user's home directory
HOME_DIR=$(eval echo ~$USER)

# Create the settings directory if it doesn't exist
SETTINGS_DIR="$HOME_DIR/.config/demonsion"
mkdir -p "$SETTINGS_DIR"

# Save the display dimensions to the settings file
echo "{\"width\": $displayWidth, \"height\": $displayHeight}" > "$SETTINGS_DIR/$displayName.json"

echo "Display dimensions saved to $SETTINGS_DIR/$displayName.json"