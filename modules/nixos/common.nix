{ pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.nix-ld.enable = true;
  programs.zsh.enable = true;

  # No per-category ro_RO overrides -- that's what made the calendar,
  # date/number formatting, etc. show up in Romanian despite LANG itself
  # being en_US.
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  # xterm is pulled in by services.xserver itself; alacritty (home-manager)
  # replaces it as the terminal emulator.
  services.xserver.excludePackages = [ pkgs.xterm ];

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  # PipeWire replaces PulseAudio; rtkit gives it realtime scheduling.
  # Options: https://search.nixos.org/options?query=services.pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
  ];
}
