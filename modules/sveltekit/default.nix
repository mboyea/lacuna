{
  pkgs ? import <nixpkgs> {},
}: let
  nodePackage = builtins.fromJSON (builtins.readFile ./package.json);
  name = nodePackage.name;
  version = nodePackage.version;
in rec {
  packages = {
    app = pkgs.callPackage ./packages/app.nix {
      inherit name version;
    };
    appImage = pkgs.callPackage ./packages/app-image.nix {
      inherit name version;
      app = packages.app;
    };
    container = pkgs.callPackage ./packages/container.nix {
      image = packages.appImage;
    };
    dev = pkgs.callPackage ./packages/dev.nix {
      inherit name version;
    };
  };
  devShells.default = import ./shell.nix { inherit pkgs; };
}
