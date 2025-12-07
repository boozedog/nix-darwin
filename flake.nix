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
    home-manager-config = {
      url = "github:boozedog/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        nixvim.follows = "nixvim";
      };
    };
    #komorebi-for-mac.url = "github:KomoCorp/komorebi-for-mac";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nox = {
      url = "github:madsbv/nix-options-search";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
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

      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Local packages
      claude-code = pkgs.callPackage ./packages/claude-code.nix { };

      # Home-manager modules (cross-platform, from external repo)
      homeModules = inputs.home-manager-config.homeModuleList;

      # Darwin-specific home modules
      homeModulesDarwin = homeModules ++ [
        ./home
        ./home/claude-code.nix
        ./home/ghostty.nix
        ./home/sketchybar.nix
      ];

      # Pre-commit hooks
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          statix.enable = true;
        };
      };

    in
    {
      # nix-darwin configuration output
      darwinConfigurations."mbp-m3-pro" = inputs.nix-darwin.lib.darwinSystem {
        modules = [
          { nixpkgs.hostPlatform = system; }
          { nixpkgs.config.allowUnfree = true; }
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
              users.${username}.imports = homeModulesDarwin;
              sharedModules = [ inputs.nixvim.homeModules.nixvim ];
              extraSpecialArgs = { inherit username; };
            };
          }
          ./ns.nix
          inputs.agenix.darwinModules.default
          ./secrets
          #./modules/claude-code.nix
          {
            environment.systemPackages = [
              inputs.nox.packages.${system}.default
              claude-code
            ];
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
          {
            home = {
              inherit username;
              # homeDirectory is set in ./home/default.nix via lib.mkForce
            };
          }
        ]
        ++ homeModulesDarwin;
        extraSpecialArgs = { inherit self username; };
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

          # Linting
          deadnix
          statix
          nil

          # Secrets management
          inputs.agenix.packages.${system}.default
        ];
        shellHook = ''
          ${pre-commit-check.shellHook}
          echo "nix-darwin development environment"
          echo "Available tools: statix, nil"
          echo "Pre-commit hooks installed: statix"
        '';
      };

    };
}
