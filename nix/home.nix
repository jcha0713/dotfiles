{ config, pkgs, system, ... }: 

{
  programs.home-manager.enable = true;

  home = {
    # The home.stateVersion is similar to system.stateVersion in your main config
    # Don't change this value after setting it
    stateVersion = "23.11";

    file.".zshrc" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/.zshrc";
    };

    # Add some basic packages to be managed by Home Manager instead of system-wide
    packages = with pkgs; [
      bat fd ripgrep 
      fzf bottom lazygit
      zk circumflex
      
      # Development tools
      git gh git-absorb
      fnm pnpm deno
      rustup gleam

      # GUI
      aldente mos raycast
      discord espanso
    ];
  };
  
  programs.git = {
    enable = true;
    userName = "jcha0713";
    userEmail = "joocha0713@gmail.com";
  };

  
  programs.zsh = {
    enable = true;
  };
}

