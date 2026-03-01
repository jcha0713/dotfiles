# Noctalia Shell Configuration
# https://docs.noctalia.dev
# https://github.com/noctalia-dev/noctalia-shell
#
# Default settings reference:
# https://docs.noctalia.dev/getting-started/nixos/#config-ref

{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;

    # ============================================================================
    # ALL DEFAULT SETTINGS (from official docs)
    # Modify any values below to customize Noctalia
    # ============================================================================

    settings = {
      settingsVersion = 0;

      # Top panel / bar configuration
      bar = {
        barType = "floating";
        position = "bottom";
        monitors = [ ];
        density = "default";
        showOutline = false;
        showCapsule = true;
        capsuleOpacity = 1;
        capsuleColorKey = "none";
        widgetSpacing = 6;
        contentPadding = 6;
        fontScale = 1.05;
        backgroundOpacity = 0;
        useSeparateOpacity = true;
        floating = false;
        marginVertical = 4;
        marginHorizontal = 4;
        frameThickness = 8;
        frameRadius = 12;
        outerCorners = true;
        hideOnOverview = true;
        displayMode = "always_visible"; # "always_visible" "auto_hide", "overlay"
        autoHideDelay = 500;
        autoShowDelay = 150;
        showOnWorkspaceSwitch = true;

        # Widgets on the bar
        widgets = {
          left = [
            { id = "Launcher"; }
            { id = "Clock"; }
            { id = "SystemMonitor"; }
            { id = "ActiveWindow"; }
            { id = "MediaMini"; }
          ];
          center = [
            { id = "Workspace"; }
          ];
          right = [
            { id = "Tray"; }
            { id = "NotificationHistory"; }
            {
              id = "Battery";
              alwaysShowPercentage = true;
              showPowerProfiles = true;
              showNoctaliaPerformance = true;
            }
            { id = "Volume"; }
            { id = "Brightness"; }
            { id = "plugin:pomodoro"; }
            { id = "plugin:todo"; }
            { id = "plugin:catwalk"; }
            { id = "ControlCenter"; }
          ];
        };

        screenOverrides = [ ];
      };

      # General appearance and behavior
      general = {
        avatarImage = "";
        dimmerOpacity = 0.2;
        showScreenCorners = false;
        forceBlackScreenCorners = false;
        scaleRatio = 1;
        radiusRatio = 1;
        iRadiusRatio = 1;
        boxRadiusRatio = 1;
        screenRadiusRatio = 1;
        animationSpeed = 1;
        animationDisabled = true;
        compactLockScreen = false;
        lockScreenAnimations = false;
        lockOnSuspend = true;
        showSessionButtonsOnLockScreen = true;
        showHibernateOnLockScreen = false;
        enableShadows = true;
        shadowDirection = "bottom_right";
        shadowOffsetX = 2;
        shadowOffsetY = 3;
        language = "";
        allowPanelsOnScreenWithoutBar = true;
        showChangelogOnStartup = true;
        telemetryEnabled = false;
        enableLockScreenCountdown = true;
        lockScreenCountdownDuration = 10000;
        autoStartAuth = false;
        allowPasswordWithFprintd = false;
        clockStyle = "custom";
        clockFormat = "hh\nmm";
        passwordChars = false;
        lockScreenMonitors = [ ];
        lockScreenBlur = 0;
        lockScreenTint = 0;

        keybinds = {
          keyUp = [ "Up" ];
          keyDown = [ "Down" ];
          keyLeft = [ "Left" ];
          keyRight = [ "Right" ];
          keyEnter = [ "Return" ];
          keyEscape = [ "Esc" ];
          keyRemove = [ "Del" ];
        };

        reverseScroll = false;
      };

      # UI settings
      ui = {
        fontDefault = "";
        fontFixed = "";
        fontDefaultScale = 1;
        fontFixedScale = 1;
        tooltipsEnabled = true;
        boxBorderEnabled = false;
        panelBackgroundOpacity = 0.93;
        panelsAttachedToBar = false;
        settingsPanelMode = "centered";
        settingsPanelSideBarCardStyle = true;
      };

      # Location and weather
      location = {
        name = "Seoul";
        weatherEnabled = false;
        weatherShowEffects = true;
        useFahrenheit = false;
        use12hourFormat = false;
        showWeekNumberInCalendar = false;
        showCalendarEvents = true;
        showCalendarWeather = true;
        analogClockInCalendar = false;
        firstDayOfWeek = -1;
        hideWeatherTimezone = false;
        hideWeatherCityName = false;
      };

      # Calendar widget
      calendar = {
        cards = [
          {
            enabled = true;
            id = "calendar-header-card";
          }
          {
            enabled = true;
            id = "calendar-month-card";
          }
          {
            enabled = true;
            id = "weather-card";
          }
        ];
      };

      # Wallpaper settings
      wallpaper = {
        enabled = true;
        overviewEnabled = false;
        directory = "~/Pictures/";
        monitorDirectories = [ ];
        enableMultiMonitorDirectories = false;
        showHiddenFiles = false;
        viewMode = "single";
        setWallpaperOnAllMonitors = true;
        fillMode = "crop"; # or "fit", "stretch", "tile", "center"
        fillColor = "#000000";
        useSolidColor = false;
        solidColor = "#1a1a2e";
        automationEnabled = false;
        wallpaperChangeMode = "random";
        randomIntervalSec = 300;
        transitionDuration = 1500;
        transitionType = "random";
        skipStartupTransition = false;
        transitionEdgeSmoothness = 0.05;
        panelPosition = "follow_bar";
        hideWallpaperFilenames = false;
        overviewBlur = 0.4;
        overviewTint = 0.6;
        useWallhaven = false;
        wallhavenQuery = "";
        wallhavenSorting = "relevance";
        wallhavenOrder = "desc";
        wallhavenCategories = "111";
        wallhavenPurity = "100";
        wallhavenRatios = "";
        wallhavenApiKey = "";
        wallhavenResolutionMode = "atleast";
        wallhavenResolutionWidth = "";
        wallhavenResolutionHeight = "";
        sortOrder = "name";
        favorites = [ ];
      };

      # App launcher
      appLauncher = {
        enableClipboardHistory = false;
        autoPasteClipboard = false;
        enableClipPreview = true;
        clipboardWrapText = true;
        clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
        clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
        position = "center";
        pinnedApps = [ ];
        useApp2Unit = false;
        sortByMostUsed = true;
        terminalCommand = "ghostty -e";
        customLaunchPrefixEnabled = false;
        customLaunchPrefix = "";
        viewMode = "list"; # or "grid"
        showCategories = true;
        iconMode = "tabler"; # or "papirus", "custom"
        showIconBackground = false;
        enableSettingsSearch = true;
        enableWindowsSearch = true;
        enableSessionSearch = true;
        ignoreMouseInput = false;
        screenshotAnnotationTool = "";
        overviewLayer = false;
        density = "default";
      };

      # Control center (system menu)
      controlCenter = {
        position = "close_to_bar_button";
        diskPath = "/";

        shortcuts = {
          left = [
            { id = "Network"; }
            { id = "Bluetooth"; }
            { id = "WallpaperSelector"; }
            { id = "NoctaliaPerformance"; }
          ];
          right = [
            { id = "Notifications"; }
            { id = "PowerProfile"; }
            { id = "KeepAwake"; }
            { id = "NightLight"; }
          ];
        };

        cards = [
          {
            enabled = true;
            id = "profile-card";
          }
          {
            enabled = true;
            id = "shortcuts-card";
          }
          {
            enabled = true;
            id = "audio-card";
          }
          {
            enabled = false;
            id = "brightness-card";
          }
          {
            enabled = true;
            id = "weather-card";
          }
          {
            enabled = true;
            id = "media-sysmon-card";
          }
        ];
      };

      # System monitor widget
      systemMonitor = {
        cpuWarningThreshold = 80;
        cpuCriticalThreshold = 90;
        tempWarningThreshold = 80;
        tempCriticalThreshold = 90;
        gpuWarningThreshold = 80;
        gpuCriticalThreshold = 90;
        memWarningThreshold = 80;
        memCriticalThreshold = 90;
        swapWarningThreshold = 80;
        swapCriticalThreshold = 90;
        diskWarningThreshold = 80;
        diskCriticalThreshold = 90;
        diskAvailWarningThreshold = 20;
        diskAvailCriticalThreshold = 10;
        batteryWarningThreshold = 20;
        batteryCriticalThreshold = 5;
        enableDgpuMonitoring = false;
        useCustomColors = false;
        warningColor = "";
        criticalColor = "";
        externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
      };

      # Dock (optional bottom dock)
      dock = {
        enabled = false;
        position = "bottom";
        displayMode = "auto_hide"; # or "always_visible"
        dockType = "floating";
        backgroundOpacity = 1;
        floatingRatio = 1;
        size = 1;
        onlySameOutput = true;
        monitors = [ ];
        pinnedApps = [ ];
        colorizeIcons = false;
        showLauncherIcon = false;
        launcherPosition = "end";
        launcherIconColor = "none";
        pinnedStatic = false;
        inactiveIndicators = false;
        groupApps = false;
        groupContextMenuMode = "extended";
        groupClickAction = "cycle";
        groupIndicatorStyle = "dots";
        deadOpacity = 0.6;
        animationSpeed = 1;
        sitOnFrame = false;
        showFrameIndicator = true;
      };

      # Network and Bluetooth
      network = {
        wifiEnabled = true;
        airplaneModeEnabled = false;
        bluetoothRssiPollingEnabled = false;
        bluetoothRssiPollIntervalMs = 60000;
        networkPanelView = "wifi";
        wifiDetailsViewMode = "grid";
        bluetoothDetailsViewMode = "grid";
        bluetoothHideUnnamedDevices = false;
        disableDiscoverability = false;
      };

      # Session menu (logout/shutdown/etc)
      sessionMenu = {
        enableCountdown = true;
        countdownDuration = 10000;
        position = "center";
        showHeader = true;
        showKeybinds = true;
        largeButtonsStyle = true;
        largeButtonsLayout = "single-row";

        powerOptions = [
          {
            action = "lock";
            enabled = true;
            keybind = "1";
          }
          {
            action = "suspend";
            enabled = true;
            keybind = "2";
          }
          {
            action = "hibernate";
            enabled = true;
            keybind = "3";
          }
          {
            action = "reboot";
            enabled = true;
            keybind = "4";
          }
          {
            action = "logout";
            enabled = true;
            keybind = "5";
          }
          {
            action = "shutdown";
            enabled = true;
            keybind = "6";
          }
          {
            action = "rebootToUefi";
            enabled = true;
            keybind = "7";
          }
        ];
      };

      # Notifications
      notifications = {
        enabled = true;
        enableMarkdown = false;
        density = "default";
        monitors = [ ];
        location = "bottom_right"; # or "top_left", "bottom_right", "bottom_left"
        overlayLayer = true;
        backgroundOpacity = 1;
        respectExpireTimeout = false;
        lowUrgencyDuration = 3;
        normalUrgencyDuration = 8;
        criticalUrgencyDuration = 15;
        clearDismissed = true;

        saveToHistory = {
          low = true;
          normal = true;
          critical = true;
        };

        sounds = {
          enabled = false;
          volume = 0.5;
          separateSounds = false;
          criticalSoundFile = "";
          normalSoundFile = "";
          lowSoundFile = "";
          excludedApps = "discord,firefox,chrome,chromium,edge";
        };

        enableMediaToast = false;
        enableKeyboardLayoutToast = true;
        enableBatteryToast = true;
      };

      # On-screen display (volume/brightness popups)
      osd = {
        enabled = true;
        location = "top_right";
        autoHideMs = 2000;
        overlayLayer = true;
        backgroundOpacity = 1;
        enabledTypes = [
          0
          1
          2
        ]; # 0=brightness, 1=volume, 2=media
        monitors = [ ];
      };

      # Audio settings
      audio = {
        volumeStep = 5;
        volumeOverdrive = false;
        cavaFrameRate = 30;
        visualizerType = "linear";
        mprisBlacklist = [ ];
        preferredPlayer = "";
        volumeFeedback = false;
        volumeFeedbackSoundFile = "";
      };

      # Brightness settings
      brightness = {
        brightnessStep = 5;
        enforceMinimum = true;
        enableDdcSupport = false;
        backlightDeviceMappings = [ ];
      };

      # Color schemes and theming
      colorSchemes = {
        useWallpaperColors = true;
        predefinedScheme = "Noctalia (default)";
        darkMode = true;
        schedulingMode = "off"; # or "sunrise_sunset", "manual"
        manualSunrise = "06:30";
        manualSunset = "18:30";
        generationMethod = "tonal-spot";
        monitorForColors = "";
      };

      # Template generation for other apps
      templates = {
        activeTemplates = [ ];
        enableUserTheming = false;
      };

      # Night light (blue light filter)
      nightLight = {
        enabled = true;
        forced = false;
        autoSchedule = true;
        nightTemp = "4000";
        dayTemp = "6500";
        manualSunrise = "06:30";
        manualSunset = "18:30";
      };

      # Hooks for custom scripts
      hooks = {
        enabled = false;
        wallpaperChange = "";
        darkModeChange = "";
        screenLock = "";
        screenUnlock = "";
        performanceModeEnabled = "";
        performanceModeDisabled = "";
        startup = "";
        session = "";
      };

      # Plugin settings
      plugins = {
        autoUpdate = false;
      };

      # Desktop widgets (optional)
      desktopWidgets = {
        enabled = false;
        overviewEnabled = true;
        gridSnap = false;
        monitorWidgets = [ ];
      };
    };

    # ============================================================================
    # CUSTOM COLORS (optional)
    # Only used if colorSchemes.useWallpaperColors = false
    # You must set ALL colors if you override them
    # ============================================================================
    # colors = {
    #   mPrimary = "#aaaaaa";
    #   mSecondary = "#a7a7a7";
    #   mTertiary = "#cccccc";
    #   mSurface = "#111111";
    #   mSurfaceVariant = "#191919";
    #   mOnSurface = "#828282";
    #   mOnSurfaceVariant = "#5d5d5d";
    #   mOnPrimary = "#111111";
    #   mOnSecondary = "#111111";
    #   mOnTertiary = "#111111";
    #   mOnHover = "#ffffff";
    #   mError = "#dddddd";
    #   mOnError = "#111111";
    #   mOutline = "#3c3c3c";
    #   mShadow = "#000000";
    #   mHover = "#1f1f1f";
    # };

    # ============================================================================
    # PLUGINS
    # https://noctalia.dev/plugins/
    # ============================================================================
    plugins = {
      version = 2;
      sources = [
        {
          name = "Official Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
          enabled = true;
        }
      ];
      states = {
        catwalk = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        todo = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        pomodoro = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
    };

    pluginSettings = {
      catwalk = {
        minimumThreshold = 15;
        hideBackground = true;
      };
      todo = {
        showCompleted = false;
      };
      pomodoro = {
        workDuration = 25;
        shortBreakDuration = 5;
        longBreakDuration = 15;
        cycles = 4;
        autoStartBreaks = false;
        autoStartWork = false;
      };
    };

    # ============================================================================
    # USER TEMPLATES
    # Auto-generate config files for other applications
    # ============================================================================
    # user-templates = {
    #   templates = {
    #     neovim = {
    #       input_path = "~/.config/noctalia/templates/template.lua";
    #       output_path = "~/.config/nvim/generated.lua";
    #       post_hook = "pkill -SIGUSR1 nvim";
    #     };
    #   };
    # };
  };

  # Keep cliphist for clipboard history - Noctalia integrates with it
  services.cliphist.enable = true;
}
