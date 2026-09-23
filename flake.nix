{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      mkSystem = import ./lib/mksystem.nix { inherit inputs; };
      mkHome = import ./lib/mkhome.nix { inherit inputs; };
    in
    {
      nixosConfigurations = {
        nixos = mkSystem "nixos";
      };

      homeConfigurations = {
        # Also doubles as the fast-iteration target for the GNOME desktop
        # profile: `home-manager switch --flake .#arby` applies just the
        # home-manager half, without a full nixos-rebuild.
        arby = mkHome { username = "arby"; };
        wsl = mkHome { username = "wsl"; };
      };
    };
}
