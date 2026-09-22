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
        arby = mkHome { username = "arby"; };
        wsl = mkHome { username = "wsl"; };

        # Standalone targets for `home-manager switch --flake .#gnome[-custom]`,
        # to iterate on the GNOME profile without a full nixos-rebuild.
        # See modules/home-manager/desktop/gnome/README.md.
        gnome = mkHome {
          username = "arby";
          modules = [ ./home/arby/gnome.nix ];
        };

        gnome-custom = mkHome {
          username = "arby";
          modules = [ ./home/arby/gnome-custom.nix ];
        };
      };
    };
}
