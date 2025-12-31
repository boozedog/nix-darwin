{ pkgs, ... }:

let
  colors = import ./colors.nix;
  font = "Maple Mono NL NF";
  appFont = "sketchybar-app-font";
  iconMapScript = "${pkgs.sketchybar-app-font}/bin/icon_map.sh";

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

  memoryScript = pkgs.writeShellScript "sketchybar-memory" (builtins.readFile ./scripts/memory.sh);

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

  aerospaceScript = pkgs.writeShellScript "sketchybar-aerospace" (
    builtins.replaceStrings [ "@iconMapScript@" ] [ iconMapScript ] (
      builtins.readFile ./scripts/aerospace.sh
    )
  );

  aerospaceScriptSimple = pkgs.writeShellScript "sketchybar-aerospace-simple" (
    builtins.readFile ./scripts/aerospace-simple.sh
  );

in
{
  fonts.packages = [ pkgs.sketchybar-app-font ];

  services.sketchybar = {
    extraPackages = with pkgs; [
      jq
      sketchybar-app-font
    ];

    config = ''
      sketchybar --bar height=28 color=${colors.bg} y_offset=2 position=top sticky=on padding_left=12 padding_right=12

      sketchybar --default \
        icon.font="${font}:Medium:13.0" \
        label.font="${font}:Regular:13.0" \
        icon.color=${colors.fg} \
        label.color=${colors.fg}

      # === AEROSPACE WORKSPACES ===
      sketchybar --add event aerospace_workspace_change

      for sid in $(aerospace list-workspaces --all); do
          # Main display (1): numbers/letters only, no app labels
          sketchybar --add item space.$sid.main left \
              --subscribe space.$sid.main aerospace_workspace_change front_app_switched \
              --set space.$sid.main \
              display=1 \
              background.color=0x40ffffff \
              background.corner_radius=5 \
              background.height=25 \
              background.drawing=off \
              background.padding_left=3 \
              background.padding_right=3 \
              icon="$sid" \
              icon.y_offset=1 \
              icon.padding_left=7 \
              icon.padding_right=7 \
              label.drawing=off \
              click_script="aerospace workspace $sid" \
              script="${aerospaceScriptSimple} $sid"

          # Secondary display (2): full labels with app icons
          sketchybar --add item space.$sid left \
              --subscribe space.$sid aerospace_workspace_change front_app_switched \
              --set space.$sid \
              display=2 \
              background.color=0x40ffffff \
              background.corner_radius=5 \
              background.height=25 \
              background.drawing=off \
              background.padding_left=3 \
              background.padding_right=3 \
              icon="$sid" \
              icon.y_offset=1 \
              icon.padding_left=7 \
              icon.padding_right=7 \
              label.font="${appFont}:Regular:14.0" \
              label.drawing=off \
              click_script="aerospace workspace $sid" \
              script="${aerospaceScript} $sid"
      done

      # Front app
      sketchybar --add item frontapp left \
        --set frontapp \
          padding_left=10 \
          label.y_offset=1 \
          label.padding_right=7 \
          label.color=${colors.subtle} \
          script='sketchybar --set $NAME label="$INFO"' \
        --subscribe frontapp front_app_switched
        
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

      sketchybar --add item memory right \
        --set memory \
          padding_left=24 \
          update_freq=30 \
          script="${memoryScript}"

      sketchybar --update
    '';
  };
}
