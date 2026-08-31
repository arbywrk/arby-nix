{ inputs, ... }:
{
  imports = [
    ../nixos-laptop/hardware-configuration.nix
    ../nixos-laptop/common.nix
    ../../modules/nixos/desktop/gdm.nix
    ../../modules/nixos/desktop/gnome.nix
  ];

  networking.hostName = "nixos-laptop-gnome";

  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users."arby" = import ../../home/arby/gnome.nix;
}
