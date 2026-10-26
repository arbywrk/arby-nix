{ lib, ... }:
{
  # Color names below (blue, purple, ...) resolve to stylix's palette.
  stylix.targets.starship.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      # Explicit order instead of $all, so only the wanted modules render.
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_status"
        "$c"
        "$cpp"
        "$cmake"
        "$rust"
        "$zig"
        "$python"
        "$docker_context"
        "$nix_shell"
        "$direnv"
        "$sudo"
        "$line_break"
        "$character"
      ];
      right_format = "$cmd_duration$jobs$status";

      # vimcmd_symbol shows when zsh's vi mode drops to command mode.
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };

      # Inside a repo the path starts at the repo root (truncate_to_repo,
      # on by default); 0 stops it being cut down to the last 3 dirs.
      # repo_root_style also turns on separate styling for the root dir.
      directory = {
        style = "bold blue";
        repo_root_style = "bold underline blue";
        truncation_length = 0;
        read_only = " 󰌾";
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
      };
      git_commit.tag_symbol = "  ";
      git_status.style = "bold orange";

      c.symbol = " ";
      # Off by default upstream.
      cpp = {
        disabled = false;
        symbol = " ";
      };
      cmake.symbol = " ";
      rust.symbol = "🦀 ";
      zig.symbol = " ";
      python.symbol = " ";
      docker_context.symbol = " ";

      nix_shell = {
        symbol = " ";
        heuristic = true;
      };

      direnv = {
        disabled = false;
        symbol = "󱁿 ";
        # Silent when loaded and allowed; only text when .envrc needs attention.
        format = "[$symbol$loaded$allowed]($style) ";
        loaded_msg = "";
        allowed_msg = "";
        unloaded_msg = "not loaded ";
        not_allowed_msg = "not allowed";
        denied_msg = "denied";
      };

      sudo.disabled = false;

      hostname.ssh_symbol = " ";

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "orange";
      };

      status = {
        disabled = false;
        format = "[✗ $status( $signal_name)]($style)";
        style = "red";
      };
    };
  };
}
