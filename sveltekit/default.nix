{ nixpkgs ? import <nixpkgs> {} }: let
  nodePackage = builtins.fromJSON (builtins.readFile "./package.json");
  name = nodePackage.name;
  version = nodePackage.version;
in rec {
  pkgs = {
    dev = nixpkgs.callPackage ./nix/dev.nix { inherit name version; };
    server = nixpkgs.callPackage ./nix/server.nix { inherit name version; };
    preview = nixpkgs.callPackage ./nix/preview.nix { inherit name version; server = pkgs.server; };
    image = nixpkgs.callPackage ./nix/image.nix { inherit name version; server = pkgs.server; };
    default = pkgs.dev;
  };
  devShells.default = nixpkgs.mkShell {
    packages = with nixpkgs; [
      pnpm
      nodejs
    ];
  };
}
