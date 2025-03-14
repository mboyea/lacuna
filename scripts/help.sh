#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

echo "This is the www-mboyea-com command line interface."
echo
echo "Usage:"
echo "  nix run"
echo "  └ Alias for \"nix run .#start-dev all\""
echo "  nix run .#script [target...] [args...]"
echo "  └ Run a script"
echo "  nix develop"
echo "  └ Start a subshell with the software dependencies installed"
echo
echo "scripts:"
echo "  help       | Print this helpful information"
echo "  start-dev  | Start apps locally using devtools"
echo "  start-prod | Start apps locally using their production images"
echo "  deploy     | Deploy the app to Fly.io"
echo
echo "targets:"
echo "  all                 | Alias for \"database analytics webserver\""
echo "  database|postgres   | Script targets the database"
echo "  analytics|umami     | Script targets the analytics server"
echo "  webserver|sveltekit | Script targets the webserver"
echo
