# tools-in-containers

A collection of tools I use containerized because I don't like them installed on my system. More tools will be added eventually.

## The tools

Information about each particular tool is provided below.

### `composer`

Composer running in a container. Uses the official image [https://hub.docker.com/_/composer](https://hub.docker.com/_/composer).

Usage:

```
composer [CONTAINER-OPTIONS] COMPOSER-COMMAND
composer [CONTAINER-OPTIONS] [-- COMPOSER_OPTIONS...] COMPOSER-COMMAND

Container options:
      --image-tag   Composer image tag, default is 2
      --home-dir    Location to mount as Composer home directory, default is
                    $HOME/.tools-in-containers/composer/home
      --cache-dir   Location to mount as Composer cache directory, default is
                    $HOME/.tools-in-containers/composer/cache
  -w, --working-dir Location to mount as working directory, default is the
                    current working directory
  -h, --help        Show this information and exit

If you need to pass any Composer option that starts with -- (e.g. --no-cache),
separate it from the container options with --, i.e.:

  composer -- --no-cache

This is due to the behavior of getopt(1) which is used by this script to parse
the command line arguments.
```
