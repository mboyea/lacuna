{
  description = "Lacuna CMS CLI.";
  inputs = {
    # get new revision # using:           git ls-remote https://github.com/<repo_path> | grep HEAD
    # pin dependency to revision # like:  url = "github:numtide/flake-utils?rev=#"
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }: let
    name = "lacuna";
    version = "0.0.0";
    utils = flake-utils;
  in utils.lib.eachDefaultSystem (
    system: let
      pkgs = import nixpkgs { inherit system; };
      # ? TODO use some map function to generate the code for the list of directories
      sveltekit = import ./sveltekit { inherit pkgs; };
      # postgres = import ./postgres { inherit pkgs; };
      # keycloak = import ./keycloak { inherit pkgs; };
      # umami = import ./umami { inherit pkgs; };
    in rec {
      packages = {
        help = pkgs.callPackage ./scripts/help.nix {
          inherit name version;
        };
        # init
        # deploy
        start = pkgs.callPackage ./scripts/start.nix {
          inherit name version;
          webServer = sveltekit.packages;
          # database = postgres.packages;
          # authServer = keycloak.packages;
          # trackingServer = umami.packages;
        };
        default = packages.start;
      };
      apps = {
        help = utils.lib.mkApp { drv = packages.help; };
        # init
        # deploy
        start = utils.lib.mkApp { drv = packages.start; };
        default = utils.lib.mkApp { drv = packages.start.override { cliArgs = [ "dev" ]; }; };
      };
      devShells = {
        sveltekit = sveltekit.devShells.default;
        # postgres = postgres.devShells.default;
        # keycloak = keycloak.devShells.default;
        # umami = umami.devShells.default;
        root = pkgs.mkShell {
          packages = [
            pkgs.podman
            pkgs.psmisc # kill program at PORT using: fuser -k PORT/tcp
            pkgs.gzip
            pkgs.skopeo
          ];
        };
        default = pkgs.mkShell {
          inputsFrom = [
            devShells.root
            devShells.sveltekit
            # devShells.postgres
            # devShells.keycloak
            # devShells.umami
          ];
        };
      };
    }
  );
}
