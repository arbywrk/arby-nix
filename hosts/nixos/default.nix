{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./common.nix
    ../../modules/nixos/desktop/gdm.nix
    ../../modules/nixos/desktop/gnome.nix
  ];

  networking.hostName = "nixos";

  home-manager.extraSpecialArgs = { inherit inputs; };
  # Trying stock-look GNOME again -- swap for ../../home/arby/gnome-custom.nix
  # to go back to the themed profile (Yaru-esque Adwaita pass, Papirus
  # icons, custom shell CSS). See modules/home-manager/desktop/gnome/README.md.
  home-manager.users."arby" = import ../../home/arby/gnome.nix;
}
