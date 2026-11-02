# The coding profile: the default `nvim` (programs.neovim), core plus LSPs,
# formatters, linters, debuggers and tests.
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  nvimLib = import ../lib.nix { inherit pkgs; };
  core = import ../core {
    inherit
      pkgs
      lib
      config
      nvimLib
      ;
  };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins =
      core.plugins
      ++ [
        (core.treesitter (
          ps: with ps; [
            bash
            c
            cpp
            diff
            lua
            luadoc
            nix
            python
            query
            toml
            vim
            vimdoc
            rust
            ron
            sql
            zig
          ]
        ))
      ]
      ++ import ./plugins.nix { inherit pkgs nvimLib; };

    # mkOrder 100: home-manager concatenates plugin config at mkOrder 200,
    # so core's leader setup has to land before it.
    initLua = lib.mkOrder 100 ''
      ${core.initLua}
      -- nixd evaluates these for completion/hover in .nix files. Options come
      -- from this flake's checkout (not a store copy), so modules imported
      -- here (e.g. stylix) complete and edits show up without a rebuild.
      vim.g.nixd_nixpkgs_expr = [[import ${inputs.nixpkgs} { }]]
      vim.g.nixd_flake = [[(builtins.getFlake "${config.home.homeDirectory}/.config/arby-nix")]]
      vim.g.nixd_nixos_options_expr = vim.g.nixd_flake .. [[.nixosConfigurations.okami.options]]
      vim.g.nixd_home_manager_options_expr = vim.g.nixd_flake .. [[.homeConfigurations.wsl.options]]
      vim.g.nixd_flake_parts_options_expr = [[(((import ${inputs.flake-parts}/flake.nix).outputs { nixpkgs-lib.lib = import ${inputs.nixpkgs}/lib; }).lib.evalFlakeModule { inputs.self.outPath = "/nixd"; } { }).options]]

      require("coding.keymaps")
    '';
  };

  home.packages =
    (import ./packages.nix { inherit pkgs; }) ++ (import ./debug-packages.nix { inherit pkgs; });

  xdg.configFile."sqlfluff/.sqlfluff".source = ./sqlfluff.cfg;
}
