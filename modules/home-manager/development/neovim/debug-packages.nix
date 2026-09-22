# Debug adapters and the embedded toolchain. codelldb/cpptools come from
# VS Code extension packages whose binaries are nested under
# share/vscode/extensions/... instead of $out/bin, so each gets a thin
# wrapper exposing a plain PATH-resolvable name, as debug.lua expects.
{ pkgs }:
let
  codelldb-bin = pkgs.runCommand "codelldb-bin" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb $out/bin/codelldb
  '';

  opendebugad7-bin = pkgs.runCommand "opendebugad7-bin" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7 $out/bin/OpenDebugAD7
  '';

  # nvim-dap-python needs a python with debugpy importable. Exposed under a
  # distinct name (not bare "python3") to avoid shadowing whatever Python
  # the rest of the system/PATH provides.
  debugpy-python = pkgs.runCommand "debugpy-python-bin" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.python3.withPackages (ps: [ ps.debugpy ])}/bin/python3 $out/bin/debugpy-python
  '';
in
with pkgs;
[
  codelldb-bin
  opendebugad7-bin
  debugpy-python

  gdb # native

  # arm-none-eabi-gdb, arm-none-eabi-gcc, etc. lib.lowPrio: both this and
  # gdb ship include/gdb/jit-reader.h, which conflicts in the profile;
  # neither copy matters to us (just a C header for GDB JIT-reader
  # plugins), so let gdb's win arbitrarily.
  (lib.lowPrio gcc-arm-embedded)

  openocd
]
