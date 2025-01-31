{
  pkgs ? import <nixpkgs> {}
}: let
  nodePackage = builtins.fromJSON (builtins.readFile ./package.json);
  name = nodePackage.name;
  version = nodePackage.version;
in rec {
  packages = {
    dev = pkgs.callPackage ./pkgs/dev.nix {
      inherit pkgs name version;
    };
    preview = pkgs.callPackage ./pkgs/preview.nix {
      inherit pkgs name version;
    };
    server = pkgs.callPackage ./pkgs/server.nix {
      inherit pkgs name version;
    };
    dockerImage = pkgs.callPackage ./pkgs/docker-image.nix {
      inherit pkgs name version;
      server = packages.server;
    };
    default = packages.dev;
  };
  devShells.default = import ./shell.nix { inherit pkgs; };
}
