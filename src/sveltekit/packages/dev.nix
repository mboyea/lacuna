{
  pkgs,
  name,
  version,
}: pkgs.writeShellApplication {
  name = "${name}-dev-${version}";
  runtimeInputs = [
    pkgs.nodejs
    pkgs.git
  ];
  text = ''
    base_dir="$(git rev-parse --show-toplevel)/src/sveltekit"
    cd "$base_dir"
    npm i
    npm run dev
  '';
}
