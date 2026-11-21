{ pkgs, ... }:
{
  services.desktopManager.cosmic.enable = true;

  # Brightness applet uses DDC/CI over /dev/i2c-* (user needs the i2c group).
  environment.systemPackages = [ pkgs.cosmic-ext-applet-external-monitor-brightness ];
  hardware.i2c.enable = true;
}
