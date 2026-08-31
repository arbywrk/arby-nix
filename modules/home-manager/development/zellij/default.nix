{ lib, ... }:
{
  programs.zellij = {
    enable = true;

    # Zellij falls back to $SHELL for new panes when this is unset, which
    # is fragile (stale login sessions, contexts where $SHELL isn't
    # propagated) -- pin it explicitly instead. mkDefault so other homes
    # importing this module can pick a different shell with a plain
    # assignment, no lib.mkForce needed.
    settings.default_shell = lib.mkDefault "zsh";

    # Every new session/pane starts locked -- zellij intercepts nothing
    # (besides Ctrl g to unlock) until you deliberately ask it to, so it
    # never fights zsh's or nvim's own keybinds by default. See the
    # `locked`/`shared_except "locked"` blocks below for what that means
    # in practice.
    settings.default_mode = "locked";

    # NOT "compact": compact-bar only ever renders the tab line -- its
    # keybind hints live behind a separate toggle-activated tooltip
    # overlay, not continuously visible. The default status-bar is the
    # same total height (1 line each for tab-bar/status-bar) and shows
    # the current mode's keybind hints inline at all times, which is
    # what's actually wanted while these binds aren't memorized yet.
    settings.pane_frames = false;
    settings.theme = "vague";

    # Full explicit keybinds, based on zellij's own stock defaults
    # (verified directly against `zellij setup --dump-config`, not
    # guessed) -- including its own multi-key-per-bind convention for
    # directional keys (e.g. `bind "h" "left" { MoveFocus "left"; }`
    # instead of two separate binds), used throughout below to avoid
    # duplicating every direction as arrow-key-bind-plus-hjkl-bind.
    #
    # Relocated (collided with blink.cmp/fzf-lua/nvim keymaps):
    #   Ctrl h (move mode)    -> Alt m  (Ctrl h needs to stay free to reach
    #                                    nvim while locked -- see below)
    #   Ctrl n (resize mode)  -> Alt r  (blink.cmp: next completion item)
    #   Ctrl p (pane mode)    -> Ctrl a (blink.cmp: prev completion item)
    #   Ctrl o (session mode) -> Alt u  (vim builtin: jumplist back)
    # Dropped entirely (tmux-compat mode, not a tmux user, its trigger
    # collided with blink.cmp/fzf-lua doc/preview scrolling):
    #   Ctrl b (tmux mode)
    #
    # Pane movement lives entirely under `pane` mode (Ctrl a to enter):
    # h/j/k/l move focus repeatedly with no auto-relock per press (unlike
    # most other binds in this config), then Enter/Esc/Ctrl a again
    # confirms and drops back to locked -- move around as much as needed,
    # confirm once. Same shape as tab navigation (Ctrl t enters `tab`
    # mode, h/j/k/l/1-9 navigate, back to locked once you land on one) --
    # deliberately not a single quick Ctrl+h/j/k/l keypress like it was
    # before. No direct global MoveFocus bind exists anymore. Ctrl
    # Shift h/j/k/l are unchanged -- still the direct one-shot shortcut
    # for MovePane (reorganize panes) without entering `move` mode, still
    # relocking after one move.
    #
    # No nvim-side integration for pane movement -- tried an
    # auto-lock-on-focus approach (nvim switching zellij into "locked"
    # while it had focus, so these binds would pass through to nvim's own
    # window-movement keymaps unintercepted) and a keystroke-forwarding
    # plugin (vim-zellij-navigator) before that; both removed. Zellij's
    # "locked" mode has no concept of "which pane is focused" -- it's one
    # global state -- so having it serve as both "the default resting
    # state for every pane" and "specifically don't intercept these keys
    # while nvim has focus" fought itself: unlocking anywhere (e.g. to
    # move panes from a shell) then landing back on an nvim pane while
    # still unlocked would intercept Ctrl h/j/k/l before nvim ever saw
    # them, same problem as before. Cost of not having any integration:
    # zsh's own Ctrl+H (backspace)/Ctrl+K (kill-line)/Ctrl+L
    # (clear-screen) are unavailable while unlocked in a non-vim pane --
    # same tradeoff any global bind on these keys would have anyway.
    #
    # "locked" is the resting state (default_mode above), and stays
    # resting: every `SwitchToMode "normal"` below that means "action
    # done, go idle" targets "locked" instead of "normal" -- so finishing
    # any single zellij action (new pane, go to tab N, resize, ...) drops
    # straight back to locked, and Ctrl g has to be pressed again before
    # the next one. The one deliberate exception is the unlock action
    # itself (`locked { bind "Ctrl g" { SwitchToMode "normal"; } }`) --
    # that one has to stay targeting "normal", it's the only way to
    # unlock at all. Nothing else was added to the `locked` context this
    # round (only Ctrl g) -- revisit later if more is wanted there.
    # Untouched (no conflict found): scroll (Ctrl s), tab (Ctrl t),
    # quit (Ctrl q).
    extraConfig = ''
      keybinds clear-defaults=true {
          locked {
              bind "Ctrl g" { SwitchToMode "normal"; }
          }
          pane {
              bind "h" "left" { MoveFocus "left"; }
              bind "j" "down" { MoveFocus "down"; }
              bind "k" "up" { MoveFocus "up"; }
              bind "l" "right" { MoveFocus "right"; }
              bind "c" { SwitchToMode "renamepane"; PaneNameInput 0; }
              bind "d" { NewPane "down"; SwitchToMode "locked"; }
              bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "locked"; }
              bind "f" { ToggleFocusFullscreen; SwitchToMode "locked"; }
              bind "i" { TogglePanePinned; SwitchToMode "locked"; }
              bind "n" { NewPane; SwitchToMode "locked"; }
              bind "p" { SwitchFocus; }
              bind "Ctrl a" { SwitchToMode "locked"; }
              bind "r" { NewPane "right"; SwitchToMode "locked"; }
              bind "s" { NewPane "stacked"; SwitchToMode "locked"; }
              bind "w" { ToggleFloatingPanes; SwitchToMode "locked"; }
              bind "x" { CloseFocus; SwitchToMode "locked"; }
              bind "z" { TogglePaneFrames; SwitchToMode "locked"; }
          }
          tab {
              bind "h" "left" "up" "k" { GoToPreviousTab; }
              bind "l" "right" "down" "j" { GoToNextTab; }
              bind "1" { GoToTab 1; SwitchToMode "locked"; }
              bind "2" { GoToTab 2; SwitchToMode "locked"; }
              bind "3" { GoToTab 3; SwitchToMode "locked"; }
              bind "4" { GoToTab 4; SwitchToMode "locked"; }
              bind "5" { GoToTab 5; SwitchToMode "locked"; }
              bind "6" { GoToTab 6; SwitchToMode "locked"; }
              bind "7" { GoToTab 7; SwitchToMode "locked"; }
              bind "8" { GoToTab 8; SwitchToMode "locked"; }
              bind "9" { GoToTab 9; SwitchToMode "locked"; }
              bind "[" { BreakPaneLeft; SwitchToMode "locked"; }
              bind "]" { BreakPaneRight; SwitchToMode "locked"; }
              bind "b" { BreakPane; SwitchToMode "locked"; }
              bind "n" { NewTab; SwitchToMode "locked"; }
              bind "r" { SwitchToMode "renametab"; TabNameInput 0; }
              bind "s" { ToggleActiveSyncTab; SwitchToMode "locked"; }
              bind "Ctrl t" { SwitchToMode "locked"; }
              bind "x" { CloseTab; SwitchToMode "locked"; }
              bind "tab" { ToggleTab; }
          }
          resize {
              bind "h" "left" { Resize "Increase left"; }
              bind "j" "down" { Resize "Increase down"; }
              bind "k" "up" { Resize "Increase up"; }
              bind "l" "right" { Resize "Increase right"; }
              bind "+" { Resize "Increase"; }
              bind "-" { Resize "Decrease"; }
              bind "=" { Resize "Increase"; }
              bind "H" { Resize "Decrease left"; }
              bind "J" { Resize "Decrease down"; }
              bind "K" { Resize "Decrease up"; }
              bind "L" { Resize "Decrease right"; }
              bind "Alt r" { SwitchToMode "locked"; }
          }
          move {
              bind "h" "left" { MovePane "left"; }
              bind "j" "down" { MovePane "down"; }
              bind "k" "up" { MovePane "up"; }
              bind "l" "right" { MovePane "right"; }
              bind "Alt m" { SwitchToMode "locked"; }
              bind "n" { MovePane; }
              bind "p" { MovePaneBackwards; }
              bind "tab" { MovePane; }
          }
          scroll {
              bind "e" { EditScrollback; SwitchToMode "locked"; }
              bind "s" { SwitchToMode "entersearch"; SearchInput 0; }
          }
          search {
              bind "c" { SearchToggleOption "CaseSensitivity"; }
              bind "n" { Search "down"; }
              bind "o" { SearchToggleOption "WholeWord"; }
              bind "p" { Search "up"; }
              bind "w" { SearchToggleOption "Wrap"; }
          }
          session {
              bind "a" {
                  LaunchOrFocusPlugin "zellij:about" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "locked"
              }
              bind "c" {
                  LaunchOrFocusPlugin "configuration" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "locked"
              }
              bind "l" {
                  LaunchOrFocusPlugin "zellij:layout-manager" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "locked"
              }
              bind "Alt u" { SwitchToMode "locked"; }
              bind "p" {
                  LaunchOrFocusPlugin "plugin-manager" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "locked"
              }
              bind "s" {
                  LaunchOrFocusPlugin "zellij:share" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "locked"
              }
              bind "w" {
                  LaunchOrFocusPlugin "session-manager" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "locked"
              }
              bind "d" { Detach; }
          }
          shared_except "locked" {
              bind "Alt left" { MoveFocusOrTab "left"; }
              bind "Alt down" { MoveFocus "down"; }
              bind "Alt up" { MoveFocus "up"; }
              bind "Alt right" { MoveFocusOrTab "right"; }
              bind "Alt +" { Resize "Increase"; }
              bind "Alt -" { Resize "Decrease"; }
              bind "Alt =" { Resize "Increase"; }
              bind "Alt [" { PreviousSwapLayout; }
              bind "Alt ]" { NextSwapLayout; }
              bind "Alt f" { ToggleFloatingPanes; }
              bind "Ctrl g" { SwitchToMode "locked"; }
              bind "Alt h" { MoveFocusOrTab "left"; }
              bind "Alt i" { MoveTab "left"; }
              bind "Alt j" { MoveFocus "down"; }
              bind "Alt k" { MoveFocus "up"; }
              bind "Alt l" { MoveFocusOrTab "right"; }
              bind "Alt n" { NewPane; }
              bind "Alt o" { MoveTab "right"; }
              bind "Alt p" { TogglePaneInGroup; }
              bind "Alt Shift p" { ToggleGroupMarking; }
              bind "Ctrl Shift q" { Quit; }
              bind "Ctrl Shift h" { MovePane "left"; SwitchToMode "locked"; }
              bind "Ctrl Shift j" { MovePane "down"; SwitchToMode "locked"; }
              bind "Ctrl Shift k" { MovePane "up"; SwitchToMode "locked"; }
              bind "Ctrl Shift l" { MovePane "right"; SwitchToMode "locked"; }
          }
          shared_except "locked" "move" {
              bind "Alt m" { SwitchToMode "move"; }
          }
          shared_except "locked" "session" {
              bind "Alt u" { SwitchToMode "session"; }
          }
          shared_except "locked" "scroll" "search" {
              bind "Ctrl s" { SwitchToMode "scroll"; }
              // Excludes scroll/search specifically because both already
              // bind Ctrl f to PageScrollDown (shared_among "scroll"
              // "search" below) -- keeping this out of those two modes is
              // what avoids the collision, not any implicit precedence.
              bind "Ctrl f" { ToggleFloatingPanes; SwitchToMode "locked"; }
          }
          shared_except "locked" "tab" {
              bind "Ctrl t" { SwitchToMode "tab"; }
          }
          shared_except "locked" "pane" {
              bind "Ctrl a" { SwitchToMode "pane"; }
          }
          shared_except "locked" "resize" {
              bind "Alt r" { SwitchToMode "resize"; }
          }
          shared_except "normal" "locked" "entersearch" {
              bind "enter" { SwitchToMode "locked"; }
          }
          shared_except "normal" "locked" "entersearch" "renametab" "renamepane" {
              bind "esc" { SwitchToMode "locked"; }
          }
          shared_among "scroll" "search" {
              bind "h" "left" "Ctrl b" "PageUp" { PageScrollUp; }
              bind "l" "right" "Ctrl f" "PageDown" { PageScrollDown; }
              bind "j" "down" { ScrollDown; }
              bind "k" "up" { ScrollUp; }
              bind "Ctrl c" { ScrollToBottom; SwitchToMode "locked"; }
              bind "d" { HalfPageScrollDown; }
              bind "Ctrl s" { SwitchToMode "locked"; }
              bind "u" { HalfPageScrollUp; }
          }
          entersearch {
              bind "Ctrl c" { SwitchToMode "scroll"; }
              bind "esc" { SwitchToMode "scroll"; }
              bind "enter" { SwitchToMode "search"; }
          }
          renametab {
              bind "esc" { UndoRenameTab; SwitchToMode "tab"; }
          }
          shared_among "renametab" "renamepane" {
              bind "Ctrl c" { SwitchToMode "locked"; }
          }
          renamepane {
              bind "esc" { UndoRenamePane; SwitchToMode "pane"; }
          }
      }
    '';
  };

  xdg.configFile."zellij/themes/vague.kdl".source = ./files/themes/vague.kdl;
}
