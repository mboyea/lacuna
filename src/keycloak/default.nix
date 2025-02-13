{
  pkgs ? import <nixpkgs> {}
}: let
  name = "lacuna-keycloak";
  version = "0.0.0";
in rec {
  packages = {
    dockerImage = pkgs.callPackage ./packages/docker-image.nix {
      inherit pkgs name version;
    };
  };
  devShells.default = import ./shell.nix { inherit pkgs; };
}
