# Get the default route interface (the one actually being used)
INTERFACE=$(route -n get default 2>/dev/null | grep interface | awk '{print $2}')

if [ -z "$INTERFACE" ]; then
  sketchybar --set "$NAME" icon="󰤭" label="--"
  exit 0
fi

# Get ping time to 1.1.1.1 (timeout after 1 second)
PING=$(ping -c 1 -t 1 1.1.1.1 2>/dev/null | grep "time=" | sed 's/.*time=\([0-9.]*\).*/\1/' | cut -d. -f1)
if [ -n "$PING" ]; then
  PING_LABEL="${PING}ms"
else
  PING_LABEL="--"
fi

# Check if Wi-Fi by looking at the interface type
WIFI_INTERFACE=$(networksetup -listallhardwareports | grep -A1 "Wi-Fi" | grep Device | awk '{print $2}')

if [[ "$INTERFACE" == "$WIFI_INTERFACE" ]]; then
  # Wi-Fi link speed via system_profiler (airport command removed in newer macOS)
  SPEED=$(system_profiler SPAirPortDataType 2>/dev/null | grep -A15 "Current Network" | grep "Transmit Rate" | head -1 | awk '{print $3}')
  if [ -n "$SPEED" ] && [ "$SPEED" -gt 0 ] 2>/dev/null; then
    if [ "$SPEED" -ge 1000 ]; then
      sketchybar --set "$NAME" icon="󰖩" label="$((SPEED/1000))G $PING_LABEL"
    else
      sketchybar --set "$NAME" icon="󰖩" label="${SPEED}M $PING_LABEL"
    fi
  else
    sketchybar --set "$NAME" icon="󰖩" label="-- $PING_LABEL"
  fi
else
  # Ethernet link speed
  MEDIA=$(ifconfig "$INTERFACE" 2>/dev/null | grep media)
  SPEED=$(echo "$MEDIA" | sed 's/.*(\([0-9]*\)base.*/\1/' | grep -oE '^[0-9]+')
  if [ -n "$SPEED" ]; then
    if [ "$SPEED" -ge 1000 ]; then
      sketchybar --set "$NAME" icon="󰈀" label="$((SPEED/1000))G $PING_LABEL"
    else
      sketchybar --set "$NAME" icon="󰈀" label="${SPEED}M $PING_LABEL"
    fi
  else
    sketchybar --set "$NAME" icon="󰈀" label="-- $PING_LABEL"
  fi
fi
