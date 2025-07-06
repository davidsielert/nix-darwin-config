# nix/overlays/my-overlays.nix
#
# ← identical logic to the inline “myOverlays” you had before
#   but wrapped so it can see `inputs` when the module passes them in.

{ inputs, ... }:         # … allows extra attrs if we add more later
self: super: {

  # carry-over package tweaks  ────────────────────────────────────────────
  eslint           = super.nodePackages.eslint or null;

  nodejs           = super.nodejs.overrideAttrs (old: { doCheck = false; });
  nodejs-slim      = super.nodejs-slim.overrideAttrs (old: { doCheck = false; });

  # pinned / cross-flake deps
  biome            = inputs.biome-pinned.legacyPackages.${self.system}.biome;
  tailwindcss-language-server =
    inputs.nixpkgs-unstable.legacyPackages.${self.system}
          .tailwindcss-language-server;
}
