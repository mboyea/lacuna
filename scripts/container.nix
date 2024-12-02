{
  pkgs ? import <nixpkgs> {},
  name ? "test",
  version ? "0.0.0",
  image,
  ports ? "",
  cliArgs ? []
}: pkgs.writeShellApplication {
  name = "${name}-${image.name}-container-${version}";
  runtimeInputs = [
    pkgs.podman
  ];
  text = ''
    ${image.stream} | podman image load
    podman container run --tty --publish ${ports} localhost/${image.name}:${image.tag} ${pkgs.lib.strings.concatStringsSep " " cliArgs}
  '';
}

