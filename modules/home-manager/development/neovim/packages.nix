# LSP servers, formatters, and linters, replacing what mason-tool-installer
# used to fetch at runtime. Debug adapters and the embedded toolchain
# (codelldb, cpptools, arm-none-eabi-gdb, openocd, ...) are pulled in
# separately -- see debug-packages.nix -- since a couple of those needed
# their own build spike before trusting them here.
{ pkgs }:
with pkgs;
[
  # C/C++
  clang-tools

  # Rust -- rust-analyzer shells out to cargo/rustfmt/clippy, so all three
  # need to be installed alongside it, not just the LSP server itself.
  cargo
  clippy
  rust-analyzer
  rustc
  rustfmt

  # Lua
  lua-language-server
  stylua

  # Zig
  zig
  zls

  # Python
  basedpyright
  ruff

  # Bash
  bash-language-server
  shfmt
  shellcheck

  # Nix
  nil
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
