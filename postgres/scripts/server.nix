# {
#   pkgs ? import <nixpkgs> {},
#   name ? "test",
#   version ? "0.0.0",
#   runtimeShell ? pkgs.runtimeShell
# } : let
#   dataDir = "data/postgres";
#   logDir = "${dataDir}/logs";
# in pkgs.stdenv.mkDerivation rec {
#   pname = "${name}-server";
#   inherit version;
#   src = ../.;
#   buildInputs = [
#     pkgs.postgresql
#   ];
#   buildPhase = ''
#     initdb "${dataDir}"
#     # postgres --single -D "${dataDir}" postgres <<-"EOF"
#     # EOF
#     # postgres --single -D "${dataDir}" ${name} <<-"EOF"
#     # EOF
#   '';
#   installPhase = ''
#     mkdir -p "$out/bin" "$out/${dataDir}" "$out/${logDir}"
#     cp -rv "${dataDir}" "$out/${dataDir}"
# 
#     cat > "$out/bin/${pname}" << EOF
#     #!${runtimeShell}
#     echo "TODO: start postgres server"
#     # ? This fails because postgresql isn't a runtime dependency
#     # ? Also I think more is required for the postgres daemon to start
#     pg_ctl -D "$out/${dataDir}" -l "$out/${logDir}" start
#     EOF
# 
#     chmod +x $out/bin/${pname}
#   '';
#   meta.mainProgram = "${pname}";
# }
