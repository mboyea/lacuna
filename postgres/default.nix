{
  pkgs ? import <nixpkgs> {}
}: let
  name = "lacuna-postgres";
  version = "0.0.0";
in rec {
  packages = {
    # server = pkgs.callPackage ./scripts/server.nix {
    #   inherit pkgs name version;
    # };
    serverImage = pkgs.callPackage ./scripts/server-image.nix {
      inherit pkgs name version;
    };
    # default = packages.server;
  };
  devShells.default = import ./shell.nix { inherit pkgs; };
}
