# Autosuggestion/syntaxHighlighting colors and files/prompt.zsh are all
# pulled from the Ayu Dark Gray palette (see ghostty.nix's theme / zellij's
# ayu-dark.kdl -- same hex values everywhere, so nvim/zellij/ghostty/zsh
# agree). history-substring-search has no dedicated home-manager option
# (unlike autosuggestion/syntaxHighlighting), so it's sourced by hand.
{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;

    # "viins" (not "vicmd"): start each prompt in insert mode -- typing
    # works like normal, Esc drops into vi command mode for editing. The
    # other option, "vicmd", would start every prompt in command mode
    # instead, which is the wrong default for a shell you're constantly
    # typing into.
    defaultKeymap = "viins";

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

    # Lands at initContent's default mkOrder (1000) -- after autosuggestion
    # (700) but before syntaxHighlighting (1200), same slot home-manager
    # itself uses for widget-creating plugins so highlighting wraps them
    # correctly (its own comment: "load zsh-syntax-highlighting after all
    # custom widgets have been created").
    initContent = ''
      source ${pkgs.zsh-history-substring-search}/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
      bindkey "$terminfo[kcuu1]" history-substring-search-up
      bindkey "$terminfo[kcud1]" history-substring-search-down

      ${builtins.readFile ./files/prompt.zsh}
    '';
  };
}
