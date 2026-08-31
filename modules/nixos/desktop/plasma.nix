{ pkgs, ... }:

{
  services.desktopManager.plasma6.enable = true;

  # Drop Plasma's optional apps down to dolphin + konsole (re-added below).
  # systemsettings can't be excluded -- it's Plasma core, not optional.
  # discover: plasma6's own module sets services.fwupd.enable = mkDefault
  # true unconditionally, which alone (independent of flatpak) makes Plasma
  # install Discover -- excluded explicitly since we want apps installed on
  # purpose, not as a side effect of another default.
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    ark
    discover
    elisa
    gwenview
    okular
    kate
    khelpcenter
    spectacle
  ];

  environment.systemPackages = with pkgs.kdePackages; [
    dolphin
    konsole
  ];
}
