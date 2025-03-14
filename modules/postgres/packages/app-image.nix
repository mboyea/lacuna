{
  pkgs,
  name,
  version,
}: let
  _name = "${name}-app-image";
  tag = version;
  # update base image using variables from:
  #   xdg-open https://hub.docker.com/_/postgres/tags
  #   nix-prefetch-docker --quiet --image-name postgres --image-tag _ --image-digest _
  baseImage = pkgs.dockerTools.pullImage {
    imageName = "postgres";
    imageDigest = "sha256:3267c505060a0052e5aa6e5175a7b41ab6b04da2f8c4540fc6e98a37210aa2d3";
    sha256 = "1ak032paxr2ainr7wk9sy7zn6lvm4md69h5nm1gpsnnlwng7bcnc";
    finalImageName = "postgres";
    finalImageTag = "17.2";
  };
in {
  name = _name;
  inherit version tag;
  stream = pkgs.dockerTools.streamLayeredImage {
    name = _name;
    inherit tag;
    fromImage = baseImage;
    config = {
      Entrypoint = [ "docker-entrypoint.sh" ];
      Cmd = [ "postgres" ];
      ExposedPorts = {
        "5432/tcp" = {};
      };
      Volumes = {
        "/var/lib/postgresql/data" = {};
      };
    };
  };
}
