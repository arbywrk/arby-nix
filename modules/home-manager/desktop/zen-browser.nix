{ inputs, ... }:
{
  # beta = Zen's stable release channel.
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;
    # Declared so stylix has a profile to theme; settings go here later.
    profiles.default = { };
  };

  stylix.targets.zen-browser = {
    enable = true;
    profileNames = [ "default" ];
  };
}
