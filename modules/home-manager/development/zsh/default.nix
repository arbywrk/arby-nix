# Autosuggestion/syntaxHighlighting colors use the same Ayu Dark Gray
# palette as ghostty.nix, zellij's theme and ../starship.nix.
{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;

    # Start each prompt in insert mode (typing works like normal, Esc
    # drops to vi command mode) rather than "vicmd" (command mode first).
    defaultKeymap = "viins";

    # Not shared live: with share on, every multiplexer pane imports the
    # others' commands, mixing up-arrow history. Each command is still
    # written immediately, so new shells see everything (`fc -RI` pulls
    # it into an open one).
    history = {
      share = false;
      extended = true; # INC_APPEND_HISTORY_TIME needs timestamps
    };
    setOptions = [ "INC_APPEND_HISTORY_TIME" ];

    autosuggestion = {
      enable = true;
      highlight = "fg=#686868"; # ayu comment/muted gray
    };

    syntaxHighlighting = {
      enable = true;
      styles = {
        default = "fg=#bfbdb6";
        comment = "fg=#686868";
        unknown-token = "fg=#ea6c73,bold";
        reserved-word = "fg=#53bdfa";
        arg0 = "fg=#7fd962";
        precommand = "fg=#53bdfa,italic";
        path = "fg=#95e6cb,underline";
        globbing = "fg=#cda1fa";
        history-expansion = "fg=#cda1fa";
        redirection = "fg=#90e1c6";
        assign = "fg=#c7c7c7";
        single-hyphen-option = "fg=#ffb454";
        double-hyphen-option = "fg=#ffb454";
        single-quoted-argument = "fg=#f9af4f";
        double-quoted-argument = "fg=#f9af4f";
        dollar-quoted-argument = "fg=#f9af4f";
        back-quoted-argument = "fg=#f9af4f";
      };
    };

    # Default mkOrder (1000) lands this between autosuggestion (700) and
    # syntaxHighlighting (1200) -- the slot home-manager reserves for
    # widget-creating plugins, so highlighting wraps them correctly.
    initContent = ''
      source ${pkgs.zsh-history-substring-search}/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
      # Arrows send ^[[A normally and $terminfo[kcuu1] (^[OA) in
      # application mode, so bind both; vi-mode k/j match the arrows.
      for keymap in viins vicmd; do
        bindkey -M $keymap '^[[A' history-substring-search-up
        bindkey -M $keymap '^[[B' history-substring-search-down
        bindkey -M $keymap "$terminfo[kcuu1]" history-substring-search-up
        bindkey -M $keymap "$terminfo[kcud1]" history-substring-search-down
      done
      bindkey -M vicmd k history-substring-search-up
      bindkey -M vicmd j history-substring-search-down
    '';
  };
}
