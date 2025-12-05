# Agent Instructions

## After Making Changes

1. Run `nix fmt` to format all Nix files
2. Run `nix flake check` to validate the configuration before the user rebuilds

## Project Structure

- `flake.nix` - Main flake with nix-darwin and home-manager configuration
- `home.nix` - Home Manager config (shells, programs, nixvim)
- `mbp-m3-pro/configuration.nix` - Machine-specific nix-darwin settings
- `.nixd.json` - LSP configuration for nixd
