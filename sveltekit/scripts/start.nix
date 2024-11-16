
{
  pkgs,
  name,
  version,
}: pkgs.writeShellApplication {
  name = "${name}-start-${version}";
  runtimeInputs = [
  ];
  text = ''
    echo "$@"
  '';
}
