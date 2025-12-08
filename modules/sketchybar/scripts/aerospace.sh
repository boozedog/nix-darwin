#!/bin/bash

# Workspace ID passed as argument
SID="$1"

# Map app names to Nerd Font icons
get_app_icon() {
  case "$1" in
    "Brave Browser"|"Safari"|"Firefox"|"Google Chrome"|"Arc") echo "" ;;
    "Code"|"Visual Studio Code") echo "󰨞" ;;
    "Terminal"|"Alacritty"|"kitty"|"iTerm2"|"Ghostty") echo "" ;;
    "Finder") echo "" ;;
    "Messages"|"Slack"|"Discord"|"Telegram") echo "󰍡" ;;
    "Mail"|"Fastmail") echo "󰇮" ;;
    "Calendar"|"Fantastical") echo "" ;;
    "Notes"|"Obsidian"|"Notion") echo "󱞁" ;;
    "Music"|"Spotify") echo "󰎆" ;;
    "Preview"|"PDF Expert") echo "" ;;
    "System Preferences"|"System Settings") echo "" ;;
    "Activity Monitor") echo "" ;;
    "Xcode") echo "" ;;
    "Docker"|"Docker Desktop") echo "" ;;
    "TablePlus"|"Sequel Pro") echo "" ;;
    "Postman"|"Insomnia") echo "󰢩" ;;
    "Figma"|"Sketch") echo "" ;;
    "zoom.us"|"Zoom") echo "󰍫" ;;
    "1Password") echo "󰌋" ;;
    *) echo "󰣆" ;; # Default app icon
  esac
}

# Get unique app names for this workspace
get_workspace_apps() {
  aerospace list-windows --workspace "$1" --json 2>/dev/null | \
    jq -r '.[]["app-name"]' 2>/dev/null | \
    sort -u
}

# Build icon string for workspace
build_icon_string() {
  local workspace="$1"
  local icons=""

  while IFS= read -r app; do
    [ -z "$app" ] && continue
    local icon
    icon=$(get_app_icon "$app")
    if [ -z "$icons" ]; then
      icons="$icon"
    else
      icons="$icons $icon"
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
