{
  description = "A website with a custom CMS.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }: let
    nodePackage = builtins.fromJSON (builtins.readFile "./package.json");
    name = nodePackage.name;
    version = nodePackage.version;
  in flake-utils.lib.eachDefaultSystem (
    system: let
      pkgs = import nixpkgs { inherit system; };
      utils = import flake-utils {};
    in rec {
      packages = {
        dev = nixpkgs.callPackage ./nix/dev.nix { inherit name version; };
        server = nixpkgs.callPackage ./nix/server.nix { inherit name version; };
        preview = nixpkgs.callPackage ./nix/preview.nix { inherit name version; server = pkgs.server; };
        image = nixpkgs.callPackage ./nix/image.nix { inherit name version; server = pkgs.server; };
        default = pkgs.dev;
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

