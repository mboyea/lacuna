{
  pkgs ? import <nixpkgs> {},
}: pkgs.mkShell {
  packages = [
    pkgs.postgresql_17        # psql
    pkgs.nix-prefetch-docker  # see packages/docker-image.nix
  ];
}
