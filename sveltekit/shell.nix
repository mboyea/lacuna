{
  pkgs ? import <nixpkgs> {}
}: pkgs.mkShell {
  packages = [
    pkgs.nix-prefetch-docker
    pkgs.nodejs
  ];
}
