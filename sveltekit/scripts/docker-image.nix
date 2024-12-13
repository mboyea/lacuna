{
  pkgs ? import <nixpkgs> {},
  name ? "test",
  version ? "0.0.0",
  server ? pkgs.callPackage ./server.nix { inherit pkgs; }
}: let
  name' = "${name}-docker-image";
  tag = version;
  baseImage = null;
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
