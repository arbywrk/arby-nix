{ pkgs, ... }:
{
  # Second session alongside GNOME; pick it from the GDM gear menu.
  services.desktopManager.cosmic.enable = true;

  # Panel applet; talks DDC/CI over /dev/i2c-*, so the user needs the i2c group.
  environment.systemPackages = [ pkgs.cosmic-ext-applet-external-monitor-brightness ];
  hardware.i2c.enable = true;
}
