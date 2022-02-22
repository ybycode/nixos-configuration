# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # https://github.com/NixOS/nixos-hardware:
      # initially found on
      # https://github.com/srid/nix-config/blob/master/configuration.nix/x1c7.nix
      <nixos-hardware/common/cpu/intel/kaby-lake>
      <nixos-hardware/lenovo/thinkpad>
      <nixos-hardware/lenovo/thinkpad/x1>
      <nixos-hardware/lenovo/thinkpad/x1/7th-gen>
    ];

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # because the intel video driver is not happy with the
    # kernel v5:
    # boot.kernelPackages = pkgs.linuxPackages_4_19;
    kernelPackages = pkgs.linuxPackages_latest;
    # supportedFilesystems = [
    #   "zfs"
    # ];
  };


  networking = {
    hostId = "72c5ac0c"; # for ZFS. Result of `head -c 8 /etc/machine-id`
    hostName = "x1carbon";
    hosts = {
      "127.0.0.1" = [ "dev.local" ];
    };
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    # for KVM networking (from https://nixos.wiki/wiki/Using_bridges_under_NixOS)
    dhcpcd.denyInterfaces = [ "macvtap0@*" ];

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.enp0s31f6.useDHCP = true;
    interfaces.wlp0s20f3.useDHCP = true;
    networkmanager = {
      enable = true;
      dns = "none"; # to use the nameservers defined statically above.
      wifi.powersave = false;
      wifi.scanRandMacAddress = false;
    };

    firewall = {
      enable = true;
      # for wireguard:
      # allowedUDPPorts = [51820];
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };

  # Set your time zone.
  # time.timeZone = "Atlantic/Canary";
  time.timeZone = "Europe/Berlin";

  # for zoom-us:
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.input-fonts.acceptLicense = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # linux tools:
    #avahi mod_dnssd
    #(pkgs.avahi.override { gtk=pkgs.gtk3; }) mod_dnssd
    baobab
    cifs-utils
    direnv
    dnsutils
    docker
    docker-compose
    docker-credential-helpers
    ffmpeg
    gparted
    htop
    imagemagick
    inetutils
    jq
    keychain
    kubectl
    lsof
    neovim
    nload
    ntfs3g
    oh-my-zsh
    p7zip
    pciutils
    pv
    rsync
    sshfsFuse
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
    brave
    chromium
    filezilla
    firefox
    # thunderbird
    signal-desktop
    transmission_gtk
    openvpn

    # development:
    arduino
    ag
    elixir
    git
    go
    goimports
    neovim
    nodejs-12_x
    nodePackages.prettier
    nodePackages.yarn
    ngrok
    shellcheck

    # rust programming:
    cargo-edit
    rustup
    rust-analyzer

    python

    # purescript and its manager spago
    purescript spago

    # security & encryption:
    croc # to securely share files (like magic-wormhole)
    cryptsetup
    obexftp
    pass
    restic # encrypted backups
    rage
    sops
    srm
    wormhole-william # to securely share files (like croc)
    yubikey-manager
    yubikey-personalization
    yubikey-personalization-gui
    # tor-browser-bundle-bin

    # ops
    awscli
    aws-vault
    terraform_0_12

    # virtualization
    # virtualbox
    # vagrant
    virt-manager

    # for Desktop:
    arandr
    dmenu
    i3lock
    i3status
    kitty # terminal
    lightdm
    networkmanager
    networkmanager_openvpn
    networkmanagerapplet
    pavucontrol
    peek # animated GIF recorder
    pinentry
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
    xfce.terminal
    xfce.thunar
    xfce.thunar_volman
    xfce.xfce4settings
    xfce.xfconf

    # theme:
    #gnome.gnomeicontheme
    #gtk
    #oxygen-gtk2
    #oxygen-gtk3
    hicolor_icon_theme
    shared_mime_info
    xfce.xfce4icontheme

    # X11 multimedia:
    evince
    gimp
    gnome3.eog
    libreoffice
    mplayer
    smplayer
    udiskie # to automount USB devices
    vlc

    # sad
    zoom-us

    # scan
    # xsane
    # simple-scan

    # for bluetooth
    # bluez
    # blueman
  ];

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "ext4";
  };

  fileSystems."/mnt/data/docker" = {
    device = "/var/lib/docker";
    fsType = "none";
    options = [ "bind" ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
    dconf.enable = true; # for libvirtd, see https://nixos.wiki/wiki/Virt-manager
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gnome3";
    };
    zsh = {
      enable = true;
      interactiveShellInit = ''
        export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/
        ZSH_THEME="avit"
        plugins=(git)
        source $ZSH/oh-my-zsh.sh
      '';
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

  # Enable CUPS to print documents.
  # services.printing.enable = true;

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
  # TODO As of 29/12/2020 and fprint v1.90: fprintd-enroll by doesn't require a
  # password to add a new print, and so is a security issue.
  # The issue seems to have been fixed in fprintd v1.90.7-1, but not yet
  # available in nixos (see
  # https://bugs.launchpad.net/ubuntu/+source/fprintd/+bug/1532264).
  #
  # services.fprintd.enable = true;
  # security.pam.services.login.fprintAuth = true;
  # security.pam.services.xscreensaver.fprintAuth = true;

  fonts.fonts = [
    pkgs.dejavu_fonts
    pkgs.inconsolata
    pkgs.nerdfonts
    pkgs.input-fonts
  ];

  services = {
    avahi = {
      enable = true;
	    nssmdns = true;
    };

    blueman.enable = true;

    openssh = {
      enable = true;
	    passwordAuthentication = false;
      permitRootLogin = "no";
    };

    # to fix the error described in https://github.com/NixOS/nixpkgs/issues/16327
    # that I was having when trying to save scanned images with xsane or simple-scan:
    # gnome3.at-spi2-core.enable = true; # TODO: still needed??

    # Needed for yubikey (see https://nixos.wiki/wiki/Yubikey):
    pcscd.enable = true;

    printing = {
      enable = true;
      drivers = [ pkgs.epson-escpr ];
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
                          "docker"
                          "lp"
                          "libvirtd"
                          "networkmanager"
                          "scanner"
                          "video"
                          "virtd"
                          "wheel"
                          "trezord"
                          # "plugdev"
          ];
          uid = 1000;
          shell = "/run/current-system/sw/bin/zsh";
          # define uid and guid to use with docker user namespaces.
          # apt uid is 65534 in containers. Thus the count > 65534
          subUidRanges = [ { count = 1; startUid = 1000; } { count = 65536; startUid = 100001; } ];
          subGidRanges = [ { count = 1; startGid = 1000; } { count = 65536; startGid = 100001; } ];
      };

      # create the group yann, gid 1000:
      extraGroups.yann.gid = 1000;
      extraGroups.vboxusers.members = [ "yann" ];
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.virtualbox.host.enable = true;

  # Enable the docker daemon and map the container root user to yann:
  virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      # extraOptions = '';
      #   # --userns-remap=1000:1000
      # '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

