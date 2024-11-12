{ pkgs, name, version }: pkgs.writeShellApplication {
  name = "${name}-dev-${version}";
  runtimeInputs = [];
  # TODO launch docker containers to serve source code on development servers
  text = ''
    echo 'Hello, World!'
  '';
}

