{
  pkgs,
  name,
  version,
}: let
  _name = "${name}-docker-image";
  tag = version;
  # update base image using variables from:
  #   xdg-open https://hub.docker.com/_/postgres/tags
  #   nix-shell -p nix-prefetch-docker
  #   nix-prefetch-docker --quiet --image-name postgres --image-tag 13.18 --image-digest sha256:13ae5ab08d8400b3002da7495978381b83ad094c24f54d7cd7ddebefc5ac9e64
  baseImage = pkgs.dockerTools.pullImage {
    imageName = "postgres";
    imageDigest ="sha256:13ae5ab08d8400b3002da7495978381b83ad094c24f54d7cd7ddebefc5ac9e64";
    finalImageName = "postgres";
    finalImageTag = "13.18";
    sha256 = "07lhm870cd5rd7zl95h0imlr6imkgffjwh88pv6lsz3yz09yqcgv";
    os = "linux";
    arch = "amd64";
  };
in {
  name = _name;
  inherit version tag;
  stream = pkgs.dockerTools.streamLayeredImage {
    name = _name;
    inherit tag;
    fromImage = baseImage;
    enableFakechroot = true;
    fakeRootCommands = ''
      mkdir -p /docker-entrypoint-initdb.d

      cat > /docker-entrypoint-initdb.d/init.sql <<- EOF
        -- CREATE DATABASE IF NOT EXISTS lacuna
        SELECT 'CREATE DATABASE lacuna'
        WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'lacuna')\gexec

        -- USE lacuna
        \c lacuna

        ${builtins.readFile ../schema/init-db.psql}
      EOF
    '';
    config = {
      # Env = [ "POSTGRES_PASSWORD=temp" ];
      # ? podman exec --tty --interactive --latest psql -U postgres lacuna
      Cmd = [ "postgres" ];
      Entrypoint = [ "docker-entrypoint.sh" ];
      ExposedPorts = {
        "5432/tcp" = {};
      };
    };
  };
  
}
