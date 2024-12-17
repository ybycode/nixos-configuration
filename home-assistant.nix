{ config, lib, mkRootlessPodmanService, ... }:

let
  serviceName = "homeassistant";
in {
  options.home-assistant.webUiPort = lib.mkOption {
    type = lib.types.int;
    default = 8123;
  };

  imports = [
  ];

  config = {
    users.users.hass = {
      home = "/var/lib/hass";
      createHome = true;
      group = "hass";
      uid = config.ids.uids.hass;
      autoSubUidGidRange = true;
      # linger = true;
    };
    users.groups.hass.gid = config.ids.gids.hass;

    # TODO: WIP
    rootless-podman-services.homeassistant = {
      image = "docker.io/homeassistant/home-assistant:2024.10.4";
      user = "hass";
      group = "hass";
      volumes = [ "/var/lib/hass:/config" ];
      environment.TZ = "Europe/Berlin";
      ports = [ "127.0.0.1:${builtins.toString config.home-assistant.webUiPort}:8123" ];
      # extraOptions = [
      #   "--device=/dev/ttyUSB0:/dev/ttyUSB0" # Sonoff zigbee USB dongle
      # ];
    };

    # virtualisation.oci-containers = {
    #   containers."${serviceName}" = {
    #     autoStart = true;
    #     # user = "hass:hass";
    #     volumes = [ "/var/lib/hass:/config" ];
    #     environment.TZ = "Europe/Berlin";
    #     image = "docker.io/homeassistant/home-assistant:2024.10.4";
    #     ports = [ "127.0.0.1:${builtins.toString config.home-assistant.webUiPort}:8123" ];
    #     # extraOptions = [
    #     #   "--device=/dev/ttyUSB0:/dev/ttyUSB0" # Sonoff zigbee USB dongle
    #     # ];
    #   };
    # };

    networking.firewall = {
      allowedTCPPorts = [ config.home-assistant.webUiPort ];
    };
  };
}
