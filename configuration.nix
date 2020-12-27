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
      <nixos-hardware/lenovo/thinkpad>
      <nixos-hardware/lenovo/thinkpad/x1>
      <nixos-hardware/lenovo/thinkpad/x1/7th-gen>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # without this parameter, firefox was really slow (typing and display
  # lagging):
  boot.kernelParams = [ "intel_pstate=active" ];

  networking.hostName = "x1carbon"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

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
  time.timeZone = "Europe/Berlin";

  # for zoom-us:
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # fonts:
    dejavu_fonts
    inconsolata

    # linux tools:
    #avahi mod_dnssd
    #(pkgs.avahi.override { gtk=pkgs.gtk3; }) mod_dnssd
    baobab
    cifs-utils
    direnv
    dnsutils
    docker
    gparted
    ffmpeg
    htop
    imagemagick
    inetutils
    jq
    keychain
    nload
    ntfs3g
    oh-my-zsh
    p7zip
    pciutils
    docker-compose
    neovim
    pv
    rsync
    sshfsFuse
    tmux
    tree
    unzip
    usbutils
    wget
    xorg.xhost
    xclip
    xsel
    zip

    # internet:
    chromium
    filezilla
    firefox
    # thunderbird
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
    # ngrok
    python
    python3


    # security:
    pass
    srm
    yubikey-manager
    yubikey-personalization
    yubikey-personalization-gui

    # ops
    awscli
    aws-vault
    terraform

    # virtualization
    # virtualbox
    # vagrant

    # for Desktop:
    arandr
    dmenu
    i3lock
    i3status
    lightdm
    networkmanager
    networkmanagerapplet
    networkmanager_openvpn
    pavucontrol
    pinentry
    unclutter
    rxvt_unicode-with-plugins
    urxvt_font_size
    xautolock
    xorg.xmodmap
    xorg.xbacklight
    xorg.xkill
    yubikey-personalization-gui
    zathura

    # XFCE:
    # xfce.libxfcegui4 # upgrade 20.03
    xfce.gvfs
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
  # sound.enable = true;
    # Sound and video configuration
  hardware = {
    # TODO: # upgrade 20.03
    # bluetooth.enable = true;
    # bluetooth.config = "
    #   [General]
    #   Enable=Source,Sink,Media,Socket
    # ";
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
    pulseaudio.package = pkgs.pulseaudioFull; # for bluetooth support
    opengl.driSupport32Bit = true;
    # sane.enable = true;
  };

  fonts.fonts = [
    pkgs.dejavu_fonts
    pkgs.inconsolata
  ];

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;
  services = {
      tlp = {
          enable = true;
      };

      avahi = {
          enable = true;
	  nssmdns = true;
      };

      openssh = {
          enable = true;
	  passwordAuthentication = false;
          permitRootLogin = "no";
      };

      printing = {
            enable = true;
            drivers = [ pkgs.epson-escpr ];
      };

      # to fix the error described in https://github.com/NixOS/nixpkgs/issues/16327
      # that I was having when trying to save scanned images with xsane or simple-scan:
      # gnome3.at-spi2-core.enable = true; # TODO: still needed??

      # Needed for yubikey (see https://nixos.wiki/wiki/Yubikey):
      pcscd.enable = true;
      udev.packages = [ pkgs.yubikey-personalization ];

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
      '';

      # For Thunar volume support.
      udisks2.enable = true;

      # Enable the X11 windowing system.
      xserver = {
          enable = true;

          desktopManager = {
            # default = "none";
            xterm.enable = false;
          };

          layout = "fr";
          xkbOptions = "eurosign:e";

          windowManager.i3.enable = true;
          synaptics= {
              enable = true;
              accelFactor = "0.035";
              twoFingerScroll = true;
              additionalOptions = ''
                Option "VertScrollDelta" "-80"
                Option "HorizScrollDelta" "-80"
              '';
          };

          displayManager = {
            lightdm.enable = true;
            defaultSession = "none+i3";
          };

          videoDrivers = [ "intel" ];
          # deviceSection = ''
          #     Option      "AccelMethod" "sna"
          #     Driver      "intel"
          #     BusID       "PCI:0:2:0"
          #     Option      "DRI"    "true"
          #     Option      "TearFree"    "true"
          # '';

          useGlamor = true;

      };
  };

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  users = {
      extraUsers.yann= {
          isNormalUser = true;
          group = "yann";
          extraGroups = [ "adbusers"
                          "audio"
                          "dialout"
                          "docker"
                          "lp"
                          "networkmanager"
                          "scanner"
                          "video"
			  "virtd"
                          "wheel"
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

  # virtualisation.libvirtd.enable
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

