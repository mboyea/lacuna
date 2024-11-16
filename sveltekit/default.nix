{
  pkgs ? import <nixpkgs> {}
}: let
  nodePackage = builtins.fromJSON (builtins.readFile ./package.json);
  name = nodePackage.name;
  version = nodePackage.version;
in rec {
  packages = {
    start = pkgs.callPackage ./scripts/start.nix {
      inherit pkgs name version;
    };
    default = packages.start;
  };
  devShells.default = import ./shell.nix { inherit pkgs; };
}
