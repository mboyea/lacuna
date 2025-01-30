{
  description = "Lacuna CMS CLI.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }: let
    name = "lacuna";
    version = "0.0.0";
    utils = flake-utils;
  in utils.lib.eachDefaultSystem (
    system: let
      # import pkgs from inputs.nixpkgs
      pkgs = import nixpkgs { inherit system; };
      # import submodules from src/
      submodules = pkgs.lib.attrsets.mapAttrs
        (n: v: import (./. + "/src/${n}") { inherit pkgs; })
        (builtins.readDir ./src);
    in rec {
      packages = {
        help = pkgs.callPackage ./scripts/help.nix {
          inherit name version;
        };
        start = pkgs.callPackage ./scripts/start.nix {
          inherit name version;
          webServer = submodules.sveltekit.packages;
          database = submodules.postgres.packages;
          envFiles = [ ".env.development" ]
        };
        default = packages.start;
      };
      apps = {
        help = utils.lib.mkApp { drv = packages.help; };
        start = utils.lib.mkApp { drv = packages.start; };
        default = utils.lib.mkApp {
          drv = packages.start.override { cliArgs = [ "dev" ]; };
        };
      };
      # the default devShell for each submodule is provided
      devShells = (pkgs.lib.attrsets.mapAttrs
        (n: v: v.devShells.default)
        submodules
      ) // {
        # the root devshell provides packages used in scripts/
        root = pkgs.mkShell {
          packages = [
            # kill program at PORT using: fuser -k PORT/tcp
            pkgs.psmisc
            # get sha256 for dockerTools.pullImage using:
            # nix-prefetch-docker --quiet --image-name _ --image-tag _ --image-digest sha256:_
            pkgs.nix-prefetch-docker
            # run docker containers without starting a daemon
            pkgs.podman
          ];
        };
        # the default devShell is a combination of every devShell
        default = pkgs.mkShell {
          inputsFrom = (
            pkgs.lib.attrsets.mapAttrsToList
            (n: v: devShells."${n}")
            submodules
          ) ++ [ devShells.root ];
        };
      };
    }
  );
}
