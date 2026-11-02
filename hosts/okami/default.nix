{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/nixos/desktop/gdm.nix
    ../../modules/nixos/desktop/gnome.nix
    ../../modules/nixos/university
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

  # SSH server; opens port 22. Key-only: no passwords, no root.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # mDNS: announces this machine as okami.local and resolves other .local
  # names. Opens UDP 5353.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    settings.publish = {
      disable-publishing = false;
      publish-addresses = true;
    };
  };

  # mosh-server for incoming `mosh`; opens UDP 60000-61000.
  programs.mosh.enable = true;

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
    # Public keys (~/.ssh/id_*.pub) of machines allowed to log in.
    openssh.authorizedKeys.keys = [ ];
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
