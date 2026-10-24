{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/nixos/desktop/gdm.nix
    ../../modules/nixos/desktop/gnome.nix
  ];

  networking.hostName = "okami";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # networking.wireless (standalone wpa_supplicant) must stay off --
  # NetworkManager runs its own and they'd fight over the interface.
  networking = {
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
  };

  virtualisation.docker.enable = true;

  time.timeZone = "Europe/Bucharest";

  environment.variables.EDITOR = "nvim";

  users.users."arby" = {
    isNormalUser = true;
    description = "Rares-Andrei Bogdan";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "uucp"
      "docker"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bkp";
    extraSpecialArgs = { inherit inputs; };
    users."arby" = import ../../home/arby/default.nix;
  };

  system.stateVersion = "26.05";
}
