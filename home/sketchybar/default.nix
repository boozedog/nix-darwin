{ pkgs, ... }:

let
  colors = import ./colors.nix;
  font = "Maple Mono NL NF";

  # Load and wrap scripts
  networkSpeedScript = pkgs.writeShellScript "sketchybar-network-speed" (
    builtins.readFile ./scripts/network-speed.sh
  );

  trippyWrapper = pkgs.writeScript "trippy-wrapper" ''
    #!/bin/bash
    exec /run/current-system/sw/bin/trip -u 1.1.1.1
  '';

  networkClickScript = pkgs.writeShellScript "sketchybar-network-click" (
    builtins.replaceStrings [ "@trippyWrapper@" ] [ "${trippyWrapper}" ] (
      builtins.readFile ./scripts/network-click.sh
    )
  );

  clockScript = pkgs.writeShellScript "sketchybar-clock" (builtins.readFile ./scripts/clock.sh);

  clockClickScript = pkgs.writeShellScript "sketchybar-clock-click" (
    builtins.readFile ./scripts/clock-click.sh
  );

  batteryScript = pkgs.writeShellScript "sketchybar-battery" (
    builtins.replaceStrings
      [
        "@green@"
        "@yellow@"
        "@red@"
      ]
      [
        colors.green
        colors.yellow
        colors.red
      ]
      (builtins.readFile ./scripts/battery.sh)
  );

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
          update_freq=10 \
          script="${batteryScript}" \
        --subscribe battery power_source_change system_woke

      sketchybar --add item date right \
        --set date \
          padding_left=24 \
          update_freq=60 \
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
