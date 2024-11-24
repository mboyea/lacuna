{ pkgs, name, version, server }: let
  name = "${name}-server-image";
  tag = version;
  baseImage = null;
in {
  inherit name version tag;
  stream = pkgs.dockerTools.streamLayeredImage {
    inherit name tag;
    fromImage = baseImage;
    contents = [ server ];
    config = {
      Cmd = [ "${pkgs.lib.getExe server}" ];
      ExposedPorts = {
        "4173/tcp" = {};
      };
    };
  }
}
