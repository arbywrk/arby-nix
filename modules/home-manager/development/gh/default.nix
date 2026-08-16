{ ... }:
{
  # ~/.config/gh/config.yml is home-manager-managed (read-only symlink), so
  # `gh config set` can never persist anything -- set preferences here
  # instead.
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
