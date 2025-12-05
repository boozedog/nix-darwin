{ pkgs, ... }:

let
  colors = {
    bg = "0x8024283a";
    fg = "0xffcdd6f4";
    accent = "0xfff5c2e7";
  };

  font = "Maple Mono NL NF";

  numerals = [
    "I"
    "II"
    "III"
    "IV"
    "V"
    "VI"
  ];

  batteryScript = pkgs.writeShellScript "sketchybar-battery" ''
    BATT_INFO=$(pmset -g batt)
    PERCENT=$(echo "$BATT_INFO" | grep -Eo "[0-9]+%" | head -1)

    if echo "$BATT_INFO" | grep -q "AC Power"; then
      if echo "$BATT_INFO" | grep -q "charged"; then
        ICON="⚡"
      else
        ICON="↑"
      fi
    else
      ICON="↓"
    fi

    sketchybar --set "$NAME" label="$ICON $PERCENT"
  '';

  spaceScript = pkgs.writeShellScript "sketchybar-space" ''
    if [ "$SELECTED" = "true" ]; then
      sketchybar --set "$NAME" \
        background.drawing=on \
        background.color=${colors.fg} \
        background.corner_radius=0 \
        background.height=20 \
        icon.padding_left=8 \
        icon.padding_right=8 \
        icon.color=0xff000000
    else
      sketchybar --set "$NAME" \
        background.drawing=off \
        icon.padding_left=0 \
        icon.padding_right=0 \
        icon.color=${colors.fg}
    fi
  '';
in
{
  programs.sketchybar = {
    enable = true;

    extraPackages = with pkgs; [
      jq
    ];

    config = ''
      # Bar appearance
      sketchybar --bar \
        height=28 \
        color=${colors.bg} \
        blur_radius=0 \
        corner_radius=0 \
        y_offset=2 \
        position=top \
        sticky=on \
        padding_left=12 \
        padding_right=12

      # Default item styling
      sketchybar --default \
        icon.font="${font}:Medium:13.0" \
        label.font="${font}:Medium:13.0" \
        icon.color=${colors.fg} \
        label.color=${colors.fg} \
        padding_left=10 \
        padding_right=10

      # Left: Space indicators
      ${builtins.concatStringsSep "\n" (
        builtins.genList (
          i:
          let
            n = i + 1;
            label = builtins.elemAt numerals i;
          in
          ''
            sketchybar --add space space.${toString n} left \
                       --set space.${toString n} \
                         space=${toString n} \
                         icon="${label}" \
                         script="${spaceScript}" \
                       --subscribe space.${toString n} space_change''
        ) 6
      )}

      # Left: Current app
      sketchybar --add item frontapp left \
                 --set frontapp \
                   script='sketchybar --set $NAME label="$INFO"' \
                   label="Finder" \
                 --subscribe frontapp front_app_switched

      # Right: Battery
      sketchybar --add item battery right \
                 --set battery \
                   update_freq=60 \
                   script="${batteryScript}" \
                 --subscribe battery power_source_change system_woke

      # Right: Date
      sketchybar --add item date right \
                 --set date \
                   update_freq=3600 \
                   script='sketchybar --set $NAME label="$(date +%Y-%m-%d)"'

      # Right: Clock
      sketchybar --add item clock right \
                 --set clock \
                   update_freq=10 \
                   script='sketchybar --set $NAME label="$(date +%H:%M)"'

      sketchybar --update
    '';
  };
}
