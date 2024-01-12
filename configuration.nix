# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  # unstable = import
  #   (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-unstable)
  #   # reuse the current configuration
  #   { config = config.nixpkgs.config; };
  plop = 42;
in
{
  imports =
    [
      # https://github.com/NixOS/nixos-hardware:
      # initially found on
      # https://github.com/srid/nix-config/blob/master/configuration.nix/x1c7.nix
      # Setup:
      # $ sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
      # $ sudo nix-channel --update
      <nixos-hardware/common/cpu/intel/kaby-lake>
      <nixos-hardware/lenovo/thinkpad>
      <nixos-hardware/lenovo/thinkpad/t480>
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # kernelPackages = pkgs.linuxPackages_latest;


    initrd.availableKernelModules = [
      "aesni_intel"
      "cryptd"
      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];
  };


  networking = {
    hostName = "t480";
    hosts = {
      "127.0.0.1" = [ "dev.local" ];
    };
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # nameservers = [ "1.1.1.1" "8.8.8.8" ];

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.enp0s31f6.useDHCP = true;
    interfaces.wlp3s0.useDHCP = true;
    networkmanager = {
      enable = true;
      # dns = "none"; # to use the nameservers defined statically above.
      wifi.powersave = false;
      wifi.scanRandMacAddress = false;
    };

    firewall = {
      enable = true;
      allowedUDPPorts = [ 51820 ];
      # Setup for allowing wireguard (from https://nixos.wiki/wiki/WireGuard):
      # if packets are still dropped, they will show up in dmesg
      logReversePathDrops = true;
      # wireguard trips rpfilter up
      extraCommands = ''
        iptables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
        iptables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
      '';
      extraStopCommands = ''
        iptables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
        iptables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
      '';
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };

  # time.timeZone = "Atlantic/Canary";
  time.timeZone = "Europe/Berlin";

  # for zoom-us:
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.input-fonts.acceptLicense = true;

  environment.systemPackages = with pkgs; [
    # linux tools:
    baobab
    cifs-utils
    direnv
    dnsutils
    docker
    docker-compose
    docker-credential-helpers
    ffmpeg
    fzf
    ghostscript
    gparted
    helix
    htop
    imagemagick
    inetutils
    jq
    keychain
    kubectl
    lsof
    moreutils # provides vidir, vipe, sponge etc. See https://joeyh.name/code/moreutils/
    neovim
    nload
    ntfs3g
    p7zip
    pciutils
    pv
    ripgrep
    rsync
    silver-searcher
    sshfs-fuse
    tmux
    tree
    unzip
    usbutils
    wget
    xclip
    xorg.xhost
    xsel
    xss-lock
    zip

    # internet:
    brave # jailed
    # chromium
    filezilla
    firefox
    # thunderbird
    signal-desktop
    tdesktop # telegram GUI
    transmission-gtk
    openvpn
    wireguard-tools # to create wireguard keys

    # development:
    arduino
    elixir
    gcc
    git
    go
    gotools
    neovim
    nodejs
    nodePackages.prettier
    nodePackages.yarn
    ngrok
    shellcheck
    watchman # dependency for coc-volar (https://github.com/yaegassy/coc-volar#recommended-additional-installation-watchman)

    elmPackages.elm

    # rust programming:
    cargo-edit
    rustup

    # # purescript and its manager spago
    # purescript spago

    # security & encryption:
    age-plugin-yubikey
    croc # to securely share files (like magic-wormhole)
    cryptsetup
    ecryptfs
    obexftp
    pass
    restic # encrypted backups
    rage
    sops
    step-cli
    srm
    wormhole-william # to securely share files (like croc)
    yubikey-manager
    yubikey-personalization
    yubikey-personalization-gui
    # tor-browser-bundle-bin

    # ops
    awscli
    aws-vault

    # for Desktop:
    arandr
    dmenu
    i3lock
    i3status
    kitty # terminal
    lightdm
    networkmanager
    networkmanager-openvpn
    networkmanagerapplet
    pavucontrol
    peek # animated GIF recorder
    # pinentry
    redshift
    rxvt_unicode-with-plugins
    unclutter
    urxvt_font_size
    xautolock
    xorg.xbacklight
    xorg.xkill
    xorg.xmodmap
    zathura

    # XFCE:
    # xfce.libxfcegui4 # upgrade 20.03
    # xfce.gvfs
    xfce.thunar
    # xfce.thunar_volman
    # xfce.xfce4settings
    # xfce.xfconf

    # theme:
    #gnome.gnomeicontheme
    #gtk
    #oxygen-gtk2
    #oxygen-gtk3
    hicolor-icon-theme
    shared-mime-info
    xfce.xfce4-icon-theme

    # X11 multimedia:
    evince
    exiftool
    gimp
    gnome3.eog
    libreoffice
    mplayer
    smplayer
    udiskie # to automount USB devices
    vlc

    # unstable.darktable
  ];

  #  fileSystems."/mnt/data" = {
  #    device = "/dev/disk/by-label/data";
  #    fsType = "ext4";
  #  };

  #  fileSystems."/mnt/data/docker" = {
  #    device = "/var/lib/docker";
  #    fsType = "none";
  #    options = [ "bind" ];
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
    dconf.enable = true; # for libvirtd, see https://nixos.wiki/wiki/Virt-manager
    firejail = {
      enable = false;
      wrappedBinaries = {
        brave = {
          executable = "${lib.getBin pkgs.brave}/bin/brave";
          profile = "${pkgs.firejail}/etc/firejail/brave.profile";
        };
        chromium = {
          executable = "${lib.getBin pkgs.chromium}/bin/chromium";
          profile = "${pkgs.firejail}/etc/firejail/chromium.profile";
        };
        firefox = {
          executable = "${lib.getBin pkgs.firefox}/bin/firefox";
          profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
        };
      };
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
        pinentryFlavor = "gnome3";
    };
    ssh.startAgent = false;
    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        theme = "avit";
        plugins = [ "git" "pass" "last-working-dir" ];
      };
    };

    # android dev:
    adb.enable = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # No CUPS
  services.printing.enable = false;

  services.gvfs.enable = true;

  # kill apps that are taking too much RAM
  services.earlyoom = {
    enable = true;
    freeSwapThreshold = 2;
    freeMemThreshold = 2;
    killHook = pkgs.writeShellScript "earlyoom-kill-hook" ''
      echo "$(date +%F-%Hh%M) Process $EARLYOOM_NAME ($EARLYOOM_PID) was killed" >> /var/log/earlyoom.log
    '';
    # extraArgs = [
    #   "-g"
    #   "--avoid '^(X|plasma.*|konsole|kwin)$'"
    #   "--prefer '^(electron|libreoffice|gimp)$'"
    # ];
  };

  services.syncthing = {
    enable = true;
    user = "yann";
    dataDir = "/home/yann/syncthing";
    configDir = "/home/yann/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        phone = {
          id = "DMZPQOV-UCTLBFJ-WNLRFEE-UEROIYL-OEFZIJR-CDHWZQZ-GXHYE37-JCHW3AK";
        };
        nas = {
          id = "JWKY5WG-DIXQRDM-Z5EQSKU-6WUSOJ2-HFTEFLP-3DYEGWZ-IHNZEKZ-VHYV4QY";
        };
      };
      folders = {
        "/home/yann/kp" = {
          id = "kp";
          devices = [ "phone" "nas" ];
          type = "sendreceive";
        };
        "/home/yann/markdown" = {
          id = "markdown";
          devices = [ "nas" ];
          type = "sendreceive";
        };
        "/home/yann/documents" = {
          id = "documents";
          devices = [ "nas" ];
          type = "sendreceive";
        };
      };
    };
  };

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "default_config"
      "met"
      "zha"
    ];
    config = {
      homeassistant = {
        name = "Home";
        # latitude = "!secret latitude";
        # longitude = "!secret longitude";
        # elevation = "!secret elevation";
        unit_system = "metric";
        time_zone = "UTC";
      };
      frontend = {
        themes = "!include_dir_merge_named themes";
      };
      http = {};
      feedreader.urls = [ "https://nixos.org/blogs.xml" ];
    };
  };

  services.yubikey-agent.enable = true;

  # Enable sound.
  sound.enable = true;

  hardware = {

    bluetooth = {
      # https://nixos.wiki/wiki/Bluetooth
      enable = true;
      settings = {
        General = {
          # Enabling A2DP Sink
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };

    opengl.driSupport32Bit = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull; # for bluetooth support
      support32Bit = true;

      # keyboard mute & mic LED do not follow the pulseaudio settings. Problem
      # of config to map source and sinks? This following config didn't fix
      # anything:
      # See
      # https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_7)#Audio
      # extraConfig = ''
      #   load-module module-alsa-sink   device=hw:0,0 channels=4
      #   load-module module-alsa-source device=hw:0,6 channels=4
      # '';
    };
    # sane.enable = true;

    enableRedistributableFirmware = true;
  };

  # fwupd allows to install/update devices firmwares, one of which is the
  # fingerprint reader. See https://wiki.archlinux.org/index.php/fwupd#Usage.
  services.fwupd.enable = true;
  # Fingerprint reader. To have it working, I had to run (as root) :
  # ```
  # # fwupdmgr refresh && fwupdmgr update
  # ```
  # then as a user:
  # ```
  # $ fprintd-enroll
  # ```
  #
  # services.fprintd.enable = true;
  # security.pam.services.login.fprintAuth = true;
  # security.pam.services.xscreensaver.fprintAuth = true;

  fonts.packages = with pkgs; [
    pkgs.dejavu_fonts
    pkgs.inconsolata
    pkgs.nerdfonts
    pkgs.input-fonts
  ];

  location = {
    # Berlin
    latitude = 52.5;
    longitude = 13.4;
  };

  services = {
    # avahi = {
    #   enable = true;
	  #   nssmdns = true;
    # };

    blueman.enable = true;

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    # Needed for yubikey (see https://nixos.wiki/wiki/Yubikey):
    pcscd.enable = true;

    redshift = {
      enable = false;
      temperature = {
        day = 5700;
        night = 3700;
      };
      extraOptions = [ "-v" "-m randr" ];
    };

    tlp = {
      enable = true;
    };

    trezord.enable = true;
    # is the trezord-go package needed?

    udev.packages = [
      pkgs.trezor-udev-rules
      pkgs.yubikey-personalization
    ];

    # Udev rules.
    udev.extraRules = ''
        # Add access to the webcam for the group users:
        SUBSYSTEM=="usb", ATTR{idVendor}=="04ca" MODE="0664", GROUP="users"
        # 05c6 is Qualcomm, to allow debugging on the One Plus:
        SUBSYSTEM=="usb", ATTR{idVendor}=="05c6" MODE="0664", GROUP="users", SYMLINK+="android%n"
        # One plus 5:
        SUBSYSTEM=="usb", ATTR{idVendor}=="2a70" MODE="0664", GROUP="users", SYMLINK+="android%n"

	      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
	      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
	      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
	      KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

	      # for Yubico, from https://github.com/Yubico/libu2f-host/blob/master/70-u2f.rules
        ACTION=="add|change", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0402|0403|0406|0407|0410", MODE="0666"


        # replaced by trezor-udev-rules
        # # For Trezor, see https://wiki.trezor.io/Udev_rules
        # SUBSYSTEM=="usb", ATTR{idVendor}=="534c", ATTR{idProduct}=="0001", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl", SYMLINK+="trezor%n"
        # KERNEL=="hidraw*", ATTRS{idVendor}=="534c", ATTRS{idProduct}=="0001", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"
        # # Trezor v2
        # SUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="53c0", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl", SYMLINK+="trezor%n"
        # SUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="53c1", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl", SYMLINK+="trezor%n"
        # KERNEL=="hidraw*", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="53c1", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"

    '';

    # For Thunar volume support.
    udisks2.enable = true;

    # Enable the X11 windowing system.
    xserver = {
        enable = true;

        libinput = {
          enable = true;
          touchpad = {
            naturalScrolling = true;
          };
        };

        desktopManager = {
          # default = "none";
          xterm.enable = false;
        };

        layout = "fr";
        xkbOptions = "eurosign:e";

        windowManager.i3.enable = true;

        displayManager = {
          lightdm.enable = true;
          defaultSession = "none+i3";
        };

        videoDrivers = [ "intel" ];

        # alacritty, kitty, chromium sometimes freeze when switching desktop.
        # See the following for the reason why the "DRI" "2" option:
        # https://github.com/kovidgoyal/kitty/issues/1681#issuecomment-683966060
        # https://wiki.archlinux.org/index.php/intel_graphics#DRI3_issues
        # https://bugs.chromium.org/p/chromium/issues/detail?id=370022
        deviceSection = ''
          Driver "intel"
          Option "DRI" "2"
        '';

         # useGlamor = true;
    };
  };

  users = {
      groups = {
        # plugdev = { };
        trezord = { };
      };
      extraUsers.yann= {
          isNormalUser = true;
          group = "yann";
          extraGroups = [ "adbusers"
                          "audio"
                          "cdrom"
                          "dialout"
                          "kvm" # for firecracker micro VMs
                          "lp"
                          "libvirtd"
                          "lxd"
                          "networkmanager"
                          "scanner"
                          "video"
                          "virtd"
                          "wheel"
                          "trezord"
                          # "plugdev"
          ];
          uid = 1000;
          # shell = "/run/current-system/sw/bin/zsh";
          shell = pkgs.zsh;
          # shell = pkgs.bashInteractive;
      };

      # create the group yann, gid 1000:
      extraGroups.yann.gid = 1000;
  };

  security.pki.certificateFiles = [ "/var/lib/step-ca/root_ca.crt" ];

  # virtualisation.libvirtd.enable = true;

  # Enable the docker daemon and map the container root user to yann:
  virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}

