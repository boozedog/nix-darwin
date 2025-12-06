{ pkgs, ... }:
{
  programs = {
    bash.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
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
  };
}
