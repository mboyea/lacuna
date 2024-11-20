{
  pkgs,
  name,
  version,
}: let
  start = rec {
    dev = pkgs.writeShellApplication {
      name = "${name}-start-dev-${version}";
      runtimeInputs = [
        pkgs.pnpm
        pkgs.nodejs
        pkgs.git
      ];
      text = ''
        base_dir="$(git rev-parse --show-toplevel)/sveltekit"
        cd "$base_dir"
        pnpm i
        pnpm run dev
      '';
    };
    preview = pkgs.writeShellApplication {
      name = "${name}-start-preview-${version}";
      runtimeInputs = [
        pkgs.pnpm
        pkgs.nodejs
        pkgs.git
      ];
      text = ''
        base_dir="$(git rev-parse --show-toplevel)/sveltekit"
        cd "$base_dir"
        pnpm i
        pnpm run build
        pnpm run preview
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
