{ ... }:

{
  # Plasma's login manager -- native SDDM/KWin integration (theme, session
  # handling) rather than the DE-agnostic GDM used on the GNOME host.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
}
