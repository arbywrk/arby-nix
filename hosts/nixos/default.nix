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
  # Stock-look GNOME profile -- swap for ../../home/arby/gnome-custom.nix
  # for the themed one. See modules/home-manager/desktop/gnome/README.md.
  home-manager.users."arby" = import ../../home/arby/gnome.nix;
}
