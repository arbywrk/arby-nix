{
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.desktopManager.gnome.enable = true;

  # Desktop-only GUI apps get installed as Flatpaks instead of nixpkgs
  # packages, declaratively via nix-flatpak -- this single `enable` also
  # turns on the underlying system flatpak service/portal (services.flatpak
  # is a shared option namespace between nixpkgs' own module and
  # nix-flatpak's). No Flatpak apps are declared through nix-flatpak here,
  # but this is what lets Flatpak (and Bazaar, the app-store front-end for
  # it -- see modules/home-manager/desktop/gnome/default.nix) work at all.

  # Drop GNOME's whole default app bundle (text editor, calculator, maps,
  # weather, yelp, ...) -- install back explicitly if you want any of them.
  services.gnome.core-apps.enable = false;

  # gnome-tour and gnome-control-center (Settings) are core-shell, not
  # core-apps, so core-apps.enable = false above doesn't touch them.
  # gnome-tour: first-run onboarding app, not needed.
  # gnome-control-center: excluded here only so it can be re-added below explicitly.
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-control-center
  ];

  environment.systemPackages = with pkgs; [
    nautilus
    nautilus-python
    gnome-control-center
  ];
}
