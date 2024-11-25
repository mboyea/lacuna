{ pkgs, name, version } : pkgs.stdenv.mkDerivation rec {
  pname = "${name}-server";
  inherit version;
  src = ./.;
  buildInputs = [
    pkgs.pnpm
  ];
  buildPhase = ''
    # pnpm i
    # pnpm run build
  '';
  installPhase = ''
    mkdir -p $out/bin $out/lib

    # cp -rv build $out/lib
    # cp -rv $src/build $out/lib
    echo "TODO install the server built by SvelteKit"


    cat > $out/bin/${pname} << EOF
    #!/bin/sh
    echo "TODO run the server"
    EOF

    chmod +x $out/bin/${pname}
  '';
  meta.mainProgram = "${pname}";
}

