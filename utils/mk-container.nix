#----------------------------------------
# Description: Use podman to start a docker image
# Usage:
# let
#   name = "test";
#   version = "0.0.0";
#   dockerImage = let
#     _name = "${name}-docker-image";
#     tag = version;
#     # update base image using variables from:
#     #   xdg-open https://hub.docker.com/_/alpine/tags
#     #   nix-shell -p nix-prefetch-docker
#     #   nix-prefetch-docker --quiet --image-name alpine --image-tag _ --image-digest _
#     baseImage = pkgs.dockerTools.pullImage {
#       imageName = "alpine";
#       imageDigest = "sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c";
#       sha256 = "1nridd7sc65h48ir7ahv47d0hfi5bdixlsnlk5xviaz9nzxzz90m";
#       finalImageName = "alpine";
#       finalImageTag = "latest";
#     };
#   in {
#     name = _name;
#     inherit version tag;
#     stream = pkgs.dockerTools.streamLayeredImage {
#       name = _name;
#       inherit tag;
#       fromImage = baseImage;
#       contents = [ pkgs.neofetch ];
#       config = {
#         Cmd = [ "${pkgs.lib.getExe pkgs.bash}" ];
#       };
#     };
#   };
# in pkgs.callPackage utils/mk-container.nix {
#   imageName = dockerImage.name;
#   imageTag = dockerImage.tag;
#   imageStream = dockerImage.stream;
#   podmanArgs = [
#     "--network=host"
#   ];
# }
# Origin: https://github.com/mboyea/www-mboyea-com
# Author: Matthew Boyea
#----------------------------------------
{
  pkgs,
  imageName,
  imageTag,
  imageStream ? null,
  podmanArgs ? [],
  defaultImageArgs ? [],
  # ? https://forums.docker.com/t/solution-required-for-nginx-emerg-bind-to-0-0-0-0-443-failed-13-permission-denied/138875/2
  # ! Linux does not allow an unprivileged user to bind software to a port below 1024.
  # ! It is not a restriction introduced by docker or containers in general.
  # ! People usually use 8080 and 8443 instead, mapping host port 80 to 8080 and host port 443 to 8443.
  # ! However, in the case you need to use a low port number for expected behavior, the option to run the container as root is provided here.
  # ! Note that this is insecure when combined with --privileged and a malicious image.
  # ! For improved security, you should use --cap-add NET_BIND_SERVICE rather than --privileged.
  runAsRootUser ? false,
  # ! Some images don't receive SIGINT correctly.
  # ! In the case that your image isn't reliably stopped when this script ends, you can enable this option so podman will stop the container.
  ensureStopOnExit ? false,
  # ! By default will pass --tty and --interactive to podman because that's the default use case for this utility
  useInteractiveTTY ? true,
  runtimeInputs ? [],
  runtimeEnv ? null,
  preStart ? "",
  postStop ? "",
}: let
  _podmanArgs = podmanArgs
    ++ pkgs.lib.lists.optionals useInteractiveTTY [ "--tty" "--interactive" ]
    ++ pkgs.lib.lists.optionals ensureStopOnExit [ "--cidfile" "\"$container_id_file\"" ];
  _runtimeInputs = runtimeInputs
    ++ [ pkgs.podman ];
  _runtimeEnv = runtimeEnv;
in pkgs.writeShellApplication {
  name = "${imageName}-container";
  runtimeInputs = _runtimeInputs;
  runtimeEnv = _runtimeEnv;
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

    # run post stop functions when this script exits
    container_id_file="$(mktemp)"
    on_exit() {
      trap ''' INT
      if "${pkgs.lib.trivial.boolToString ensureStopOnExit}"; then
        flags=$-
        if [[ $flags =~ e ]]; then set +e; fi # disable exit on error
        container_id="$(< "$container_id_file")"
        podman container kill "$container_id" > /dev/null 2>&1
        if [[ $flags =~ e ]]; then set -e; fi # re-enable exit on error
      fi
      ${postStop}
      trap - INT
    }
    trap on_exit EXIT

    # echo a command before executing it
    echo_exec() {
      ( set -x; "$@" )
    }

    # load the image into podman
    if "${pkgs.lib.trivial.boolToString (imageStream != null)}"; then
      echo_exec ${imageStream} | echo_exec podman image load
    fi

    # run pre start functions
    ${preStart}

    # declare the image arguments
    if [ "$#" -gt 0 ]; then
      image_args=("$@")
    else
      image_args=(${pkgs.lib.strings.concatStringsSep " " defaultImageArgs})
    fi

    # run the image using podman
    echo_exec podman container run \
      ${pkgs.lib.strings.concatStringsSep " " _podmanArgs} \
      localhost/${imageName}:${imageTag} \
      "''${image_args[@]}"
  '';
}
