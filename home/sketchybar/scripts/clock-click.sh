STATE_FILE="/tmp/sketchybar-clock-utc"
if [ -f "$STATE_FILE" ]; then
  rm "$STATE_FILE"
else
  touch "$STATE_FILE"
fi
sketchybar --trigger clock
