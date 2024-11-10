{ stdenv, packages }: let
  nodePackage = builtins.fromJSON (builtins.readFile "../package.json");
in stdenv.mkDerivation rec {
  pname = "${nodePackage.name}-server";
  version = nodePackage.version;
  src = ./.;
  buildInputs = [];
  buildPhase = ''
    echo "TODO build the server using SvelteKit"
  '';
  installPhase = ''
    mkdir -p $out/bin $out/lib

    echo "TODO install the server built by SvelteKit"
    # cp -rv $src $out/lib

    cat > $out/bin/${pname} << EOF
    #!/bin/sh
    echo "TODO run the server"
    EOF

    chmod +x $out/bin/${pname}
  '';
  meta.mainProgram = "${pname}";
}

