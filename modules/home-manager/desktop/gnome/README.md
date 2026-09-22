# GNOME module: `default.nix` vs `custom.nix`

This module ships two GNOME flavors that share one functional base:

- **`default.nix`** — stock-look GNOME. No shell theme, no icon/cursor
  swap beyond MoreWaita (see below), no libadwaita color overrides. Just
  the things that make vanilla GNOME actually usable day to day:
  keybindings, a couple of small extensions, and the apps needed to
  replace what `services.gnome.core-apps.enable = false`
  (`modules/nixos/desktop/gnome.nix`) strips out.
- **`custom.nix`** — `imports = [ ./default.nix ]` and layers a from-scratch
  dark, Yaru-esque cosmetic pass on top: Papirus icons, Bibata cursor,
  hand-tuned libadwaita/GTK3 colors, a custom GNOME Shell stylesheet
  (`files/gnome-shell/*.css`), and the two extensions that support all of
  that (`user-theme`, and a tiny local `hide-dark-style` extension that
  hides the now-pointless Dark Style toggle).

Two home-manager profiles wire these up: `home/arby/gnome.nix` (default)
and `home/arby/gnome-custom.nix` (custom), each also exposed as a
standalone flake target (`homeConfigurations.gnome` /
`.gnome-custom`) for iterating without a full `nixos-rebuild`:

```
home-manager switch --flake .#gnome          # stock look
home-manager switch --flake .#gnome-custom   # themed look
```

The actual NixOS host (`hosts/nixos/default.nix`) picks one via
`home-manager.users."arby" = import ../../home/arby/gnome.nix;` — swap
the import path to switch which one the real machine runs. It currently
points at the **default** (stock) profile.

## Why the split, and where things went

This used to be one file (`gnome.nix`) with everything mixed together,
including the `dash-to-dock` extension (now removed entirely — vanilla
GNOME's own Activities-overview dash is used instead, in both flavors).
Splitting it was about being able to answer "is this GNOME behaving
differently because of the theme, or because of something else?" without
reading 400 lines of CSS-adjacent nix to find out.

The dividing line: **would a plain, unthemed GNOME still want this?**

| Goes in `default.nix` (functional) | Goes in `custom.nix` (cosmetic) |
| --- | --- |
| Workspace switch/move keybindings, freeing `Super+1..9` from the app launcher | `gtk.colorScheme`, all `gtk3.extraCss`/`gtk4.extraCss` |
| `caffeine` extension + its keybinding | GNOME Shell theme CSS (`files/gnome-shell/*.css`), `user-theme` extension |
| The "Office" app-folder grouping LibreOffice/OnlyOffice/Collabora | `hide-dark-style` local extension |
| Apps that replace what `core-apps.enable = false` removed (Loupe, Papers, Calendar, Endeavour, Resources) | Papirus icon theme, Bibata cursor theme |
| Bazaar (Flatpak app store) and Fastmail (Flatpak) | `wm/preferences` `button-layout` (hides the CSD app icon) |
| MoreWaita icon theme (see below) | `accent-color` |

### A few things that needed `lib.mkForce`

`dconf.settings` leaf values are single GVariants, not lists — when
`custom.nix` wants to override a key `default.nix` already set (icon
theme, the extensions list), it can't just reassign it the normal way;
that's a "conflicting definition" eval error. Instead those specific
keys use `lib.mkForce` in `custom.nix` to win outright:

- `org/gnome/shell` `enabled-extensions` — `default.nix` sets
  `[ "caffeine@patapon.info" ]`; `custom.nix` forces its own longer list
  (caffeine + user-theme + hide-dark-style) on top.
- `org/gnome/desktop/interface` `icon-theme`, and `gtk.iconTheme.name`/
  `.package` — `default.nix` sets MoreWaita; `custom.nix` forces Papirus
  instead.

Everything else either lives in only one of the two files, or is a
mergeable type (`home.packages`, most `xdg.dataFile` entries) that
combines automatically across the `imports`.

## Icon theme: MoreWaita

Stock Adwaita only ships icons for GNOME's own apps — everything else
(Signal, Obsidian, Brave, ...) falls back to a generic icon. MoreWaita is
Adwaita plus a large set of extra app icons drawn in the same style, so
`default.nix` uses it as the baseline: it stays visually "default GNOME"
while actually covering what's installed. `custom.nix` overrides this to
Papirus, its own distinct icon aesthetic.

## New apps (this pass)

All added to `default.nix` since they're functional, not cosmetic —
they'll show up in either flavor:

- **Loupe** — image viewer (replaces the one `core-apps.enable = false` removed).
- **Papers** — GNOME's document viewer, the renamed/rebranded Evince.
- **GNOME Calendar**, **Endeavour** (GNOME's own to-do/task manager).
- **Resources** — GNOME's Rust system monitor, `gnome-system-monitor`'s replacement.
- **Bazaar** — a Flathub-first GNOME app store, for anything not worth a
  nixpkgs entry in this repo. Needs `services.flatpak.enable`
  (`modules/nixos/desktop/gnome.nix`) to actually install/run Flatpaks.
- **Fastmail** — installed as its official Flatpak (`com.fastmail.Fastmail`,
  from Flathub) via `services.flatpak`, rather than a nixpkgs package (none
  exists) or a Brave app-mode wrapper.

Office-suite apps (LibreOffice/OnlyOffice/Collabora, and the "Office"
app-folder that groups them) live in `home/arby/default.nix` and this
module respectively — see that file's own comments; unrelated to this
default/custom split.

## GNOME version

`flake.lock`'s `nixpkgs` input is pinned to nixos-unstable as of
2026-09-22. As of that commit, nixpkgs packages **GNOME 50.x**
(`gnome-shell` 50.4) across the board — **GNOME 51 is not in nixpkgs
yet**, so "GNOME 51" here isn't achievable by bumping the flake input
alone; it'll arrive automatically in a future `nix flake update nixpkgs`
once nixpkgs itself packages it. The one exception: GNOME Circle apps
version independently of the shell, so **Resources** above is already at
`51.0`.

## Trying this out / switching back

Extension enable/disable and shell-theme changes need GNOME Shell to
reload to fully take effect — on Wayland that means logging out and back
in (Alt+F2 `r` only reloads on X11 sessions). A `home-manager switch`
alone will write the new dconf/package state immediately, but the shell
itself may still look stale until the next login.
