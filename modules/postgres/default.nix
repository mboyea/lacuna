{
  pkgs ? import <nixpkgs> {},
}: let
  name = "lacuna-database";
  version = "0.17.2";
in rec {
  packages = {
    appImage = pkgs.callPackage ./packages/app-image.nix {
      inherit name version;
    };
    container = pkgs.callPackage ./packages/container.nix {
      image = packages.appImage;
    };
  };
  devShells.default = import ./shell.nix { inherit pkgs; };
}
