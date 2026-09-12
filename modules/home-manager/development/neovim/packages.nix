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

  # Rust -- rust-analyzer alone can't do anything (its own error is
  # literally "Failed to load workspaces"): it shells out to `cargo` to
  # discover the workspace/dependencies and to `rustfmt` for LSP-based
  # formatting, and rustacean.lua's checkOnSave is set to "clippy".
  # Without a real toolchain installed, all of that silently has nothing
  # to run.
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
]
