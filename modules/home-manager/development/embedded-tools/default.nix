{ pkgs, ... }:
{
  home.packages = with pkgs; [
    openocd
    pyocd
    gdb
    probe-rs-tools
  ];
}
