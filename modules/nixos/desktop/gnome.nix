{ pkgs, ... }:

{
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];

  # gnome-console: replaced by alacritty (home-manager). epiphany/gnome-maps/
  # gnome-tour/yelp: default GNOME apps not wanted on this machine.
  environment.gnome.excludePackages = with pkgs; [
    gnome-console
    epiphany
    gnome-maps
    gnome-tour
    yelp
  ];
}
