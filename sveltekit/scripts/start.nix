{
  pkgs,
  name,
  version,
}: let
  start = rec {
    # TODO: move help script out into lacuna/scripts/start.nix
    help = pkgs.writeShellApplication {
      name = "${name}-start-help-${version}";
      runtimeInputs = [];
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
    # TODO implement dev and preview scripts
    dev = null;
    preview = null;
    main = pkgs.writeShellApplication {
      name = "${name}-start-main-${version}";
      runtimeInputs = [
        help
      ];
      text = ''
        echoerror() {
          echo "Error in start-main:" "$@" 1>&2;
        }
        interpret_args() {
          while [[ $# -gt 0 ]]; do
            case $1 in
              help|--help|-h)
                : "''${script:="${pkgs.lib.getExe help}"}"
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
            echoerror "No valid script identified among arguments:" "''${additional_args[@]}"
            exit 1
          fi
        }
        main "$@"
      '';
    };
  };
in start.main
# pkgs.stdenv.mkDerivation rec {
#   pname = "${name}-start";
#   inherit version;
#   src = ./.;
#   phases = [ "installPhase" ];
#   buildInputs = [
#     start.main
#   ];
#   installPhase = ''
#     mkdir -p $out/bin/
#     cp ${pkgs.lib.getExe start.main} $out/bin/main.sh
#     chmod +x $out/bin/main.sh
#   '';
#   meta.mainProgram = "main.sh";
# }
