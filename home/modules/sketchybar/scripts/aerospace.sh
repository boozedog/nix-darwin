#!/bin/bash

# Source the icon map from sketchybar-app-font
source "@iconMapScript@"

# Workspace ID passed as argument
SID="$1"

# Config file for workspace names
NAMES_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/aerospace/workspace-names"

# Get custom workspace name if set
get_workspace_name() {
  local ws="$1"
  if [ -f "$NAMES_FILE" ]; then
    grep "^${ws}=" "$NAMES_FILE" 2>/dev/null | cut -d'=' -f2-
  fi
}

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
    # Map Fastmail to use Mail icon
    if [ "$app" = "Fastmail" ]; then
      __icon_map "Mail"
    # Grok uses bilibili icon (robot-like)
    elif [ "$app" = "Grok" ]; then
      icon_result=":bilibili:"
    else
      __icon_map "$app"
    fi
    if [ -z "$icons" ]; then
      icons="$icon_result"
    else
      icons="$icons$icon_result"
    fi
  done < <(get_workspace_apps "$workspace")

  # Strip all whitespace that may have been introduced
  echo "${icons}"
}

# Get the currently focused workspace
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

# Check for custom workspace name
CUSTOM_NAME=$(get_workspace_name "$SID")

# If custom name: show "N name" in icon, no label
# Otherwise: show N in icon, app icons in label
if [ -n "$CUSTOM_NAME" ]; then
  # Custom name: always show workspace with "N name", no app icons
  if [ "$SID" = "$FOCUSED" ]; then
    sketchybar --set "$NAME" \
      drawing=on \
      background.drawing=on \
      icon="$SID $CUSTOM_NAME" \
      label.drawing=off
  else
    sketchybar --set "$NAME" \
      drawing=on \
      background.drawing=off \
      icon="$SID $CUSTOM_NAME" \
      label.drawing=off
  fi
else
  # No custom name: use app icons
  APP_ICONS=$(build_icon_string "$SID")

  if [ "$SID" = "$FOCUSED" ]; then
    # Focused workspace: always show with highlight background
    if [ -n "$APP_ICONS" ]; then
      sketchybar --set "$NAME" \
        drawing=on \
        background.drawing=on \
        icon="$SID" \
        label="$APP_ICONS" \
        label.padding_right=7 \
        label.drawing=on
    else
      sketchybar --set "$NAME" \
        drawing=on \
        background.drawing=on \
        icon="$SID" \
        label.drawing=off
    fi
  else
    # Unfocused workspace: only show if it has apps
    if [ -n "$APP_ICONS" ]; then
      sketchybar --set "$NAME" \
        drawing=on \
        background.drawing=off \
        icon="$SID" \
        label="$APP_ICONS" \
        label.padding_right=7 \
        label.drawing=on
    else
      sketchybar --set "$NAME" \
        drawing=off
    fi
  fi
fi
