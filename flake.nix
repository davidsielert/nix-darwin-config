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
    substituters = [
      # Query the mirror of USTC first, and then the official cache.
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # Use a single Nixpkgs input for consistency
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home Manager input, following `nixpkgs`
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix-Darwin input, following `nixpkgs`
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixVim input, following `nixpkgs`
    #nixvim = {
    #  url = "github:nix-community/nixvim";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    khanelivim = {
      url = "github:khaneliman/khanelivim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    Neve = {
      url = "github:redyf/Neve";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    mac-app-util.url = "github:hraban/mac-app-util";

    nvf.url = "github:notashelf/nvf";
  };
  # The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs = {
    self,
    nixpkgs,
    darwin,
    home-manager,
    khanelivim,
    Neve,
    nvf,
    ...
  } @ inputs: let
    # User-specific settings
    username = "davidsielert";
    useremail = "david@sielert.com";
    system = "aarch64-darwin"; # Use "aarch64-darwin" for Apple Silicon, "x86_64-darwin" for Intel Macs
    hostname = "mbp14";
    myOverlays = self: super: {
      # Adding eslint to the package set
      eslint = super.nodePackages.eslint or null;
    };
    sources = import ./npins;
    # Package set for the selected system
    pkgs = import nixpkgs {
      inherit system;
      overlays = [myOverlays];
    };
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
          ;
      };
  in {
    darwinConfigurations."${hostname}" = darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/apps.nix
        ./modules/host-users.nix
        # nixvim.nixDarwinModules.nixvim
        # Home Manager integration
        home-manager.darwinModules.home-manager
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
}
