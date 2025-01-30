#--------------------------------
# Author : Matthew Boyea
# Origin : https://github.com/mboyea/lacuna
# Description : convert .env file to a nix attribute set
# Nix Usage : envVars = import ./env.nix { inherit pkgs; };
#--------------------------------
{
  pkgs ? import <nixpkgs> {},
  envFile ? ".env",
}: let
  # filter out nameless attributes from the attribute set
  envVars = pkgs.lib.attrsets.filterAttrs
    (name: value: name != "")
    # convert the list of name value pairs to an attribute set
    (builtins.listToAttrs (
      # for each line from the file, map it to a name value pair
      builtins.map
      (string: let
        # split the string at "="
        splitString = pkgs.lib.strings.splitString "=" string;
      in {
        # name is before the first "=" excluding "\""
        name = builtins.replaceStrings ["\""] [""] (builtins.elemAt splitString 0);
        # value is after the first "=" excluding "\""
        value = builtins.replaceStrings ["\""] [""] (
          pkgs.lib.strings.concatStrings (lib.lists.drop 1 splitString)
        );
      })
      # get a list with each line from the file .env
      (pkgs.lib.strings.splitString "\n"
        (builtins.readFile (./. + "/${envFile}"))
      )
    ));
in envVars
