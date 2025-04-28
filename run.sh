#!/bin/bash

# Make the script executable
chmod +x run.sh
chmod +x set-dimensions.sh

# Call the set-dimensions.sh script to get the dimensions of the current display
./set-dimensions.sh

# Run the yabai command to get all dimensions for all windows across
spacesJson=$(yabai -m query --spaces)

echo "$spacesJson" | jq -c '.[]' | while read -r space; do
  index=$(echo "$space" | jq '.index')
  windows=$(echo "$space" | jq '.windows[]?')

  echo "Desktop $index:"

  # If there are windows, list them
  if [[ -n "$windows" ]]; then
    for window in $windows; do
      echo "  - Window ID: $window"
      dimensions=$(yabai -m query --windows --window $window | jq '.frame')
      echo "  - Dimensions: $dimensions"
    done
  else
    echo "  (No windows)"
  fi

  echo ""
done


