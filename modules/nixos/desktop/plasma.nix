{ pkgs, lib, ... }:

let
  isolateToKDE = import ../../../lib/isolate-to-desktop.nix { inherit lib; } "KDE";
in
{
  services.desktopManager.plasma6.enable = true;

  # Drop Plasma's optional apps down to dolphin + konsole (re-added below,
  # isolated). systemsettings can't be excluded (Plasma core, not optional)
  # -- see modules/home-manager/desktop/plasma.nix for its fix instead.
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    ark
    elisa
    gwenview
    okular
    kate
    khelpcenter
    spectacle
  ];

  environment.systemPackages = isolateToKDE [
    pkgs.kdePackages.dolphin
    pkgs.kdePackages.konsole
  ];

  # plasma6's module sets programs.ssh.askPassword via mkDefault to
  # ksshaskpass, which ties with gnome.nix's seahorse module (also
  # mkDefault) now that both desktop managers are enabled together --
  # nixpkgs gives them equal priority, so it's a hard eval conflict unless
  # one is pinned. Keep the existing GNOME/seahorse prompt as the winner.
  programs.ssh.askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
}
