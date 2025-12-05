{
  description = "nix-darwin configuration";

  # Flake inputs
  inputs = {
    # Stable Nixpkgs (use 0.1 for unstable)
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    # Stable nix-darwin (use 0.1 for unstable)
    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #komorebi-for-mac.url = "github:KomoCorp/komorebi-for-mac";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Flake outputs
  outputs =
    { self, ... }@inputs:
    let
      # The values for `username` and `system` supplied here are used to construct the hostname
      # for your system, of the form `${username}-${system}`. Set these values to what you'd like
      # the output of `scutil --get LocalHostName` to be.

      # Your system username
      username = "david";

      # Your system type (Apple Silicon here)
      # Change this to `x86_64-darwin` for Intel macOS
      system = "aarch64-darwin";

      pkgs = inputs.nixpkgs.legacyPackages.${system};

      # Treefmt configuration
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

      # Pre-commit hooks
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          treefmt = {
            enable = true;
            package = treefmtEval.config.build.wrapper;
          };
          statix.enable = true;
        };
      };

    in
    {
      # nix-darwin configuration output
      darwinConfigurations."mbp-m3-pro" = inputs.nix-darwin.lib.darwinSystem {
        modules = [
          { nixpkgs.hostPlatform = system; }
          # Add the komorebi-for-mac overlay
          #{ nixpkgs.overlays = [ inputs.komorebi-for-mac.overlays.default ]; }
          # Apply the modules output by this flake
          self.darwinModules.base
          # Apply any other imported modules here
          ./mbp-m3-pro/configuration.nix
          # inputs.nixvim.nixDarwinModules.nixvim
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.david = ./home.nix;
              sharedModules = [ inputs.nixvim.homeModules.nixvim ];
            };
          }
          # In addition to adding modules in the style above, you can also
          # add modules inline like this. Delete this if unnecessary.
          # (
          #   {
          #     config,
          #     pkgs,
          #     lib,
          #     ...
          #   }:
          #   {
          #     # Inline nix-darwin configuration
          #   }
          # )
        ];
        specialArgs = { inherit inputs self; };
      };

      homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        modules = [
          inputs.nixvim.homeModules.nixvim
          ./home.nix
        ];
        extraSpecialArgs = { inherit self; };
      };

      # nix-darwin module outputs
      darwinModules = {
        # Some base configuration
        base = _: {
          # Required for nix-darwin to work
          system.stateVersion = 1;

          users.users.${username} = {
            name = username;
            home = "/Users/${username}";
            uid = 501; # from `id -u`
          };

          # Determinate Nix is installed, let it manage nix
          nix.enable = false;
        };

        # Add other module outputs here
      };

      # Development environment
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          # Shell script for applying the nix-darwin configuration.
          # Run this to apply the configuration in this flake to your macOS system.
          (writeShellApplication {
            name = "apply-nix-darwin-configuration";
            runtimeInputs = [
              # Make the darwin-rebuild package available in the script
              inputs.nix-darwin.packages.${system}.darwin-rebuild
            ];
            text = ''
              echo "> Applying nix-darwin configuration..."

              echo "> Running darwin-rebuild switch as root..."
              sudo --preserve-env=NIX_CONFIG darwin-rebuild switch --flake .
              echo "> darwin-rebuild switch was successful ✅"

              echo "> macOS config was successfully applied 🚀"
            '';
          })

          # Formatting and linting
          treefmtEval.config.build.wrapper
          statix
          nil
        ];
        shellHook = ''
          ${pre-commit-check.shellHook}
          echo "nix-darwin development environment"
          echo "Available tools: treefmt, statix, nil"
          echo "Pre-commit hooks installed: treefmt, statix"
        '';
      };

      # Nix formatter (using treefmt wrapper)
      formatter.${system} = treefmtEval.config.build.wrapper;

      # Checks for CI
      checks.${system} = {
        formatting = treefmtEval.config.build.check self;
        pre-commit = pre-commit-check;
      };
    };
}
