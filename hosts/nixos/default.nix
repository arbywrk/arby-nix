# The one real machine this flake manages: a laptop booted into GNOME.
{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/desktop/gdm.nix
    ../../modules/nixos/desktop/gnome.nix
  ];

  networking.hostName = "nixos";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-3776db7c-a9d9-4afe-80cb-b10d0bf33035".device =
    "/dev/disk/by-uuid/3776db7c-a9d9-4afe-80cb-b10d0bf33035";

  # networking.wireless (standalone wpa_supplicant) must stay off --
  # NetworkManager runs its own and they'd fight over the interface.
  networking = {
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
  };

  time.timeZone = "Europe/Bucharest";

  users.users."arby" = {
    isNormalUser = true;
    description = "Rares-Andrei Bogdan";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "uucp"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Rename a pre-existing unmanaged file to <name>.backup instead of
    # hard-failing activation when home-manager first takes it over.
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users."arby" = import ../../home/arby/default.nix;
  };

  system.stateVersion = "26.05";
}
