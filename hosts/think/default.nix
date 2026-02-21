# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ThinkPad sleep/wake Wi-Fi fix - disable power management for iwlwifi
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
    options iwlwifi uapsd_disable=1
  '';

  # Use deep sleep for better ThinkPad compatibility
  boot.kernelParams = [ "mem_sleep_default=deep" ];

  # FIX: Proper suspend/resume handling with Tailscale awareness
  systemd.services.fix-network-after-resume = {
    description = "Fix network after resume from suspend";
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" "systemd-suspend.service" "systemd-hibernate.service" ];
    wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "fix-network" ''
        set -e
        LOGFILE="/home/joohoon/suspend-debug.log"
        echo "$(date '+%Y-%m-%d %H:%M:%S') === POST-RESUME FIX ===" >> "$LOGFILE"
        
        # Wait for Wi-Fi to reconnect
        for i in {1..30}; do
          if ${pkgs.iw}/bin/iw dev wlp4s0 link 2>/dev/null | grep -q "Connected"; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') Wi-Fi connected" >> "$LOGFILE"
            break
          fi
          sleep 1
        done
        
        # Check if we have internet
        if ! ${pkgs.iputils}/bin/ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
          echo "$(date '+%Y-%m-%d %H:%M:%S') No internet, restarting NetworkManager..." >> "$LOGFILE"
          ${pkgs.systemd}/bin/systemctl restart NetworkManager
          sleep 5
        else
          echo "$(date '+%Y-%m-%d %H:%M:%S') Internet OK" >> "$LOGFILE"
        fi
        
        # Restart Tailscale to fix its routing
        echo "$(date '+%Y-%m-%d %H:%M:%S') Restarting Tailscale..." >> "$LOGFILE"
        ${pkgs.systemd}/bin/systemctl restart tailscaled
      ''}";
    };
  };

  networking.hostName = "jcha-think"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.


  # Set your time zone.
  time.timeZone = "Asia/Seoul";


  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ko_KR.UTF-8";
    LC_IDENTIFICATION = "ko_KR.UTF-8";
    LC_MEASUREMENT = "ko_KR.UTF-8";
    LC_MONETARY = "ko_KR.UTF-8";
    LC_NAME = "ko_KR.UTF-8";
    LC_NUMERIC = "ko_KR.UTF-8";
    LC_PAPER = "ko_KR.UTF-8";
    LC_TELEPHONE = "ko_KR.UTF-8";
    LC_TIME = "ko_KR.UTF-8";
  };


  # Kime - Korean IME (replaces ibus)
  i18n.inputMethod = {
    enable = true;
    type = "kime";
  };

  # Environment variables for Wayland apps
  environment.variables = {
    # Kime input method (no GTK/QT_IM_MODULE needed for kime)
    XMODIFIERS = "@im=kime";
    # Tell apps it's running in a desktop session
    XDG_CURRENT_DESKTOP = "niri";
    # Force Wayland for Firefox and other apps
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.logind.lidSwitch = "suspend";

  programs.niri.enable = true;
  programs.xwayland.enable = true;
  programs.zsh.enable = true;

  # Idle management: lock screen and turn off monitors
  systemd.user.services.swayidle = {
    description = "Idle management for Wayland";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
          timeout 600 '${pkgs.swaylock}/bin/swaylock -f' \
          timeout 601 '${pkgs.niri}/bin/niri msg action power-off-monitors' \
          before-sleep '${pkgs.swaylock}/bin/swaylock -f'
      '';
      Restart = "on-failure";
    };
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
  };

  # Notification daemon (mako)
  environment.etc."xdg/mako/config".text = ''
    background-color=#1e1e2e
    text-color=#cdd6f4
    border-color=#cba6f7
    border-size=2
    border-radius=10
    default-timeout=5000
    anchor=top-right
  '';

  systemd.user.services.mako = {
    description = "Mako notification daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "on-failure";
    };
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
  };

  # Status bar - waybar reads config from ~/.config/waybar/ (symlinked by home-manager)
  programs.waybar = {
    enable = true;
  };

  # Wallpaper - using dotfiles path
  systemd.user.services.swaybg = {
    description = "Wallpaper service";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.swaybg}/bin/swaybg -m fill -i /home/joohoon/Pictures/time.png";
      Restart = "on-failure";
    };
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
  };



  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "ctrl:nocaps";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;


  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;


  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.joohoon = {
    isNormalUser = true;
    description = "joohoon";
    extraGroups = [ "networkmanager" "wheel" "video" ]; # Enable 'sudo' for the user.
    shell = pkgs.zsh;
  #   packages = with pkgs; [
  #     tree
  #   ];
  };


  services.displayManager.autoLogin.enable = lib.mkForce false;
  services.displayManager.autoLogin.user = "joohoon";


  # Workaround for GNOME autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;


  programs.firefox.enable = true;


  nixpkgs.config.allowUnfree = true;


  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = (with pkgs; [
    vim
    neovim
    # tree, gh moved to home/common.nix
    # xclip
    wl-clipboard
    wezterm
    ghostty
    tailscale
    discord
    fuzzel
    waybar
    git
    gcc  # C compiler for tree-sitter
    nodejs_22  # Node.js 22.x LTS (using fnm on Mac Mini)
    lua-language-server  # LSP for Lua (Mason version doesn't work on NixOS)
    go
    sqlite
    gnumake
  ])
  ++
  (with inputs.llm-agents.packages.${pkgs.system}; [
    pi
  ]);


  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    monaspace
  ];


  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };


  services.tailscale.enable = true;

  services.flatpak.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
