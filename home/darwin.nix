# Darwin-specific home-manager settings
{ pkgs, lib, ... }:
{
  home = {
    homeDirectory = lib.mkForce "/Users/david";
    sessionPath = [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];
  };

  # Disable home-manager's nix management (Determinate Nix handles it)
  nix.enable = false;

  programs.fish = {
    plugins = [
      {
        name = "macos";
        inherit (pkgs.fishPlugins.macos) src;
      }
    ];
    loginShellInit = ''
      # OrbStack integration
      test -f ~/.orbstack/shell/init2.fish; and source ~/.orbstack/shell/init2.fish
    '';
    shellInit = ''
      if status is-interactive
        # Bitwarden SSH agent socket (macOS app location)
        set -x SSH_AUTH_SOCK ~/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock
        # GitHub access token for Homebrew (for private tap formulas)
        set -x HOMEBREW_GITHUB_API_TOKEN (gh auth token)
      end
    '';
  };
}
