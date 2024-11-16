{
  pkgs ? import <nixpkgs> {}
}: pkgs.mkShell {
  packages = [
    pkgs.pnpm
    pkgs.nodejs
    pkgs.nix-prefetch-docker
  ];
}
