{
  pkgs,
  name,
  version,
}: let
  _name = "${name}-docker-image";
  tag = version;
  # update base image using variables from:
  #   xdg-open https://hub.docker.com/r/keycloak/keycloak/tags
  #   nix-shell -p nix-prefetch-docker
  #   nix-prefetch-docker --quiet --image-name keycloak/keycloak --image-tag _ --image-digest _
  baseImage = pkgs.dockerTools.pullImage {
    imageName = "keycloak/keycloak";
    imageDigest = "sha256:75ca4b2e4e954ff89c20ba8e5aeeef3bd0d250847fedb1c9752949823b319dda";
    sha256 = "01f3sp4pvc1n2gh0vi7jbxlm5rpq96fr5vk2dvp7cbqgfwbm1rk9";
    finalImageName = "keycloak/keycloak";
    finalImageTag = "latest";
  };
in {
  name = _name;
  inherit version tag;
  stream = pkgs.dockerTools.streamLayeredImage {
    name = _name;
    inherit tag;
    fromImage = baseImage;
    # TODO: configure keycloak for lacuna
    # enableFakechroot = true;
    # fakeRootCommands = ''
    # '';
    config = {
      Cmd = [ "start" ];
      Entrypoint = [ "/opt/keycloak/bin/kc.sh" ];
      ExposedPorts = {
        "8080/tcp" = {};
        "8443/tcp" = {};
      };
    };
  };
  
}
