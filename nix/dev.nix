{ pkgs, name, version } : pkgs.writeShellApplication {
  name = "${name}-dev-server-${version}";
  runtimeInputs = [
  ];
  text = ''
    echo 'Hello, World!'
  '';
}

