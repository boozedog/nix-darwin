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
      nodePackages.vscode-json-languageserver
    ];
    shells = with pkgs; [
      fish
    ];
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
      "docker-compose-langserver"
      "fish-lsp"
      "helix"
      "prettier"
      "starship"
      "tig"
      "tombi"
      "typescript-language-server"
      "yaml-language-server"
      "zellij"
    ];
    casks = [
      "alt-tab"
      "amethyst"
      "brave-browser"
      "claude-code"
      "obsidian"
      "ghostty"
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
