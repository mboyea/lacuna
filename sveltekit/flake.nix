{
  description = "A website to show off a custom CMS.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }: let
    nodePackage = builtins.fromJSON (builtins.readFile "./package.json");
    name = nodePackage.name;
    version = nodePackage.version;
    utils = flake-utils;
  in utils.lib.eachDefaultSystem (
    system: let
      pkgs = import nixpkgs { inherit system; };
    in rec {
      packages = {
        dev = pkgs.callPackage ./nix/dev.nix { inherit name version; };
        server = pkgs.callPackage ./nix/server.nix { inherit name version; };
        preview = pkgs.callPackage ./nix/preview.nix { inherit name version; server = packages.server; };
        serverImage = pkgs.callPackage ./nix/image.nix { inherit name version; server = packages.server; };
        default = packages.dev;
      };
      apps = {
        dev = utils.lib.mkApp { drv = packages.dev; };
        preview = utils.lib.mkApp { drv = packages.preview; };
        default = apps.dev;
      };
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.pnpm
          pkgs.nodejs
          pkgs.nix-prefetch-docker
        ];
      };
    }
  );
}
