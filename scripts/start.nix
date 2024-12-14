{
  pkgs,
  name,
  version,
  webServer,
  database,
  # authServer,
  # trackingServer,
  cliArgs ? []
}: let
  start = let
    webServerImageContainer = pkgs.callPackage ./mk-container.nix {
      inherit pkgs name version;
      image = webServer.dockerImage;
      podmanArgs = [
        "--publish"
        "3000:3000"
      ];
    };
    databaseImageContainer = pkgs.callPackage ./mk-container.nix {
      inherit pkgs name version;
      image = database.dockerImage;
      podmanArgs = [
        "--publish"
        "5432:5432"
        "--env"
        "POSTGRES_PASSWORD=temp"
        # ? TODO: use nix-sops to pull in secrets
        # "POSTGRES_PASSWORD=${"PG_PASSWORD"}"
      ];
    };
  in rec {
    # ? TODO: restructure to use mkDerviation where we declare helpHook, devHook, prodHook, etc
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
        pids=()
        kill_programs() {
          kill "''${pids[@]}"
          # wait "''${pids[@]}"
          # for pid in "''${pids[@]}" ; do
          #   while kill -0 "$pid"; do
          #     sleep 0.1
          #   done
          # done
          # kill "$pid"
          # wait "$pid" 2>/dev/null
        }
        trap kill_programs EXIT
        ${pkgs.lib.getExe databaseImageContainer} "$@" &
        pids+=($!)
        ${pkgs.lib.getExe webServer.dev} "$@"
      '';
    };
    prod = pkgs.writeShellApplication {
      name = "${name}-start-prod-${version}";
      text = ''
        ${pkgs.lib.getExe webServer.server} "$@"
        # TODO ${pkgs.lib.getExe databaseImageContainer} "$@"
      '';
    };
    container = pkgs.writeShellApplication {
      name = "${name}-start-container-${version}";
      text = ''
        ${pkgs.lib.getExe webServerImageContainer} "$@"
        # TODO ${pkgs.lib.getExe databaseImageContainer} "$@"
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
