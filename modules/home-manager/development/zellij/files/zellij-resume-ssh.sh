# Reconnects to the most recent ssh target recorded in this zellij
# session (see development/zsh's ssh() wrapper, defined in
# development/zellij/files/record-ssh.zsh, for how it's recorded), or
# falls back to a plain shell if nothing was recorded yet. Bound to
# "Shift s" for new-pane/new-tab in development/zellij/default.nix.
state_file="${XDG_RUNTIME_DIR:-/tmp}/zellij-last-ssh-${ZELLIJ_SESSION_NAME:-none}"
if [ -x "$state_file" ]; then
    exec "$state_file"
fi
exec zsh
