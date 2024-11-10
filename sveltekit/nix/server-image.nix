{ lib, pkgs }: let
  server = pkgs.callPackage ./server.nix {};
in rec {
  name = "${server.pname}-image";
  tag = nodePackage.version;
  stream = pkgs.dockerTools.streamLayeredImage {
    inherit name, tag;
    contents = [
      server
    ];
    config = {
      Cmd = [ "${lib.getExe server}" ];
      ExposedPorts = {
        "4173/tcp" = {};
      };
    };
  };
}

