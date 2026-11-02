# Helpers shared by core/, coding/ and writing/.
{ pkgs }:
{
  # Explicit type: nixpkgs' wrapper defaults plugin config to viml.
  luaPlugin = plugin: config: {
    inherit plugin config;
    type = "lua";
  };

  # A profile's own runtime/ dir (lua/, luasnippets/, ...) as a bare plugin,
  # so require("core.x") etc. resolve via the runtimepath.
  mkRuntime = name: src: pkgs.runCommand name { } "cp -r ${src} $out";
}
