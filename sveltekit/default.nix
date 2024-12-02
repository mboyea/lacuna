{
  pkgs ? import <nixpkgs> {}
}: let
  nodePackage = builtins.fromJSON (builtins.readFile ./package.json);
  name = nodePackage.name;
  version = nodePackage.version;
in rec {
  packages = {
    dev = pkgs.callPackage ./nix/dev.nix {
      inherit pkgs name version;
    };
    preview = pkgs.callPackage ./nix/preview.nix {
      inherit pkgs name version;
    };
    server = pkgs.callPackage ./nix/server.nix {
      inherit pkgs name version;
    };
    # serverImage = pkgs.callPackage ./nix/server-image.nix {
    #   inherit pkgs name version;
    #   server = packages.server;
    # };
    default = packages.dev;
  };
  devShells.default = import ./shell.nix { inherit pkgs; };
}
