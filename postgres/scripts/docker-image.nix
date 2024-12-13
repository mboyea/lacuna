{
  pkgs ? import <nixpkgs> {},
  name ? "test",
  version ? "0.0.0",
}: let
  name' = "${name}-docker-image";
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
  name = name';
  inherit version tag;
  stream = pkgs.dockerTools.streamLayeredImage {
    name = name';
    inherit tag;
    fromImage = baseImage;
    fakeRootCommands = ''
      # ? to reproduce, `nix run` and use: podman exec --latest postgres --single postgres
      docker-entrypoint.sh --single postgres <<- EOF
        CREATE DATABASE lacuna'
      EOF
      # # ! currently this errors: "root" execution of the PostgreSQL server is not permitted.
      # postgres --single postgres <<- EOF
      #   SELECT 'CREATE DATABASE lacuna'
      #   WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'lacuna')\gexec
      # EOF
      # postgres --single lacuna <<- EOF
        # $ {builtins.readFile ../schema/init-db.psql}
      # EOF
    '';
    config = {
      # Env = [ "POSTGRES_PASSWORD=temp" ];
      Cmd = [ "postgres" ];
      Entrypoint = [ "docker-entrypoint.sh" ];
      ExposedPorts = {
        "5432/tcp" = {};
      };
    };
  };
  
}
