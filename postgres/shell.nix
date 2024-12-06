{
  pkgs ? import <nixpkgs> {}
}: pkgs.mkShell {
  packages = [
    pkgs.postgresql
    pkgs.nix-prefetch-docker  # see server-image.nix
  ];
}
