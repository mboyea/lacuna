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
      # "--publish" "3000:3000"
      "--network=host"
      "--env" "POSTGRES_WEBSERVER_USERNAME"
      "--env" "POSTGRES_WEBSERVER_PASSWORD"
      "--env" "POSTGRES_NETLOC"
      "--env" "POSTGRES_PORT"
    ];
    useInteractiveTTY = true;
  };
  databaseDockerContainer = let
    image = database.dockerImage;
  in pkgs.callPackage utils/mk-container.nix {
    inherit pkgs name version image;
    podmanArgs = [
      "--publish" "5432:5432"
      "--env" "POSTGRES*"
      "--volume" "${image.name}-${image.tag}:/var/lib/postgresql/data"
    ];
    preStart = ''
      flags=$-
      if [[ $flags =~ e ]]; then set +e; fi
      # if volume doesn't exist, create one
      if ! podman volume exists "${image.name}-${image.tag}" > /dev/null 2>&-; then
        podman volume create "${image.name}-${image.tag}" > /dev/null 2>&1
        echo "New volume created at ${image.name}-${image.tag}"
      # else volume exists; if schema modified, backup old volume and make a new one
      elif git status --porcelain | grep -q "src/postgres/schema/"; then
        echo "PostgreSQL Database schema appears to be modified; Replacing old volume"
        volume_backup_number=$(($(podman volume ls \
          | grep "${image.name}-${image.tag}" \
          | grep -o "backup.*" \
          | grep -oE '[0-9]+' \
          | sort -n \
          | tail -n 1 \
        ) + 1))
        volume_backup_name="${image.name}-${image.tag}-backup-$volume_backup_number"
        podman volume create "$volume_backup_name" > /dev/null 2>&1
        podman run -it \
          "--volume" "${image.name}-${image.tag}:/from" \
          "--volume" "$volume_backup_name:/to" \
          docker.io/library/bash \
          cp -rpf /from /to
        echo "Copied old volume to $volume_backup_name; Use 'podman volume prune' to delete unused backups"
        podman volume rm --force "${image.name}-${image.tag}" > /dev/null 2>&1
        podman volume create "${image.name}-${image.tag}" > /dev/null 2>&1
        echo "New volume created at ${image.name}-${image.tag}"
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
    START_DEV_WEBSERVER = pkgs.lib.getExe webServer.dev;
    START_DEV_DATABASE = pkgs.lib.getExe databaseDockerContainer;
    START_CONTAINER_WEBSERVER = pkgs.lib.getExe webServerDockerContainer;
    START_CONTAINER_DATABASE = pkgs.lib.getExe databaseDockerContainer;
  };
  text = builtins.readFile ./start.sh;
}
