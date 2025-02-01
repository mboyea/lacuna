{
  pkgs ? import <nixpkgs> {}
}: pkgs.mkShell {
  packages = [
    pkgs.postgresql
    pkgs.nix-prefetch-docker  # see pkgs/docker-image.nix
  ];
}
