{
  pkgs,
  name,
  version,
  runtimeShell ? pkgs.runtimeShell
} : pkgs.buildNpmPackage rec {
  pname = "${name}-server";
  inherit version;
  src = ../.;
  # Generate a new hash using:
  #   nix-shell -p prefetch-npm-deps
  #   prefetch-npm-deps path/to/sveltekit/package-lock.json
  npmDepsHash = "sha256-c2LJSHc3J+/WDxnSaBbbMEIu2VhWlwYYSSN7Rwy5MSM=";
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
