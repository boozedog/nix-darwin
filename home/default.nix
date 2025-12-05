{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./nixvim.nix
    ./shells.nix
    ./sketchybar.nix
  ];

  home = {
    username = "david";
    homeDirectory = lib.mkForce "/Users/david";
    stateVersion = "25.11";
    sessionPath = [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];
  };

  # Disable home-manager's nix management (Determinate Nix handles it)
  nix.enable = false;

  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };

  programs = {
    home-manager.enable = true;

    aichat.enable = true;
    eza = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      git = true;
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
    ghostty = {
      enable = true;
      package = null;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      #installBatSyntax = true;
      #installVimSyntax = true;
      settings = {
        #bell-features = "audio,system,title";
        font-family = "Maple Mono NL NF";
        # support claude code shift+enter
        keybind = "shift+enter=text:\\x1b\\r";
        # support alt key in tmux
        macos-option-as-alt = "left";
        macos-titlebar-style = "hidden";
        quit-after-last-window-closed = false;
        theme = "GitHub Dark";
        window-padding-x = 16;
        window-padding-y = 16;
        window-save-state = "always";
      };
    };
    git = {
      enable = true;
      settings = {
        user.name = "boozedog";
        user.email = "code@booze.dog";
        core.editor = "vim";
      };
    };
    helix = {
      enable = true;
      defaultEditor = false;
    };
    ripgrep.enable = true;
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      settings = {
        format = "$all$cmd_duration$custom";
        character.disabled = true;
        custom.prompt_symbol = {
          command = ''
            case "$STARSHIP_SHELL" in
              bash) printf '$' ;;
              zsh) printf '%%' ;;
              fish) printf '>' ;;
              *) printf '?' ;;
            esac
          '';
          when = true;
          format = "[$output](bold green) ";
          shell = [
            "bash"
            "--noprofile"
            "--norc"
          ];
        };
      };
    };
    tmux = {
      enable = true;
      terminal = "tmux-256color";
      historyLimit = 50000;
      sensibleOnTop = true;

      extraConfig = ''
        # Your original settings
        set -g mouse on
        set -g base-index 1
        setw -g pane-base-index 1
        set -g renumber-windows on

        # Alt+number window switching (no prefix)
        bind-key -n M-1 select-window -t 1
        bind-key -n M-2 select-window -t 2
        bind-key -n M-3 select-window -t 3
        bind-key -n M-4 select-window -t 4
        bind-key -n M-5 select-window -t 5
        bind-key -n M-6 select-window -t 6
        bind-key -n M-7 select-window -t 7
        bind-key -n M-8 select-window -t 8
        bind-key -n M-9 select-window -t 9

        # (optional) a few tiny modern niceties I actually recommend
        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '15'
      '';

      plugins = with pkgs.tmuxPlugins; [
        sensible
        resurrect
        continuum
        yank
      ];
    };
    trippy = {
      enable = true;
      settings.trippy.mode = "tui";
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };
}
