# btca - Better Context CLI

CLI for asking questions about libraries/frameworks by cloning their repos
locally and searching the source directly.

- **Repository**: <https://github.com/davis7dotsh/better-context>
- **Homepage**: <https://btca.dev>

## Building

Uses [bun2nix](https://nix-community.github.io/bun2nix/) to manage Bun
dependencies reproducibly.

```bash
nix build .#btca
```

## Updating Dependencies

When the upstream `bun.lock` changes:

```bash
# Clone the upstream repo
cd /tmp
git clone https://github.com/davis7dotsh/better-context
cd better-context

# Generate new deps file
nix run github:nix-community/bun2nix -- -o bun.nix

# Copy to this directory
cp bun.nix /path/to/nix-darwin/packages/btca/deps.nix
```

Then edit `deps.nix` to comment out the workspace packages (they come from
source, not fetched):

```nix
# Around line 600:
# Workspace package - provided by src, not fetched
# "btca" = copyPathToStore ./apps/cli;

# Around line 1166:
# Workspace package - provided by src, not fetched
# "web" = copyPathToStore ./apps/web;
```

## Updating Version

1. Get the latest commit SHA from the repo
2. Update `rev` in `default.nix`
3. Run `nix build` - it will fail with hash mismatch
4. Use the correct hash from the error, or:

   ```bash
   nix-prefetch-url --unpack https://github.com/davis7dotsh/better-context/archive/<commit>.tar.gz
   nix hash to-sri sha256:<hash>
   ```

5. Update the `hash` in `default.nix`
6. Update `version` string (format: `X.Y.Z-unstable-YYYY-MM-DD`)

## Re-enabling in Flake

The btca package is currently commented out. To enable:

1. Uncomment the `bun2nix` input in `flake.nix`
2. Uncomment `bun2nix` in the outputs function parameters
3. Uncomment the `btca = pkgs.callPackage ...` line
4. Uncomment `btca` from `environment.systemPackages` in each darwin configuration
5. Uncomment `packages.${system}.btca = btca;`
