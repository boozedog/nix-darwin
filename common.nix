{
  pkgs,
  self,
  lib,
  ...
}:
{
  nix.settings = {
    trusted-users = [ "@admin" ];
    substituters = [
      "https://claude-code.cachix.org"
      "https://devenv.cachix.org"
    ];
    trusted-public-keys = [
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };
  environment = {
    systemPackages = with pkgs; [
      awk-language-server
      claude-monitor
      deadnix
      devenv
      dockerfile-language-server
      duf
      dust
      fd
      #fishPlugins.forgit
      gh
      git
      git-extras
      grc
      helix
      #komorebi-full
      nix-search-tv
      nixd
      nixfmt
      nodePackages.npm-check-updates
      nodePackages.vscode-json-languageserver
      #orbstack # use brew'
      statix
      terminal-notifier
      tldr
      tree # claude is always trying to use this
      trippy
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
      "supabase"
      #"starship" # use nix
      #"tig" # using forgit
      "tombi"
      "topgrade"
      "typescript-language-server"
      "yaml-language-server"
      #"zellij"
    ];
    casks = [
      #"alacritty" # using ghostty
      "alt-tab"
      #"amethyst"
      "betterdisplay"
      "beyond-compare"
      "brave-browser"
      "claude"
      #"claude-code" # use nix derivation
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
      "raycast"
      "steam"
      "tailscale-app"
      #"ubersicht" # using sketchybar and not simple-bar
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
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fish.enable = true;
    man.enable = lib.mkForce false;
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
    aerospace = {
      enable = true;
    };
    openssh = {
      enable = true;
      extraConfig = ''
        PasswordAuthentication no
        PermitRootLogin no
      '';
    };
    sketchybar = {
      enable = true;
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
        # no longer using macos desktops, using aerospace
        # "com.apple.symbolichotkeys" = {
        #   AppleSymbolicHotKeys =
        #     let
        #       # Key codes for 1-7 keys
        #       keyCodes = [
        #         18
        #         19
        #         20
        #         21
        #         23
        #         22
        #         26
        #       ];
        #       mkDesktopShortcut = n: {
        #         enabled = true;
        #         value = {
        #           parameters = [
        #             65535
        #             (builtins.elemAt keyCodes (n - 1))
        #             262144
        #           ];
        #           type = "standard";
        #         };
        #       };
        #     in
        #     {
        #       # Switch to Desktop 1-7 (Ctrl+1 through Ctrl+7)
        #       # Hotkey IDs 118-124 correspond to Desktops 1-7
        #       "118" = mkDesktopShortcut 1;
        #       "119" = mkDesktopShortcut 2;
        #       "120" = mkDesktopShortcut 3;
        #       "121" = mkDesktopShortcut 4;
        #       "122" = mkDesktopShortcut 5;
        #       "123" = mkDesktopShortcut 6;
        #       "124" = mkDesktopShortcut 7;
        #     };
        # };
      };
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        expose-animation-duration = 0.0;
        magnification = true;
        persistent-apps = [];
        persistent-others = [];
        show-recents = false;
        wvous-br-corner = 1;
      };
      NSGlobalDomain = {
        "com.apple.keyboard.fnState" = true;
        _HIHideMenuBar = true;
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
      # note: following requires full disk access
      universalaccess = {
        reduceMotion = true;
        reduceTransparency = true;
      };
      WindowManager = {
        EnableTilingByEdgeDrag = false;
        EnableTilingOptionAccelerator = false;
        EnableTopTilingByEdgeDrag = false;
      };
    };
  };
}
