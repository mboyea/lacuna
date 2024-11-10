{ pkgs, lib, name, version, server }: let
  name = "${name}-image";
  tag = version;
  baseImage = null;
in {
  inherit name version tag;
  stream = pkgs.dockerTools.streamLayeredImage {
    inherit name tag;
    fromImage = baseImage;
    contents = [ server ];
    config = {
      Cmd = [ "${lib.getExe server}" ];
      ExposedPorts = {
        "4173/tcp" = {};
      };
    };
  }
}
