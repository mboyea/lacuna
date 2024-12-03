{
  pkgs,
  name,
  version,
  webServer,
  # database,
  # authServer,
  # trackingServer,
  cliArgs ? []
}: let
  start = rec {
    # TODO: pull these out into hooks ? perhaps
    help = pkgs.writeShellApplication {
      name = "${name}-start-help-${version}";
      text = ''
        echo "Start the app locally."
        echo
        echo "Usage:"
        echo "  nix run .#start [SCRIPT]"
        echo
        echo "Scripts:"
        echo "  help  --help  -h  Print this helpful information"
        echo "  dev               Run all servers from their source code with hot-reloading where possible, and without Docker where possible"
        echo "  preview           Build the app, then run the build results without Docker where possible"
        echo "  container         Build the app, package it into Docker containers, then run the docker containers"
      '';
    };
    dev = pkgs.writeShellApplication {
      name = "${name}-start-dev-${version}";
      text = ''
        ${pkgs.lib.getExe webServer.dev} "$@"
      '';
    };
    prod = pkgs.writeShellApplication {
      name = "${name}-start-prod-${version}";
      text = ''
        ${pkgs.lib.getExe webServer.server} "$@"
      '';
    };
    container = pkgs.writeShellApplication {
      name = "${name}-start-container-${version}";
      text = let
        serverImageContainer = pkgs.callPackage ./mk-container.nix {
          inherit pkgs name version;
          image = webServer.serverImage;
          ports = "3000:3000";
        };
      in ''
        ${pkgs.lib.getExe serverImageContainer} "$@"
      '';
    };
    main = pkgs.writeShellApplication {
      name = "${name}-start-main-${version}";
      text = ''
        set -- "$@" ${pkgs.lib.strings.concatStringsSep " " cliArgs}

        echo_error() {
          echo "Error in start-main:" "$@" 1>&2;
        }

        interpret_args() {
          while [[ $# -gt 0 ]]; do
            case $1 in
              help|--help|-h)
                : "''${script:="${pkgs.lib.getExe help}"}"
                shift
              ;;
              dev)
                : "''${script:="${pkgs.lib.getExe dev}"}"
                shift
              ;;
              prod)
                : "''${script:="${pkgs.lib.getExe prod}"}"
                shift
              ;;
              container)
                : "''${script:="${pkgs.lib.getExe container}"}"
                shift
              ;;
              *)
                additional_args+=("$1")
                shift
              ;;
            esac
          done
          set -- "''${additional_args[@]}"
        }

        main() {
          interpret_args "$@"
          if [[ -n "''${script:-}" ]]; then
            "$script" "''${additional_args[@]}"
          else
            echo_error "No valid script identified among arguments:" "''${additional_args[@]}"
            exit 1
          fi
        }

        main "$@"
      '';
    };
  };
in start.main
