{ pkgs, inputs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ inputs.claude-code.overlays.default ];
  environment.systemPackages = [ pkgs.claude-code ];
}
