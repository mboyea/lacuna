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

# ! Requires package-lock.json, not provided by pnpm
# pkgs.buildNpmPackage {
#   pname = "${name}-server";
#   inherit version;
#   src = ./.;
#   npmBuildScript = "build";
# }

# stdenv.mkDerivation {
#   pname = "${name}-server";
#   inherit version;
#   src = ./.;
#   dontStrip = true;
#   buildInputs = [
#     pkgs.pnpm
#     pkgs.nodejs
#   ];
# #   buildPhase = ''
# #     # TODO build the project mimicking prefetchNpmDeps and then fetchNpmDeps
# #   '';
# #   installPhase = ''
# #     # TODO install the project to a derivation
# #     mkdir -p $out/bin $out/lib
# # 
# #     # cp -rv build $out/lib
# #     # cp -rv $src/build $out/lib
# #   '';
# }
# 
# # ! REFERENCE FOR ABOVE EXAMPLE
# { lib, stdenv, fetchNpmDeps, npmHooks, nodejs }:
# { name ? "${args.pname}-${args.version}"
# , src ? null
# , srcs ? null
# , sourceRoot ? null
# , prePatch ? ""
# , patches ? [ ]
# , postPatch ? ""
# , nativeBuildInputs ? [ ]
# , buildInputs ? [ ]
#   # The output hash of the dependencies for this project.
#   # Can be calculated in advance with prefetch-npm-deps.
# , npmDepsHash ? ""
#   # Whether to force the usage of Git dependencies that have install scripts, but not a lockfile.
#   # Use with care.
# , forceGitDeps ? false
#   # Whether to make the cache writable prior to installing dependencies.
#   # Don't set this unless npm tries to write to the cache directory, as it can slow down the build.
# , makeCacheWritable ? false
#   # The script to run to build the project.
# , npmBuildScript ? "build"
#   # Flags to pass to all npm commands.
# , npmFlags ? [ ]
#   # Flags to pass to `npm ci`.
# , npmInstallFlags ? [ ]
#   # Flags to pass to `npm rebuild`.
# , npmRebuildFlags ? [ ]
#   # Flags to pass to `npm run ${npmBuildScript}`.
# , npmBuildFlags ? [ ]
#   # Flags to pass to `npm pack`.
# , npmPackFlags ? [ ]
#   # Flags to pass to `npm prune`.
# , npmPruneFlags ? npmInstallFlags
#   # Value for npm `--workspace` flag and directory in which the files to be installed are found.
# , npmWorkspace ? null
# , ...
# } @ args:
# 
# let
#   npmDeps = fetchNpmDeps {
#     inherit forceGitDeps src srcs sourceRoot prePatch patches postPatch;
#     name = "${name}-npm-deps";
#     hash = npmDepsHash;
#   };
# 
#   inherit (npmHooks.override { inherit nodejs; }) npmConfigHook npmBuildHook npmInstallHook;
# in
# stdenv.mkDerivation (args // {
#   inherit npmDeps npmBuildScript;
# 
#   nativeBuildInputs = nativeBuildInputs ++ [ nodejs npmConfigHook npmBuildHook npmInstallHook ];
#   buildInputs = buildInputs ++ [ nodejs ];
# 
#   strictDeps = true;
# 
#   # Stripping takes way too long with the amount of files required by a typical Node.js project.
#   dontStrip = args.dontStrip or true;
# 
#   meta = (args.meta or { }) // { platforms = args.meta.platforms or nodejs.meta.platforms; };
# })

# ! node2nix requires you generate a build artifact for it; you have to make a wrapper derivation to do so; this is possible, but overly complicated
# pkgs.stdenv.mkDerivation rec {
#   pname = "${name}-server";
#   inherit version;
#   src = ./.;
#   buildInputs = [
#     pkgs.node2nix
#     pkgs.pnpm
#   ];
#   buildPhase = ''
#     # nix equivalent of pnpm i
#     mkdir ".node2nix"
#     node2nix -i "package.json" -o ".node2nix/node-packages.nix" -c ".node2nix/default.nix" -e ".node2nix/node-env.nix"
#     # pnpm run build
#   '';
#   installPhase = ''
#     mkdir -p $out/bin $out/lib
# 
#     # cp -rv build $out/lib
#     # cp -rv $src/build $out/lib
#     echo "TODO install the server built by SvelteKit"
# 
#     cat > $out/bin/${pname} << EOF
#     #!/bin/sh
#     echo "TODO run the server"
#     EOF
# 
#     chmod +x $out/bin/${pname}
#   '';
#   meta.mainProgram = "${pname}";
# }
