{
  pkgs ? import <nixpkgs> {},
  name ? "test",
  version ? "0.0.0",
  runtimeShell ? pkgs.runtimeShell
} : pkgs.buildNpmPackage rec {
  pname = "${name}-server";
  inherit version;
  src = ../.;
  # Generate a new hash using:
  #   nix-shell -p prefetch-npm-deps
  #   prefetch-npm-deps path/to/sveltekit/package-lock.json
  npmDepsHash = "sha256-XwHQc8NkoiWmCW4g7bBis+m1lC7IunRyzoKFe+SrLfQ=";
  npmBuildScript = "build";
  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -rv build $out/lib
    cp -rv package.json $out/lib

    cat > $out/bin/${pname} << EOF
    #!${runtimeShell}
    ${pkgs.lib.getExe pkgs.nodejs} $out/lib/build
    EOF

    chmod +x $out/bin/${pname}
  '';
  meta.mainProgram = "${pname}";
}
