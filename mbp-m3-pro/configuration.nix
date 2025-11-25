{ pkgs, self, ... }:
{
  networking.hostName = "mbp-m3-pro";

  environment = {
    systemPackages = with pkgs; [
      awk-language-server
      direnv
      dockerfile-language-server
      nil
      nixd
      nixfmt
      nodePackages.vscode-json-languageserver
    ];
    shells = with pkgs; [
      fish
    ];
    variables = {
      EDITOR = "hx";
    };
  };

  programs = {
    fish.enable = true;
    # nixvim = {
    #   enable = true;
    #   colorschemes.catppuccin.enable = true;
    #   plugins = {
    #     nvim-tree.enable = true;
    #   	web-devicons.enable = true;
    #   };
    # };
  };

  services.tailscale.enable = true;

  fonts.packages = [
    pkgs.inter
    pkgs.maple-mono.NL-NF
  ];

  homebrew = {
    enable = true;
    user = "david";
    brews = [
      "aichat"
      "bat"
      "btop"
      "chezmoi"
      #"container"
      "docker-compose-langserver"
      "fish-lsp"
      "helix"
      "lazydocker"
      "lazygit"
      "opencode"
      "prettier"
      "starship"
      "tig"
      "tombi"
      "typescript-language-server"
      "yaml-language-server"
      "zellij"
    ];
    casks = [
      # "alacritty"
      "alt-tab"
      "amethyst"
      "brave-browser"
      "claude-code"
      "google-chrome"
      # "hyper"
      # "kitty"
      "microsoft-edge"
      "obsidian"
      "orbstack"
      "ghostty"
      "ungoogled-chromium"
      "vscodium"
      "warp"
      # "wezterm"
      "zed"
    ];
  };

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };

  system = {
    primaryUser = "root";
    configurationRevision = self.rev or self.dirtyRev or null;
    defaults = {
      dock.expose-animation-duration = 0.1;
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        NSAutomaticWindowAnimationsEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
    };
  };
}
