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
    # ${image.stream} | podman image load
    # podman container run --tty --publish ${ports} localhost/${image.name}:${image.tag} ${pkgs.lib.strings.concatStringsSep " " cliArgs}
    echo "TODO: make podman run container"
  '';
}

