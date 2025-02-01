{
  pkgs ? import <nixpkgs> {}
}: pkgs.mkShell {
  packages = [
    pkgs.nodejs
    pkgs.prefetch-npm-deps    # see pkgs/server.nix
  ];
}
