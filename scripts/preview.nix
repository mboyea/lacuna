{ pkgs, name, version } : pkgs.writeShellApplication {
  name = "${name}-preview-${version}";
  runtimeInputs = [];
  # TODO build dependencies, then launch docker containers to serve previews for the production servers
  text = ''
    echo 'Hello, World!'
  '';
}

