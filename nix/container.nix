{ lib, pkgs, name, version, image, ports } : pkgs.writeShellApplication {
  name = "${name}-${image.name}-container-${version}";
  runtimeInputs = [
    image
    pkgs.podman
  ];
  text = ''
    ${image} | podman image load
    podman container run --tty --publish ${ports} localhost/${image.name}:${image.tag}
  '';
}

