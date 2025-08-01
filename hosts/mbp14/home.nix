{
  inputs,
  username,
  ...
}: {
  # import sub modules
  imports = [
    ./core.nix
    ./git.nix
    ./starship.nix
    #./nvf.nix
    ../../home/programs/terminal
    # nvf.homeManagerModules.default
    inputs.mac-app-util.homeManagerModules.default
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.kitty = {
    enable = true;
    themeFile = "Dracula";
    font.name = "DejaVuSansM Nerd Font Mono";
    extraConfig = ''
      map kitty_mod+space no_op
    '';
  };
}
