# Packages not (yet) in nixpkgs. Applied to both nixosSystem (via
# nixpkgs.overlays in lib/mksystem.nix) and standalone Home Manager (via
# the `overlays` argument to `import inputs.nixpkgs { ... }` in
# lib/mkhome.nix) so `pkgs.<name>` resolves the same way everywhere.
final: prev: {
  # Settings' Appearance page hardcodes its "Style" (light/dark) and
  # "Accent Color" sections -- nothing gates their visibility, no
  # gsettings/lockdown key hides just these rows, and there's no runtime
  # extension mechanism for a compiled GTK app the way gnome-shell has.
  # Only real fix is a source patch + rebuild. The patch adds
  # `visible: false;` to those two Adw.PreferencesGroup blocks in the .blp
  # (blueprint, compiled to .ui at build time by blueprint-compiler) --
  # GTK skips invisible widgets during size allocation entirely, so
  # "Background" ends up as the only, ungapped section. Not deleting the
  # blocks outright: that would also require ripping out the C code that
  # binds/reloads their template children (accent_box, the color-scheme
  # toggles, the gsettings change handlers), for zero practical
  # difference over just hiding them.
  gnome-control-center = prev.gnome-control-center.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./patches/gnome-control-center-hide-appearance-style-accent.patch
    ];
  });
}
