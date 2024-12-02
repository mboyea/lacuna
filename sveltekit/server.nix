{
  pkgs,
  name,
  version
} : pkgs.buildNpmPackage rec {
  pname = "${name}-server";
  inherit version;
  src = ./.;
  # run `nix develop`, then `prefetch-npm-deps path/to/sveltekit/package.json` to generate a new hash
  npmDepsHash = "sha256-miLecgXG6a4mMUA728pBITSgNQSESKnCEyUte73dwX0=";
  npmBuildScript = "build";
  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -rv build $out/lib
    cp -rv package.json $out/lib

    cat > $out/bin/${pname} << EOF
    #!/bin/sh
    ${pkgs.lib.getExe pkgs.nodejs} $out/lib/build
    EOF

    chmod +x $out/bin/${pname}
  '';
  meta.mainProgram = "${pname}";
}
