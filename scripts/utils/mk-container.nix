#--------------------------------
# Author : Matthew Boyea
# Origin : https://github.com/mboyea/lacuna
# Description : use podman to start a docker image with Nix
# Nix Usage : 
#  server = pkgs.writeShellApplication {
#    name = "${name}-server-${version}";
#    runtimeInputs = [
#      pkgs.uutils-coreutils-noprefix
#    ];
#    text = ''
#      echo "Hello, world!"
#      tail -f /dev/null
#    '';
#  };
#  serverImage = let
#    _name = "${name}-docker-image";
#     tag = version;
#     baseImage = null;
#  in {
#    name = _name;
#    inherit version tag;
#    stream = pkgs.dockerTools.streamLayeredImage {
#      name = _name;
#      inherit tag;
#      fromImage = baseImage;
#      contents = [ server ];
#      config = {
#        Cmd = [ "${pkgs.lib.getExe server}" ];
#        ExposedPorts = {
#          "5555/tcp" = {};
#        };
#      };
#    };
#  };
#  serverContainer = pkgs.callPackage ./mk-container.nix {
#    inherit pkgs name version;
#    image = serverImage;
#    podmanArgs = [
#      "--publish"
#      "5555:5555"
#    ];
#  };
#--------------------------------
{
  pkgs,
  name,
  version,
  image,
  useInteractiveTTY ? true,
  podmanArgs ? [],
  defaultImageArgs ? [],
  # ? https://forums.docker.com/t/solution-required-for-nginx-emerg-bind-to-0-0-0-0-443-failed-13-permission-denied/138875/2
  # ! Linux does not allow an unprivileged user to bind software to a port below 1024.
  # ! It is not a restriction introduced by docker or containers in general.
  # ! People usually use 8080 and 8443 instead, mapping host port 80 to 8080 and host port 443 to 8443.
  # ! However, in the case you need to use a low port number for expected behavior, the option to run as root is provided here.
  # ! Note that this is insecure when combined with --privileged and a malicious image.
  # ! For improved security, you should use --cap-add NET_BIND_SERVICE rather than --privileged.
  runAsRootUser ? false,
  preStart ? "",
  postStop ? "",
}: let
  _podmanArgs = podmanArgs ++ pkgs.lib.lists.optionals useInteractiveTTY [ "--tty" "--interactive" ];
in pkgs.writeShellApplication {
  name = "${name}-${image.name}-mk-container-${version}";
  runtimeInputs = [
    pkgs.podman
  ];
  text = ''
    # return true if user is root user
    isUserRoot() {
      [ "$(id -u)" == "0" ]
    }

    # if this should run as the root user, make sure user is the root user
    if "${pkgs.lib.trivial.boolToString runAsRootUser}"; then
      if ! isUserRoot; then
        sudo "$0" "$@"
        exit
      fi
    fi

    # run pre start functions
    ${preStart}

    # run post stop functions when this script exits
    on_exit() {
      ${postStop}
      :
    }
    trap on_exit EXIT

    # echo a command before executing it
    echo_exec() {
      ( set -x; "$@" )
    }

    # load the image into podman
    echo_exec ${image.stream} | echo_exec podman image load

    # declare the image arguments
    if [ "$#" -gt 0 ]; then
      image_args=("$@")
    else
      image_args=(${pkgs.lib.strings.concatStringsSep " " defaultImageArgs})
    fi

    # run the image using podman
    echo_exec podman container run \
      ${pkgs.lib.strings.concatStringsSep " " _podmanArgs} \
      localhost/${image.name}:${image.tag} \
      "''${image_args[@]}"
  '';
}
