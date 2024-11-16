{
  pkgs,
  name,
  version,
  webServer,
  # database,
  # authServer,
  # trackingServer,
  cliArgs ? []
}: pkgs.writeShellApplication {
  name = "${name}-start-${version}";
  runtimeInputs = [
    webServer
  ];
  text = ''
    set -- "$@" ${pkgs.lib.strings.concatStringsSep " " cliArgs}
    ${pkgs.lib.getExe webServer} "$@"
  '';
}
