# nix-darwin

## update home-manager config only

```sh
nix run github:nix-community/home-manager#home-manager -- switch --flake .#david
# reload fish config
source ~/.config/fish/config.fish
# reload zsh config
. ~/.zshrc
```

## update system (including home-manager config)

```sh
sudo --preserve-env=NIX_CONFIG darwin-rebuild switch --flake ~/projects/nix-darwin
```

## initial

```sh
sudo determinate-nixd upgrade
nix flake init --template "https://flakehub.com/f/DeterminateSystems/flake-templates/0#nix-darwin"
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/projects/nix-darwin#mbp-m3-pro
```
