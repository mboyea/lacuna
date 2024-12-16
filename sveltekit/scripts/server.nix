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
  #   nix develop
  #   cd path/to/sveltekit
  #   npm i --package-lock-only
  #   prefetch-npm-deps package-lock.json
  npmDepsHash = "sha256-ThHvyW0noBgoihIZIEzOfmUap4TGv/wj/S9wqJJ8aTA=";
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
