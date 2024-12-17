{ config, options, lib, pkgs, ... }:

with lib;
let
  cfg = config.rootless-podman-services;
  containerOptions =
    { ... }: {

      options = {
        image = mkOption {
          type = with types; str;
          description = "OCI image to run.";
          example = "library/hello-world";
        };

        imageFile = mkOption {
          type = with types; nullOr package;
          default = null;
          description = ''
            Path to an image file to load before running the image. This can
            be used to bypass pulling the image from the registry.

            The `image` attribute must match the name and
            tag of the image contained in this file, as they will be used to
            run the container with that image. If they do not match, the
            image will be pulled from the registry as usual.
          '';
          example = literalExpression "pkgs.dockerTools.buildImage {...};";
        };

        login = {

          username = mkOption {
            type = with types; nullOr str;
            default = null;
            description = "Username for login.";
          };

          passwordFile = mkOption {
            type = with types; nullOr str;
            default = null;
            description = "Path to file containing password.";
            example = "/etc/nixos/dockerhub-password.txt";
          };

          registry = mkOption {
            type = with types; nullOr str;
            default = null;
            description = "Registry where to login to.";
            example = "https://docker.pkg.github.com";
          };

        };

        cmd = mkOption {
          type =  with types; listOf str;
          default = [];
          description = "Commandline arguments to pass to the image's entrypoint.";
          example = literalExpression ''
            ["--port=9000"]
          '';
        };

        labels = mkOption {
          type = with types; attrsOf str;
          default = {};
          description = "Labels to attach to the container at runtime.";
          example = literalExpression ''
            {
              "traefik.https.routers.example.rule" = "Host(`example.container`)";
            }
          '';
        };

        entrypoint = mkOption {
          type = with types; nullOr str;
          description = "Override the default entrypoint of the image.";
          default = null;
          example = "/bin/my-app";
        };

        environment = mkOption {
          type = with types; attrsOf str;
          default = {};
          description = "Environment variables to set for this container.";
          example = literalExpression ''
            {
              DATABASE_HOST = "db.example.com";
              DATABASE_PORT = "3306";
            }
        '';
        };

        environmentFiles = mkOption {
          type = with types; listOf path;
          default = [];
          description = "Environment files for this container.";
          example = literalExpression ''
            [
              /path/to/.env
              /path/to/.env.secret
            ]
        '';
        };

        log-driver = mkOption {
          type = types.str;
          default = "journald";
          description = ''
            Logging driver for the container.  The default of
            `"journald"` means that the container's logs will be
            handled as part of the systemd unit.

            For more details and a full list of logging drivers, refer to respective backends documentation.

            For Docker:
            [Docker engine documentation](https://docs.docker.com/engine/reference/run/#logging-drivers---log-driver)

            For Podman:
            Refer to the docker-run(1) man page.
          '';
        };

        ports = mkOption {
          type = with types; listOf str;
          default = [];
          description = ''
            Network ports to publish from the container to the outer host.

            Valid formats:
            - `<ip>:<hostPort>:<containerPort>`
            - `<ip>::<containerPort>`
            - `<hostPort>:<containerPort>`
            - `<containerPort>`

            Both `hostPort` and `containerPort` can be specified as a range of
            ports.  When specifying ranges for both, the number of container
            ports in the range must match the number of host ports in the
            range.  Example: `1234-1236:1234-1236/tcp`

            When specifying a range for `hostPort` only, the `containerPort`
            must *not* be a range.  In this case, the container port is published
            somewhere within the specified `hostPort` range.
            Example: `1234-1236:1234/tcp`

            Refer to the
            [Docker engine documentation](https://docs.docker.com/engine/reference/run/#expose-incoming-ports) for full details.
          '';
          example = literalExpression ''
            [
              "8080:9000"
            ]
          '';
        };

        user = mkOption {
          type = with types; nullOr str;
          description = ''
            The user for the process that runs the container.
          '';
          example = "hass";
        };

        group = mkOption {
          type = with types; nullOr str;
          description = ''
            The user for the process that runs the container.
          '';
          example = "hass";
        };

        userInContainer = mkOption {
          type = with types; nullOr str;
          default = null;
          description = ''
            Override the username or UID (and optionally groupname or GID) used
            in the container.
          '';
          example = "nobody:nogroup";
        };

        volumes = mkOption {
          type = with types; listOf str;
          default = [];
          description = ''
            List of volumes to attach to this container.

            Note that this is a list of `"src:dst"` strings to
            allow for `src` to refer to `/nix/store` paths, which
            would be difficult with an attribute set.  There are
            also a variety of mount options available as a third
            field; please refer to the
            [docker engine documentation](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) for details.
          '';
          example = literalExpression ''
            [
              "volume_name:/path/inside/container"
              "/path/on/host:/path/inside/container"
            ]
          '';
        };

        workdir = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "Override the default working directory for the container.";
          example = "/var/lib/hello_world";
        };

        dependsOn = mkOption {
          type = with types; listOf str;
          default = [];
          description = ''
            Define which other containers this one depends on. They will be added to both After and Requires for the unit.

            Use the same name as the attribute under `virtualisation.oci-containers.containers`.
          '';
          example = literalExpression ''
            virtualisation.oci-containers.containers = {
              node1 = {};
              node2 = {
                dependsOn = [ "node1" ];
              }
            }
          '';
        };

        hostname = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "The hostname of the container.";
          example = "hello-world";
        };

        extraOptions = mkOption {
          type = with types; listOf str;
          default = [];
          description = "Extra options for {command}`${defaultBackend} run`.";
          example = literalExpression ''
            ["--network=host"]
          '';
        };

        autoStart = mkOption {
          type = types.bool;
          default = true;
          description = ''
            When enabled, the container is automatically started on boot.
            If this option is set to false, the container has to be started on-demand via its service.
          '';
        };
      };
    };

  mkService = name: container:
    let
      plop = builtins.trace ''name_________________________________________________: ${builtins.toString name}'' 42;
      dependsOn = map (x: "podman-${x}.service") container.dependsOn;
      escapedName = escapeShellArg name;
      user = container.user;
      group = container.group;
      cidfile = "/run/user/${builtins.toString config.users.users.${user}.uid}/podman-${escapedName}.ctr-id";
      preStartScript = pkgs.writeShellApplication {
        name = "pre-start";
        runtimeInputs = [ ];
        text = ''
          podman rm -f ${name} || true
          rm -f ${cidfile}
        '';
      };
    in {
      wantedBy = [] ++ optional (container.autoStart) "multi-user.target";
      after = dependsOn;
      requires = dependsOn;
      # environment = proxy_env;

      path = [ config.virtualisation.podman.package ];

      script = concatStringsSep " \\\n  " ([
        "exec podman run"
        "--rm"
        "--name=${escapedName}"
        "--log-driver=${container.log-driver}"
      ] ++ optional (container.entrypoint != null)
        "--entrypoint=${escapeShellArg container.entrypoint}"
        ++ optional (container.hostname != null)
        "--hostname=${escapeShellArg container.hostname}"
        ++ [
          "--cidfile=${cidfile}"
          "--cgroups=no-conmon"
          "--sdnotify=conmon"
          "-d"
          "--replace"
        ] ++ (mapAttrsToList (k: v: "-e ${escapeShellArg k}=${escapeShellArg v}") container.environment)
        ++ map (f: "--env-file ${escapeShellArg f}") container.environmentFiles
        ++ map (p: "-p ${escapeShellArg p}") container.ports
        ++ optional (container.userInContainer != null) "-u ${escapeShellArg container.userInContainer}"
        ++ map (v: "-v ${escapeShellArg v}") container.volumes
        ++ (mapAttrsToList (k: v: "-l ${escapeShellArg k}=${escapeShellArg v}") container.labels)
        ++ optional (container.workdir != null) "-w ${escapeShellArg container.workdir}"
        ++ map escapeShellArg container.extraOptions
        ++ [container.image]
        ++ map escapeShellArg container.cmd
      );

      preStop = "podman stop --ignore --cidfile=${cidfile}";

      postStop = "podman rm -f --ignore --cidfile=${cidfile}";

      serviceConfig = {
        ### There is no generalized way of supporting `reload` for docker
        ### containers. Some containers may respond well to SIGHUP sent to their
        ### init process, but it is not guaranteed; some apps have other reload
        ### mechanisms, some don't have a reload signal at all, and some docker
        ### images just have broken signal handling.  The best compromise in this
        ### case is probably to leave ExecReload undefined, so `systemctl reload`
        ### will at least result in an error instead of potentially undefined
        ### behaviour.
        ###
        ### Advanced users can still override this part of the unit to implement
        ### a custom reload handler, since the result of all this is a normal
        ### systemd service from the perspective of the NixOS module system.
        ###
        # ExecReload = ...;
        ###
        ExecStartPre = [ "${preStartScript}/bin/pre-start" ];
        TimeoutStartSec = 0;
        TimeoutStopSec = 120;
        Restart = "always";
        Environment="PODMAN_SYSTEMD_UNIT=podman-${name}.service";
        Type="notify";
        NotifyAccess="all";
        User = user;
        Group = group;
      };
    };
in {

  options.rootless-podman-services = mkOption {
    default = {};
    type = types.attrsOf (types.submodule containerOptions);
    description = "rootless podman containers to run as services by systemd (by root)";
  };

  config = lib.mkIf (cfg != {}) {
    systemd.services = mapAttrs' (n: v: nameValuePair "podman-${n}" (mkService n v)) cfg;
    virtualisation.podman.enable = true;
  };
}
