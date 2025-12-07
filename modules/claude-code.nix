{ inputs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ inputs.claude-code.overlays.default ];
}
