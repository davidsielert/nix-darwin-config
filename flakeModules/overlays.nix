# flakeModules/overlays.nix
#
# A flake-parts module that
#   1. scans ./nix/overlays/ for every “*.nix” file,
#   2. imports each file as an overlay function,
#   3. exposes them two ways:
#        • self.overlays.<name>     – for downstream flakes
#        • allOverlays (list value) – for internal use in other modules
#
# Each overlay file can be a traditional
#   self: super: { … }
# or the newer flake-departing form that takes `{ inputs, ... }`.

{ inputs, lib, ... }:

let
  # Directory that holds *.nix overlay files
  overlayDir = ../nix/overlays;

  # Helper: turn every file in overlayDir into an attr-set entry
  overlayAttrs =
    builtins.listToAttrs
      (map
        (file:
          let
            name = builtins.removeSuffix ".nix" (lib.strings.baseNameOf file);
          in
          {
            inherit name;
            value = import (overlayDir + "/${file}") { inherit inputs; };
          })
        (lib.filterAttrs
          (_: type: type == "regular")
          (builtins.readDir overlayDir)
          |> builtins.attrNames));

  # The list form many nixpkgs imports expect
  overlayList = lib.attrValues overlayAttrs;
in
{
  # 1️⃣  surfaces overlays to the outside world (so another flake can do
  #     `inputs.self.overlays.neovim`)
  flake.overlays = overlayAttrs;

  # 2️⃣  makes `allOverlays` available as an argument to every other
  #     flake-parts module in *this* repo
  config._module.args.allOverlays = overlayList;
}
