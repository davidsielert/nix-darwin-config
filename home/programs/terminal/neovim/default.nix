{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # install the kickstart-nix build of Neovim:
    nvim-pkg
  ];

  programs.neovim = {
    enable = true;
    # use the same package so NM’s `:checkhealth` and runtimes all line up:
    package = pkgs.nvim-pkg;
    # if you want to pull in your kickstart init.lua by default:
    extraConfig = ''
      -- e.g. require("kickstart")    -- or however your init.lua is structured
    '';
  };
}
