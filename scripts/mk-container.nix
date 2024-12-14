{
  pkgs,
  name,
  version,
  image,
  imageArgs ? [],
  podmanArgs ? []
}: pkgs.writeShellApplication {
  name = "${name}-${image.name}-mk-container-${version}";
  runtimeInputs = [
    pkgs.podman
  ];
  text = ''
    ${image.stream} | podman image load
    podman container run --tty --detach ${pkgs.lib.strings.concatStringsSep " " podmanArgs} localhost/${image.name}:${image.tag} ${pkgs.lib.strings.concatStringsSep " " imageArgs}
    podman container attach --latest
  '';
}
