{ pkgs, ... }:
{
  # mosh (mobile shell): UDP-based, survives wifi drops/IP changes/laptop
  # sleep the way a plain ssh TCP session doesn't. Usage is just
  # `mosh <host>` in place of `ssh <host>` -- no config needed, it shells
  # out to the system ssh client to authenticate/bootstrap the connection.
  home.packages = [ pkgs.mosh ];
}
