{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./nixvim.nix
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

    # shells
    bash.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
      '';
      plugins = [
        {
          name = "autopair";
          inherit (pkgs.fishPlugins.autopair) src;
        }
        {
          name = "done";
          inherit (pkgs.fishPlugins.done) src;
        }
        {
          name = "forgit";
          inherit (pkgs.fishPlugins.forgit) src;
        }
        {
          name = "fzf-fish";
          inherit (pkgs.fishPlugins.fzf-fish) src;
        } # broken
        {
          name = "macos";
          inherit (pkgs.fishPlugins.macos) src;
        }
        {
          name = "sponge";
          inherit (pkgs.fishPlugins.sponge) src;
        }
      ];
      shellAbbrs = {
        ai = "aichat";
        cd = "z";
        l = "ls -lah";
        ls = "eza --long --all --git";
      };
      # init scripts
      loginShellInit = ''
        # OrbStack integration
        test -f ~/.orbstack/shell/init2.fish; and source ~/.orbstack/shell/init2.fish
      '';
      shellInit = ''
        if status is-interactive
          # Bitwarden SSH agent socket (macOS app location)
          set -x SSH_AUTH_SOCK ~/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock
          # GitHub access token for private flake inputs
          set -x NIX_CONFIG "access-tokens = github.com="(gh auth token)
          # GitHub access token for Homebrew (for private tap formulas)
          set -x HOMEBREW_GITHUB_API_TOKEN (gh auth token)
          # fzf-fish: show failed commands in history search
          set fzf_history_opts --no-sort
        end
      '';
    };
    zsh.enable = true;

    # utilities
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
