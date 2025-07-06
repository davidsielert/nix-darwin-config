{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    # ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    fzf # A command-line fuzzy finder

    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    caddy
    gnupg
    mprocs
    # productivity
    glow # markdown previewer in terminal
    zoxide
    #sqlFormatter
    #eslint
    nodejs_22
    #inputs.Neve.packages.${pkgs.system}.default

    # khanelivim.packages.${system}.default
    zsh-autoenv
    zsh-autocomplete
    awscli2
    (python3.withPackages (
      p:
        with p; [
          boto3
          pandas
          numpy
          #virtualenvwrapper
        ]
    ))
    python3Packages.virtualenvwrapper
    poetry
    uv
    rke
  ];
  programs = {
    #nvf = {
    # enable = true;
    # # your settings need to go into the settings attribute set
    # # most settings are documented in the appendix
    # settings = {
    #   vim.viAlias = false;
    #   vim.vimAlias = true;
    #   vim.lsp = {
    #     enable = true;
    #   };
    # };
    # modern vim
    #neovim = {
    #  enable = true;
    #  defaultEditor = true;
    #  vimAlias = true;
    #};
    # A modern replacement for ‘ls’
    # useful in bash/zsh prompt, not in nushell.
    eza = {
      enable = true;
      git = true;
      icons = "auto";
      enableZshIntegration = true;
    };

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
