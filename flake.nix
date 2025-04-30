{
  description = "Nix for macOS configuration";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    extra-substituters = [
      # Query the mirror of USTC first, and then the official cache.
      "https://cache.nixos.org?priority=10"
      #"https://mirrors.ustc.edu.cn/nix-channels/store"
      #"https://cache.nixos.org"
      "https://nyx.chaotic.cx"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://yazi.cachix.org"
    ];
    extra-trusted-public-keys = ["nix-community.cachix.org-1:iH5YI1D3vds8ILsPzQXTrCG/tvY1pG+sGbGjfm6u5gI="];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # Use a single Nixpkgs input for consistency
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home Manager input, following `nixpkgs`
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix-Darwin input, following `nixpkgs`
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    mac-app-util.url = "github:hraban/mac-app-util";
    systems.url = "github:nix-systems/default-darwin";

    nvf.url = "github:notashelf/nvf";
    flake-utils.url = "github:numtide/flake-utils";
    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./args.nix
      ];
      systems = ["aarch64-darwin"];
      flake = let
        # User-specific settings
        username = "davidsielert";
        useremail = "david@sielert.com";
        system = "aarch64-darwin"; # Use "aarch64-darwin" for Apple Silicon, "x86_64-darwin" for Intel Macs
        hostname = "mbp14";
        myOverlays = self: super: {
          eslint = super.nodePackages.eslint or null;
          # Disable checks for nodejs and nodejs-slim
          nodejs = super.nodejs.overrideAttrs (oldAttrs: {
            doCheck = false;
          });
          nodejs-slim = super.nodejs-slim.overrideAttrs (oldAttrs: {
            doCheck = false;
          });
          neovim-overlay = import ./nix/neovim-overlay.nix {inherit inputs;};
        inputs.gen-luarc.overlays.default;
        };
        # Package set for the selected system
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [myOverlays];
        };
        inherit (inputs) nvf;
        # nvf = inputs.nvf;
        # Special arguments passed to modules
        specialArgs =
          inputs
          // {
            inherit
              username
              useremail
              hostname
              inputs
              nvf
              myOverlays
              ;
          };
      in {
        darwinConfigurations."${hostname}" = inputs.darwin.lib.darwinSystem {
          inherit system specialArgs;
          modules = [
            ./modules/nix-core.nix
            ./modules/system.nix
            ./modules/apps.nix
            ./modules/host-users.nix
            # nixvim.nixDarwinModules.nixvim
            # Home Manager integration
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.backupFileExtension = "before-nix";
              home-manager.users.${username} = import ./home;
            }
            # ./modules/nixvim/nixvim.nix
          ];
        };

        # Nix code formatter
        formatter.${system} = pkgs.alejandra;
      };
    };
}
