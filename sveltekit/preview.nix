{ pkgs, name, version }: pkgs.writeShellApplication {
  name = "${name}-preview-${version}";
  runtimeInputs = [
    pkgs.nodejs
    pkgs.pnpm
    pkgs.git
  ];
  text = ''
    base_dir="$(git rev-parse --show-toplevel)/sveltekit"
    cd "$base_dir"
    pnpm i
    pnpm run build
    pnpm run preview
  '';
}
