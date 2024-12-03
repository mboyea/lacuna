{
  pkgs ? import <nixpkgs> {},
  name ? "test",
  version ? "0.0.0",
  server ? pkgs.callPackage ./server.nix { inherit pkgs; }
}: let
  name' = "${name}-server-image";
  tag = version;
  baseImage = null;
  # EXAMPLE:
  # pkgs.dockerTools.pullImage {
  #   # variables to update base image found using:
  #   # xdg-open https://hub.docker.com/_/busybox/tags
  #   # nix develop
  #   # nix-prefetch-docker --quiet --image-name busybox --image-tag 1.37.0 --image-digest sha256:bd39d7ac3f02301aec35d27a633d643770c0c4073c5b8cb588b1680c4f1e84e5
  #   imageName = "busybox";
  #   imageDigest ="sha256:bd39d7ac3f02301aec35d27a633d643770c0c4073c5b8cb588b1680c4f1e84e5";
  #   finalImageName = "busybox";
  #   finalImageTag = "1.37.0";
  #   sha256 = "1rwnka21y7rj8jz250ay7c6mmyja7nngl0ia1z64rbcxq4ylgdvi";
  #   os = "linux";
  #   arch = "amd64";
  # };
in {
  name = name';
  inherit version tag;
  stream = pkgs.dockerTools.streamLayeredImage {
    name = name';
    inherit tag;
    fromImage = baseImage;
    contents = [ server ];
    config = {
      Cmd = [ "${pkgs.lib.getExe server}" ];
      ExposedPorts = {
        "4173/tcp" = {};
      };
    };
  };
}
