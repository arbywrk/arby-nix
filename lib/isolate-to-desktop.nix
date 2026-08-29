# Wraps a list of packages so each one's .desktop file(s) are only shown in
# the given desktop environment (OnlyShowIn -- the same field GNOME/KDE's
# own packages already use for this, e.g. org.gnome.Settings.desktop).
# Isolation is the default for anything passed through here; sharing a
# package across desktop environments means not routing it through this
# function -- installing it via the DE-agnostic home-manager layer instead.
{ lib }:
de: pkgs:
map (
  pkg:
  pkg.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        if [ -d "$out/share/applications" ]; then
          for f in "$out/share/applications"/*.desktop; do
            if ! grep -q '^\(OnlyShowIn\|NotShowIn\)=' "$f"; then
              sed -i "/^\[Desktop Entry\]/a OnlyShowIn=${de};" "$f"
            fi
          done
        fi
      '';
  })
) pkgs
