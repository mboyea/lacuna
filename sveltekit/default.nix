{
  pkgs ? import <nixpkgs> {}
}: let
  nodePackage = builtins.fromJSON (builtins.readFile ./package.json);
  name = nodePackage.name;
  version = nodePackage.version;
in rec {
  packages = {
    dev = pkgs.callPackage ./scripts/dev.nix {
      inherit pkgs name version;
    };
    preview = pkgs.callPackage ./scripts/preview.nix {
      inherit pkgs name version;
    };
    server = pkgs.callPackage ./scripts/server.nix {
      inherit pkgs name version;
    };
    serverImage = pkgs.callPackage ./scripts/server-image.nix {
      inherit pkgs name version;
      server = packages.server;
    };
    default = packages.dev;
  };
  devShells.default = import ./shell.nix { inherit pkgs; };
}
