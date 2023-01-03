#!/usr/bin/env bash

# Print usage information.
usage() {
    cat << USAGE
Usage: composer [CONTAINER-OPTIONS] COMPOSER-COMMAND
       composer [CONTAINER-OPTIONS] [-- COMPOSER_OPTIONS...] COMPOSER-COMMAND

Container options:
      --image-tag   Composer image tag, default is 2
      --home-dir    Location to mount as Composer home directory, default is
                    \$HOME/.tools-in-containers/composer/home
      --cache-dir   Location to mount as Composer cache directory, default is
                    \$HOME/.tools-in-containers/composer/cache
  -w, --working-dir Location to mount as working directory, default is the
                    current working directory
  -h, --help        Show this information and exit

If you need to pass any Composer option that starts with -- (e.g. --no-cache),
separate it from the container options with --, i.e.:

  composer -- --no-cache

This is due to the behavior of getopt(1) which is used by this script to parse
the command line arguments.

More info (and tools) at https://github.com/aicantar/tools-in-containers.
USAGE
}

# Locate either Docker or Podman executable and return its path.
get_runner() {
    # TODO: any better way?
    runner=$(command -v docker)

    if [ ! -x "$runner" ]; then
        runner=$(command -v podman)

        if [ ! -x "$runner" ]; then
            exit 1
        fi
    fi

    echo "$runner"
}

# Parse command line options.
parse_opts() {
    short_opts="hw:"
    long_opts="help,working-dir:,image-tag:,home-dir:,cache-dir:"
    parsed_opts=$(getopt -n composer -o "$short_opts" -l "$long_opts" -- "$@")
    opts_end=0

    composer_image_tag=2
    composer_home_dir="$HOME/.tools-in-containers/composer/home"
    composer_cache_dir="$HOME/.tools-in-containers/composer/cache"
    composer_working_dir=$(pwd)
    composer_args=( )

    if [ $? -ne 0 ]; then
        exit 1
    fi

    for opt in $parsed_opts; do
        if [ $opts_end -eq 1 ]; then
            composer_args+=( "$opt" )
            continue
        fi

        case $opt in
            -h | --help)        usage;                       exit 1 ;;
            -w | --working-dir) composer_working_dir=$2;    shift 2 ;;
            --image-tag)        composer_image_tag=$2;      shift 2 ;;
            --home-dir)         composer_home_dir=$2;       shift 2 ;;
            --cache-dir)        composer_cache_dir=$2;      shift 2 ;;
            --)                 opts_end=1                          ;;
        esac
    done

    # TODO: any better way?
    export composer_image_tag
    export composer_home_dir
    export composer_cache_dir
    export composer_working_dir
    export composer_args
}

main() {
    runner=$(get_runner)

    if [ $? -ne 0 ]; then
        usage
        exit 1
    fi

    parse_opts "$@"

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
        --volume "$composer_working_dir:/app:rw,z"              \
        docker.io/composer:"$composer_image_tag" composer "${composer_args[@]//\'/}"

}

main "$@"
