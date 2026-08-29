{ ... }:

{
  # DE-agnostic login manager, shared by every desktop session enabled on
  # this host (see gnome.nix, plasma.nix) -- lists whatever sessions exist
  # in /usr/share/{x,wayland-}sessions, so it doesn't need to know about
  # either of them.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
}
