{
  pkgs ? import <nixpkgs> {}
}: let
  name = "lacuna-postgres";
  version = "0.0.0";
in rec {
  packages = {
    # dev = pkgs.callPackage ./pkgs/dev.nix {
    #   inherit pkgs name version;
    # };
    dockerImage = pkgs.callPackage ./pkgs/docker-image.nix {
      inherit pkgs name version;
    };
    # default = packages.dev;
  };
  devShells.default = import ./shell.nix { inherit pkgs; };
}
