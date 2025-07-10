{
  description = "Nix for macOS configuration";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org?priority=10"
      #"https://mirrors.ustc.edu.cn/nix-channels/store"
      #"https://cache.nixos.org"
      "https://nyx.chaotic.cx"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://yazi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:iH5YI1D3vds8ILsPzQXTrCG/tvY1pG+sGbGjfm6u5gI="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    mac-app-util.url = "github:hraban/mac-app-util";
    systems.url = "github:nix-systems/default-darwin";
#:    nvf.url = "github:notashelf/nvf";
    flake-utils.url = "github:numtide/flake-utils";
    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";
    biome-pinned = {
      # use the exact commit
      url = "github:NixOS/nixpkgs/fb80ed6efd437ac2ef2f98681d8a06c08fc5966e";
      };

  };

  outputs = inputs @ {flake-parts, ...}:

    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["aarch64-darwin"];

      flake = let
        # User-specific settings
        username = "dsielert";
        useremail = "david@sielert.com";
        system = "aarch64-darwin";
        hostname = "mbp14";

        neovim-overlay = import ./nix/neovim-overlay.nix {inherit inputs;};
        # Your custom overlay
        myOverlays = self: super: {
          #eslint = super.nodePackages.eslint or null;
          nodejs = super.nodejs.overrideAttrs (old: {doCheck = false;});
          nodejs-slim = super.nodejs-slim.overrideAttrs (old: {doCheck = false;});
          biome = inputs.biome-pinned.legacyPackages.${self.system}.biome;
          tailwindcss-language-server =
            inputs.nixpkgs-unstable.legacyPackages.${self.system}.tailwindcss-language-server;
        };

        # Include both your overlay and the gen-luarc default overlay
        overlays = [
          myOverlays
          neovim-overlay
          inputs.gen-luarc.overlays.default
        ];

        # Load pkgs with those overlays
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = overlays;
          config = {
            allowUnfree = true;
          };
        };

        #inherit (inputs) nvf;

        specialArgs =
          inputs
          // {
            inherit username useremail hostname inputs myOverlays;
          };
      in {
        overlays = [neovim-overlay];
        darwinConfigurations."${hostname}" = inputs.darwin.lib.darwinSystem {
          inherit system specialArgs;
          # ← tell nix-darwin to use _this_ pkgs (with your kickstart overlay)
          pkgs = pkgs;
          modules = [
            ./modules/nix-core.nix
            ./modules/system.nix
            ./modules/apps.nix
            ./modules/host-users.nix

            # Home Manager integration
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.backupFileExtension = "before-nix";
              home-manager.users.${username} = import ./home;
            }
          ];
        };

        # Nix code formatter
        formatter.${system} = pkgs.alejandra;
      };
    };
}
