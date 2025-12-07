# CLAUDE.md

- after editing a nix file
  - first run nixfmt, statix, and deadnix and correct any issues
  - once those are clean, then run nix flake check
- always correct any lsp generated warnings you encounter
- note that we are using nixd 2.x which does not support .nixd.json
  - nixd is configured in nix-infra.code-workspace
