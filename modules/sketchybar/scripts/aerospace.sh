#!/bin/bash

# Source the icon map from sketchybar-app-font
source "@iconMapScript@"

# Workspace ID passed as argument
SID="$1"

# Get unique app names for this workspace
get_workspace_apps() {
  aerospace list-windows --workspace "$1" --json 2>/dev/null | \
    jq -r '.[]["app-name"]' 2>/dev/null | \
    sort -u
}

# Build icon string for workspace using sketchybar-app-font ligatures
build_icon_string() {
  local workspace="$1"
  local icons=""

  while IFS= read -r app; do
    [ -z "$app" ] && continue
    __icon_map "$app"
    if [ -z "$icons" ]; then
      icons="$icon_result"
    else
      icons="$icons $icon_result"
    fi
  done < <(get_workspace_apps "$workspace")

  echo "$icons"
}

# Get the currently focused workspace
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

# Build the app icons string for this workspace
APP_ICONS=$(build_icon_string "$SID")

# Update the workspace item
if [ "$SID" = "$FOCUSED" ]; then
  # Focused workspace: highlight background, show icons if any
  if [ -n "$APP_ICONS" ]; then
    sketchybar --set "$NAME" \
      background.drawing=on \
      label="$APP_ICONS" \
      label.drawing=on
  else
    sketchybar --set "$NAME" \
      background.drawing=on \
      label.drawing=off
  fi
else
  # Unfocused workspace: no background highlight, still show icons if any
  if [ -n "$APP_ICONS" ]; then
    sketchybar --set "$NAME" \
      background.drawing=off \
      label="$APP_ICONS" \
      label.drawing=on
  else
    sketchybar --set "$NAME" \
      background.drawing=off \
      label.drawing=off
  fi
fi
