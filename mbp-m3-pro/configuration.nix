{ pkgs, self, lib,... }:
{
  networking.hostName = "mbp-m3-pro";

  environment = {
    systemPackages = with pkgs; [
      awk-language-server
      #direnv
      dockerfile-language-server
      #fishPlugins.forgit
      git
      git-extras
      helix
      nil
      nixd
      nixfmt
      nodePackages.npm-check-updates
      nodePackages.vscode-json-languageserver
      #orbstack # use brew
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
    onActivation.cleanup = "zap";
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
      "opencode"
      "pnpm"
      "prettier"
      #"ripgrep" # use nix
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
      "ghostty"
      #"google-chrome" using brave
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
