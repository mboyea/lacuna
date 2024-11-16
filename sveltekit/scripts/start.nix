
{
  pkgs,
  name,
  version,
  cliArgs ? []
}: pkgs.writeShellApplication {
  name = "${name}-start-${version}";
  runtimeInputs = [
  ];
  text = ''
    set -- "$@" ${pkgs.lib.strings.concatStringsSep " " cliArgs}
    echo "$@"
  '';
}
