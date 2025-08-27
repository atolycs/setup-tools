#!/usr/bin/env bash

if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi

tty_mkbold() {
  tty_escape "1;$1"
}

tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

say() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$@"
}

warn() {
  printf "${tty_red}==>${tty_reset} %s\n" "$@"
}

ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

shell_join() {
  local arg
  printf "%s" "$1"

  shift

  for arg in "$@"; do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

echo "Welcome macOS Setup tools"
echo "   create by Atolycs 2025"

ohai "Checking os detection... => uname"
OS="$(uname)"
if [[ "${OS}" != "Darwin" ]]; then
  abort "This script is only supported on macOS"
fi

say "Setup Show extension"

defaults write NSGlobalDomain AppleShowAllExtensions -bool true

say "Setup show path and status bar"
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

say "Setup Don't Create .DS_Store file on Network folder"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

say "Completed"
