{ inputs, config, ... }:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ../../modules/home-manager/common.nix
    ../../modules/home-manager/development/neovim
    ../../modules/home-manager/development/zellij
    ../../modules/home-manager/development/zsh
  ];

  home.username = "bogdanrares";
  home.homeDirectory = "/home/bogdanrares";

  home.stateVersion = "26.05";

  xdg.enable = true;

  # Decrypts home/work/secrets.yaml at activation time using this machine's
  # own dedicated age key (generated locally with `age-keygen`, never an ssh
  # key -- this machine has no GitHub identity and shouldn't need one) --
  # see .sops.yaml for which machines' keys can decrypt it.
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.work_email = { };

  # Rendered to a runtime-only file outside the nix store (which is world
  # readable) at activation, then pulled into gitconfig via `includes` below
  # -- programs.git.settings.user.email would bake the plaintext address
  # straight into /nix/store, defeating the point of encrypting it.
  sops.templates."gitconfig-work-email".content = ''
    [user]
      email = ${config.sops.placeholder.work_email}
  '';

  programs.git = {
    enable = true;
    settings.user.name = "Rares-Andrei Bogdan";
    includes = [ { path = config.sops.templates."gitconfig-work-email".path; } ];
  };

  programs.home-manager.enable = true;
}
