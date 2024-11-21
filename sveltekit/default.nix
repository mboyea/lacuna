{
  pkgs ? import <nixpkgs> {}
}: let
  nodePackage = builtins.fromJSON (builtins.readFile ./package.json);
  name = nodePackage.name;
  version = nodePackage.version;
in rec {
  packages = {
    dev = pkgs.callPackage ./scripts/dev.nix {
      inherit pkgs name version;
    };
    preview = pkgs.callPackage ./scripts/preview.nix {
      inherit pkgs name version;
    };
    # image = pkgs.callPackage ./scripts/image.nix {
    #   inherit pkgs name version;
    #   server = pkgs.callPackage ./scripts/server.nix {
    #     inherit pkgs name version;
    #   };
    # };
    default = packages.dev;
  };
  devShells.default = import ./shell.nix { inherit pkgs; };
}
