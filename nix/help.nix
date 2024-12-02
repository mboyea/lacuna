{
  pkgs,
  name,
  version
}: pkgs.writeShellApplication {
  name = "${name}-help-${version}";
  text = ''
    echo "This is the Lacuna command line interface."
    echo
    echo "Usage:"
    echo "  nix run .#[SCRIPT] [ARGUMENT]..."
    echo
    echo "Scripts:"
    echo "  help    Print this helpful information"
    echo "  start   Start the app locally"
    echo "  init    Initialize the app for deployment"
    echo "  deploy  Deploy the app"
    echo
    echo "Use \"nix run .#[SCRIPT] help\" for more information about a script."
    echo "Use \"nix run\" as an alias for \"nix run .#start dev\"."
  '';
}
