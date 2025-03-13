#----------------------------------------
# Description: Use writeShellApplication to shellcheck & execute an existing script
# ? https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/build-support/trivial-builders/default.nix#L193
# Usage: 
# pkgs.callPackage utils/run.nix {
#   name = "${name}-${version}-help";
#   target = scripts/help.sh;
# };
# Origin: https://github.com/mboyea/www-mboyea-com
# Author: Matthew Boyea
#----------------------------------------
{
  pkgs,
  stdenv,
  name,
  target,
  runtimeInputs ? [],
  runtimeEnv ? null,
  envFiles ? [],
  meta ? {},
  passthru ? {},
  excludeShellChecks ? [],
  extraShellCheckFlags ? [],
  derivationArgs ? {},
  cliArgs ? [],
}: pkgs.writeShellApplication {
  inherit name runtimeInputs runtimeEnv meta passthru derivationArgs;
  checkPhase = let
    # GHC (=> shellcheck) isn't supported on some platforms (such as risc-v)
    # but we still want to use writeShellApplication on those platforms
    shellcheckSupported = pkgs.lib.meta.availableOn stdenv.buildPlatform pkgs.shellcheck-minimal.compiler && (builtins.tryEval pkgs.shellcheck-minimal.compiler.outPath).success;
    excludeFlags = pkgs.lib.optionals (excludeShellChecks != [ ]) [ "--exclude" (pkgs.lib.concatStringsSep "," excludeShellChecks) ];
    shellcheckCommand = pkgs.lib.optionalString shellcheckSupported ''
      # use shellcheck which does not include docs
      # pandoc takes long to build and documentation isn't needed for just running the cli
      ${pkgs.lib.getExe pkgs.shellcheck-minimal} ${pkgs.lib.escapeShellArgs (excludeFlags ++ extraShellCheckFlags)} "${target}"
    '';
  in ''
    runHook preCheck
    if [ -d "${target}" ]; then
      echo "Error: Path \"${target}\" is a directory, not a file" 1>&2
      exit 1
    elif [ ! -f "${target}" ]; then
      echo "Error: File \"${target}\" does not exist" 1>&2
      echo "Perhaps you need to run \"git add\" on the source file" 1>&2
      exit 1
    elif [ ! -r "${target}" ]; then
      echo "Error: File \"${target}\" is not readable" 1>&2
      exit 1
    elif [ ! -x "${target}" ]; then
      echo "Error: File \"${target}\" is not executable" 1>&2
      echo "Perhaps you need to run \"chmod +x\" on the source file" 1>&2
      exit 1
    fi
    ${stdenv.shellDryRun} "${target}"
    ${shellcheckCommand}
    runHook postCheck
  '';
  text = ''
    go_to_base_directory() {
      # if current directory is not a git directory, return
      if ! "${pkgs.lib.getExe pkgs.git}" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return
      fi
      # go to the base of the git directory
      cd "$("${pkgs.lib.getExe pkgs.git}" rev-parse --show-toplevel)"
    }
    load_env_files() {
      go_to_base_directory
      # for each file
      while [[ $# -gt 0 ]]; do
        # if file isn't readable, continue
        if [ ! -r "$1" ]; then
          shift
          continue
        fi
        # load file
        set -a
        # shellcheck disable=SC1091 source=/dev/null
        source "$1"
        set +a
        shift
      done
      cd - > /dev/null
    }
    load_env_files ${pkgs.lib.strings.concatStringsSep " " envFiles}
    "${target}" "$@" ${pkgs.lib.strings.concatStringsSep " " cliArgs}
  '';
}
