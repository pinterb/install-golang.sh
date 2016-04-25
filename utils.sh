#!/bin/bash -

readonly GOLANG_VERSION="1.6.1"
readonly INSTALL_DIR="/usr/local"
readonly DOWNLOAD_DIR="/tmp"
readonly DOWNLOAD_URL="https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz"
readonly DOWNLOADED_FILE="$DOWNLOAD_DIR/go$GOLANG_VERSION.linux-amd64.tar.gz"

# Get distro data from /etc/os-release
readonly DISTRO_VER=$(awk -F'=' '/VERSION_ID/ {print $2}' /etc/os-release | tr -d '"')
readonly DISTRO_ID=$(awk -F'=' '/ID/ {print $2; exit}' /etc/os-release | tr '[:upper:]' '[:lower:]')


function warn() {
  echo -e "\033[1;33mWARNING: $1\033[0m"
}

function error() {
  echo -e "\033[0;31mERROR: $1\033[0m"
}

function inf() {
  echo -e "\033[0;32m$1\033[0m"
}

function follow() {
  inf "Following docker logs now. Ctrl-C to cancel."
  docker logs --follow $1
}

function run_command() {
  inf "Running:\n $1"
  eval $1 &> /dev/null
}

# Given a relative path, calculate the absolute path
absolute_path() {
  pushd "$(dirname $1)" > /dev/null
  local abspath="$(pwd -P)"
  popd > /dev/null
  echo "$abspath/$(basename $1)"
}
