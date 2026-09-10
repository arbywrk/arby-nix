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
  # nix-flatpak's). Currently unused (no Flatpak apps declared), kept in
  # place for future use.
  services.flatpak.enable = true;

  # Drop GNOME's whole default app bundle (text editor, calculator, maps,
  # weather, yelp, ...) -- install back explicitly if you want any of them.
  services.gnome.core-apps.enable = false;

  # gnome-tour and gnome-control-center (Settings) are core-shell, not
  # core-apps, so core-apps.enable = false above doesn't touch them.
  # gnome-tour: first-run onboarding app, not wanted. gnome-control-center:
  # excluded here only so it can be re-added below explicitly.
  environment.gnome.excludePackages = [
    pkgs.gnome-tour
    pkgs.gnome-control-center
  ];

  # No terminal here -- ghostty and alacritty (both home-manager-managed,
  # see home/arby/default.nix) are the only two terminals wanted in this
  # session. gnome-console isn't re-added (core-apps.enable = false above
  # already excludes it) and GNOME Terminal isn't installed anywhere
  # either.
  environment.systemPackages = [
    pkgs.nautilus
    pkgs.gnome-control-center
  ];
}
