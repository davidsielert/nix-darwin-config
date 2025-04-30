{
  inputs,
  lib,
  ...
}: {
  home.packages = rec {
    default = nvim;
    nvim = pkgs.nvim-pkg;
  };
}
