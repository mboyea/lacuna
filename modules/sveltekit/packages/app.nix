{
  pkgs,
  name,
  version,
  runtimeShell ? pkgs.runtimeShell,
}: let
  _name = "${name}-app";
in pkgs.buildNpmPackage {
  pname = _name;
  inherit version;
  src = ../.;
  # Generate a new dependency hash using:
  #   prefetch-npm-deps path/to/package-lock.json
  npmDepsHash = "sha256-ILtzGkiTOcNMYX5Ox05VujnU0sXiAzX+SeJ27ofS4jI=";
  npmBuildScript = "build";
  installPhase = ''
    mkdir -p "$out/bin" "$out/lib"
    cp -rv {build,node_modules,package.json} "$out/lib"
    cat > $out/bin/${_name} << EOF
    #!${runtimeShell}
    "${pkgs.lib.getExe pkgs.nodejs}" "$out/lib/build"
    EOF
    chmod +x $out/bin/${_name}
  '';
  meta.mainProgram = "${_name}";
}
