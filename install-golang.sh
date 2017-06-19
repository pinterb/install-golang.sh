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
  local curl_cmd=`which curl`
  local tar_cmd=`which tar`

  if [ -z "$curl_cmd" ]; then
    error "curl does not appear to be installed. Please install and re-run this script."
    exit 1
  fi

  if [ -z "$tar_cmd" ]; then
    error "tar does not appear to be installed. Please install and re-run this script."
    exit 1
  fi

  # we want to be root to install / uninstall
  if [ "$EUID" -ne 0 ]; then
    error "Please run as root"
    exit 1
  fi
}


# Uninstall the current installed version of Go
uninstall_golang() {

  if [ -d "$GOLANG_INSTALL_DIR/go" ]; then
    echo ""
    echo "Removing previous installation"
    rm -rf "$GOLANG_INSTALL_DIR/go"
  fi
}


# Install the latest version of Go
install_golang() {
#  source "$PROGDIR/golang_profile"

  echo ""
  echo "Installing Go"
  curl -o "$GOLANG_DOWNLOADED_FILE" "$GOLANG_DOWNLOAD_URL"
  tar -C /usr/local -xzf "$GOLANG_DOWNLOADED_FILE"
  rm "$GOLANG_DOWNLOADED_FILE"

  echo ""
  echo "Updating /etc/profile"
  cp "$PROGDIR/golang_profile" /etc/profile.d/golang.sh
}


main() {
  # Be unforgiving about errors
  set -euo pipefail
  readonly SELF="$(absolute_path $0)"

  prerequisites
  uninstall_golang
  install_golang
}

[[ "$0" == "$BASH_SOURCE" ]] && main
