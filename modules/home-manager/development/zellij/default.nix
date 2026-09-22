{ pkgs, lib, ... }:
let
  # Reconnects to the last ssh target run in this zellij session; bound
  # to "Shift s" below. See files/record-ssh.zsh for how it's recorded.
  resumeSsh = pkgs.writeShellScriptBin "zellij-resume-ssh" (
    builtins.readFile ./files/zellij-resume-ssh.sh
  );
in
{
  home.packages = [ resumeSsh ];

  # The ssh() wrapper that records each ssh invocation for
  # zellij-resume-ssh to pick back up -- lives here (not
  # development/zsh) since it's meaningless outside a zellij session.
  programs.zsh.initContent = builtins.readFile ./files/record-ssh.zsh;

  programs.zellij = {
    enable = true;

    # $SHELL fallback is fragile (stale login sessions, unset in some
    # contexts) -- pin explicitly. mkDefault lets other homes override it.
    settings.default_shell = lib.mkDefault "zsh";

    # Every new session/pane starts locked -- zellij intercepts nothing
    # (besides Ctrl g to unlock) until asked to, so it never fights zsh's
    # or nvim's own keybinds by default. See the `locked`/`shared_except
    # "locked"` blocks below for what that means in practice.
    settings.default_mode = "locked";

    # Default status-bar, not compact-bar -- shows the current mode's
    # keybind hints inline at all times instead of behind a toggle.
    settings.pane_frames = false;
    settings.theme = "ayu-dark";

    # Full explicit keybinds, based on zellij's stock defaults. Notes on
    # what's non-obvious below; everything else follows zellij's own
    # mode/action names directly.
    #
    # Relocated (collided with nvim/blink.cmp/fzf-lua keymaps):
    #   Ctrl h (move)    -> Alt m   (Ctrl h must stay free to reach nvim)
    #   Ctrl n (resize)  -> Alt r   (blink.cmp: next completion item)
    #   Ctrl p (pane)    -> Ctrl a  (blink.cmp: prev completion item)
    #   Ctrl o (session) -> Alt u   (vim builtin: jumplist back)
    # Dropped: Ctrl b (tmux-compat mode, unused, collided with scrolling).
    #
    # Pane/tab movement (`pane`/`tab` mode, entered via Ctrl a/Ctrl t):
    # h/j/k/l move focus repeatedly without relocking, then Enter/Esc/the
    # mode key again confirms back to locked. No nvim-side integration
    # for this exists -- an auto-lock-on-focus approach and a
    # keystroke-forwarding plugin were both tried and dropped; zellij's
    # "locked" is one global state with no per-pane awareness, so it
    # can't reliably tell "nvim has focus" from "just unlocked elsewhere".
    #
    # "locked" (default_mode above) is the resting state throughout: every
    # action-complete `SwitchToMode` below targets "locked", not "normal"
    # -- Ctrl g (the one bind that targets "normal") is what unlocks.
    # Quit is Ctrl Shift q, not stock Ctrl q, so muscle-memory Ctrl q from
    # another program can't kill the session by accident.
    #
    # "Shift s" (pane/tab mode): new pane/tab reconnecting to the most
    # recent ssh target run anywhere in *this* zellij session -- see
    # files/record-ssh.zsh (records it) and files/zellij-resume-ssh.sh
    # (reconnects). mosh (development/mosh) covers the same "keep remote
    # sessions alive" need for connections started directly, not via this.
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
              bind "Shift s" { Run "zellij-resume-ssh"; SwitchToMode "locked"; }
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
              bind "Shift s" {
                  NewTab {
                      layout "${./files/layouts/resume-ssh.kdl}"
                  }
                  SwitchToMode "locked"
              }
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
              // scroll/search excluded: both already bind Ctrl f to
              // PageScrollDown (shared_among "scroll" "search" below).
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
          shared_except "locked" "entersearch" "renametab" "renamepane" {
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

  xdg.configFile."zellij/themes/ayu-dark.kdl".source = ./files/themes/ayu-dark.kdl;
}
