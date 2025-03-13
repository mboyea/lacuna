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
      # import submodules from modules/
      modules = pkgs.lib.attrsets.mapAttrs
        (n: v: import (./. + "/modules/${n}") { inherit pkgs; })
        (builtins.readDir ./modules);
    in rec {
      packages = {
        help = pkgs.callPackage utils/run.nix {
          name = "${name}-${version}-help";
          target = scripts/help.sh;
        };
        start-dev = pkgs.callPackage utils/run.nix {
          name = "${name}-${version}-start-dev";
          target = scripts/start.sh;
          runtimeInputs = [
            pkgs.git
            pkgs.expect
          ];
          runtimeEnv = {
            START_DATABASE = pkgs.lib.getExe modules.postgres.packages.container;
            START_ANALYTICS = pkgs.lib.getExe modules.umami.packages.container;
            START_WEBSERVER = pkgs.lib.getExe modules.sveltekit.packages.dev;
            START_ENV_FILE = ".env.development";
          };
        };
        start-prod = packages.start-dev.override (base: {
          name = "${name}-${version}-start-prod";
          runtimeEnv = base.runtimeEnv // {
            START_DATABASE = pkgs.lib.getExe modules.postgres.packages.container;
            START_ANALYTICS = pkgs.lib.getExe modules.umami.packages.container;
            START_WEBSERVER = pkgs.lib.getExe modules.sveltekit.packages.container;
          };
        });
        deploy = pkgs.callPackage utils/run.nix {
          name = "${name}-${version}-deploy";
          runtimeInputs = [
            pkgs.git
            pkgs.flyctl
            pkgs.gzip
            pkgs.skopeo
          ];
          runtimeEnv = {
            WEBSERVER_IMAGE_NAME = modules.sveltekit.packages.dockerImage.name;
            WEBSERVER_IMAGE_TAG = modules.sveltekit.packages.dockerImage.tag;
            WEBSERVER_IMAGE_STREAM = modules.sveltekit.packages.dockerImage.stream;
            POSTGRES_SCHEMA_DIR = "modules/postgres/schema";
            DEPLOY_ENV_FILE = ".env";
          }
        };
        default = packages.start-dev.override (base: {
          cliArgs = base.cliArgs ++ [ "all" ];
        });
      };
      apps = {
        start-dev = utils.lib.mkApp { drv = packages.start-dev; };
        default = utils.lib.mkApp { drv = packages.default; };
      };
      # the default devShell for each module is provided
      devShells = (pkgs.lib.attrsets.mapAttrs
        (n: v: v.devShells.default)
        modules
      ) // {
        # the root devshell provides packages used in scripts/
        root = pkgs.mkShell {
          packages = [
            # run docker containers without starting a daemon
            pkgs.podman
            # install program unbuffer to preserve formatting when piping to tee
            pkgs.expect
            # kill program at <port> using: fuser -k <port>/tcp
            pkgs.psmisc
            # get information about the project like modified files and 
            pkgs.git
            # manage deployments on hosting provider Fly.io
            pkgs.flyctl
            # zip Docker images for deployment
            pkgs.gzip
            # deploy Docker images to a remote server
            pkgs.skopeo
          ];
        };
        # the default devShell is a combination of every devShell
        default = pkgs.mkShell {
          inputsFrom = (
            pkgs.lib.attrsets.mapAttrsToList
            (n: v: devShells."${n}")
            modules
          ) ++ [ devShells.root ];
        };
      };
    }
  );
}
