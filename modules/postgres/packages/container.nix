{
  pkgs,
  image,
}: pkgs.callPackage ../../../utils/mk-container.nix {
  imageName = image.name;
  imageTag = image.tag;
  imageStream = image.stream;
  podmanArgs = [
    "--publish" "5432:5432"
    "--env" "POSTGRES*"
    "--volume" "\"${image.name}-${image.tag}:/var/lib/postgresql/data\""
  ];
  preStart = ''
    # expects $1 to be the name of the volume to initialize
    initialize_volume() {
      temp_dir="$(mktemp -d)"
      chmod -R +rx "$temp_dir"
      init_sql_file="$temp_dir/init.sql"
      init_sql_script="$temp_dir/init.sh"

      cat > "$init_sql_file" << '___EOF___'
    ${builtins.readFile ../schema/init.sql}
    ___EOF___

      cat > "$init_sql_script" << ___EOF___
    #!/usr/bin/env bash
    set -Eeo pipefail

    # ? https://github.com/docker-library/postgres/blob/master/17/alpine3.21/docker-entrypoint.sh
    source docker-entrypoint.sh

    docker_setup_env
    docker_create_db_directories

    # check that user is not root
    if [ "\$(id -u)" = '0' ]; then
      # then restart script as postgres user
      exec gosu postgres "\$BASH_SOURCE" "\$@"
    fi

    # check that database is initialized
    if [ -z "\$DATABASE_ALREADY_EXISTS" ]; then
      docker_verify_minimum_env

      # check for folder permissions
      ls /docker-entrypoint-initdb.d/ > /dev/null

      docker_init_database_dir
      pg_setup_hba_conf
    fi

    export PGPASSWORD="\''${PGPASSWORD:-\$POSTGRES_PASSWORD}"
    docker_temp_server_start

    # check that database is initialized
    if [ -z "\$DATABASE_ALREADY_EXISTS" ]; then
      docker_setup_db
      docker_process_init_files /docker-entrypoint-initdb.d/*
    fi

    # apply database schema
    docker_process_sql -f "$init_sql_file"

    docker_temp_server_stop
    unset PGPASSWORD
    ___EOF___
      chmod +x "$init_sql_script"

      echo_exec podman container run \
        "--env" "POSTGRES*" \
        "--volume" "$temp_dir:$temp_dir" \
        "--volume" "$1:/var/lib/postgresql/data" \
        "--user" "postgres" \
        "localhost/${image.name}:${image.tag}" \
        "$init_sql_script"
    }

    # expects $1 to be the source volume (/from) and $2 to be the target volume (/to)
    copy_volume() {
      podman container run \
        "--volume" "$1:/from" \
        "--volume" "$2:/to" \
        docker.io/library/bash \
        cp -rpf /from /to
    }

    # expects $1 to be the name of the volume to backup
    backup_volume() {
      local backup_number=$(($(podman volume ls \
        | grep "$1" \
        | grep -o "backup.*" \
        | grep -oE '[0-9]+' \
        | sort -n \
        | tail -n 1 \
      ) + 1))
      local backup_name="$1-backup-$backup_number"
      podman volume create "$backup_name" > /dev/null 2>&1
      copy_volume "$1" "$backup_name"
    }

    verify_volume() {
      if ! podman volume exists "${image.name}-${image.tag}" > /dev/null 2>&1; then
        echo "Creating volume at ${image.name}-${image.tag}..."
        podman volume create "${image.name}-${image.tag}" > /dev/null 2>&1
        echo "Done."
        echo "Initializing volume at ${image.name}-${image.tag}..."
        initialize_volume "${image.name}-${image.tag}"
        echo "Done."
        return
      fi
      # if schema is modified, backup old volume and re-initialize the current one
      if git status --porcelain | grep -q "modules/postgres/schema/"; then
        echo "Postgres schema appears to be modified."
        echo "Backing up volume at ${image.name}-${image.tag}..."
        backup_volume "${image.name}-${image.tag}"
        echo "Done. Use 'podman volume prune' to delete unused backups."
        echo "Re-initializing volume at ${image.name}-${image.tag}..."
        initialize_volume "${image.name}-${image.tag}"
        echo "Done."
        return
      fi
    }

    verify_volume
  '';
  ensureStopOnExit = true;
  useInteractiveTTY = false;
}
