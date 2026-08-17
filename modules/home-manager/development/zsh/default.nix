# Autosuggestion/syntaxHighlighting colors and files/prompt.zsh are all
# pulled from this repo's vague palette (see neovim's colorscheme.lua /
# zellij's vague.kdl -- same hex values everywhere, so nvim/zellij/zsh
# agree). history-substring-search has no dedicated home-manager option
# (unlike autosuggestion/syntaxHighlighting), so it's sourced by hand.
{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;

    autosuggestion = {
      enable = true;
      highlight = "fg=#606079"; # vague comment gray
    };

    syntaxHighlighting = {
      enable = true;
      styles = {
        default = "fg=#cdcdcd";
        comment = "fg=#606079";
        unknown-token = "fg=#d8647e,bold";
        reserved-word = "fg=#6e94b2";
        arg0 = "fg=#7fa563";
        precommand = "fg=#6e94b2,italic";
        path = "fg=#9bb4bc,underline";
        globbing = "fg=#bb9dbd";
        history-expansion = "fg=#bb9dbd";
        redirection = "fg=#90a0b5";
        assign = "fg=#c3c3d5";
        single-hyphen-option = "fg=#e0a363";
        double-hyphen-option = "fg=#e0a363";
        single-quoted-argument = "fg=#e8b589";
        double-quoted-argument = "fg=#e8b589";
        dollar-quoted-argument = "fg=#e8b589";
        back-quoted-argument = "fg=#e8b589";
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
