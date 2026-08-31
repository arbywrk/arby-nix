{ inputs, ... }:
{
  imports = [
    ../nixos-laptop/hardware-configuration.nix
    ../nixos-laptop/common.nix
    ../../modules/nixos/desktop/sddm.nix
    ../../modules/nixos/desktop/plasma.nix
  ];

  networking.hostName = "nixos-laptop-kde";

  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users."arby" = import ../../home/arby/kde.nix;
}
