{ pkgs, name, version }: pkgs.writeShellApplication {
  name = "${name}-deploy-${version}";
  runtimeInputs = [];
  # TODO build dependencies, then deploy production servers to their hosting providers
  text = ''
    echo 'Hello, World!'
  '';
}

