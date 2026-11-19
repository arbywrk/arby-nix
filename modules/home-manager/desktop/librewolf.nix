{ lib, ... }:
{
  programs.librewolf = {
    enable = true;
    policies = import ./mozilla-policies.nix;
  };

  xdg.mimeApps.defaultApplications = lib.genAttrs [
    "text/html"
    "application/xhtml+xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/about"
    "x-scheme-handler/unknown"
  ] (_: "librewolf.desktop");
}
