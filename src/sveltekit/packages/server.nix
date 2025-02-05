{
  pkgs,
  name,
  version,
  runtimeShell ? pkgs.runtimeShell,
  # TODO: consider switching back to pnpm: https://nixos.org/manual/nixpkgs/stable/#javascript-pnpm
} : pkgs.buildNpmPackage rec {
  pname = "${name}-server";
  inherit version;
  src = ../.;
  # Generate a new hash using:
  #   nix-shell -p prefetch-npm-deps
  #   prefetch-npm-deps path/to/sveltekit/package-lock.json
  npmDepsHash = "sha256-gW8EhY8EpdwqDQbqxm3f4LYQN6RoevwmIJAz7k8DwkU=";
  npmBuildScript = "build";
  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -rv build $out/lib
    cp -rv package.json $out/lib
    cp -rv node_modules $out/lib

    cat > $out/bin/${pname} << EOF
    #!${runtimeShell}
    ${pkgs.lib.getExe pkgs.nodejs} $out/lib/build
    EOF

    chmod +x $out/bin/${pname}
  '';
  meta.mainProgram = "${pname}";
}
