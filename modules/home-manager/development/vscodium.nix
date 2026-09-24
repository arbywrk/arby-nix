{ pkgs, ... }:
{
  programs.vscodium = {
    enable = true;
    mutableExtensionsDir = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      bierner.markdown-mermaid
    ];
  };
}
