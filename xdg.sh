#!/bin/sh

# This script will install buildah using the automated builds from the kubic
# project

set -eu

# Set this to 1 for more verbosity (on stderr)
XDG_VERBOSE=${XDG_VERBOSE:-0}


XDG_HOME=${XDG_HOME:-${HOME}}
XDG_DATA_HOME=${XDG_DATA_HOME:-${XDG_HOME%%*/}/.local/share}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${XDG_HOME%%*/}/.config}
XDG_STATE_HOME=${XDG_STATE_HOME:-${XDG_HOME%%*/}/.local/state}
XDG_CACHE_HOME=${XDG_CACHE_HOME:-${XDG_HOME%%*/}/.cache}
XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-"/run/user/$(id -u)"}
XDG_BIN_DIR=${XDG_HOME%%*/}/.local/bin

# This uses the comments behind the options to show the help. Not extremly
# correct, but effective and simple.
usage() {
  echo "$0 installs kubectl auth context and runs kubectl with all remaining args:" && \
    grep "[[:space:]].)\ #" "$0" |
    sed 's/#//' |
    sed -r 's/([a-z])\)/-\1/'
  exit "${1:-0}"
}

while getopts "c:vh-" opt; do
  case "$opt" in
    v) # Turn on verbosity
      XDG_VERBOSE=1;;
    h) # Print help and exit
      usage;;
    -)
      break;;
    *)
      usage 1;;
  esac
done
shift $((OPTIND-1))

_verbose() {
  if [ "$XDG_VERBOSE" = "1" ]; then
    printf %s\\n "$1" >&2
  fi
}

_error() {
  printf %s\\n "$1" >&2
  exit 1
}


_mkdir() {
  if ! [ -d "$1" ]; then
    _verbose "Creating ${2:-} directory $1"
    if mkdir -p "$1"; then
      return 0
    else
      return 1
    fi
  fi
  return 0
}


_export() {
  # ask our environment for its set of variables, restrict ourselves to the
  # variable which name is passed as a parameter, once done: remove the leading
  # and ending single quotes around the value of the variable.
  set |
    grep -E "^${1}\s*=" |
    sed -E -e "s/^${1}\s*=\s*'/${1}=/" -e "s/'$//" >> "$GITHUB_ENV"
}


# Create the directories, use the absence of the variable as a marker that
# directory creation failed.
_mkdir "$XDG_DATA_HOME" data || unset XDG_DATA_HOME
_mkdir "$XDG_CONFIG_HOME" config || unset XDG_CONFIG_HOME
_mkdir "$XDG_STATE_HOME" state || unset XDG_STATE_HOME
_mkdir "$XDG_CACHE_HOME" cache || unset XDG_CACHE_HOME
if _mkdir "$XDG_RUNTIME_DIR" runtime; then
  chmod 0700 "$XDG_RUNTIME_DIR"
else
  unset XDG_RUNTIME_DIR
fi
_mkdir "$XDG_BIN_DIR" bin || unset XDG_BIN_DIR

# Export the variables, only if they exists, meaning their directories were
# created
_verbose "Pertaining variables"
if [ -n "${GITHUB_ENV:-}" ]; then
  _export XDG_DATA_HOME
  _export XDG_CONFIG_HOME
  _export XDG_STATE_HOME
  _export XDG_CACHE_HOME
  _export XDG_RUNTIME_DIR
fi

if [ -n "${XDG_BIN_DIR:-}" ] && [ -n "${GITHUB_PATH:-}" ]; then
  _verbose "Adding $XDG_BIN_DIR to PATH"
  printf "%s\n" "$XDG_BIN_DIR" >> "$GITHUB_PATH"
fi
