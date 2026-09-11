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
  home-manager.users."arby" = import ../../home/arby/gnome.nix;
}
