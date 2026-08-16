{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    {
      nixosConfigurations.thinkpad-p16s-nixos =
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ./system/thinkpad-p16s-nixos/configuration.nix
            home-manager.nixosModules.default
          ];
        };
    };
}
