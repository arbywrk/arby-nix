{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/desktop/gnome.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-3776db7c-a9d9-4afe-80cb-b10d0bf33035".device =
    "/dev/disk/by-uuid/3776db7c-a9d9-4afe-80cb-b10d0bf33035";

  networking.hostName = "nixos-laptop";
  # NetworkManager already runs its own wpa_supplicant for Wi-Fi, so
  # networking.wireless (the standalone wpa_supplicant service) must stay
  # off to avoid both fighting over the same interface.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Bucharest";

  users.users."arby" = {
    isNormalUser = true;
    description = "Rares-Andrei Bogdan";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users."arby" = import ../../home/arby;
    # When a managed path already exists on disk (e.g. a tool wrote its own
    # default config before home-manager took it over), rename it to
    # <name>.backup instead of hard-failing the whole activation.
    backupFileExtension = "backup";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05";
}
