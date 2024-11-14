{ stdenv, pkgs, name, version } : stdenv.mkDerivation rec {
  pname = "${name}-server";
  inherit version;
  src = ./.;
  buildInputs = [ pnpm nodejs ];
  buildPhase = ''
    pnpm run build
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

