{ pkgs, self, ... }: {
  networking.hostName = "mbp-m3-pro";
  
  environment.systemPackages = with pkgs; [
  ];
 
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
      "btop"
      "helix"
      "tig"
    ];
    casks = [
      "obsidian"
      "brave-browser"
      "ghostty"
      "alt-tab"
      "amethyst"
    ];
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
