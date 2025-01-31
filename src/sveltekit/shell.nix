{
  pkgs ? import <nixpkgs> {}
}: pkgs.mkShell {
  packages = [
    pkgs.nodejs
    pkgs.prefetch-npm-deps    # see server.nix
    pkgs.nix-prefetch-docker  # see docker-image.nix
  ];
}
