{
  pkgs,
  name,
  version,
  app,
}: let
  _name = "${name}-app-image";
  tag = version;
  baseImage = null;
in {
  name = _name;
  inherit version tag;
  stream = pkgs.dockerTools.streamLayeredImage {
    name = _name;
    inherit tag;
    fromImage = baseImage;
    config = {
      Entrypoint = [];
      Cmd = [ "${pkgs.lib.getExe app}" ];
      ExposedPorts = {
        "3000/tcp" = {};
      };
    };
  };
}
