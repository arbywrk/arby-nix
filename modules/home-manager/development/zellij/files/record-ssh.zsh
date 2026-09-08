# Records the most recent `ssh` invocation per zellij session to a small
# executable state file, so zellij-resume-ssh (bound to "Shift s" for
# new-pane/new-tab in development/zellij/default.nix) can reconnect to
# the same host there. This approximates "same place as the pane I'm
# looking at" -- it's actually "last ssh run anywhere in this zellij
# session", since zellij keybinds have no way to introspect which
# command a specific pane is currently running (would need a zellij
# plugin, not just a keybind, to do that properly).
if [[ -n $ZELLIJ_SESSION_NAME ]]; then
    ssh() {
        local state_file="${XDG_RUNTIME_DIR:-/tmp}/zellij-last-ssh-$ZELLIJ_SESSION_NAME"
        { print -r -- "#!/bin/sh"; print -r -- "exec ssh ${(q@)@}"; } >| "$state_file"
        chmod +x "$state_file"
        command ssh "$@"
    }
fi
