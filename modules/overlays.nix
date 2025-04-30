{
  config,
  pkgs,
  lib,
  ...
}: {
  # Any overlay functions you like:
  nixpkgs.overlays = [
    # your own file-based overlay
    (import ./my-neovim-overlay.nix)

    # any flakes you’re consuming that expose an overlay:
    inputs.gen-luarc.overlays.default
    inputs.kickstart-nix.overlays.default
  ];
}
