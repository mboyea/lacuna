{
  pkgs ? import <nixpkgs> {}
}: let
  nodePackage = builtins.fromJSON (builtins.readFile ./package.json);
  name = nodePackage.name;
  version = nodePackage.version;
in rec {
  packages = {
    dev = pkgs.callPackage ./packages/dev.nix {
      inherit pkgs name version;
    };
    preview = pkgs.callPackage ./packages/preview.nix {
      inherit pkgs name version;
    };
    server = pkgs.callPackage ./packages/server.nix {
      inherit pkgs name version;
    };
    dockerImage = pkgs.callPackage ./packages/docker-image.nix {
      inherit pkgs name version;
      server = packages.server;
    };
    default = packages.dev;
  };
  devShells.default = import ./shell.nix { inherit pkgs; };
}
