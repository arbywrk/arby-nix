{ lib, ... }:
{
  programs.zellij = {
    enable = true;

    # Zellij falls back to $SHELL for new panes when this is unset, which
    # is fragile (stale login sessions, contexts where $SHELL isn't
    # propagated) -- pin it explicitly instead. mkDefault so other homes
    # importing this module can pick a different shell with a plain
    # assignment, no lib.mkForce needed.
    settings.default_shell = lib.mkDefault "zsh";
  };
}
