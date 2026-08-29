{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  isolateToGNOME = import ../../../lib/isolate-to-desktop.nix { inherit lib; } "GNOME";
in
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.desktopManager.gnome.enable = true;

  # Desktop-only GUI apps get installed as Flatpaks instead of nixpkgs
  # packages, declaratively via nix-flatpak -- this single `enable` also
  # turns on the underlying system flatpak service/portal (services.flatpak
  # is a shared option namespace between nixpkgs' own module and
  # nix-flatpak's). Currently unused (no Flatpak apps declared), kept in
  # place for future use.
  services.flatpak.enable = true;

  # Drop GNOME's whole default app bundle (text editor, calculator, maps,
  # weather, yelp, ...) -- install back explicitly if you want any of them.
  services.gnome.core-apps.enable = false;

  # gnome-tour and gnome-control-center (Settings) are core-shell, not
  # core-apps, so core-apps.enable = false above doesn't touch them.
  # gnome-tour: first-run onboarding app, not wanted. gnome-control-center:
  # excluded here only so it can be re-added below as the isolated copy.
  environment.gnome.excludePackages = [
    pkgs.gnome-tour
    pkgs.gnome-control-center
  ];

  # Every app GNOME gets goes through isolateToGNOME -- that's what makes
  # isolation the default instead of something to remember per package.
  environment.systemPackages = isolateToGNOME [
    pkgs.nautilus
    pkgs.gnome-console
    pkgs.gnome-control-center
  ];
}
