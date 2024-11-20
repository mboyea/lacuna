{
  pkgs,
  name,
  version,
}: let
  start = rec {
    # TODO implement dev and preview scripts
    dev = null;
    preview = null;
    main = pkgs.writeShellApplication {
      name = "${name}-start-main-${version}";
      runtimeInputs = [
        help
      ];
      text = ''
        echo_error() {
          echo "Error in start-main:" "$@" 1>&2;
        }
        interpret_args() {
          while [[ $# -gt 0 ]]; do
            case $1 in
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
