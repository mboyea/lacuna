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
    ${pkgs.lib.getExe (webServer.override { inherit cliArgs; })}
  '';
}
