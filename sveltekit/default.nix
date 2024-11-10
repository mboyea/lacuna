{ pkgs ? import <nixpkgs> {} }: let
  nodePackage = builtins.fromJSON (builtins.readFile "../package.json");
  name = nodePackage.name;
  version = nodePackage.version;
in rec {
  packages = {
    dev = pkgs.callPackage ./nix/dev.nix { inherit name version; };
    server = pkgs.callPackage ./nix/server.nix { inherit name version; };
    preview = pkgs.callPackage ./nix/preview.nix { inherit name version; server = packages.server; };
    image = pkgs.callPackage ./nix/image.nix { inherit name version; server = packages.server; };
    default = packages.dev;
  };
  devShells.default = pkgs.mkShell {
    packages = [
      pnpm
      nodejs
    ];
  };
}
