{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    getExe
    toLower
    lists
    listToAttrs
    ;
  inherit (config.services) sketchybar;
in
{
  services.aerospace.settings = {
    # Restart sketchybar after aerospace starts so workspace items are created
    # (sketchybar's config runs `aerospace list-workspaces` which needs aerospace running)
    after-startup-command = mkIf sketchybar.enable [
      "exec-and-forget killall sketchybar"
    ];
    # Notify Sketchybar about workspace change
    exec-on-workspace-change = mkIf sketchybar.enable [
      "${getExe pkgs.bash}"
      "-c"
      "${getExe sketchybar.package} --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
    ];

    mode.main.binding =
      let
        workspaces = lists.map toString (lists.range 1 9) ++ [
          "A"
          "B"
          "C"
          "D"
          "E"
          "F"
        ];
        forAllWorkspaces =
          keyfn: actionfn:
          builtins.listToAttrs (
            lists.map (ws: {
              name = keyfn ws;
              value = actionfn ws;
            }) workspaces
          );
        focusWorkspaces = forAllWorkspaces (ws: "alt-${toLower ws}") (ws: "workspace ${ws}");
        moveToWorkspace = forAllWorkspaces (ws: "alt-shift-${toLower ws}") (
          ws:
          if sketchybar.enable then
            [
              "move-node-to-workspace ${ws}"
              "exec-and-forget ${getExe sketchybar.package} --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
            ]
          else
            "move-node-to-workspace ${ws}"
        );
        layoutBindings = {
          "alt-h" = "focus left";
          "alt-j" = "focus down";
          "alt-k" = "focus up";
          "alt-l" = "focus right";
          "alt-shift-h" = "move left";
          "alt-shift-j" = "move down";
          "alt-shift-k" = "move up";
          "alt-shift-l" = "move right";
          "alt-slash" = "layout tiles horizontal vertical"; # Default tiling
          "alt-comma" = "layout accordion horizontal"; # Horizontal accordion
        };
      in
      focusWorkspaces // moveToWorkspace // layoutBindings;

    workspace-to-monitor-force-assignment =
      let
        numericWorkspaces = lists.range 1 9;
        letterWorkspaces = [
          "A"
          "B"
          "C"
          "D"
          "E"
          "F"
        ];
        secondaryMonitor = [
          "secondary"
          "main"
        ];
        numericAssignments = listToAttrs (
          lists.map (ws: {
            name = builtins.toString ws;
            value = if ws <= 3 then "main" else secondaryMonitor;
          }) numericWorkspaces
        );
        letterAssignments = listToAttrs (
          lists.map (ws: {
            name = ws;
            value = secondaryMonitor;
          }) letterWorkspaces
        );
      in
      numericAssignments // letterAssignments;
  };
}
