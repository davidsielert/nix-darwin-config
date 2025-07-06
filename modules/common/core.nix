#modules/common/core.nix
#
# Import path is the same for both nix-darwin and NixOS:
#   modules = [ ./modules/common/core.nix … ]

{ lib, pkgs, ... }:

{
  ##########################################################################
  # 1. Nix daemon & store behaviour (cross-platform)                       #
  ##########################################################################
  nix = {
    package = pkgs.nix;

    settings = {
      # turn on all the goodies that work everywhere
      experimental-features = [
        "nix-command" "flakes" "repl-flake"
        "ca-derivations" "auto-allocate-uids"
        "pipe-operators"
      ];


      trusted-users = [ "root" "davidsielert" ];  # add others if needed
      warn-dirty    = false;                      # avoid noisy git msg
    };

    optimise = {
      # The Nix store is shared between all users, so we need to
      # ensure that the garbage collector doesn't delete our stuff.
      # This is done by running the GC automatically at a set interval.
      # Note: this is not needed on NixOS, as it runs the GC automatically.
      # See https://nixos.wiki/wiki/Automatic_GC
      automatic = true;
    };
  };

  ##########################################################################
  # 2. nixpkgs defaults shared by all hosts                                #
  ##########################################################################
  # The builders that import nixpkgs already pass your overlay list,
  # but we still set global “meta” options here.
  nixpkgs = {
    config = {
      allowUnfree = true;      # vscode, zoom, etc.
      allowBroken = true;
    };
    # hostPlatform is inferred automatically, but you can pin it:
    # hostPlatform = pkgs.stdenv.hostPlatform;
  };

  ##########################################################################
  # 3. Packages that *every* system should have out of the box             #
  ##########################################################################
  environment.systemPackages = with pkgs; [
    git
    curl
    htop
    vim              # or neovim-custom once the overlay is active
    jq
  ];

  ##########################################################################
  # 4. Shell & locale bits that are identical on macOS and Linux           #
  ##########################################################################
  programs.zsh.enable          = true;   # both platforms support it
  programs.fish.enable         = true;  # opt-out here if you want

}
