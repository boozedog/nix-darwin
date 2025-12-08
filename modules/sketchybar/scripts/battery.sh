BATT_INFO=$(pmset -g batt)
PERCENT=$(echo "$BATT_INFO" | grep -Eo "[0-9]+%" | head -1)
TIME_RAW=$(echo "$BATT_INFO" | grep -Eo "[0-9]+:[0-9]+" | head -1)

# Format time as Xh Ym or just Ym if less than an hour
if [ -n "$TIME_RAW" ]; then
  HOURS=$(echo "$TIME_RAW" | cut -d: -f1)
  MINS=$(echo "$TIME_RAW" | cut -d: -f2)
  # Remove leading zeros
  HOURS=$((10#$HOURS))
  MINS=$((10#$MINS))
  if [ "$HOURS" -gt 0 ]; then
    TIME_REMAINING="${HOURS}h${MINS}m"
  else
    TIME_REMAINING="${MINS}m"
  fi
else
  TIME_REMAINING=""
fi

# Colors injected via substitution
GREEN="@green@"
YELLOW="@yellow@"
RED="@red@"

if echo "$BATT_INFO" | grep -q "AC Power"; then
  if echo "$BATT_INFO" | grep -q "charged"; then
    ICON="󰚥"
    COLOR="$GREEN"
    LABEL="$PERCENT"
  elif echo "$BATT_INFO" | grep -qi "not charging"; then
    ICON="󰚥"
    COLOR="$YELLOW"
    LABEL="$PERCENT"
  else
    ICON="↑"
    COLOR="$GREEN"
    if [ -n "$TIME_REMAINING" ]; then
      LABEL="$PERCENT $TIME_REMAINING"
    else
      LABEL="$PERCENT"
    fi
  fi
else
  ICON="↓"
  COLOR="$RED"
  if [ -n "$TIME_REMAINING" ]; then
    LABEL="$PERCENT $TIME_REMAINING"
  else
    LABEL="$PERCENT"
  fi
fi

sketchybar --set "$NAME" label="$LABEL" icon="$ICON" icon.color="$COLOR"
