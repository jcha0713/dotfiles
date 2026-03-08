# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Noctalia shell NixOS module
    inputs.noctalia.nixosModules.default
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

  # Stable resume recovery for deep sleep:
  # restart tailscaled first, then NetworkManager only if internet is still down.
  systemd.services.fix-network-after-resume = {
    description = "Recover network after resume (tailscaled-first)";
    after = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "systemd-suspend.service"
      "systemd-hibernate.service"
      "systemd-hybrid-sleep.service"
    ];
    wantedBy = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "fix-network-after-resume" ''
        set -euo pipefail

        nmcli_bin="${pkgs.networkmanager}/bin/nmcli"
        ip_bin="${pkgs.iproute2}/bin/ip"
        ping_bin="${pkgs.iputils}/bin/ping"
        grep_bin="${pkgs.gnugrep}/bin/grep"
        awk_bin="${pkgs.gawk}/bin/awk"
        systemctl_bin="${pkgs.systemd}/bin/systemctl"

        log() {
          echo "[resume-net] $*"
        }

        wait_wifi_connected() {
          local i=0
          while [ "$i" -lt 20 ]; do
            if $nmcli_bin -t -f DEVICE,TYPE,STATE device status | $awk_bin -F: '$2=="wifi" && $3=="connected"{found=1} END{exit(found?0:1)}'; then
              return 0
            fi
            i=$((i + 1))
            sleep 1
          done
          return 1
        }

        has_default_route() {
          $ip_bin route show default | $grep_bin -q '^default '
        }

        internet_ok() {
          has_default_route && $ping_bin -c 1 -W 3 1.1.1.1 >/dev/null 2>&1
        }

        restart_tailscaled() {
          log "restarting tailscaled"
          $systemctl_bin restart tailscaled
          sleep 4
        }

        log "starting recovery"

        if wait_wifi_connected; then
          log "wifi-connected"
        else
          log "wifi-not-connected-after-wait"
        fi

        restart_tailscaled
        if internet_ok; then
          log "internet-restored-by=tailscaled"
          exit 0
        fi

        log "internet-still-down restarting NetworkManager-fallback"
        $systemctl_bin restart NetworkManager
        sleep 6
        if internet_ok; then
          log "internet-restored-by=NetworkManager-fallback"
          exit 0
        fi

        log "internet-still-down restarting tailscaled-second-fallback"
        restart_tailscaled

        if internet_ok; then
          log "internet-restored-by=tailscaled-second-fallback"
        else
          log "internet-final=down"
        fi
      ''}";
    };
  };

  networking.hostName = "jcha-think"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Use systemd-resolved for more robust DNS handling (incl. Tailscale + resume)
  services.resolved.enable = true;

  # https://docs.noctalia.dev/getting-started/nixos/
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

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

  # Required for Niri XWayland support
  services.xserver.displayManager.sessionCommands = ''
    export PATH="${pkgs.xwayland-satellite}/bin:$PATH"
  '';

  programs.zsh.enable = true;

  # NOTE: Noctalia shell replaces waybar, mako, swaybg, and idle management
  # These services are now handled by Noctalia

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "ctrl:nocaps";
  };

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ]; # Match all keyboards
        settings = {
          main = {
            # Map capslock to control (already done via xkb, but good to have here too)
            capslock = "layer(control)";
            # Space as leader: hold for symbol layer, tap for space
            space = "overloadt(symbol, space, 200)";
          };
          control = {
            h = "backspace";
          };
          symbol = {
            k = "-";
            l = "=";
            ";" = "\\";
            "'" = "`";
          };
        };
      };
    };
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
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ]; # Enable 'sudo' for the user.
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
  environment.systemPackages =
    (with pkgs; [
      vim
      neovim
      wl-clipboard
      xwayland-satellite
      wezterm
      ghostty
      tailscale
      fuzzel
      waybar
      git
      gcc # C compiler for tree-sitter
      nodejs_22 # Node.js 22.x LTS (using fnm on Mac Mini)
      lua-language-server # LSP for Lua (Mason version doesn't work on NixOS)
      stylua
      sqlite
      gnumake
    ])
    ++ (with inputs.llm-agents.packages.${pkgs.system}; [
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

  # Enable nix-command and flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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
