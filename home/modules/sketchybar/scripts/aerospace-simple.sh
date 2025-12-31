#!/bin/bash

# Simple workspace script for main display - no app icons, just numbers/letters
# Workspace ID passed as argument
SID="$1"

# Get the currently focused workspace
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

# Check if workspace has any windows
HAS_WINDOWS=$(aerospace list-windows --workspace "$SID" --json 2>/dev/null | jq -r 'length' 2>/dev/null)

if [ "$SID" = "$FOCUSED" ]; then
  # Focused workspace: show with highlight background
  sketchybar --set "$NAME" \
    drawing=on \
    background.drawing=on \
    icon="$SID" \
    label.drawing=off
else
  # Unfocused workspace: only show if it has windows
  if [ -n "$HAS_WINDOWS" ] && [ "$HAS_WINDOWS" -gt 0 ]; then
    sketchybar --set "$NAME" \
      drawing=on \
      background.drawing=off \
      icon="$SID" \
      label.drawing=off
  else
    sketchybar --set "$NAME" \
      drawing=off
  fi
fi
