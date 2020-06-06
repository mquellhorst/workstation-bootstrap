#!/usr/bin/env bash

################################################################################
# bootstrap
#
# This script is intended to set up a new Mac computer with my dotfiles and
# other development preferences.
################################################################################


# Thank you, thoughtbot!
bootstrap_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\\n[BOOTSTRAP] $fmt\\n" "$@"
}

################################################################################
# VARIABLE DECLARATIONS
################################################################################

osname=$(uname)

export COMMANDLINE_TOOLS="/Library/Developer/CommandLineTools"
export DOTFILES_REPO_URL="https://github.com/mquellhorst/dotfiles.git"
export DOTFILES_DIR=$HOME/Workspace/dotfiles
export DOTFILES_BACKUP_DIR=$HOME/Workspace/dotfiles_backup
export BOOTSTRAP_REPO_URL="https://github.com/mquellhorst/workstation-bootstrap.git"
export BOOTSTRAP_DIR=$HOME/Workspace/workstation-bootstrap

export DEFAULT_DOTFILES_BRANCH="master"
export DEFAULT_BOOTSTRAP_BRANCH="master"

################################################################################
# Make sure we're on a Mac before continuing
################################################################################

if [ "$osname" == "Linux" ]; then
  bootstrap_echo "Oops, looks like you're on a Linux machine. Please have a look at
  my Linux Bootstrap script: https://github.com/mquellhorst/linux-bootstrap"
  exit 1
elif [ "$osname" != "Darwin" ]; then
  bootstrap_echo "Oops, it looks like you're using a non-UNIX system. This script
only supports Mac. Exiting..."
  exit 1
fi

################################################################################
# Check for presence of command line tools if macOS
#
# TODO: automate this
################################################################################

if [ ! -d "$COMMANDLINE_TOOLS" ]; then
  bootstrap_echo "Apple's command line developer tools must be installed before
running this script. To install them, just run 'xcode-select --install' from
the terminal and then follow the prompts. Once the command line tools have been
installed, you can try running this script again."
  exit 1
fi

################################################################################
# Welcome and setup
################################################################################

echo
echo "*************************************************************************"
echo "*******                                                           *******"
echo "*******                 Let's Bootstrap this Mac!                 *******"
echo "*******                                                           *******"
echo "*************************************************************************"
echo

sudo --prompt="[⚠️ ] Password required to run some commands with 'sudo': " -v
# Aquire sudo privlidges now so we can show a custom prompt
# -v updates the user's cached credentials, does not run a command

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

bootstrap_echo "Cloning bootstrap repo..."
git clone $BOOTSTRAP_REPO_URL -b $BOOTSTRAP_BRANCH $BOOTSTRAP_DIR

################################################################################
# 1. Setup dotfiles
################################################################################

bootstrap_echo "Step 1: Installing dotfiles..."

if [[ -d $DOTFILES_DIR ]]; then
  bootstrap_echo "Backing up old dotfiles to $DOTFILES_BACKUP_DIR..."
  rm -rf "$DOTFILES_BACKUP_DIR"
  cp -R "$DOTFILES_DIR" "$DOTFILES_BACKUP_DIR"
  rm -rf "$DOTFILES_DIR"
fi

bootstrap_echo "Cloning dotfiles repo to ${DOTFILES_DIR}..."

git clone "$DOTFILES_REPO_URL" -b "$DOTFILES_BRANCH" "$DOTFILES_DIR"

# Check if zshrc exists, if so back it up
if [ -f "$HOME/.zshrc" ]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc_old"
fi  

# shellcheck source=/dev/null
make $DOTFILES_DIR

bootstrap_echo "Done!"

################################################################################
# 2. Install Oh-My-Zsh (http://ohmyz.sh/)
################################################################################

bootstrap_echo "Step 3: Installing Oh-My-Zsh..."

if [ -d "$HOME"/.oh-my-zsh ]; then
  rm -rf "$HOME"/.oh-my-zsh
fi

git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

bootstrap_echo "Done!"

################################################################################
# 3. Install Homebrew and binaries
################################################################################

bootstrap_echo "Step 3: Installing Homebrew and binaries..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew update
brew bundle

bootstrap_echo "Done!"

################################################################################
# 4. Configure MacOs
################################################################################

bootstrap_echo "Step 4: Configuring OS & applications..."

source "$BOOTSTRAP_DIR"/macos.sh

bootstrap_echo "Done!"

echo
echo "**********************************************************************"
echo "**********************************************************************"
echo "****                                                              ****"
echo "****    Your Mac is ready to go! Please restart your computer.    ****"
echo "****                                                              ****"
echo "**********************************************************************"
echo "**********************************************************************"
echo
