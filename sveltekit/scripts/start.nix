{
  pkgs,
  name,
  version,
}: let
  start = rec {
    dev = pkgs.writeShellApplication {
      name = "${name}-start-dev-${version}";
      runtimeInputs = [
      ];
      text = ''
        echo "TODO implement sveltekit dev script"
      '';
    };
    preview = pkgs.writeShellApplication {
      name = "${name}-start-preview-${version}";
      runtimeInputs = [
      ];
      text = ''
        echo "TODO implement sveltekit preview script"
      '';
    };
    main = pkgs.writeShellApplication {
      name = "${name}-start-main-${version}";
      runtimeInputs = [
        dev
        preview
      ];
      text = ''
        echo_error() {
          echo "Error in start-main:" "$@" 1>&2;
        }
        interpret_args() {
          while [[ $# -gt 0 ]]; do
            case $1 in
              dev)
                : "''${script:="${pkgs.lib.getExe dev}"}"
                shift
              ;;
              preview)
                : "''${script:="${pkgs.lib.getExe preview}"}"
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
