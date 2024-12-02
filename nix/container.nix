{
  pkgs,
  name,
  version,
  image,
  ports,
  cliArgs ? ""
}: pkgs.writeShellApplication {
  name = "${name}-${image.name}-container-${version}";
  runtimeInputs = [
    image
    pkgs.podman
  ];
  text = ''
    ${image.stream} | podman image load
    podman container run --tty --publish ${ports} localhost/${image.name}:${image.tag} ${cliArgs}
  '';
}

