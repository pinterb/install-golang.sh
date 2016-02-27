#!/bin/bash

# vim: filetype=sh:tabstop=2:shiftwidth=2:expandtab

# Following the following official golang instructions:
# https://golang.org/doc/install

readonly PROGNAME=$(basename $0)
readonly PROJECTDIR="$( cd "$(dirname "$0")" ; pwd -P )"

readonly TMP_DIR="/tmp"
readonly BIN_DIR="$HOME/bin"
readonly CURL_CMD=`which curl`
readonly TAR_CMD=`which tar`
readonly WGET_CMD=`which wget`

readonly GOLANG_VERSION="1.6"
readonly DOWNLOAD_URL="https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz"

source "$PROJECTDIR/golang_profile"

#if [ "$(id -u)" != "0" ]; then
#  echo "This script must be run as root" 1>&2
#  exit 1
#fi

echo ""
echo "Installing Go"
$CURL_CMD $DOWNLOAD_URL | $TAR_CMD -C $TMP_DIR -zx
rm -rf $GOROOT
mv $TMP_DIR/go $GOROOT

echo ""
echo "Creating $GOPATH/{src,bin,pkg}"
mkdir -p "$GOPATH"/{src,bin,pkg}
mkdir -p "$GOPATH/src/github.com/pinterb"


###
# glide
###
readonly GLIDE_VERSION="0.9.0"
readonly GLIDE_URL="https://github.com/Masterminds/glide/releases/download/$GLIDE_VERSION/glide-$GLIDE_VERSION-linux-amd64.tar.gz"

echo ""
echo "Installing Glide"
$CURL_CMD -Lo "$TMP_DIR/glide.tar.gz" "$GLIDE_URL"
cd $TMP_DIR && $TAR_CMD -xvf $TMP_DIR/glide.tar.gz
mv $TMP_DIR/linux-amd64/glide $BIN_DIR
chmod +x $BIN_DIR/glide
rm $TMP_DIR/glide.tar.gz
rm -rf $TMP_DIR/linux-amd64


###
# godep
###
readonly GODEP_VERSION="53"
readonly GODEP_URL="https://github.com/tools/godep/releases/download/v$GODEP_VERSION/godep_linux_amd64"
echo ""
echo "Installing godep"
$CURL_CMD -Lo "$BIN_DIR/godep" "$GODEP_URL"
chmod +x $BIN_DIR/godep


###
# .bash_profile or .profile
###
echo "Setting up profile"
cp $PROJECTDIR/golang_profile $HOME/.golang_profile

echo ""
if [ -f "$HOME/.bash_profile" ]; then
  echo "Setting up .bash_profile"
  grep -q -F 'source "$HOME/.golang_profile"' "$HOME/.bash_profile" || echo 'source "$HOME/.golang_profile"' >> "$HOME/.bash_profile"
else
  echo "Setting up .profile"
  grep -q -F 'source "$HOME/.golang_profile"' "$HOME/.profile" || echo 'source "$HOME/.golang_profile"' >> "$HOME/.profile"
fi

###
# Finished!
###
echo ""
echo 'now you can source $HOME/.golang_profile'
