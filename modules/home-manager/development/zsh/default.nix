# Highlight colors come from stylix's palette, following base16's roles
# (base0E keywords, base0D functions, base0B strings, ...).
{ pkgs, config, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
in
{
  programs.zsh = {
    enable = true;

    # Start prompts in insert mode; Esc drops to vi command mode.
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
      highlight = "fg=${c.base03}";
    };

    syntaxHighlighting = {
      enable = true;
      styles = {
        default = "fg=${c.base05}";
        comment = "fg=${c.base03}";
        unknown-token = "fg=${c.base08},bold";
        reserved-word = "fg=${c.base0E}";
        arg0 = "fg=${c.base0D}";
        precommand = "fg=${c.base0D},italic";
        path = "fg=${c.base0C},underline";
        globbing = "fg=${c.base09}";
        history-expansion = "fg=${c.base09}";
        redirection = "fg=${c.base0C}";
        assign = "fg=${c.base05}";
        single-hyphen-option = "fg=${c.base0A}";
        double-hyphen-option = "fg=${c.base0A}";
        single-quoted-argument = "fg=${c.base0B}";
        double-quoted-argument = "fg=${c.base0B}";
        dollar-quoted-argument = "fg=${c.base0B}";
        back-quoted-argument = "fg=${c.base0B}";
      };
    };

    # Default order lands between autosuggestion and syntaxHighlighting,
    # the slot for widget-creating plugins, so highlighting wraps them.
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
