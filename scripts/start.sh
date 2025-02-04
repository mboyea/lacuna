# print an error message to the console
echo_error() {
  echo "Error in $SCRIPT_NAME:" "$@" 1>&2;
}

# print input with a given label
echo_label() {
  while read -r l; do
    echo "$1 | $l"
  done
}

# run a development version of each server locally with hot-reloading where possible
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

# kill each process in process_ids
process_ids=()
kill_processes() {
  # send kill signal to each process
  for process_id in "${process_ids[@]}"; do
    kill "$process_id" > /dev/null 2>&1
  done
  # wait for each process to exit
  for process_id in "${process_ids[@]}"; do
    wait "$process_id" 2>/dev/null
  done
}

# script to print usage instructions for the start scripts
script_start_help() {
  echo "Start the app locally."
  echo
  echo "Usage:"
  echo "  nix run .#start          | Alias for \"nix run .#start help\""
  echo "  nix run .#start [SCRIPT] | Run the specified script"
  echo
  echo "SCRIPTS:"
  echo "  help --help -h | Print this helpful information"
  echo "  dev            | Start each server using devtools"
  echo "  prod           | Start each server in a container, as similar to the production server as possible"
  echo
}

# script to start each server using devtools
script_start_dev() {
  # check database env
  test_env POSTGRES_PASSWORD POSTGRES_WEBSERVER_USERNAME POSTGRES_WEBSERVER_PASSWORD
  # start database process
  database_log_file="$(mktemp)"
  "$START_DEV_DATABASE" 2>&1 | tee "$database_log_file" | echo_label "DAT" & process_ids+=($!)
  database_process_id="${process_ids[-1]}"
  # wait for the database to initialize and be ready to accept connections
  until \
    grep -q "^.*\[1\].*database system is ready to accept connections" "$database_log_file"
  do
    if ! ps -p "$database_process_id" > /dev/null; then
      echo_error "The database failed to start"
      exit 1
    fi
    sleep 0.1
  done
  # check that the database is accessible at port 5432
  if ! netstat -tulpn 2>&1 | grep ":5432 " > /dev/null 2>&1; then
    echo_error "The database did not bind to port 5432"
    exit 1
  fi
  # check webserver env
  test_env POSTGRES_WEBSERVER_USERNAME POSTGRES_WEBSERVER_PASSWORD
  : "${POSTGRES_NETLOC:="localhost"}"
  : "${POSTGRES_PORT:="5432"}"
  # get webserver env
  webserver_env=(
    POSTGRES_WEBSERVER_USERNAME
    POSTGRES_WEBSERVER_PASSWORD
    POSTGRES_NETLOC
    POSTGRES_PORT
  )
  for i in "${!webserver_env[@]}"; do
    webserver_env[i]="${webserver_env[i]}=${!webserver_env[i]}"
  done
  # start webserver as main process
  env "${webserver_env[@]}" "$START_DEV_WEBSERVER" 2>&1 | echo_label "WEB"
}

# script to start each server in a container, as similar to the production server as possible
script_start_prod() {
  # check database env
  test_env POSTGRES_PASSWORD POSTGRES_WEBSERVER_USERNAME POSTGRES_WEBSERVER_PASSWORD
  # start database process
  database_log_file="$(mktemp)"
  "$START_CONTAINER_DATABASE" 2>&1 | tee "$database_log_file" | echo_label "DAT" & process_ids+=($!)
  database_process_id="${process_ids[-1]}"
  # wait for the database to initialize and be ready to accept connections
  until \
    grep -q "^.*\[1\].*database system is ready to accept connections" "$database_log_file"
  do
    if ! ps -p "$database_process_id" > /dev/null; then
      echo_error "The database failed to start"
      exit 1
    fi
    sleep 0.1
  done
  # check that the database is accessible at port 5432
  if ! netstat -tulpn 2>&1 | grep ":5432 " > /dev/null 2>&1; then
    echo_error "The database did not bind to port 5432"
    exit 1
  fi
  # check webserver env
  test_env POSTGRES_WEBSERVER_USERNAME POSTGRES_WEBSERVER_PASSWORD
  : "${POSTGRES_NETLOC:="localhost"}"
  : "${POSTGRES_PORT:="5432"}"
  # get webserver env
  webserver_env=(
    POSTGRES_WEBSERVER_USERNAME
    POSTGRES_WEBSERVER_PASSWORD
    POSTGRES_NETLOC
    POSTGRES_PORT
  )
  for i in "${!webserver_env[@]}"; do
    webserver_env[i]="${webserver_env[i]}=${!webserver_env[i]}"
  done
  # start webserver as main process
  env "${webserver_env[@]}" "$START_CONTAINER_WEBSERVER" 2>&1 | echo_label "WEB"
  # # start background processes
  # "$START_CONTAINER_DATABASE" 2>&1 | echo_label "DATABASE" & process_ids+=($!)
  # database_process_id="${process_ids[-1]}"
  # # until the database is accessible at port 5432
  # until netcat -z "localhost" "5432" > /dev/null 2>&1; do
  #   # check that the process still exists
  #   if ! ps -p "$database_process_id" > /dev/null; then
  #     echo_error "The database failed to start"
  #     exit 1
  #   fi
  #   # wait 100ms
  #   sleep 0.1
  # done
  # # start main process
  # "$START_CONTAINER_WEBSERVER" | echo_label "WEBSERVER"
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
  test_env SCRIPT_NAME ENV_FILES START_DEV_WEBSERVER START_DEV_DATABASE START_CONTAINER_WEBSERVER START_CONTAINER_DATABASE
  load_env_files "$ENV_FILES"
  interpret_script "$@"
  trap kill_processes EXIT
  eval "$script ${script_args[*]}"
}

main "$@"
