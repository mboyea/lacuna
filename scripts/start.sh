#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# print an error message
echo_error() {
  echo "Error:" "$@" 1>&2
}

# if the listed commands aren't found, exit with an error message
test_commands() {
  local flags=$-
  local exit=false
  if [[ $flags =~ e ]]; then set +e; fi # disable exit on error
  # for each argument
  while [[ $# -gt 0 ]]; do
    # check that command is defined
    if [ ! -x "$(command -v "$1")" ]; then
      echo_error "The required program \"$1\" is not installed"
      exit=true
    fi
    shift
  done
  if [[ $flags =~ e ]]; then set -e; fi # re-enable exit on error
  if $exit; then exit 1; fi
}

# if the listed env variables aren't found, exit with an error message
test_env_variables() {
  local flags=$-
  local exit=false
  if [[ $flags =~ u ]]; then set +u; fi # disable exit on undefined variables
  # for each argument
  while [[ $# -gt 0 ]]; do
    # check that env variable is defined
    if [ -z "${!1}" ]; then
      echo_error "The required environment variable \"$1\" is not defined"
      exit=true
    fi
    shift
  done
  if [[ $flags =~ u ]]; then set -u; fi # re-enable exit on undefined variables
  if $exit; then exit 1; fi
}

# use git to go to the base of the current project directory
go_to_base_directory() {
  test_commands git
  # if current directory is not a git directory, return
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    return
  fi
  # go to the base of the git directory
  cd "$(git rev-parse --show-toplevel)"
}

# load env variables from the given files (relative to the base directory)
load_env_files() {
  # go to base directory
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
  # return to last directory
  cd - > /dev/null
}

process_ids=()
# kill each process in process_ids
kill_processes() {
  local flags=$-
  if [[ $flags =~ e ]]; then set +e; fi # disable exit on error
  # send kill signal to each process
  for process_id in "${process_ids[@]}"; do
    kill -9 -- "-$process_id" > /dev/null 2>&1
  done
  # wait for each process to exit
  for process_id in "${process_ids[@]}"; do
    wait "$process_id" 2>/dev/null
  done
  if [[ $flags =~ e ]]; then set -e; fi # re-enable exit on error
}

# script to start the database
script_start_database() {
  test_commands unbuffer
  test_env_variables POSTGRES_PASSWORD POSTGRES_WEBSERVER_USERNAME POSTGRES_WEBSERVER_PASSWORD POSTGRES_ANALYTICS_USERNAME POSTGRES_ANALYTICS_PASSWORD
  echo "DATABASE STARTING"
  # start database as background process
  database_log_file="$(mktemp)"
  (unbuffer "$START_DATABASE" | tee "$database_log_file") & process_ids+=($!)
  local database_process_id="${process_ids[-1]}"
  # wait for database to be ready to accept connections
  until \
    grep -q "^.*\[1\].*database system is ready to accept connections" "$database_log_file"
  do
    if ! ps -p "$database_process_id" > /dev/null; then
      echo_error "The database failed to start"
      exit 1
    fi
    sleep 0.1
  done
  echo "DATABASE STARTED"
}

# script to start the analytics server
script_start_analytics() {
  test_commands unbuffer
  test_env_variables
  echo "ANALYTICS SERVER STARTING"
  # TODO
  echo "ANALYTICS SERVER STARTED"
}

# script to start the webserver
script_start_webserver() {
  test_commands unbuffer
  test_env_variables POSTGRES_WEBSERVER_USERNAME POSTGRES_WEBSERVER_PASSWORD POSTGRES_NETLOC POSTGRES_PORT
  echo "WEBSERVER STARTING"
  # start webserver as background process
  webserver_log_file="$(mktemp)"
  (unbuffer "$START_WEBSERVER" | tee "$webserver_log_file") & process_ids+=($!)
  local webserver_process_id="${process_ids[-1]}"
  # wait for webserver to be ready to accept connections
  until \
    grep -q "^.*VITE.*ready" "$webserver_log_file"
  do
    if ! ps -p "$webserver_process_id" > /dev/null; then
      echo_error "The database failed to start"
      exit 1
    fi
    sleep 0.1
  done
  echo "WEBSERVER STARTED"
}

do_start_database=false
do_start_analytics=false
do_start_webserver=false
# determine the functions to run from arguments
interpret_args() {
  # if no arguments passed, start all servers
  if [[ $# -eq 0 ]]; then
    do_start_database=true
    do_start_analytics=true
    do_start_webserver=true
    return
  fi
  # otherwise start each server specified by arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      all)
        do_start_database=true
        do_start_analytics=true
        do_start_webserver=true
      ;;
      database|postgres)
        do_start_database=true
      ;;
      analytics|umami)
        do_start_analytics=true
      ;;
      webserver|sveltekit)
        do_start_webserver=true
      *)
        echo_error "The argument \"$1\" is not a recognized target"
        exit 1
      ;;
    esac
    shift
  done
}

# entrypoint of the script
main() {
  : "${START_ENV_FILE:=".env.development"}"
  load_env_files "$START_ENV_FILE"
  set -a
  : "${POSTGRES_WEBSERVER_USERNAME:="webserver"}"
  : "${POSTGRES_ANALYTICS_USERNAME:="analytics"}"
  : "${POSTGRES_DATABASE_MAIN:="main"}"
  : "${POSTGRES_NETLOC:="localhost"}"
  : "${POSTGRES_PORT:="5432"}"
  set +a
  interpret_args "$@"
  trap kill_processes EXIT
  if "$do_start_database"; then;
    script_start_database
  fi
  if "$do_start_analytics"; then;
    script_start_analytics
  fi
  if "$do_start_webserver"; then;
    script_start_webserver
  fi
  # wait for any background job to terminate
  wait -n
}

main "$@"
