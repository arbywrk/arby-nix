{ pkgs }:
with pkgs;
[
  # C/C++
  clang-tools

  # Lua
  lua-language-server
  stylua

  # Python
  basedpyright
  ruff

  # Bash
  bash-language-server
  shfmt
  shellcheck

  # Nix
  nixd
  nixfmt

  # TOML / SQL / misc
  taplo
  sqls
  jq

  # YAML
  yaml-language-server

  # Zephyr devicetree (.dts/.dtsi/.overlay)
  dts-lsp

  # Typst
  tinymist
  typstyle
]
