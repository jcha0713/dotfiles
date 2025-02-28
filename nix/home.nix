{ pkgs, ... }: 

{
  programs.home-manager.enable = true;

  home = {
    # The home.stateVersion is similar to system.stateVersion in your main config
    # Don't change this value after setting it
    stateVersion = "23.11";
    
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
      aldente _1password-gui mos
      raycast
    ];
  };
  
  programs.git = {
    enable = true;
    userName = "jcha0713";
    userEmail = "joocha0713@gmail.com";
  };
}

