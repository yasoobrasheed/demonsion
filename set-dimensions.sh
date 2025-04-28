#!/bin/bash

# Make the script executable
chmod +x set-dimensions.sh

# Ask user for the name of the display
read -p "Enter the name of your display: " displayName

# Ask user if they want to set the dimensions themselves
read -p "Use your current display dimensions? (y/n): " useCurrentDimensions

if [ "$useCurrentDimensions" = "n" ]; then
    # Ask user for the width and height
    read -p "Enter the width of your display: " displayWidth
    read -p "Enter the height of your display: " displayHeight
elif [ "$useCurrentDimensions" = "y" ] || [ "$useCurrentDimensions" = "" ]; then
    # Get current display information
    displayJson=$(yabai -m query --displays)
    
    # Get the active window information
    activeWindowJson=$(yabai -m query --windows --window)
    
    # Get the focused display (the one with the cursor/active window)
    if [ -n "$activeWindowJson" ] && [ "$activeWindowJson" != "null" ]; then
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
    
    # If no active window is found or no display contains the window, use the first display
    if [ -z "$currentDisplay" ] || [ "$currentDisplay" = "null" ]; then
        currentDisplay=$(echo "$displayJson" | jq '.[0]')
    fi
    
    # Extract display dimensions
    displayWidth=$(echo "$currentDisplay" | jq '.frame.w')
    displayHeight=$(echo "$currentDisplay" | jq '.frame.h')
fi

# Get the current user's home directory
HOME_DIR=$(eval echo ~$USER)

# Create the settings directory if it doesn't exist
SETTINGS_DIR="$HOME_DIR/.config/demonsion"
mkdir -p "$SETTINGS_DIR"

# Save the display dimensions to the settings file
echo "{\"width\": $displayWidth, \"height\": $displayHeight}" > "$SETTINGS_DIR/$displayName.json"

# Print the dimensions to the terminal
echo "Display dimensions for $displayName: $displayWidth x $displayHeight saved to $SETTINGS_DIR/$displayName.json"