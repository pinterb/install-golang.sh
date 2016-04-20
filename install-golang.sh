#!/bin/bash

# vim: filetype=sh:tabstop=2:shiftwidth=2:expandtab

# Following the following official golang instructions:
# https://golang.org/doc/install

readonly PROGNAME=$(basename $0)
readonly PROJECTDIR="$( cd "$(dirname "$0")" ; pwd -P )"

readonly OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
readonly ARCH="$(uname -m)"
if [ -f "/etc/os-release" ]; then
  source os_release
fi

readonly TMP_DIR="/tmp"
readonly BIN_DIR="$HOME/bin"
readonly CURL_CMD=`which curl`
readonly TAR_CMD=`which tar`
readonly WGET_CMD=`which wget`

readonly GOLANG_VERSION="1.6.1"
readonly DOWNLOAD_URL="https://storage.googleapis.com/golang/go$GOLANG_VERSION.$OS-amd64.tar.gz"
readonly DOWNLOADED_FILE="$TMP_DIR/go$GOLANG_VERSION.$OS-amd64.tar.gz"

source "$PROJECTDIR/golang_profile"

INSTALL_CMD="$TAR_CMD -C /usr/local -xzf $DOWNLOADED_FILE"
REMOVE_CMD="rm -rf /usr/local/go"

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  echo "Will attempt to install using sudo..."
  INSTALL_CMD="sudo ${INSTALL_CMD}"
  REMOVE_CMD="sudo ${REMOVE_CMD}"
#  exit 1
fi


echo ""
echo "Remove any residual artitfacts from previous installs..."
rm -rf  $DOWNLOADED_FILE
$REMOVE_CMD

echo ""
echo "Installing Go"
$CURL_CMD -o  $DOWNLOADED_FILE $DOWNLOAD_URL
$INSTALL_CMD

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
# cobra
###
readonly COBRA_URL="github.com/spf13/cobra/cobra"
echo ""
echo "Installing cobra"
$GOROOT/bin/go get -u "$COBRA_URL"
cp $PROJECTDIR/cobra.yaml $HOME/.cobra.yaml


###
# interfacer
###
readonly INTERFACER_URL="github.com/mvdan/interfacer/cmd/interfacer"
echo ""
echo "Installing interfacer"
$GOROOT/bin/go get -u "$INTERFACER_URL"


###
# depscheck
###
readonly DEPSCHECK_URL="github.com/divan/depscheck"
echo ""
echo "Installing depscheck"
$GOROOT/bin/go get -u "$DEPSCHECK_URL"


###
# gosimple
###
readonly GOSIMPLE_URL="honnef.co/go/simple/cmd/gosimple"
echo ""
echo "Installing gosimple"
$GOROOT/bin/go get -u "$GOSIMPLE_URL"


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
# .vim pathogen
###
echo "Setting up .vim pathogen"
if [ -f "$HOME/.vim/autoload/pathogen.vim" ]; then
  echo "Pathogen appears to already be installed"
else
  mkdir -p $HOME/.vim/autoload $HOME/.vim/bundle && \
  $CURL_CMD -LSso $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
  git clone git://github.com/tpope/vim-sensible.git $HOME/.vim/bundle/vim-sensible
fi

if [ -f "$HOME/.vimrc" ]; then
  echo ".vimrc already exists"
else
  echo "execute pathogen#infect()" > $HOME/.vimrc
  echo "syntax on" >> $HOME/.vimrc
  echo "filetype plugin indent on" >> $HOME/.vimrc
fi

if [ -d "$HOME/.vim/bundle/vim-go" ]; then
  echo "vim-go appears to already be installed"
else
  git clone https://github.com/fatih/vim-go.git $HOME/.vim/bundle/vim-go
fi


###
# Finished!
###
echo ""
echo 'now you can source $HOME/.golang_profile'
