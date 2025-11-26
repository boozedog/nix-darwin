# nix-darwin

## update

```sh
sudo darwin-rebuild switch --flake ~/projects/nix-darwin#mbp-m3-pro
```

## initial

```sh
sudo determinate-nixd upgrade
nix flake init --template "https://flakehub.com/f/DeterminateSystems/flake-templates/0#nix-darwin"
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/projects/nix-darwin#mbp-m3-pro
```
