{
  pkgs,
  name,
  version,
  webServer,
  database,
  envFiles ? [],
  cliArgs ? [],
}: let
  _name = "${name}-start-${version}";
  webServerDockerContainer = let
    image = webServer.dockerImage;
  in pkgs.callPackage utils/mk-container.nix {
    inherit pkgs name version image;
    podmanArgs = [
      "--publish" "3000:3000"
      "--env" "VITE*"
    ];
  };
  databaseDockerContainer = let
    image = database.dockerImage;
  in pkgs.callPackage utils/mk-container.nix {
    inherit pkgs name version image;
    podmanArgs = [
      "--publish" "5432:5432"
      "--env" "POSTGRES*"
    ];
    preStart = ''
      flags=$-
      if [[ $flags =~ e ]]; then set +e; fi
      if ! podman volume exists "${image.name}-${image.tag}" > /dev/null 2>&-; then
        podman volume create "${image.name}-${image.tag}"
      fi
      if [[ $flags =~ e ]]; then set -e; fi
    '';
    useInteractiveTTY = false;
  };
in pkgs.writeShellApplication {
  name = _name;
  runtimeEnv = {
    SCRIPT_NAME = _name;
    ADDITIONAL_CLI_ARGS = pkgs.lib.strings.concatStringsSep " " cliArgs;
    ENV_FILES = pkgs.lib.strings.concatStringsSep " " envFiles;
    START_DEV_WEB_SERVER = pkgs.lib.getExe webServer.dev;
    START_DEV_DATABASE = "echo TODO";#pkgs.lib.getExe database.dev;
    START_CONTAINER_WEB_SERVER = pkgs.lib.getExe webServerDockerContainer;
    START_CONTAINER_DATABASE = pkgs.lib.getExe databaseDockerContainer;
  };
  text = builtins.readFile ./start.sh;
}
