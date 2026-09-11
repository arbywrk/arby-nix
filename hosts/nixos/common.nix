{ pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-3776db7c-a9d9-4afe-80cb-b10d0bf33035".device =
    "/dev/disk/by-uuid/3776db7c-a9d9-4afe-80cb-b10d0bf33035";

  # NetworkManager already runs its own wpa_supplicant for Wi-Fi, so
  # networking.wireless (the standalone wpa_supplicant service) must stay
  # off to avoid both fighting over the same interface.
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
    # When a managed path already exists on disk (e.g. a tool wrote its own
    # default config before home-manager took it over), rename it to
    # <name>.backup instead of hard-failing the whole activation.
    backupFileExtension = "backup";
  };

  system.stateVersion = "26.05";
}
