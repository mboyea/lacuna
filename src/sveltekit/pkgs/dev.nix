{
  pkgs ? import <nixpkgs> {},
  name ? "test",
  version ? "0.0.0",
}: pkgs.writeShellApplication {
  name = "${name}-dev-${version}";
  runtimeInputs = [
    pkgs.nodejs
    pkgs.git
  ];
  text = ''
    base_dir="$(git rev-parse --show-toplevel)/sveltekit"
    cd "$base_dir"
    npm i
    npm run dev
  '';
}
