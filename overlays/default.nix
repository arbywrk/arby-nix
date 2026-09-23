# Packages not (yet) in nixpkgs. Applied to both nixosSystem (via
# nixpkgs.overlays in lib/mksystem.nix) and standalone Home Manager (via
# the `overlays` argument to `import inputs.nixpkgs { ... }` in
# lib/mkhome.nix) so `pkgs.<name>` resolves the same way everywhere. See
# the nixpkgs manual's "Overlays" chapter:
# https://nixos.org/manual/nixpkgs/stable/#chap-overlays
final: prev: {
  # Settings' Appearance page hardcodes its "Style"/"Accent Color" sections
  # -- no gsettings/lockdown key or runtime extension point hides them, so
  # this patches `visible: false;` onto those two blueprint blocks (GTK
  # skips invisible widgets during layout, leaving "Background" alone).
  gnome-control-center = prev.gnome-control-center.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./patches/gnome-control-center-hide-appearance-style-accent.patch
    ];
  });
}
