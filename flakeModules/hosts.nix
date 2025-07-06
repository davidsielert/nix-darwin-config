# flakeModules/hosts.nix
{ self, inputs, lib, allOverlays, ... }:

let
  # declarative list of machines
  hosts = {
    mbp14 = { system = "aarch64-darwin"; hmOnly = false; };
    desktop = { system = "x86_64-linux";   hmOnly = false; };
    fedora-laptop = { system = "x86_64-linux"; hmOnly = true; };
  };

  pkgsFor = system: import inputs.nixpkgs { inherit system; overlays = allOverlays; config.allowUnfree = true; };

  # convenience builders --------------------------------------------------
  mkHM = name: cfg:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs   = pkgsFor cfg.system;
      modules = [ ./../home ./../hosts/${name}/home.nix ];
      extraSpecialArgs = { inherit inputs name; };
    };

  mkDarwin = name: cfg:
    inputs.darwin.lib.darwinSystem {
      system = cfg.system;
      specialArgs = { inherit inputs name; };
      modules = [
        ../modules/common/core.nix
        ../modules/darwin/system.nix
        ../hosts/${name}/darwin.nix
        inputs.home-manager.darwinModules.home-manager
        ({ config, ... }: {
          home-manager.useGlobalPkgs   = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { 
          inherit inputs; 
            username = "davidsielert"; 

          };
          home-manager.users.davidsielert.imports = [ ./../hosts/${name}/home.nix ];
        })
      ];
    };

  mkNixos = name: cfg:
    inputs.nixpkgs.lib.nixosSystem {
      system = cfg.system;
      specialArgs = { inherit inputs name; };
      modules = [
        ../modules/common/core.nix
        ../modules/nixos     # optional Linux-only tweaks
        ../hosts/${name}/nixos.nix
        inputs.home-manager.nixosModules.home-manager
        ({ ... }: {
          home-manager.useGlobalPkgs   = true;
          home-manager.useUserPackages = true;
          home-manager.users.davidsielert.imports = [ ../../home ];
        })
      ];
    };
in
{
  # flake-parts lets us *write* to the final flake outputs like this:
  flake = {
    darwinConfigurations =
      lib.mapAttrs' (n: v: lib.nameValuePair n (mkDarwin n v))
        (lib.filterAttrs (_: v: ! v.hmOnly) hosts);

    nixosConfigurations =
      lib.mapAttrs' (n: v: lib.nameValuePair n (mkNixos n v))
        (lib.filterAttrs (_: v: ! v.hmOnly && v.system != "aarch64-darwin") hosts);

    homeConfigurations =
      lib.mapAttrs' (n: v: lib.nameValuePair "davidsielert@${n}" (mkHM n v))
        (lib.filterAttrs (_: v: v.hmOnly) hosts);
  };
}
