#!/usr/bin/env bash

# Print usage information.
usage() {
    cat << USAGE
Usage: composerc [CONTAINER-OPTIONS] COMPOSER-COMMAND
       composerc [CONTAINER-OPTIONS] [-- COMPOSER_OPTIONS...] COMPOSER-COMMAND

Container options:
      --image-tag   Composer image tag, default is 2
      --home-dir    Location to mount as Composer home directory, default is
                    \$HOME/.tools-in-containers/composer/home
      --cache-dir   Location to mount as Composer cache directory, default is
                    \$HOME/.tools-in-containers/composer/cache
  -w, --workdir     Location to mount as working directory, default is the
                    current working directory
  -h, --help        Show this information and exit

If you need to pass any Composer option that starts with -- (e.g. --no-cache),
separate it from the container options with --, i.e.:

  composerc -- --no-cache

This is due to the behavior of getopt(1) which is used by this script to parse
the command line arguments.

More info (and tools) at https://github.com/aicantar/tools-in-containers.
USAGE
}

# Locate either Docker or Podman executable and return its path.
get_runner() {
    echo $(command -v docker || command -v podman || exit 1)
}

# Parse command line arguments.
parse_options() {
    short_options="hw:"
    long_options="help,workdir:,image-tag:,home-dir:,cache-dir:"
    parsed_options=$(getopt -n composer -o "$short_options" -l "$long_options" -- "$@")
    options_end=0

    [ $? -ne 0 ] && exit 1

    composer_image_tag=2
    composer_home_dir="$HOME/.tools-in-containers/composer/home"
    composer_cache_dir="$HOME/.tools-in-containers/composer/cache"
    composer_workdir=$(pwd)
    composer_args=( )

    for option in $parsed_options; do
        if [ $options_end -eq 1 ]; then
            composer_args+=( "$option" )
            continue
        fi

        case "$option" in
            -h | --help)        usage;                       exit 1 ;;
            -w | --workdir)     composer_workdir=$2;        shift 2 ;;
            --image-tag)        composer_image_tag=$2;      shift 2 ;;
            --home-dir)         composer_home_dir=$2;       shift 2 ;;
            --cache-dir)        composer_cache_dir=$2;      shift 2 ;;
            --)                 options_end=1                       ;;
        esac
    done

    export composer_image_tag
    export composer_home_dir
    export composer_cache_dir
    export composer_workdir
    export composer_args
}

main() {
    runner=$(get_runner)

    if [ $? -ne 0 ]; then
        usage
        exit 1
    fi

    parse_options "$@"

    if [ $? -ne 0 ]; then
        usage
        exit 1
    fi

    mkdir -p "$composer_home_dir" "$composer_cache_dir"

    $runner run                                                 \
        --rm                                                    \
        --interactive                                           \
        --tty                                                   \
        --env "COMPOSER_HOME_DIR=/composer-home"                \
        --env "COMPOSER_CACHE_DIR=/composer-cache"              \
        --volume "$composer_home_dir:/composer-home:rw,z"       \
        --volume "$composer_cache_dir:/composer-cache:rw,z"     \
        --volume "$composer_workdir:/app:rw,z"              \
        docker.io/composer:"$composer_image_tag" composer "${composer_args[@]//\'/}"
}

main "$@"
