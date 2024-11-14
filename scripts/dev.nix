{ pkgs, name, version, system, webServer }: pkgs.writeShellApplication {
  name = "${name}-dev-${version}";
  runtimeInputs = [
    webServer
  ];
  # TODO launch docker containers to serve development servers and launch hot-reloading web server with vite
  text = ''
    ${pkgs.lib.getExe webServer.packages.${system}.dev}
  '';
}

