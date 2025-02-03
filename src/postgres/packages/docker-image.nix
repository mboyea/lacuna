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
  #   nix-prefetch-docker --quiet --image-name postgres --image-tag _ --image-digest _
  baseImage = pkgs.dockerTools.pullImage {
    imageName = "postgres";
    imageDigest = "sha256:68bb947ec37e6cfd5486c51ecdd122babc3ddaedb490acb913130a7e325d36c5";
    sha256 = "082f0q16gfark1yrh8ms7a10wpjqx9x1zpzvskr0bw1jnv249jia";
    finalImageName = "postgres";
    finalImageTag = "15";
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

      cat > /docker-entrypoint-initdb.d/init.sql << 'EOF'
        -- CREATE DATABASE IF NOT EXISTS lacuna
        SELECT 'CREATE DATABASE lacuna'
        WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'lacuna')\gexec

        -- USE lacuna
        \c lacuna

        -- CREATE USER IF NOT EXISTS $POSTGRES_WEBSERVER_USERNAME WITH PASSWORD $POSTGRES_WEBSERVER_PASSWORD
        \getenv webserver_password POSTGRES_WEBSERVER_PASSWORD
        \getenv webserver_username POSTGRES_WEBSERVER_USERNAME
        \set do 'BEGIN\n  CREATE USER ' :webserver_username ' WITH PASSWORD ' :'webserver_password' ';  EXCEPTION WHEN duplicate_object THEN RAISE NOTICE '''%, skipping''', SQLERRM USING ERRCODE = SQLSTATE;\nEND'
        DO :'do';
        \unset do

        ${builtins.readFile ../schema/init-db.psql}
      EOF
    '';
    config = {
      Cmd = [ "postgres" ];
      Entrypoint = [ "docker-entrypoint.sh" ];
      ExposedPorts = {
        "5432/tcp" = {};
      };
    };
  };
  
}
