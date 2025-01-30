# print an error message to the console
echo_error() {
  echo "Error in $SCRIPT_NAME:" "$@" 1>&2;
}

# if the listed env variables aren't found, exit with an error message
test_env() {
  flags=$-
  # if u flag (exit when an undefined variable is used) was set, disable it
  if [[ $flags =~ u ]]; then
    set +u
  fi
  # for each env variable
  while [[ $# -gt 0 ]]; do
    # check that env variable is defined
    if [ -z "${!1}" ]; then
      echo_error "The required environment variable $1 is not defined"
      exit 1
    fi
    shift
  done
  # if u flag was set, re-enable it
  if [[ $flags =~ u ]]; then
    set -u
  fi
}

# use git to go to the base directory of this repository
go_to_top_level_directory() {
  # if git is not installed, return
  if ! [ -x "$(command -v git)" ]; then
    return
  fi
  # if current directory is not a git directory, return
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    return
  fi
  # go to top-level of git directory
  base_dir="$(git rev-parse --show-toplevel)"
  cd "$base_dir"
}

# load env variables from the given files (relative to the base directory)
load_env_files() {
  go_to_top_level_directory
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
}

# print usage instructions for this function
script_start_help() {
  echo "Start the app locally."
  echo
  echo "Usage:"
  echo "  nix run .#start [SCRIPT] | Run the specified script"
  echo
  echo "SCRIPTS:"
  echo "  help --help -h | Print this helpful information"
  echo "  dev            | Run each server with devtools"
  echo "  prod           | Run each server in a container, as similar to the production server as possible"
  echo
  echo "If no argument is given, this help script is run."
  echo "If the first argument corresponds to a script name, that script is run."
  echo "If the first argument is not a recognized script, an error is thrown."
  echo
}

# run a development version of each server locally with hot-reloading where possible
script_start_dev() {
  # $START_DEV_WEB_SERVER "$@"
  # $START_DEV_DATABASE "$@"
  :
}

# run each server in a docker container, as similar to its production environment as possible
script_start_prod() {
  # $START_CONTAINER_WEB_SERVER
  # $START_CONTAINER_DATABASE
  :
}

# get the script to run from arguments passed to this function
interpret_script() {
  # if no arguments passed, run the default script
  if [[ $# -eq 0 ]]; then
    script="script_start_help"
    script_args=("$@")
    return
  fi
  # otherwise run the script specified by the first argument
  case $1 in
    help|--help|-h)
      script="script_start_help"
    ;;
    dev)
      script="script_start_dev"
    ;;
    prod)
      script="script_start_prod"
    ;;
    *)
      echo_error "The argument \"$1\" is not a recognized script; Try \"help\" to show available scripts"
      exit 1
    ;;
  esac
  shift
  script_args=("$@")
}

# entrypoint of this script
main() {
  if [[ -n "${ADDITIONAL_CLI_ARGS// /}" ]]; then
    set -- "$@" "$ADDITIONAL_CLI_ARGS"
  fi
  test_env SCRIPT_NAME ENV_FILES START_DEV_WEB_SERVER START_DEV_DATABASE START_CONTAINER_WEB_SERVER START_CONTAINER_DATABASE
  load_env_files "$ENV_FILES"
  interpret_script "$@"
  eval "$script ${script_args[*]}"
}

main "$@"
