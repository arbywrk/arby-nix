{ pkgs, inputs, ... }:

{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # Desktop-only GUI apps (currently just wezterm) get installed as
  # Flatpaks instead of nixpkgs packages, declaratively via nix-flatpak --
  # this single `enable` also turns on the underlying system flatpak
  # service/portal (services.flatpak is a shared option namespace between
  # nixpkgs' own module and nix-flatpak's). Per-app declarations live next
  # to whatever home-manager module wants them (see
  # modules/home-manager/desktop/wezterm.nix), not here.
  services.flatpak.enable = true;

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
