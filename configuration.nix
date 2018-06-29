# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

with builtins; with pkgs.lib; {

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.extraModulePackages = with pkgs; [
    linuxPackages.acpi_call # needed for battery management
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.loader.grub.extraEntries = ''
    menuentry "Ubuntu" {
      chainloader (hd0,1)+1
    }
  '';

  networking = {
    hostName = "darkstar"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager = {
      enable = true;
      #appendNameservers = [ "8.8.8.8" ];
    };
    extraHosts = ''
      172.17.0.1 docker
      127.0.0.1 dev-local.com
    '';
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "fr";
    defaultLocale = "fr_FR.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  nixpkgs.config.allowUnfree = true; # for unrar

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [

    # fonts:
    dejavu_fonts
    inconsolata

    # linux tools:
    #avahi mod_dnssd
    #(pkgs.avahi.override { gtk=pkgs.gtk3; }) mod_dnssd
    baobab
    cifs-utils
    docker
    gparted
    ffmpeg
    htop
    inetutils
    jq
    keychain
    nload
    ntfs3g
    oh-my-zsh
    p7zip
    pciutils
    python27Packages.docker_compose
    python35Packages.neovim
    pv
    rsync
    rxvt_unicode
    sshfsFuse
    tmux
    tree
    unrar
    unzip
    usbutils
    wget
    xorg.xhost
    xsel
    zip

    # internet:
    chromium
    filezilla
    firefox
    thunderbird
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
    ngrok
    python
    python3
    python35Packages.jedi

    # virtualization
    virtualbox
    vagrant

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
    unclutter
    urxvt_font_size
    xautolock
    xorg.xmodmap
    xorg.xbacklight
    xorg.xkill
    yubikey-personalization-gui
    zathura

    # XFCE:
    xfce.libxfcegui4
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
    xfce.gtk_xfce_engine
    xfce.xfce4icontheme

    # X11 multimedia:
    evince
    gimp
    gnome3.eog
    libreoffice
    mplayer
    smplayer
    vlc

    # scan
    xsane
    simple-scan

    # for bluetooth
    bluez
    blueman

  ];

  # environment variables # TODO make it work
  environment.variables = {
    EDITOR="${pkgs.neovim}/bin/nvim";
    SHELL="${pkgs.zsh}/bin/zsh";
  };

  environment.shellAliases = {
    vim = "nvim";
  };

  environment.shellInit = ''
    
    ## so that GTK+ can find the theme engines.
    export GTK_PATH=$GTK_PATH:${pkgs.xfce.gtk_xfce_engine}/lib/gtk-2.0

    #
    export GTK2_RC_FILES=$GTK2_RC_FILES:${pkgs.xfce.gtk_xfce_engine}/share/themes/oxygen-gtk/gtk-2.0/gtkrc

    ## so that GTK+ can find the Xfce themes.
    export GTK_DATA_PREFIX=${config.system.path}
    # so that gvfs works.
    export GIO_EXTRA_MODULES=${pkgs.xfce.gvfs}/lib/gio/modules
  '';

  environment.pathsToLink = 
    [ "/share/xfce4" "/share/themes" "/share/mime" "/share/desktop-directories" ];

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "ext2";
  };

  fileSystems."/mnt/data/docker" = {
    device = "/var/lib/docker";
    fsType = "none";
    options = [ "bind" ];
  };


  # Sound and video configuration
  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
    pulseaudio.package = pkgs.pulseaudioFull; # for bluetooth support
    opengl.driSupport32Bit = true;
    sane.enable = true;
  };

  programs.zsh={
    enable = true;
    interactiveShellInit = ''
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/
      ZSH_THEME="avit"
      plugins=(git)
      source $ZSH/oh-my-zsh.sh
    '';
  };

  fonts.fonts = [
    pkgs.dejavu_fonts
    pkgs.inconsolata
  ];

  # List services that you want to enable:

  services = {
      avahi = {
          enable = true;
	  nssmdns = true;
      };

      openssh = {
          enable = false;
          permitRootLogin = "no";
      };

      printing = {
            enable = true;
            drivers = [ pkgs.epson-escpr ];
      };

      # to fix the error described in https://github.com/NixOS/nixpkgs/issues/16327
      # that I was having when trying to save scanned images with xsane or simple-scan:
      gnome3.at-spi2-core.enable = true;

      # Udev rules.
      udev.extraRules = ''
          # Add access to the webcam for the group users:
          SUBSYSTEM=="usb", ATTR{idVendor}=="04ca" MODE="0664", GROUP="users"
          # 05c6 is Qualcomm, to allow debugging on the One Plus:
          SUBSYSTEM=="usb", ATTR{idVendor}=="05c6" MODE="0664", GROUP="users", SYMLINK+="android%n"

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
          layout = "fr";
          xkbOptions = "eurosign:e";

          windowManager.i3.enable = true;
          synaptics= {
              enable = true;
              accelFactor = "0.035";
              twoFingerScroll = true;
              additionalOptions = ''
                Option "VertScrollDelta" "-114"
                Option "HorizScrollDelta" "-114"
              '';
          };

          displayManager.lightdm.enable = true;
          videoDrivers = [ "intel" ];
          deviceSection = ''
              Option      "AccelMethod" "sna"
              Driver      "intel"
              BusID       "PCI:0:2:0"
              Option      "DRI"    "true"
              Option      "TearFree"    "true"
          '';

          useGlamor = true;

      };
  };




  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
      extraUsers.yann= {
          isNormalUser = true;
          group = "yann";
          extraGroups = [ "wheel" "video" "dialout" "docker" "lp" "networkmanager" "scanner" ];
          uid = 1000;
          shell = "/run/current-system/sw/bin/zsh";
          # define uid and guid to use with docker user namespaces.
          # apt uid is 65534 in containers. Thus the count > 65534
          subUidRanges = [ { count = 1; startUid = 1000; } { count = 65536; startUid = 100001; } ];
          subGidRanges = [ { count = 1; startGid = 1000; } { count = 65536; startGid = 100001; } ];
      };

      # create the group yann, gid 1000:
      extraGroups.yann.gid = 1000;
  };


  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

  # Enable the docker daemon and map the container root user to yann:
  virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      # extraOptions = '';
      #   # --userns-remap=1000:1000
      # '';
  };

  virtualisation.virtualbox = {
      host.enable = true;
      host.headless = true;
  };


}
