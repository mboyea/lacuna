{ pkgs, name, version }: pkgs.writeShellApplication {
  name = "${name}-dev-${version}";
  runtimeInputs = [
    pkgs.nodejs
    pkgs.pnpm
  ];
  text = ''
    #!/bin/sh
    pnpm run dev
  '';
}
