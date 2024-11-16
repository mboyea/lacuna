
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
    echo "cliArgs = \"${pkgs.lib.strings.concatStringsSep " " cliArgs}\""
  '';
}
