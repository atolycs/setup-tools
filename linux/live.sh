#!/usr/bin/env bash
set -euo pipefail

source <(curl -fsSL https://raw.githubusercontent.com/atolycs/bash-util-closet/main/logs.func)

msg_info "ArchLinux Live Session SSH setup..."

msg_info "Step1: Checking commands..."

missing=0
for cmd in curl jq; do
  if ! hash "$cmd" 2>/dev/null; then
    echo "Required: $cmd"
    missing=1
  fi
done

if [ "$missing" -eq 1 ]; then
  msg_error "Required commands are missing. Aborting."
  exit 1
fi

msg_info "Step2: Setup SSH configuration..."

cat <<EOF >/etc/ssh/sshd_config.d/99-livesession.conf
PubkeyAuthentication yes
EOF

msg_info "Step3: Preparing .ssh directory..."

mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"
touch "${HOME}/.ssh/authorized_keys"
chmod 600 "${HOME}/.ssh/authorized_keys"

msg_info "Step4: Downloading SSH Public key from GitHub..."
# curl -fsSL https://api.github.com/users/atolycs/keys | jq -r '.[].key' | tee -a ${HOME}/.ssh/authorized_keys
curl -fsSL https://github.com/atolycs.keys | tee -a "${HOME}/.ssh/authorized_keys"

msg_info "Step5: Ensuring sshd is running..."

if command -v systemctl >/dev/null 2>&1; then
  systemctl enable --now sshd 2>/dev/null || systemctl restart sshd || true
fi

msg_ok "Setup complited."
msg_ok "IPv4 Address: $(ip route get 1.1.1.1 | awk '{print $7; exit}')"
