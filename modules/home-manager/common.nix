{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.stylix.homeModules.stylix ];

  # One palette/font for terminal tools. Targets are opt-in: each module
  # enables stylix.targets.<name> next to the program it configures.
  stylix = {
    enable = true;
    autoEnable = false;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
    # Neutral grays instead of Ayu's blue-tinted background shades.
    override = {
      base00 = "131313";
      base01 = "1f1f1f";
      base02 = "3c3c3c";
      base03 = "686868";
    };
    fonts = {
      # Not the "Mono" variant: terminals get full-width icon glyphs.
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sizes.terminal = 11;
    };
  };

  fonts.fontconfig = {
    enable = true;
    # "Mono" variant: fixed-width icon glyphs keep grid alignment in
    # apps that don't size them themselves.
    defaultFonts.monospace = [ "JetBrainsMono Nerd Font Mono" ];
  };

  # Under NixOS integration programs.home-manager doesn't install the CLI,
  # so add it back for quick `home-manager switch` iteration.
  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ]
  ++ lib.optional config.submoduleSupport.enable pkgs.home-manager;

  programs.bat.enable = true;
  stylix.targets.bat.enable = true;
  home.shellAliases.cat = "bat";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    config.global.hide_env_diff = true;
  };

  # lsd's own zsh integration already provides ls/ll/la/lt/lla/llt.
  programs.lsd.enable = true;
}
