# modules/darwin/system.nix
#
# macOS-specific system settings for every machine that runs nix-darwin.
# Adjust the computerName/hostName block (and user account) per host if
# you don’t override them in ./hosts/<name>/darwin.nix.

{ pkgs, lib, ... }:

{
  ######################################################################
  ## 0. Identify the macOS version this file was written for
  ######################################################################
  system.stateVersion = 4;        # Darwin “4”  ≈ macOS Ventura/Sonoma

  ######################################################################
  ## 1. Run Nix as a launchd service (needs root)                   ★
  ######################################################################
  services.nix-daemon.enable = true;     # core.nix sets nix.settings

  ######################################################################
  ## 2. macOS defaults & preference panes                           ★
  ##    All keys come from the nix-darwin manual                    ★
  ######################################################################
  system.defaults = {
    dock = {
      autohide  = true;
      tilesize  = 36;
      expose-animation-duration = "0.12";   # speed up Mission Control
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar            = true;
      FXPreferredViewStyle   = "clmv";       # column view
    };

    trackpad = {
      Clicking           = true;    # tap-to-click
      TrackpadThreeFingerDrag = true;
    };

    NSGlobalDomain = {
      "AppleShowAllExtensions" = true;
      "AppleInterfaceStyleSwitchesAutomatically" = true;
      "InitialKeyRepeat" = 15;      # 225 ms
      "KeyRepeat"       = 2;        # 30 ms
    };
  };  #  [oai_citation:0‡nix-darwin.github.io](https://nix-darwin.github.io/nix-darwin/manual/?utm_source=chatgpt.com)

  ######################################################################
  ## 3. Homebrew integration                                        ★
  ######################################################################
  homebrew = {
    enable = true;
    onActivation.autoUpdate = false;        # idempotent rebuilds  [oai_citation:1‡nix-darwin.github.io](https://nix-darwin.github.io/nix-darwin/manual/?utm_source=chatgpt.com)
    global.autoUpdate = false;

    taps  = [ "homebrew/cask" ];
    brews = [ "mas" ];                      # Mac App Store CLI
    casks = [
      "google-chrome"
      "visual-studio-code"
      # add more casks here
    ];
  };

  ######################################################################
  ## 4. Fonts (enable ~/Library/Fonts/Nix)                          ★
  ######################################################################
  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    ];
  };

  ######################################################################
  ## 5. User account & login shell                                  ★
  ##    (override in host file if user differs per machine)
  ######################################################################
  users.users.davidsielert = {
    name  = "davidsielert";
    home  = "/Users/davidsielert";
    shell = pkgs.zsh;
    # nix-darwin automatically puts this user in the wheel group
  };

  ######################################################################
  ## 6. Host identification (can be overridden per host)            ★
  ######################################################################
  networking = {
    computerName = "mbp14";   # Shows up in Finder sidebar / AirDrop
    hostName     = "mbp14";   # BSD hostname
  };

  ######################################################################
  ## 7. Extra system packages unique to macOS                       ★
  ######################################################################
  environment.systemPackages = with pkgs; [
    # pkgs.hammerspoon
    # pkgs.istioctl
  ];

  ######################################################################
  ## 8. Launchd / services tweaks                                    #
  ######################################################################
  # Example: speed up the Spotlight metadata import so Nix store
  # paths are searchable quicker.
  services.spotlight = {
    enable = true;
    indexOnLowPowerDevices = false;
  };
}
