{ lib, pkgs, ... }:
let
  # Detects whether the focused pane is running vim/nvim before deciding
  # whether to forward the raw keystroke (letting smart-splits.nvim handle
  # its own internal split-navigation, unmodified) or move zellij's own
  # pane focus directly. This is what makes Ctrl h/j/k/l work bidirectionally
  # -- into AND out of nvim -- without zellij's static keybinds ever having
  # to guess: https://github.com/hiasr/vim-zellij-navigator
  vimZellijNavigator = "file:${pkgs.zellijPlugins.vim-zellij-navigator}";
in
{
  programs.zellij = {
    enable = true;

    # Zellij falls back to $SHELL for new panes when this is unset, which
    # is fragile (stale login sessions, contexts where $SHELL isn't
    # propagated) -- pin it explicitly instead. mkDefault so other homes
    # importing this module can pick a different shell with a plain
    # assignment, no lib.mkForce needed.
    settings.default_shell = lib.mkDefault "zsh";

    # NOT "compact": compact-bar only ever renders the tab line -- its
    # keybind hints live behind a separate toggle-activated tooltip
    # overlay, not continuously visible. The default status-bar is the
    # same total height (1 line each for tab-bar/status-bar) and shows
    # the current mode's keybind hints inline at all times, which is
    # what's actually wanted while these binds aren't memorized yet.
    settings.pane_frames = false;
    settings.theme = "vague";

    # Full explicit keybinds, based on zellij's own stock defaults (not
    # scoped `unbind` inside shared_except contexts -- fragile to get
    # right without a live session to test against). Only the mode-entry
    # triggers that collide with this config's actual nvim/completion
    # keymaps are relocated; everything else is verbatim stock behavior.
    #
    # Relocated (collided with blink.cmp/fzf-lua/nvim keymaps):
    #   Ctrl h (move mode)    -> Alt m  (Ctrl h now routed through vim-zellij-navigator)
    #   Ctrl n (resize mode)  -> Alt r  (blink.cmp: next completion item)
    #   Ctrl p (pane mode)    -> Alt a  (blink.cmp: prev completion item)
    #   Ctrl o (session mode) -> Alt u  (vim builtin: jumplist back)
    # Dropped entirely (tmux-compat mode, not a tmux user, its trigger
    # collided with blink.cmp/fzf-lua doc/preview scrolling):
    #   Ctrl b (tmux mode)
    # Ctrl h/j/k/l are bound globally (shared_except "locked") to
    # vim-zellij-navigator: it detects whether the focused pane is
    # running vim/nvim and either forwards the raw keystroke (letting
    # smart-splits.nvim's own internal split-navigation handle it,
    # unmodified) or moves zellij's pane focus directly. Cost: in any
    # NON-vim pane (shell included), these keys never reach the program
    # underneath -- zsh's own Ctrl+H (backspace)/Ctrl+K (kill-line)/
    # Ctrl+L (clear-screen) are unavailable, same tradeoff as a global
    # bind would have anyway, just correctly scoped to spare nvim.
    # Untouched (no conflict found): locked (Ctrl g), scroll (Ctrl s),
    # tab (Ctrl t), quit (Ctrl q).
    extraConfig = ''
      keybinds clear-defaults=true {
          locked {
              bind "Ctrl g" { SwitchToMode "normal"; }
          }
          pane {
              bind "left" { MoveFocus "left"; }
              bind "down" { MoveFocus "down"; }
              bind "up" { MoveFocus "up"; }
              bind "right" { MoveFocus "right"; }
              bind "c" { SwitchToMode "renamepane"; PaneNameInput 0; }
              bind "d" { NewPane "down"; SwitchToMode "normal"; }
              bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "normal"; }
              bind "f" { ToggleFocusFullscreen; SwitchToMode "normal"; }
              bind "h" { MoveFocus "left"; }
              bind "i" { TogglePanePinned; SwitchToMode "normal"; }
              bind "j" { MoveFocus "down"; }
              bind "k" { MoveFocus "up"; }
              bind "l" { MoveFocus "right"; }
              bind "n" { NewPane; SwitchToMode "normal"; }
              bind "p" { SwitchFocus; }
              bind "Alt a" { SwitchToMode "normal"; }
              bind "r" { NewPane "right"; SwitchToMode "normal"; }
              bind "s" { NewPane "stacked"; SwitchToMode "normal"; }
              bind "w" { ToggleFloatingPanes; SwitchToMode "normal"; }
              bind "x" { CloseFocus; SwitchToMode "normal"; }
              bind "z" { TogglePaneFrames; SwitchToMode "normal"; }
          }
          tab {
              bind "left" { GoToPreviousTab; }
              bind "down" { GoToNextTab; }
              bind "up" { GoToPreviousTab; }
              bind "right" { GoToNextTab; }
              bind "1" { GoToTab 1; SwitchToMode "normal"; }
              bind "2" { GoToTab 2; SwitchToMode "normal"; }
              bind "3" { GoToTab 3; SwitchToMode "normal"; }
              bind "4" { GoToTab 4; SwitchToMode "normal"; }
              bind "5" { GoToTab 5; SwitchToMode "normal"; }
              bind "6" { GoToTab 6; SwitchToMode "normal"; }
              bind "7" { GoToTab 7; SwitchToMode "normal"; }
              bind "8" { GoToTab 8; SwitchToMode "normal"; }
              bind "9" { GoToTab 9; SwitchToMode "normal"; }
              bind "[" { BreakPaneLeft; SwitchToMode "normal"; }
              bind "]" { BreakPaneRight; SwitchToMode "normal"; }
              bind "b" { BreakPane; SwitchToMode "normal"; }
              bind "h" { GoToPreviousTab; }
              bind "j" { GoToNextTab; }
              bind "k" { GoToPreviousTab; }
              bind "l" { GoToNextTab; }
              bind "n" { NewTab; SwitchToMode "normal"; }
              bind "r" { SwitchToMode "renametab"; TabNameInput 0; }
              bind "s" { ToggleActiveSyncTab; SwitchToMode "normal"; }
              bind "Ctrl t" { SwitchToMode "normal"; }
              bind "x" { CloseTab; SwitchToMode "normal"; }
              bind "tab" { ToggleTab; }
          }
          resize {
              bind "left" { Resize "Increase left"; }
              bind "down" { Resize "Increase down"; }
              bind "up" { Resize "Increase up"; }
              bind "right" { Resize "Increase right"; }
              bind "+" { Resize "Increase"; }
              bind "-" { Resize "Decrease"; }
              bind "=" { Resize "Increase"; }
              bind "H" { Resize "Decrease left"; }
              bind "J" { Resize "Decrease down"; }
              bind "K" { Resize "Decrease up"; }
              bind "L" { Resize "Decrease right"; }
              bind "h" { Resize "Increase left"; }
              bind "j" { Resize "Increase down"; }
              bind "k" { Resize "Increase up"; }
              bind "l" { Resize "Increase right"; }
              bind "Alt r" { SwitchToMode "normal"; }
          }
          move {
              bind "left" { MovePane "left"; }
              bind "down" { MovePane "down"; }
              bind "up" { MovePane "up"; }
              bind "right" { MovePane "right"; }
              bind "h" { MovePane "left"; }
              bind "Alt m" { SwitchToMode "normal"; }
              bind "j" { MovePane "down"; }
              bind "k" { MovePane "up"; }
              bind "l" { MovePane "right"; }
              bind "n" { MovePane; }
              bind "p" { MovePaneBackwards; }
              bind "tab" { MovePane; }
          }
          scroll {
              bind "e" { EditScrollback; SwitchToMode "normal"; }
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
                  SwitchToMode "normal"
              }
              bind "c" {
                  LaunchOrFocusPlugin "configuration" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
              }
              bind "l" {
                  LaunchOrFocusPlugin "zellij:layout-manager" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
              }
              bind "Alt u" { SwitchToMode "normal"; }
              bind "p" {
                  LaunchOrFocusPlugin "plugin-manager" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
              }
              bind "s" {
                  LaunchOrFocusPlugin "zellij:share" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
              }
              bind "w" {
                  LaunchOrFocusPlugin "session-manager" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
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
              bind "Ctrl q" { Quit; }
              bind "Ctrl h" {
                  MessagePlugin "${vimZellijNavigator}" {
                      name "move_focus_or_tab"
                      payload "left"
                      move_mod "ctrl"
                  }
              }
              bind "Ctrl j" {
                  MessagePlugin "${vimZellijNavigator}" {
                      name "move_focus"
                      payload "down"
                      move_mod "ctrl"
                  }
              }
              bind "Ctrl k" {
                  MessagePlugin "${vimZellijNavigator}" {
                      name "move_focus"
                      payload "up"
                      move_mod "ctrl"
                  }
              }
              bind "Ctrl l" {
                  MessagePlugin "${vimZellijNavigator}" {
                      name "move_focus_or_tab"
                      payload "right"
                      move_mod "ctrl"
                  }
              }
          }
          shared_except "locked" "move" {
              bind "Alt m" { SwitchToMode "move"; }
          }
          shared_except "locked" "session" {
              bind "Alt u" { SwitchToMode "session"; }
          }
          shared_except "locked" "scroll" "search" {
              bind "Ctrl s" { SwitchToMode "scroll"; }
          }
          shared_except "locked" "tab" {
              bind "Ctrl t" { SwitchToMode "tab"; }
          }
          shared_except "locked" "pane" {
              bind "Alt a" { SwitchToMode "pane"; }
          }
          shared_except "locked" "resize" {
              bind "Alt r" { SwitchToMode "resize"; }
          }
          shared_except "normal" "locked" "entersearch" {
              bind "enter" { SwitchToMode "normal"; }
          }
          shared_except "normal" "locked" "entersearch" "renametab" "renamepane" {
              bind "esc" { SwitchToMode "normal"; }
          }
          shared_among "scroll" "search" {
              bind "PageDown" { PageScrollDown; }
              bind "PageUp" { PageScrollUp; }
              bind "left" { PageScrollUp; }
              bind "down" { ScrollDown; }
              bind "up" { ScrollUp; }
              bind "right" { PageScrollDown; }
              bind "Ctrl b" { PageScrollUp; }
              bind "Ctrl c" { ScrollToBottom; SwitchToMode "normal"; }
              bind "d" { HalfPageScrollDown; }
              bind "Ctrl f" { PageScrollDown; }
              bind "h" { PageScrollUp; }
              bind "j" { ScrollDown; }
              bind "k" { ScrollUp; }
              bind "l" { PageScrollDown; }
              bind "Ctrl s" { SwitchToMode "normal"; }
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
              bind "Ctrl c" { SwitchToMode "normal"; }
          }
          renamepane {
              bind "esc" { UndoRenamePane; SwitchToMode "pane"; }
          }
      }
    '';
  };

  xdg.configFile."zellij/themes/vague.kdl".source = ./files/themes/vague.kdl;
}
