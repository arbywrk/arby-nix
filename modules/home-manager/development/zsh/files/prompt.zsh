# Hand-rolled prompt: cwd, git branch + dirty-file count, exit-status-colored
# arrow (green on success, red -- with the numeric code in RPROMPT -- on
# failure). Colors match the Ayu Dark Gray palette used everywhere else
# (ghostty.nix's theme, zellij's ayu-dark.kdl) so nvim/zellij/ghostty/zsh
# all agree.

setopt PROMPT_SUBST

_ayu_git_info() {
    local branch
    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || branch=$(git rev-parse --short HEAD 2>/dev/null)
    [[ -z $branch ]] && return

    local changes
    changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

    local out=" %F{#cda1fa}${branch}%f"
    [[ $changes -gt 0 ]] && out+=" %F{#ffb454}±${changes}%f"
    print -n "$out"
}

precmd() {
    ayu_git_info=$(_ayu_git_info)
}

PROMPT='%F{#59c2ff}%~%f${ayu_git_info} %(?.%F{#7fd962}.%F{#ea6c73})❯%f '
RPROMPT='%(?..%F{#ea6c73}✗ %?%f)'
