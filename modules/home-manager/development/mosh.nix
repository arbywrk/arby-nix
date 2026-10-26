# `mosh <host>` in place of `ssh <host>` -- survives wifi drops/sleep
# that would kill a plain ssh TCP session.
{ pkgs, ... }:
{
  home.packages = [ pkgs.mosh ];
}
