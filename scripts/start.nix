{
  pkgs,
  name,
  version,
  webServer,
  database,
  envFiles ? []
  cliArgs ? []
}: let
  _name = "${name}-start-${version}";
  loadEnvText = ''
    go_to_top_level_directory() {
      # if git is not installed, return
      if ! [ -x "$(command -v git)" ]; then
        return
      fi
      # if current directory is not a git directory, return
      if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return
      fi
      # go to top-level of git directory
      base_dir="$(git rev-parse --show-toplevel)"
      cd "$base_dir"
    }
    load_env_files() {
      go_to_top_level_directory
      # for each file
      while [[ $# -gt 0 ]]; do
        # if file isn't readable, continue
        if [ ! -r "$1" ]; then
          shift
          continue
        fi
        # load file
        set -a
        # shellcheck disable=SC1091 source=/dev/null
        source "$1"
        set +a
        shift
      done
    }
    load_env_files ${pkgs.lib.strings.concatStringsSep " " envFiles}
  '';
  webServerDockerContainer = let
    image = webServer.dockerImage;
  in pkgs.callPackage ../utils/mk-container.nix {
    inherit pkgs name version image;
    podmanArgs = [
      "--publish" "3000:3000"
      "--env" "VITE*"
    ];
    preStart = ''
      ${loadEnvText}
    '';
  };
  databaseDockerContainer = let
    image = database.dockerImage;
  in pkgs.callPackage ../utils/mk-container.nix {
    inherit pkgs name version image;
    podmanArgs = [
      "--publish" "5432:5432"
      "--env" "POSTGRES*"
    ];
    preStart = ''
      ${loadEnvText}
      flags=$-
      if [[ $flags =~ e ]]; then set +e; fi
      if ! podman volume exists "${image.name}-${image.tag}" > /dev/null 2>&-; then
        podman volume create "${image.name}-${image.tag}"
      fi
      if [[ $flags =~ e ]]; then set -e; fi
    '';
  };
in pkgs.writeShellApplication {
  name = _name;
  runtimeEnv = {
    SCRIPT_NAME = _name;
    ADDITIONAL_CLI_ARGS = pkgs.lib.strings.concatStringsSep " " cliArgs;
    START_WEB_SERVER_CONTAINER = pkgs.lib.getExe webServerDockerContainer;
    START_DATABASE_CONTAINER = pkgs.lib.getExe databaseDockerContainer;
  };
  text = builtins.readFile ./start.sh;
}
