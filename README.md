# tools-in-containers

A collection of tools I use containerized because I don't like them installed on my system. More tools will be added eventually.

## Installation

Copy any tools you need into a directory added to your `PATH` without the `sh` extension, then add execution permission to the copied file.

E.g. if you need `composerc` and `$HOME/.local/bin` is on your path do:

```sh
cp bash/composerc.sh $HOME/.local/bin/composerc
chmod +x $HOME/.local/bin/composerc
```

Then you can run `composerc`.

## Structure

The tools are organized by the language they're written in. The name of each tool is the name of the containerized program + `c` suffix to indicate that it's containerized, i.e. `composer` -> `composerc`, `php` -> `phpc`, etc.

## The tools

Information about each particular tool is provided below.

### `composerc`

Composer running in a container. Uses the official image [https://hub.docker.com/_/composer](https://hub.docker.com/_/composer).

By default mounts the current directory as the container's working directory and runs composer commands there.

#### Command line arguments

| Argument | Description | Default value |
| - | - | - |
| `--image-tag` | Composer container image tag to download from the Docker Hub. | `2`
| `--home-dir` | Directory to mount as `COMPOSER_HOME`. | `$HOME/.tools-in-containers/composer/home` |
| `--cache-dir` | Directory to mount as `COMPOSER_CACHE_DIR`. | `$HOME/.tools-in-containers/composer/cache` |
| `-w`, `--workdir` | Directory to mount as container's working directory. All composer commands will be executed in this directory. | `$(pwd)`
| `-h`, `--help` | Show help text and exit. | |

#### Passing composer-specific command line arguments

If you need to pass any arguments to composer itself, first type `composerc` arguments (if any), then add `--` and only then type the composer arguments.

E.g. if you need to pass `--no-cache` argument to `composer install` and you want to use `~/git/myproject` as the working directory, run `composerc` as follows:

```sh
composerc -w ~/git/myproject -- --no-cache install
```

This is due to the behavior of [`getopt(1)`](https://www.man7.org/linux/man-pages/man1/getopt.1.html) which this script uses to parse command line arguments.
