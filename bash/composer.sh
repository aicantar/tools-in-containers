#!/usr/bin/env bash

usage() {
    cat << USAGE
Usage: composer [CONTAINER-OPTIONS] [-- [COMPOSER-OPTIONS]...] [COMPOSER-COMMAND]

Container options:
  -i <version>      Composer image version, default is 2
  -d <directory>    Composer home directory, default is \$HOME/.tools-in-containers/composer/home
  -c <directory>    Composer cache directory, default is \$HOME/.tools-in-containers/composer/cache
  -w <directory>    Location to mount into the container as working directory, default is the current working directory
  -h                Show this information and exit

More info at https://github.com/aicantar/tools-in-containers.
USAGE
}

# TODO: come up with a better way to check whether podman or docker are installed.

_runner=$(command -v docker)

if [ ! -x "$_runner" ]; then
    _runner=$(command -v podman)

    if [ ! -x "$_runner" ]; then
        echo "You must have either podman or docker installed. Can't detect either, exiting."
        exit 1
    fi
fi

_opts="hi:d:c:w:"
_opts_parsed=$(getopt -n composer -o $_opts -- "$@")

if [ $? != 0 ]; then
    usage
    exit 1
fi

_opts_end=0
_composer_version=2
_composer_home_dir="$HOME/.tools-in-containers/composer/home"
_composer_cache_dir="$HOME/.tools-in-containers/composer/cache"
_composer_working_directory=$(pwd)
_composer_args=( )

for opt in $_opts_parsed; do
    if [ $_opts_end -eq 1 ]; then
        _composer_args+=( "$opt" )
    fi

    if [ "$opt" == "-h" ]; then
        usage
        exit
    elif [ "$opt" == "-i" ]; then
        _composer_version=$2
        shift 2
    elif [ "$opt" == "-d" ]; then
        _composer_home_dir=$2
        shift 2
    elif [ "$opt" == "-c" ]; then
        _composer_cache_dir=$2
        shift 2
    elif [ "$opt" == "-w" ]; then
        _composer_working_directory=$2
        shift 2
    elif [ "$opt" == "--" ]; then
        _opts_end=1
    fi
done

mkdir -p "$_composer_home_dir" "$_composer_cache_dir"

$_runner run                                                \
    --rm                                                    \
    --interactive                                           \
    --tty                                                   \
    --env "COMPOSER_HOME_DIR=/composer-home"                \
    --env "COMPOSER_CACHE_DIR=/composer-cache"              \
    --volume "$_composer_home_dir:/composer-home:rw,z"      \
    --volume "$_composer_cache_dir:/composer-cache:rw,z"    \
    --volume "$_composer_working_directory:/app:rw,z"       \
    docker.io/composer:"$_composer_version" composer "${_composer_args[@]//\'/}"
