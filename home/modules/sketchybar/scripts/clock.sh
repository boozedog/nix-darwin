STATE_FILE="/tmp/sketchybar-clock-utc"
if [ -f "$STATE_FILE" ]; then
  sketchybar --set "$NAME" label="$(date -u +%H:%M)Z"
else
  sketchybar --set "$NAME" label="$(date +%H:%M)"
fi
