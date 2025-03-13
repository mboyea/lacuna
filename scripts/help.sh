#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

echo "This is the www-mboyea-com command line interface."
echo
echo "Usage:"
echo "  nix run                      | Alias for \"nix run .#start dev\""
echo "  nix run .#[SCRIPT]           | Alias for \"nix run .#[SCRIPT] all\""
echo "  nix run .#[SCRIPT] [TARGETS] | Run a script"
echo "  nix develop             | Start a subshell with the software dependencies installed"
echo
echo "SCRIPTS:"
echo "  help       | Print this helpful information"
echo "  start-dev  | Start apps locally using devtools"
echo "  start-prod | Start apps locally using their production images"
echo "  deploy     | Deploy the app to Fly.io"
echo
echo "TARGETS:"
echo "  all                 | Alias for \"database analytics webserver\""
echo "  database|postgres   | Script targets the database"
echo "  analytics|umami     | Script targets the analytics server"
echo "  webserver|sveltekit | Script targets the webserver"
echo
