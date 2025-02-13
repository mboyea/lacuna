{
  pkgs ? import <nixpkgs> {}
}: pkgs.mkShell {
  packages = [
    pkgs.keycloak
    pkgs.nix-prefetch-docker  # see pkgs/docker-image.nix
  ];
}
