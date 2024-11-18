{

  imports = [
    ./opts.nix
    ./keymaps.nix
    ./autocmds.nix
    ./plugins/plugins-bundle.nix
  ];

  programs.nixvim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    # defaultEditor = true;
    colorschemes.oxocarbon.enable = true;
  };
}
