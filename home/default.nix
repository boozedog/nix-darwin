# Darwin-specific home-manager settings
{ pkgs, lib, ... }:
{
  # Disable home-manager's nix management (Determinate Nix handles it)
  nix.enable = false;

  home = {
    stateVersion = "25.11";
    homeDirectory = lib.mkForce "/Users/david";
    sessionPath = [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];
  };

  # home.file.".aerospace.toml".text =
  #   builtins.replaceStrings [ "@sketchybar@" ] [ "${pkgs.sketchybar}/bin/sketchybar" ]
  #     (builtins.readFile ./aerospace.toml);

  programs = {
    # note: aerospace is handled by nix-darwin
    atuin = {
      enable = true;
      enableFishIntegration = true;
      daemon.enable = true;
      settings = {
        filter_mode = "workspace";
        style = "auto";
        workspaces = "true";
      };
    };
    git = {
      settings = {
        user.name = "boozedog";
        user.email = "code@booze.dog";
      };
    };

    fish = {
      interactiveShellInit = ''
        # Zellij auto tab naming: show running command during execution
        function zellij_tab_preexec --on-event fish_preexec
          if set -q ZELLIJ
            set -l cmd (string split ' ' $argv)[1]
            command nohup zellij action rename-tab $cmd >/dev/null 2>&1 &
          end
        end

        # Zellij auto tab naming: show directory when idle
        function zellij_tab_postexec --on-event fish_postexec
          if set -q ZELLIJ
            set -l tab_name (basename $PWD)
            test "$PWD" = "$HOME"; and set tab_name "~"
            command nohup zellij action rename-tab $tab_name >/dev/null 2>&1 &
          end
        end

        # Set initial tab name on shell start
        if set -q ZELLIJ
          set -l tab_name (basename $PWD)
          test "$PWD" = "$HOME"; and set tab_name "~"
          command nohup zellij action rename-tab $tab_name >/dev/null 2>&1 &
        end
      '';
      loginShellInit = ''
        # OrbStack integration
        test -f ~/.orbstack/shell/init2.fish; and source ~/.orbstack/shell/init2.fish
      '';
      plugins = [
        {
          name = "macos";
          inherit (pkgs.fishPlugins.macos) src;
        }
        {
          name = "grc";
          inherit (pkgs.fishPlugins.grc) src;
        }
      ];
      shellAbbrs = {
        za = "zellij attach";
      };
      shellInit = ''
        if status is-interactive
          # Bitwarden SSH agent socket (macOS app location)
          set -x SSH_AUTH_SOCK ~/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock
          # GitHub access token for Homebrew (for private tap formulas)
          set -x HOMEBREW_GITHUB_API_TOKEN (gh auth token)
        end
      '';
    };
    nix-search-tv.enableTelevisionIntegration = true;
    vscode = {
      enable = true;
      package = pkgs.emptyDirectory // {
        pname = "vscode";
        version = "0";
      }; # use brew to install
      profiles.default.userSettings = {
        "claudeCode.preferredLocation" = "panel";
        "editor.fontFamily" = "'Maple Mono NL NF', Menlo, Monaco, 'Courier New', monospace";
        "editor.fontSize" = 12.999999999999999;
        "editor.formatOnSave" = true;
        "explorer.sortOrder" = "mixed";
        "window.title" = "$\{rootName} [$\{activeRepositoryBranchName}] $\{activeEditorShort} $\{dirty}";
        "workbench.activityBar.location" = "top";
      };
    };
    television = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
    zellij = {
      enable = true;
      settings = {
        on_force_close = "detach";
      };
      extraConfig = ''
        keybinds {
          normal {
            unbind "Ctrl q"
          }
        }
      '';
    };
  };
}
