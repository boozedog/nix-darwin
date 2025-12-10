#!/bin/bash

# Get the focused window's title using aerospace
TITLE=$(aerospace list-windows --focused --json 2>/dev/null | jq -r '.[0]["window-title"] // empty' 2>/dev/null)

if [ -n "$TITLE" ]; then
  # Truncate if too long
  if [ ${#TITLE} -gt 60 ]; then
    TITLE="${TITLE:0:57}..."
  fi
  sketchybar --set "$NAME" label="$TITLE" label.drawing=on
else
  sketchybar --set "$NAME" label.drawing=off
fi
