{
  pkgs ? import <nixpkgs> {}
}: let
  name = "lacuna-postgres";
  version = "0.0.0";
in rec {
  packages = {
    # TODO: link to dev package
    # dev = pkgs.callPackage ./packages/dev.nix {
    #   inherit pkgs name version;
    # };
    dockerImage = pkgs.callPackage ./packages/docker-image.nix {
      inherit pkgs name version;
    };
    # default = packages.dev;
  };
  devShells.default = import ./shell.nix { inherit pkgs; };
}
