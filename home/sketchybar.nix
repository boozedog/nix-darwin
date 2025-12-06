{ pkgs, ... }:

let
  colors = {
    bg = "0x8024283a";
    fg = "0xffcdd6f4";
    accent = "0xfff5c2e7";
  };

  font = "Maple Mono NL NF";

  networkSpeedScript = pkgs.writeShellScript "sketchybar-network-speed" ''
    # Get the default route interface (the one actually being used)
    INTERFACE=$(route -n get default 2>/dev/null | grep interface | awk '{print $2}')

    if [ -z "$INTERFACE" ]; then
      sketchybar --set "$NAME" icon="󰤭" label="--"
      exit 0
    fi

    # Get ping time to 1.1.1.1 (timeout after 1 second)
    PING=$(ping -c 1 -t 1 1.1.1.1 2>/dev/null | grep "time=" | sed 's/.*time=\([0-9.]*\).*/\1/' | cut -d. -f1)
    if [ -n "$PING" ]; then
      PING_LABEL="''${PING}ms"
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
          sketchybar --set "$NAME" icon="󰖩" label="$((SPEED/1000))Gbps $PING_LABEL"
        else
          sketchybar --set "$NAME" icon="󰖩" label="''${SPEED}Mbps $PING_LABEL"
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
          sketchybar --set "$NAME" icon="󰈀" label="$((SPEED/1000))Gbps $PING_LABEL"
        else
          sketchybar --set "$NAME" icon="󰈀" label="''${SPEED}Mbps $PING_LABEL"
        fi
      else
        sketchybar --set "$NAME" icon="󰈀" label="-- $PING_LABEL"
      fi
    fi
  '';

  trippyWrapper = pkgs.writeScript "trippy-wrapper" ''
    #!/bin/bash
    exec /run/current-system/sw/bin/trip -u 1.1.1.1
  '';

  networkClickScript = pkgs.writeShellScript "sketchybar-network-click" ''
    open -a Terminal "${trippyWrapper}"
  '';

  clockScript = pkgs.writeShellScript "sketchybar-clock" ''
    STATE_FILE="/tmp/sketchybar-clock-utc"
    if [ -f "$STATE_FILE" ]; then
      sketchybar --set "$NAME" label="$(date -u +%H:%M)Z"
    else
      sketchybar --set "$NAME" label="$(date +%H:%M)"
    fi
  '';

  clockClickScript = pkgs.writeShellScript "sketchybar-clock-click" ''
    STATE_FILE="/tmp/sketchybar-clock-utc"
    if [ -f "$STATE_FILE" ]; then
      rm "$STATE_FILE"
    else
      touch "$STATE_FILE"
    fi
    sketchybar --trigger clock
  '';

  batteryScript = pkgs.writeShellScript "sketchybar-battery" ''
    BATT_INFO=$(pmset -g batt)
    PERCENT=$(echo "$BATT_INFO" | grep -Eo "[0-9]+%" | head -1)
    TIME_REMAINING=$(echo "$BATT_INFO" | grep -Eo "[0-9]+:[0-9]+" | head -1)

    if echo "$BATT_INFO" | grep -q "AC Power"; then
      if echo "$BATT_INFO" | grep -q "charged"; then
        ICON="󰚥"
        COLOR="0xfff9e2af"  # yellow
        LABEL="$PERCENT"
      elif echo "$BATT_INFO" | grep -qi "not charging"; then
        ICON="󰚥"
        COLOR="0xfff9e2af"  # yellow
        LABEL="$PERCENT"
      else
        ICON="↑"
        COLOR="0xffa6e3a1"  # green
        if [ -n "$TIME_REMAINING" ]; then
          LABEL="$PERCENT $TIME_REMAINING"
        else
          LABEL="$PERCENT"
        fi
      fi
    else
      ICON="↓"
      COLOR="0xfff38ba8"  # red
      if [ -n "$TIME_REMAINING" ]; then
        LABEL="$PERCENT $TIME_REMAINING"
      else
        LABEL="$PERCENT"
      fi
    fi

    sketchybar --set "$NAME" label="$LABEL" icon="$ICON" icon.color="$COLOR"
  '';

in
{
  programs.sketchybar = {
    enable = true;
    extraPackages = with pkgs; [ jq ];

    config = ''
      sketchybar --bar height=28 color=${colors.bg} y_offset=2 position=top sticky=on padding_left=12 padding_right=12

      sketchybar --default \
        icon.font="${font}:Bold:14.0" \
        label.font="${font}:Medium:13.0" \
        icon.color=${colors.fg} \
        label.color=${colors.fg}

      # === SPACES (sketchybar only shows spaces that exist) ===
      ${builtins.concatStringsSep "\n" (
        builtins.genList (
          i:
          let
            n = i + 1;
            romanNumerals = [
              "I"
              "II"
              "III"
              "IV"
              "V"
              "VI"
              "VII"
            ];
            roman = builtins.elemAt romanNumerals i;
          in
          ''
            sketchybar --add space space.${toString n} left \
              --set space.${toString n} \
                associated_space=${toString n} \
                icon="${roman}" \
                icon.padding_left=8 \
                icon.padding_right=8 \
                icon.y_offset=1 \
                padding_left=2 \
                padding_right=2 \
                label.padding_right=8 \
                label.drawing=off \
                label.y_offset=1 \
                background.color=${colors.fg} \
                background.corner_radius=4 \
                background.height=20 \
                background.drawing=off \
                script='[ "$SELECTED" = "true" ] && sketchybar --set $NAME background.drawing=on icon.color=0xff000000 label.color=0xff000000 || sketchybar --set $NAME background.drawing=off icon.color=${colors.fg} label.color=${colors.fg}' \
              --subscribe space.${toString n} space_change
          ''
        ) 7
      )}

      # Front app + window title
      sketchybar --add item frontapp left \
        --set frontapp \
          padding_left=10 \
          script='sketchybar --set $NAME label="$INFO"' \
        --subscribe frontapp front_app_switched

      sketchybar --add item window_title left \
        --set window_title \
          script='sketchybar --set $NAME label="$WINDOW_TITLE"' \
        --subscribe window_title front_app_switched title_change

      # Right side items with spacing
      sketchybar --add item battery right \
        --set battery \
          padding_left=24 \
          update_freq=60 \
          script="${batteryScript}" \
        --subscribe battery power_source_change system_woke

      sketchybar --add item date right \
        --set date \
          padding_left=24 \
          update_freq=3600 \
          script='sketchybar --set $NAME label="$(date "+%a %Y-%m-%d")"'

      sketchybar --add event clock
      sketchybar --add item clock right \
        --set clock \
          padding_left=24 \
          update_freq=1 \
          script="${clockScript}" \
          click_script="${clockClickScript}" \
        --subscribe clock clock

      sketchybar --add item network right \
        --set network \
          padding_left=24 \
          update_freq=30 \
          script="${networkSpeedScript}" \
          click_script="${networkClickScript}"

      sketchybar --update
    '';
  };
}
