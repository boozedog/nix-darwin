{ pkgs, ... }:
let
  ns = pkgs.writeShellScriptBin "ns" (builtins.readFile ./nixpkgs.sh);
in
{
  environment.systemPackages = [ ns ];
}
