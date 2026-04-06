#!/usr/bin/env bash

if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi

tty_mkbold() {
  tty_escape "1;$1"
}

scr_location="${HOME}/Pictures/Screenshots"

AWK="/usr/bin/awk"
MACPORTS_RELEASE_API="https://api.github.com/repos/macports/macports-base/releases/latest"

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
EULAFILE='/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf'

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
sudo /usr/sbin/systemsetup -settimezone "Asia/Tokyo"

if should_install_command_line_tools && version_ge "${macos_version}" "10.13"; then
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

  if [[ -n "${clt_label}" ]]; then
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

say "setup Dock size"
defaults write "com.apple.Dock" tilesize -int 30
defaults write "com.apple.Dock" largesize -float 55

say "Setup Dock icons"
defaults delete com.apple.Dock persistent-apps
defaults delete com.apple.Dock recent-apps

dock_item() {
  printf '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>%s</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>', "$1"
}

defaults write com.apple.Dock persistent-apps -array \
  "$(dock_item /System/Cryptexes/App/System/Applications/Safari.app)" \
  "$(dock_item /System/Applications/Apps.app)" \
  "$(dock_item /System/Applications/Utilities/Screenshot.app)" \
  "$(dock_item /System/Applications/Calendar.app)" \
  "$(dock_item /System/Applications/Clock.app)" \
  "$(dock_item '/System/Applications/App Store.app')" \
  "$(dock_item '/System/Applications/System Settings.app')" \
  "$(dock_item /System/Applications/Utilities/Terminal.app)"

ohai "Installing MacPorts..."
say "Getting OS Codename..."
OS_CODENAME=$(${AWK} '/SOFTWARE LICENSE AGREEMENT FOR /{gsub(/\\/,"");print$(NF-1)" "$NF}' "${EULAFILE}" | cut -d " " -f 2)
say "${OS_CODENAME}"

if [[ ! -d "/opt/local" ]]; then
  say "Getting MacPorts Installer..."
  (
    cd /tmp
    MACPORTS_DOWNLOAD_URL=$(curl -L ${MACPORTS_RELEASE_API} |
      jq -r --arg OSCODENAME $OS_CODENAME '.assets[] | select(.name | contains($OSCODENAME)) | select(.name | endswith(".pkg")) | .browser_download_url')
    curl -Lo MacPorts.pkg $MACPORTS_DOWNLOAD_URL
  )

  say "Installing MacPorts..."
  (
    cd /tmp
    sudo /usr/sbin/installer -pkg ./MacPorts.pkg -target /
  )

  say "Setting MacPorts PATH to set PATH Envrionment"
  echo "/opt/local/bin" | sudo tee -a /etc/paths.d/20-macports
  echo "/opt/local/sbin" | sudo tee -a /etc/paths.d/20-macports
fi

say "Screenshot location setup"
say "setup to ${scr_location}"

if [ ! -d ${scr_location} ]; then
  mkdir -p ${scr_location}
  defaults write com.apple.screencapture location ${scr_location}
else
  :
fi

say "Disable Text edit RichText mode"
defaults write com.apple.TextEdit -int 0

say "Replace Standard Function Keys"
defaults write -g com.apple.keyboard.fnState 1

say "Completed"

say "Please restart OS or Finder Process"
say "Cmdline: killall Finder && killall SystemUIServer && killall Dock"
