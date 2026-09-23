{ pkgs, ... }:
{
  # `mosh <host>` in place of `ssh <host>` -- survives wifi drops/sleep
  # that would kill a plain ssh TCP session.
  home.packages = [ pkgs.mosh ];
}
