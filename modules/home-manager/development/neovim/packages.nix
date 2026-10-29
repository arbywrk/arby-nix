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

  # TOML / misc
  taplo
  jq

  # SQL (SQLite + PostgreSQL)
  sqls
  postgres-language-server
  sqlfluff

  # YAML
  yaml-language-server

  # Zephyr devicetree (.dts/.dtsi/.overlay)
  dts-lsp

  # Typst
  tinymist
  typstyle
]
