{ pkgs, lib, config, ... }:
{
  fonts.fontconfig = {
    enable = true;
    # "Mono" variant specifically: fixed advance width for the icon
    # glyphs too, so terminal grid alignment stays correct (the
    # proportional "Nerd Font" variant can misalign icon columns).
    defaultFonts.monospace = [ "JetBrainsMono Nerd Font Mono" ];
  };

  # `programs.home-manager.enable` (set in each home/*/default.nix) looks
  # like the standard way to get the `home-manager` CLI onto PATH, but it
  # silently no-ops under this repo's NixOS-integrated hosts: read
  # straight from home-manager's own programs/home-manager.nix, that
  # option only adds its package when `!config.submoduleSupport.enable` --
  # and home-manager's NixOS integration (how `home-manager.users.<name>`
  # in hosts/* wires things up) sets `submoduleSupport.enable = true`
  # specifically to signal "this instance is being driven by
  # nixos-rebuild, don't also hand out a standalone CLI that tracks its
  # own separate generation history." Only add the package back in
  # ourselves in exactly that case -- the standalone homeConfigurations
  # outputs (arby/work/arby-gnome) already get it for free from
  # `programs.home-manager.enable` itself (submoduleSupport.enable is
  # false there), and adding it unconditionally collides with that
  # already-present copy. This lets `home-manager switch --flake
  # .#arby-gnome` (see flake.nix) apply just the home-manager half for
  # quick iteration on the NixOS-integrated host, without a full
  # nixos-rebuild pulling in the kernel/systemd/etc rebuild every time.
  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ] ++ lib.optional config.submoduleSupport.enable pkgs.home-manager;

  programs.bat.enable = true;
  home.shellAliases.cat = "bat";

  # ls/ll/la/lt/lla/llt aliases come free via its own zsh integration --
  # no need for a manual home.shellAliases.ls (would conflict with it).
  programs.lsd.enable = true;
}
