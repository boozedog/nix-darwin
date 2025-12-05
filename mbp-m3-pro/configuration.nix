{
  pkgs,
  self,
  ...
}:
{
  networking.hostName = "mbp-m3-pro";

  environment = {
    systemPackages = with pkgs; [
      awk-language-server
      #direnv
      dockerfile-language-server
      #fishPlugins.forgit
      gh
      git
      git-extras
      helix
      #komorebi-full
      nixd
      nixfmt
      nodePackages.npm-check-updates
      nodePackages.vscode-json-languageserver
      #orbstack # use brew
      statix
      terminal-notifier
      tree # claude is always trying to use this
      zinit
      #zsh-forgit
    ];
    shells = with pkgs; [
      bash
      fish
      zsh
    ];
    # EDITOR is set by nixvim.defaultEditor in home.nix
  };

  fonts.packages = [
    pkgs.inter
    pkgs.maple-mono.NL-NF
  ];

  homebrew = {
    enable = true;
    user = "david";
    onActivation.cleanup = "uninstall";
    # taps = [
    #   #"koekeishiya/formulae"
    #   #"lgug2z/tap"
    # ];
    brews = [
      #"aichat" # use home manager
      "asitop"
      "bat"
      "btop"
      #"chezmoi" # use home manager
      #"container" # using orbstack
      "docker-compose-langserver"
      #"duf" # use nix
      #"eza" # use nix
      "fish-lsp"
      #"forgit" # use nix
      #"fzf" # use nix
      #"gping" # using trippy
      #"helix" # use nix
      "lazydocker"
      #"lazygit" # using forgit
      #"komorebi-for-mac-nightly" # use nix flake for this
      "opencode"
      "pnpm"
      "prettier"
      #"ripgrep" # use nix
      #"sketchybar" # use nix
      #"koekeishiya/formulae/skhd" # use nix
      #"starship" # use nix
      #"tig" # using forgit
      "tombi"
      "topgrade"
      "typescript-language-server"
      "yaml-language-server"
      #"zellij" # using tmux
    ];
    casks = [
      #"alacritty" # using ghostty
      "alt-tab"
      "amethyst"
      "beyond-compare"
      "brave-browser"
      "claude"
      "claude-code"
      "discord"
      "ghostty"
      "google-chrome"
      #"hyper" # using ghostty
      #"kitty" # using ghostty
      "localsend"
      "microsoft-edge"
      "numi"
      "obsidian"
      "orbstack"
      "postgres-unofficial"
      "steam"
      "tailscale-app"
      #"ungoogled-chromium" # using brave
      "visual-studio-code"
      #"vscodium"
      #"warp" # nah
      #"wezterm" # using ghostty
      "yaak"
      #"zed" # using visual-studio-code
    ];
  };

  programs = {
    direnv.enable = true;
    fish.enable = true;
    nix-index.enable = true;
    # nixvim = {
    #   enable = true;
    #   colorschemes.catppuccin.enable = true;
    #   plugins = {
    #     nvim-tree.enable = true;
    #   	web-devicons.enable = true;
    #   };
    # };
    zsh.enable = true;
  };

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };

  services = {
    #tailscale.enable = true; # use brew
    openssh = {
      enable = true;
      extraConfig = ''
        PasswordAuthentication no
        PermitRootLogin no
      '';
    };
  };

  system = {
    primaryUser = "david";
    configurationRevision = self.rev or self.dirtyRev or null;
    defaults = {
      CustomUserPreferences = {
        "com.apple.AppleMultitouchTrackpad" = {
          ForceSuppressed = true;
        };
        "com.apple.dock" = {
          workspaces-swoosh-animation-off = true;
          springboard-show-duration = 0.0;
          springboard-hide-duration = 0.0;
        };
        "com.apple.finder" = {
          FXEnableSlowAnimation = false;
        };
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # Switch to Desktop 1-6 (Ctrl+1 through Ctrl+6)
            "118" = {
              enabled = true;
              value = {
                parameters = [
                  65535
                  18
                  262144
                ];
                type = "standard";
              };
            };
            "119" = {
              enabled = true;
              value = {
                parameters = [
                  65535
                  19
                  262144
                ];
                type = "standard";
              };
            };
            "120" = {
              enabled = true;
              value = {
                parameters = [
                  65535
                  20
                  262144
                ];
                type = "standard";
              };
            };
            "121" = {
              enabled = true;
              value = {
                parameters = [
                  65535
                  21
                  262144
                ];
                type = "standard";
              };
            };
            "122" = {
              enabled = true;
              value = {
                parameters = [
                  65535
                  23
                  262144
                ];
                type = "standard";
              };
            };
            "123" = {
              enabled = true;
              value = {
                parameters = [
                  65535
                  22
                  262144
                ];
                type = "standard";
              };
            };
          };
        };
      };
      dock = {
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        expose-animation-duration = 0.0;
        magnification = true;
        wvous-br-corner = 1;
      };
      universalaccess.reduceMotion = true;
      NSGlobalDomain = {
        "com.apple.keyboard.fnState" = true;
        AppleShowAllExtensions = true;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSScrollAnimationEnabled = false;
        NSWindowResizeTime = 0.0;
      };
    };
  };
}
