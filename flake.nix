{
  description = "A website with a custom CMS.";
  # # NOTE: you cannot generate inputs, they must be hard-coded
  # # https://www.reddit.com/r/NixOS/comments/1delm85/flakenix_errors_with_expected_a_set_but_got_a/
  # # Otherwise, I would use the following:
  # inputs = {
  #   # REMOTE INPUTS
  #   # get new revision # using:           git ls-remote https://github.com/<repo_path> | grep HEAD
  #   # pin dependency to revision # like:  url = "github:numtide/flake-utils?rev=#"
  #   nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  #   flake-utils.url = "github:numtide/flake-utils";
  # } // builtins.mapAttrs (
  #   packageName: directory: {
  #     url = "git+file:.?dir=" + directory;
  #     inputs.nixpkgs.follows="nixpkgs";
  #     inputs.flake-utils.follows="flake-utils";
  #   }
  # ) {
  #   # LOCAL INPUTS
  #   webServer = "sveltekit";
  #   databaseServer = "postgresql";
  #   authServer = "keycloak";
  #   analyticsServer = "umami";
  # };
  inputs = {
    # REMOTE INPUTS
    # get new revision # using:           git ls-remote https://github.com/<repo_path> | grep HEAD
    # pin dependency to revision # like:  url = "github:numtide/flake-utils?rev=#"
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    # LOCAL INPUTS
    webServer = {
      url = "git+file:.?dir=sveltekit";
      inputs.nixpkgs.follows="nixpkgs";
      inputs.flake-utils.follows="flake-utils";
    };
    # databaseServer = {
    #   url = "git+file:.?dir=postgresql";
    #   inputs.nixpkgs.follows="nixpkgs";
    #   inputs.flake-utils.follows="flake-utils";
    # };
    # authServer = {
    #   url = "git+file:.?dir=keycloak";
    #   inputs.nixpkgs.follows="nixpkgs";
    #   inputs.flake-utils.follows="flake-utils";
    # };
    # analyticsServer = {
    #   url = "git+file:.?dir=umami";
    #   inputs.nixpkgs.follows="nixpkgs";
    #   inputs.flake-utils.follows="flake-utils";
    # };
  };
  outputs = { self, nixpkgs, flake-utils, webServer, ... }: let
    name = "lacuna";
    version = "0.0.0";
  in flake-utils.lib.eachDefaultSystem (
    system: let
      pkgs = import nixpkgs { inherit system; };
      utils = import flake-utils {};
    in rec {
      packages = {
        dev = pkgs.callPackage ./scripts/dev.nix { inherit name version; };
        preview = pkgs.callPackage ./scripts/preview.nix { inherit name version; };
        deploy = pkgs.callPackage ./scripts/deploy.nix { inherit name version; };
        default = packages.dev;
      };
      apps = {
        dev = utils.lib.mkApp { drv = packages.dev; };
        preview = utils.lib.mkApp { drv = packages.preview; };
        deploy = utils.lib.mkApp { drv = packages.deploy; };
        default = apps.dev;
      };
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.podman
          pkgs.gzip
          pkgs.skopeo
        ];
        inputsFrom = [
          webServer.devShells.${system}.default
          # databaseServer.devShells.${system}.default
          # authServer.devShells.${system}.default
          # analyticsServer.devShells.${system}.default
        ];
      };
    }
  );
}
