# Neovim config

This is **not** a normal `~/.config/nvim` you'd point `lazy.nvim` at. There is
no plugin manager, no `init.lua` you edit directly, and no `:Lazy update`.
Everything — which plugins exist, their config, LSP servers, formatters,
linters, debug adapters — is declared in Nix and gets assembled into a
runnable Neovim by `home-manager`/`programs.neovim` at build time. Plugins
come straight from `nixpkgs.vimPlugins` (pinned by the flake's `nixpkgs`
input) and are loaded eagerly — there's no lazy-loading layer.

To actually see any change made here, you have to rebuild: see
**Applying changes** at the bottom.

## How a Neovim startup is assembled

1. `default.nix` turns on `programs.neovim`, feeds it a plugin list built
   from `plugins.nix` + `self-lua.nix`, and sets `initLua` to set the
   leader keys and `require("options")` / `require("keymaps")`.
2. Every plugin's own `config` (if it has one) gets sourced by
   home-manager, in list order, right after that `initLua` block.
3. `self-lua.nix` isn't a real plugin — it's a small derivation that copies
   this directory's `files/lua/` onto Neovim's runtimepath (as a plugin
   with no `config` of its own) so `require("options")`, `require("keymaps")`,
   `require("config.debug")`, `require("util.keymap")`, etc. resolve like
   they would in any normal Lua-based Neovim config. `files/lua/plugins/`
   is deliberately excluded from that copy (see step 2 — those files are
   wired in individually, not `require()`'d).
4. `packages.nix` / `debug-packages.nix` install LSP servers, formatters,
   linters, and debug adapters as plain `home.packages` — replacing what
   `mason.nvim` would otherwise download at runtime. Neovim just finds them
   on `$PATH`.

## File map

```
default.nix                    entry point -- turns programs.neovim on, wires
                                 everything else together, sets the leader keys
plugins.nix                     the plugin list itself (see below)
self-lua.nix                    puts files/lua/ on the runtimepath (minus plugins/)
packages.nix                    LSP servers, formatters, linters (home.packages)
debug-packages.nix              debug adapters + embedded-dev toolchain

files/lua/
  options.lua                   vim.opt.* -- global editor settings
  keymaps.lua                   top-level keymaps + autocommands, then
                                  require()s the keymaps/ submodules below
  keymaps/
    buffer.lua, build.lua, window.lua   keymaps grouped by concern
  util/
    keymap.lua                  keymap.map()/buffer_map() helper used
                                  everywhere instead of raw vim.keymap.set
  config/
    debug/, build/, lsp/        bigger non-plugin subsystems -- required
                                  from keymaps or plugin configs as needed
  plugins/
    <name>.lua                  per-plugin config bodies -- NOT require()'d;
                                  each one is wired into plugins.nix
                                  individually as that plugin's `config`
```

## `plugins.nix` — the plugin list

Each entry is either:

- a bare package (`p.plenary-nvim`) — plugin has no `setup()`/config at all,
  just needs to be on the runtimepath, **or**
- `{ plugin = p.foo; config = <lua source string>; }` — plugin needs
  configuring. `config` is built one of two ways:
  - `toLua "require('foo').setup({ ... })"` — for a one-liner, written
    inline right there in `plugins.nix`
  - `toLuaFile ./files/lua/plugins/foo.lua` — for anything longer; the
    actual Lua lives in its own file under `files/lua/plugins/`

`p` is just `pkgs.vimPlugins` — every plugin name here is a real nixpkgs
attribute. Look one up with `nix search nixpkgs vimPlugins.<name>` or on
[search.nixos.org/packages](https://search.nixos.org/packages) before
assuming it isn't packaged.

### Adding a new plugin

1. Confirm it's in `nixpkgs.vimPlugins` (see above). If it isn't, it needs
   packaging first — out of scope for a normal "add a plugin" change.
2. **No config needed** (nothing to call, or it self-activates like
   `vim-sleuth`): just add `p.<name>` to the list in `plugins.nix`.
3. **Needs a `setup()` call:**
   - Config is a one-liner → add it inline with `toLua "..."` right in
     `plugins.nix`, next to similar entries (see `fidget-nvim` or
     `persistent-breakpoints-nvim` for examples).
   - Config is more than a line or two → create
     `files/lua/plugins/<name>.lua` containing just the plugin's own setup
     code (see `files/lua/plugins/gitsigns.lua` or `lualine.lua` for the
     shape), then add `{ plugin = p.<name>; config = toLuaFile
     ./files/lua/plugins/<name>.lua; }` to `plugins.nix`.
4. Rebuild (see **Applying changes**).

A `files/lua/plugins/*.lua` file is sourced directly as that plugin's
`config` — it is never `require()`'d, so don't add a `return M` /
`local M = {}` wrapper to it like you would for a real module; just write
the setup calls/keymaps at the top level, same as the existing files.

## Adding a keymap

- A small one-off, not tied to any plugin → `files/lua/keymaps.lua`
  directly, or the relevant file under `files/lua/keymaps/` if it fits an
  existing grouping (buffer / build / window).
- A new *category* of keymaps → new file under `files/lua/keymaps/`, then
  add `require("keymaps.<name>")` at the bottom of `files/lua/keymaps.lua`
  (that's how `buffer.lua`/`build.lua`/`window.lua` get loaded today).
- A keymap that belongs to a specific plugin's own behavior → put it in
  that plugin's `files/lua/plugins/<name>.lua` instead (see how
  `conform.lua` defines its own `<leader>f` right next to the plugin
  setup that keymap drives).

Prefer `require("util.keymap").map(mode, lhs, rhs, desc)` over raw
`vim.keymap.set` for consistency with the rest of the config — it just
forces every keymap to carry a `desc` (which `which-key` reads).
`buffer_map(bufnr, ...)` is the buffer-local variant, used for keymaps set
inside an LSP `on_attach` or similar.

## Adding a custom function / bigger custom module

Anything that's genuinely its own subsystem (not "one plugin's config",
not "a couple of keymaps") goes under `files/lua/config/<name>/`, as a real
`require()`-able module (`local M = {}`, ..., `return M` — unlike
`plugins/*.lua`, these files *are* meant to be required). See
`files/lua/config/debug/init.lua` for the shape: a small registry other
code calls into via `require("config.debug")`. Wire it up by calling
`require("config.<name>")` from wherever it's actually needed (a keymap,
another plugin's config, etc.) — it doesn't need to be listed anywhere
special, `self-lua.nix` already puts all of `files/lua/config/` on the
runtimepath.

## Adding an LSP server, formatter, linter, or debug adapter

These are plain Nix packages, not Neovim plugins:

- **LSP server / formatter / linter** → add the package to `packages.nix`.
  Then wire it into whichever plugin actually invokes it by name:
  - LSP servers: `files/lua/plugins/lsp.lua` (per-language `lspconfig`
    setup — the binary just needs to be on `$PATH`, which `packages.nix`
    already guarantees)
  - Formatters: `formatters_by_ft` in `files/lua/plugins/conform.lua`
  - Linters: the equivalent table in `files/lua/plugins/lint.lua`
- **Debug adapter / embedded toolchain** → `debug-packages.nix`, then wire
  it into `files/lua/config/debug/kinds/` (see `native.lua` /
  `openocd_remote.lua` for the existing pattern) or `files/lua/plugins/debug.lua`
  directly for simpler cases.

Formatting on save is a single tri-state cycle (`files/lua/plugins/conform.lua`),
bound to `<leader>uf`, buffer-local:

1. **All enabled** (default) — language formatters (the `formatters_by_ft`
   table above), LSP-fallback formatting (clangd's clang-format for C/C++,
   via `config/lsp/clangd.lua`), and trailing-whitespace trimming.
2. **Formatters disabled** — trailing-whitespace trimming still runs.
3. **Everything disabled** — no formatting at all on save.

Cycling again from state 3 goes back to state 1. `<leader>f` always runs a
manual format regardless of this toggle's state.

To opt a specific repo out permanently instead of toggling by hand every
session, drop a `.nvim.lua` in its root with `vim.b.format_state = 2`
— `options.lua` already sets `exrc = true`, so a trusted per-project file
like this runs automatically on open (`:trust` the first time you open
that directory).

## Applying changes

Same as the rest of this flake (see the top-level `README.md`):

```
git add -A                                   # new files must be staged
nix flake check --no-build
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
sudo nixos-rebuild switch --flake .#<host>
```

`<host>` is whichever of `nixos-laptop-gnome` / `nixos-laptop-kde` you're
currently running.
