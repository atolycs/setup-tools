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

chomp() {
  printf "%s" "${1/"$'\n'"/}"
}

version_gt() {
  [[ "${1%.*}" -gt "${2%.*}" ]] || [[ "${1%.*}" -eq "${2%.*}" && "${1#*.}" -gt "${2#*.}" ]]
}

version_ge() {
  [[ "${1%.*}" -gt "${2%.*}" ]] || [[ "${1%.*}" -eq "${2%.*}" && "${1#*.}" -ge "${2#*.}" ]]
}

major_minor() {
  echo "${1%%.*}.$(
    x="${1#*.}"
    echo "${x%%.*}"
  )"
}

macos_version="$(major_minor "$(/usr/bin/sw_vers -productVersion)")"

should_install_command_line_tools() {
  if version_gt "${macos_version}" "10.13"; then
    ! [[ -e "/Library/Developer/CommandLineTools/usr/bin/git" ]]
  else
    ! [[ -e "/Library/Developer/CommandLineTools/usr/bin/git" ]] ||
      ! [[ -e "/usr/include/iconv.h" ]]
  fi
}

echo "Welcome macOS Setup tools"
echo "   create by Atolycs 2025"

ohai "Checking os detection... => uname"
OS="$(uname)"
if [[ "${OS}" != "Darwin" ]]; then
  abort "This script is only supported on macOS"
fi

say "Setup timezone to Asia/Tokyo"
sudo systemsetup -settimezone Asia/Tokyo

if should_install_command_line_tools && verison_ge "${macos_version}" "10.13"; then
  ohai "Searching online for the Command Line Tools"
  clt_placeholder="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  sudo touch "${clt_placeholder}"

  clt_label_command="/usr/sbin/softwareupdate -l |
                      grep -B 1 -E 'Command Line Tools' |
                      awk -F'*' '/^ *\\*/ {print \$2}' |
                      sed -e 's/^ *Label: //' -e 's/^ *//' |
                      sort -V |
                      tail -n1"

  clt_label="$(chomp "$(/bin/bash -c "${clt_label_command}")")"

  if [[ -n "${clt_label}"]];then
    ohai "Installing ${clt_label}"
    sudo /usr/sbin/softwareupdate -i "${clt_label}"
    sudo /usr/bin/xcode-select --switch "/Library/Developer/CommandLineTools"
  fi
  sudo rm -f "${clt_placeholder}"
fi

say "Setup Show extension"
defaults write NSGlobalDomain AppleShowAllExtensions true
defaults write com.apple.finder AppleShowAllFiles true

say "Setup show path and status bar"
defaults write com.apple.finder ShowPathbar true
defaults write com.apple.finder ShowStatusBar true
defaults write com.apple.finder ShowSideBar -bool true

say "Setup Finder configuration"
defaults write com.apple.finder ShowHardDrivesOnDesktop 1
defaults write com.apple.finder "_FXSortFoldersFirst" 1
defaults write com.apple.finder ShowRecentTags 0
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

say "Setup Don't Create .DS_Store file on Network folder"
defaults write com.apple.desktopservices DSDontWriteNetworkStores true

say "Setup Don't show recent app and file"
defaults write com.apple.dock show-recents -bool false

say "Setup Menu bar clock show Seconds"
defaults write com.apple.menuextra.clock ShowSeconds 1

say "Setup Click wallpaper to revelal desktop disable"
defaults write "com.apple.WindowManager" EnableStandardClickToShowDesktop -bool false

say "Completed"

say "Please restart OS or Finder Process"
say "Cmdline: killall Finder && killall SystemUIServer && killall Dock"
