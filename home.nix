{
  pkgs,
  lib,
  ...
}:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "david";
  home.homeDirectory = lib.mkForce "/Users/david";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";

  # Add Homebrew to PATH for all shells
  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  manual = {
    html.enable = false; # Skip HTML manual
    json.enable = false; # Skip JSON (options.json source)
    manpages.enable = false;
  };

  programs = {
    # Let Home Manager install and manage itself.
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
          src = pkgs.fishPlugins.autopair.src;
        }
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
        {
          name = "forgit";
          src = pkgs.fishPlugins.forgit.src;
        }
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        } # broken
        {
          name = "macos";
          src = pkgs.fishPlugins.macos.src;
        }
        {
          name = "sponge";
          src = pkgs.fishPlugins.sponge.src;
        }
      ];
      shellAbbrs = {
        ai = "aichat";
        l = "ls -lah";
        ls = "eza --long --all --git";
        vi = "hx";
        vim = "hx";
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
    tmux.enable = true;
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
