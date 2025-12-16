# btca - Better Context CLI
#
# CLI for asking questions about libraries/frameworks by cloning
# their repos locally and searching the source directly.
#
# Uses bun2nix to manage Bun dependencies reproducibly.
# To update deps: nix run github:nix-community/bun2nix -- -o packages/btca-deps.nix
# (run from the upstream repo with bun.lock)
{
  lib,
  stdenv,
  fetchFromGitHub,
  bun2nix,
  git,
  makeWrapper,
}:

let
  pname = "btca";
  version = "0.2.1-unstable-2025-12-13";

  src = fetchFromGitHub {
    owner = "davis7dotsh";
    repo = "better-context";
    rev = "025cc552f053a2f7231ef8659919e227a256f9a4";
    hash = "sha256-V0ESfMyz9zge1CPlaJOPEs/sjPtmGnD6LAC2guAWglo=";
  };

  # Map Nix platform to Bun compile target
  bunTarget =
    {
      "x86_64-linux" = "bun-linux-x64";
      "aarch64-linux" = "bun-linux-arm64";
      "x86_64-darwin" = "bun-darwin-x64";
      "aarch64-darwin" = "bun-darwin-arm64";
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

  # Output binary name matches upstream convention
  binaryName =
    {
      "x86_64-linux" = "btca-linux-x64";
      "aarch64-linux" = "btca-linux-arm64";
      "x86_64-darwin" = "btca-darwin-x64";
      "aarch64-darwin" = "btca-darwin-arm64";
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./deps.nix;
  };

in
bun2nix.mkDerivation {
  inherit
    pname
    version
    src
    bunDeps
    ;

  nativeBuildInputs = [ makeWrapper ];

  # Custom build - we compile to standalone binary, not default bun compile
  bunBuildFlags = [ ];

  buildPhase = ''
    runHook preBuild

    # Build the standalone binary for this platform
    cd apps/cli
    mkdir -p dist

    bun build src/index.ts \
      --compile \
      --target=${bunTarget} \
      --outfile=dist/${binaryName} \
      --define __VERSION__='"${version}"'

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 dist/${binaryName} $out/bin/btca

    # btca shells out to git for clone/pull operations
    wrapProgram $out/bin/btca \
      --prefix PATH : ${lib.makeBinPath [ git ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "CLI for asking questions about libraries/frameworks by searching their source";
    homepage = "https://btca.dev";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "btca";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
