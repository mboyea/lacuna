{
  pkgs ? import <nixpkgs> {}
}: let
  name = "lacuna-postgres";
  version = "0.0.0";
in rec {
  packages = {
    # dev = pkgs.callPackage ./scripts/dev.nix {
    #   inherit pkgs name version;
    # };
    # server = pkgs.callPackage ./scripts/server.nix {
    #   inherit pkgs name version;
    # };
    dockerImage = pkgs.callPackage ./scripts/docker-image.nix {
      inherit pkgs name version;
    };
    # default = packages.server;
  };
  devShells.default = import ./shell.nix { inherit pkgs; };
}
