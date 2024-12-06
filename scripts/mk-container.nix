{
  pkgs,
  name,
  version,
  image,
  ports ? "",
  cliArgs ? []
}: pkgs.writeShellApplication {
  name = "${name}-${image.name}-mk-container-${version}";
  runtimeInputs = [
    pkgs.podman
  ];
  text = ''
    # TODO generate image stream at compile time
    ${image.stream} | podman image load
    podman container run --tty --detach --publish ${ports} localhost/${image.name}:${image.tag} ${pkgs.lib.strings.concatStringsSep " " cliArgs}
    podman container attach --latest
  '';
}
