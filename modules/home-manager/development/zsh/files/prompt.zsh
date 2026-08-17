# Hand-rolled prompt: cwd, git branch + dirty-file count, exit-status-colored
# arrow (green on success, red -- with the numeric code in RPROMPT -- on
# failure). Colors match this repo's vague palette (neovim's colorscheme.lua
# / zellij's vague.kdl) so nvim/zellij/zsh all agree.

setopt PROMPT_SUBST

_vague_git_info() {
    local branch
    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || branch=$(git rev-parse --short HEAD 2>/dev/null)
    [[ -z $branch ]] && return

    local changes
    changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

    local out=" %F{#bb9dbd}${branch}%f"
    [[ $changes -gt 0 ]] && out+=" %F{#f3be7c}±${changes}%f"
    print -n "$out"
}

precmd() {
    vague_git_info=$(_vague_git_info)
}

PROMPT='%F{#7e98e8}%~%f${vague_git_info} %(?.%F{#7fa563}.%F{#d8647e})❯%f '
RPROMPT='%(?..%F{#d8647e}✗ %?%f)'
