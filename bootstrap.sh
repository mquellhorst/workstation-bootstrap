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

export DEFAULT_REPO_DIR="$HOME"/Workspace
export COMMANDLINE_TOOLS="/Library/Developer/CommandLineTools"
export DOTFILES_REPO_URL="https://github.com/mquellhorst/dotfiles.git"
export BOOTSTRAP_REPO_URL="https://github.com/mquellhorst/workstation-bootstrap.git"

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

bootstrap_echo "What directory do you want to put the repo's? (%s)" "$DEFAULT_REPO_DIR"
read -r -p "> " REPO_DIR
if [ -n "$REPO_DIR" ]; then
  export REPO_DIR
else
  export REPO_DIR="$DEFAULT_REPO_DIR"
fi

if [ ! -d "$REPO_DIR" ]; then
  mkdir -p $REPO_DIR
  chmod 700 $REPO_DIR
fi

if [[ -d "$REPO_DIR"/workstation-bootstrap ]]; then
  bootstrap_echo "Backing up old workstation-bootstrap to ${REPO_DIR}/workstation-bootstrap_old..."
  rm -rf "$REPO_DIR"/workstation-bootstrap_old 
  mv "$REPO_DIR"/workstation-bootstrap "$REPO_DIR"/workstation-bootstrap_old
fi

bootstrap_echo "Cloning bootstrap repo..."
git clone "$BOOTSTRAP_REPO_URL" -b "$DEFAULT_BOOTSTRAP_BRANCH" "$REPO_DIR"/workstation-bootstrap


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
brew bundle --file="$REPO_DIR"/workstation-bootstrap/Brewfile

bootstrap_echo "Done!"

################################################################################
# 4. Setup dotfiles
################################################################################

bootstrap_echo "Step 1: Installing dotfiles..."

if [[ -d "$REPO_DIR"/dotfiles ]]; then
  bootstrap_echo "Backing up old dotfiles to ${REPO_DIR}/dotfiles_old..."
  rm -rf "$REPO_DIR"/dotfiles_old 
  mv "$REPO_DIR"/dotfiles "$REPO_DIR"/dotfiles_old
fi

bootstrap_echo "Cloning dotfiles repo to ${REPO_DIR}/dotfiles..."

git clone "$DOTFILES_REPO_URL" -b "$DEFAULT_DOTFILES_BRANCH" "$REPO_DIR"/dotfiles

# Check if zshrc exists, if so back it up
if [ -f "$HOME"/.zshrc ]; then
  mv "$HOME"/.zshrc "$HOME"/.zshrc_old
fi 

# Create this dir so the .zcompdump files don't clutter  home (see .zshrc)
mkdir -p "$HOME"/.cache/zsh

# shellcheck source=/dev/null
make -C "$REPO_DIR"/dotfiles

bootstrap_echo "Done!"

################################################################################
# 4. Configure MacOs
################################################################################

bootstrap_echo "Step 4: Configuring OS & applications..."

source "$REPO_DIR"/workstation-bootstrap/macos.sh

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
