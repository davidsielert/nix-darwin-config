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
  overlayDir = ../nix/overlays;

  # ── overlay files in nix/overlays/ ────────────────────────────────────
  fileNames =
    builtins.attrNames
      (lib.filterAttrs (_: t: t == "regular") (builtins.readDir overlayDir));

  fileOverlays =
    builtins.listToAttrs (map
      (file: {
        name  = builtins.removeSuffix ".nix" (lib.strings.baseNameOf file);
        value = import (overlayDir + "/${file}") { inherit inputs; };
      })
      fileNames);

  # ── overlays that come from other flakes -----------------------------
  externalOverlays = {
    gen-luarc = inputs.gen-luarc.overlays.default;
  };

  overlayAttrs = fileOverlays // externalOverlays;
  overlayList  = lib.attrValues overlayAttrs;
in
{
  ## 1. expose them to the outside world  ────────────────────────────────
  flake.overlays = overlayAttrs;

  ## 2. make them available to *other* flake-parts modules in this repo
  _module.args.allOverlays = overlayList;
}
