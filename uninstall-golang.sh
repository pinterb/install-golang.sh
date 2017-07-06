#!/bin/bash

# vim: filetype=sh:tabstop=2:shiftwidth=2:expandtab

# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/

# Following the following official golang instructions:
# https://golang.org/doc/install

readonly PROGNAME=$(basename $0)
readonly PROGDIR="$( cd "$(dirname "$0")" ; pwd -P )"
readonly ARGS="$@"

# pull in utils
source "${PROGDIR}/utils.sh"


# Make sure we have all the right stuff
prerequisites() {
  # we want to be root to install / uninstall
  if [ "$EUID" -ne 0 ]; then
    error "Please run as root"
    exit 1
  fi
}


# Uninstall the latest version of Go
uninstall_golang() {
  if [ -f "$GOLANG_DOWNLOADED_FILE" ]; then
    echo ""
    echo "Removing previous download"
    rm -rf "$GOLANG_DOWNLOADED_FILE"
  fi

  if [ -d "$GOLANG_INSTALL_DIR/go" ]; then
    echo ""
    echo "Removing previous installation"
    rm -rf "$GOLANG_INSTALL_DIR/go"
  fi

  if [ -f "$HOME/.golang_profile" ]; then
    echo ""
    echo "Removing $HOME/.golang_profile"
    rm "$HOME/.golang_profile"
  fi

  if [ -f "$HOME/.golang_install" ]; then
    echo ""
    echo "Removing $HOME/.golang_install"
    rm "$HOME/.golang_install"
  fi
  
  if [ -f "/etc/profile.d/golang.sh" ]; then
    echo ""
    echo "Removing /etc/profile.d/golang.sh"
    rm "/etc/profile.d/golang.sh"
  fi
}


main() {
  # Be unforgiving about errors
  set -euo pipefail
  readonly SELF="$(absolute_path $0)"
  prerequisites
  uninstall_golang
}

[[ "$0" == "$BASH_SOURCE" ]] && main
