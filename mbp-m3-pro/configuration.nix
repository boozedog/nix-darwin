{ pkgs, self, ... }:
{
  networking.hostName = "mbp-m3-pro";

  environment = {
    systemPackages = with pkgs; [
      awk-language-server
      #direnv
      dockerfile-language-server
      git
      git-extras
      nil
      nixd
      nixfmt
      nodePackages.npm-check-updates
      nodePackages.vscode-json-languageserver
      terminal-notifier
      trippy
      tmux
    ];
    shells = with pkgs; [
      fish
    ];
    variables = {
      EDITOR = "hx";
    };
  };

  fonts.packages = [
    pkgs.inter
    pkgs.maple-mono.NL-NF
  ];

  homebrew = {
    enable = true;
    user = "david";
    brews = [
      "aichat"
      "asitop"
      "bat"
      "btop"
      "chezmoi"
      #"container"
      "docker-compose-langserver"
      "duf"
      "eza"
      "fish-lsp"
      "forgit"
      "fzf"
      #"gping" # using trippy now
      "helix"
      "lazydocker"
      #"lazygit" # using forgit now
      "opencode"
      "pnpm"
      "prettier"
      "ripgrep"
      "starship"
      #"tig" # using forgit now
      "tombi"
      "topgrade"
      "typescript-language-server"
      "yaml-language-server"
      #"zellij" # using tmux now
    ];
    casks = [
      # "alacritty"
      "alt-tab"
      "amethyst"
      "beyond-compare"
      "brave-browser"
      "claude"
      "claude-code"
      "google-chrome"
      #"hyper" # using ghostty
      #"kitty" # using ghostty
      "localsend"
      "microsoft-edge"
      "numi"
      "obsidian"
      "orbstack"
      "postgres-unofficial"
      "ghostty"
      "ungoogled-chromium"
      "vscodium"
      #"warp" # nah
      #"wezterm" # using ghostty
      "yaak"
      "zed"
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
  };

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };

  services = {
    tailscale.enable = true;
    openssh = {
      enable = true;
      extraConfig = ''
        PasswordAuthentication no
        PermitRootLogin no
      '';
    };
  };

  system = {
    primaryUser = "root";
    configurationRevision = self.rev or self.dirtyRev or null;
    defaults = {
      CustomUserPreferences = {
        "com.apple.AppleMultitouchTrackpad" = {
          ForceSuppressed = true;
        };
      };
      dock = {
        expose-animation-duration = 0.1;
        magnification = true;
        wvous-br-corner = 1;
      };
      NSGlobalDomain = {
        "com.apple.keyboard.fnState" = true;
        AppleShowAllExtensions = true;
        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowResizeTime = 0.001;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
    };
  };
}
