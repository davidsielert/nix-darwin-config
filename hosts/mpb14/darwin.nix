# hosts/mbp14/darwin.nix
# -----------------------------------------------------------
# Overrides and machine-only settings for David's M1/M2 (?) MBP14
# -----------------------------------------------------------

{ lib, pkgs, ... }:

{
  ########################################################################
  # 1. Host identification & networking
  ########################################################################
  networking = {
    computerName = "davids-mbp14";   # Finder / AirDrop name
    hostName     = "mbp14";          # BSD hostname
  };

  ########################################################################
  # 2. Architecture hint (helps when cross-building from x86 builders)
  ########################################################################
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";

  ########################################################################
  # 3. Homebrew bits unique to this laptop
  ########################################################################
  homebrew = {
    taps  = [ "homebrew/cask-fonts" ];
    casks = [
      "docker"          # container runtime
      "slack"
      "spotify"
      "font-jetbrains-mono-nerd-font"
    ];
  };

  ########################################################################
  # 4. System packages just for this Mac
  ########################################################################
  environment.systemPackages = with pkgs; [
    colima           # container runtime backed by Lima/VM
    podman           # alt container CLI
    hammerspoon
  ];

  ########################################################################
  # 5. Hardware / power-management tweaks (laptop only)
  ########################################################################
  system.defaults.energysaver = {
    "AutomaticRestartOnPowerLoss" = 1;
    "DisplaySleepTimer"           = 5;   # minutes on AC
  };

  ########################################################################
  # 6. Touch ID sudo
  ########################################################################
  security.pam.enableSudoTouchIdAuth = true;

  ########################################################################
  # 7. Optional: key-remapping via Karabiner-Elements
  ########################################################################
  # services.karabiner-elements.extraConfig =
  #   builtins.readFile ./karabiner.json;
}
