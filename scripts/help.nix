{
  pkgs,
  name,
  version
}: pkgs.writeShellApplication {
  name = "${name}-help-${version}";
  text = builtins.readFile ./help.sh;
}
